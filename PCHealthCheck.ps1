<#
.SYNOPSIS
    Automated PC health check: stress tests + benchmarks + HWiNFO logging + AV scan + summary report.

.DESCRIPTION
    Orchestrates Prime95, FurMark, Cinebench, and AIDA64 in sequence, with HWiNFO64 CSV sensor
    logging running throughout, then runs a full Windows Defender scan and parses the HWiNFO log
    into a summary report with a basic automated health score.

    RUN AS ADMINISTRATOR. Run this ON THE TARGET PC directly (PowerShell, or via Task Scheduler) —
    it cannot be run from a remote/cloud session.

.NOTES
    IMPORTANT — verify before first run:
      - Update every path in the CONFIG block below to match your actual install locations.
      - CLI flags for Prime95 / FurMark / Cinebench / AIDA64 differ by version and edition.
        Run each tool with `/?` or check its docs and adjust the flags marked "VERIFY" below.
      - HWiNFO64 must have "Sensors-only" CSV logging configured once via its Settings dialog
        (Logging tab -> enable "Log to CSV", set an interval, e.g. 2 sec) before this script can
        drive it headlessly. This script launches it with -SENSORS to skip the summary screen.
      - Prime95 needs a one-time interactive setup of local.txt (Options -> Torture Test, choose
        "Blend" for a mixed CPU+RAM stress, save) OR just let it prompt on first run and it will
        remember the config for future -t launches.
      - This script does not attempt to interpret raw sensor values as "throttling" beyond simple
        threshold checks (temp/clock). Treat the score as a rough triage aid, not a certification.
#>

[CmdletBinding()]
param(
    [switch]$SkipStressTests,   # for a quick re-run of just the AV scan + report
    [switch]$SkipAntivirus
)

$ErrorActionPreference = 'Stop'

# ============================== CONFIG — EDIT THESE ==============================

$Paths = @{
    Prime95   = 'C:\Tools\Prime95\prime95.exe'
    FurMark   = 'C:\Program Files (x86)\Geeks3D\Benchmarks\FurMark\FurMark.exe'
    Cinebench = 'C:\Program Files\Maxon\Cinebench 2024\Cinebench.exe'
    AIDA64    = 'C:\Program Files\FinalWire\AIDA64 Extreme\aida64.exe'
    HWiNFO64  = 'C:\Program Files\HWiNFO64\HWiNFO64.exe'
}

$Durations = @{
    Prime95Minutes   = 15
    FurMarkMinutes   = 10
    CinebenchMinutes = 10   # Cinebench's own run length is fixed by its benchmark type;
                             # this is a hard timeout/kill-safety only
    AIDA64Minutes    = 30
}

$WorkDir   = 'C:\PCHealthCheck'
$RunStamp  = Get-Date -Format 'yyyy-MM-dd_HHmmss'
$RunDir    = Join-Path $WorkDir $RunStamp
$HwLogCsv  = Join-Path $RunDir 'hwinfo_log.csv'
$ReportMd  = Join-Path $RunDir 'health_report.md'

# Rough triage thresholds — adjust for your hardware (e.g. laptop vs desktop, HEDT, etc.)
$Thresholds = @{
    CpuTempWarnC   = 85
    CpuTempCritC   = 95
    GpuTempWarnC   = 83
    GpuTempCritC   = 90
}

# ===================================================================================

function Test-ToolPath {
    param([string]$Name, [string]$Path)
    if (-not (Test-Path $Path)) {
        Write-Warning "$Name not found at: $Path  (edit `$Paths.$Name in this script)"
        return $false
    }
    return $true
}

function New-RunDirectory {
    New-Item -ItemType Directory -Force -Path $RunDir | Out-Null
    Write-Host "Run directory: $RunDir"
}

function Start-HwInfoLogging {
    if (-not (Test-ToolPath -Name 'HWiNFO64' -Path $Paths.HWiNFO64)) {
        Write-Warning 'Skipping HWiNFO launch — sensor logging will not be captured.'
        return $null
    }
    # -SENSORS: launch straight into the sensor monitor (skip the summary/system report screen).
    # CSV logging path/interval must already be configured in HWiNFO's Settings -> Logging tab,
    # OR point HWiNFO's "Log file" setting at $HwLogCsv beforehand so this run's log lands here.
    Write-Host 'Starting HWiNFO64 sensor logging...'
    $proc = Start-Process -FilePath $Paths.HWiNFO64 -ArgumentList '-SENSORS' -PassThru
    Start-Sleep -Seconds 5
    return $proc
}

function Stop-ProcessTree {
    param([string]$Name)
    Get-Process -Name $Name -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
}

function Run-Prime95 {
    if (-not (Test-ToolPath -Name 'Prime95' -Path $Paths.Prime95)) { return }
    Write-Host "`n=== Prime95 torture test: $($Durations.Prime95Minutes) min ==="
    # VERIFY: -t starts torture test using the last-saved local.txt config (Blend recommended).
    $proc = Start-Process -FilePath $Paths.Prime95 -ArgumentList '-t' -PassThru -WorkingDirectory (Split-Path $Paths.Prime95)
    Start-Sleep -Seconds ($Durations.Prime95Minutes * 60)
    Write-Host 'Stopping Prime95...'
    Stop-ProcessTree -Name 'prime95'
    Stop-ProcessTree -Name 'mprime'
    Start-Sleep -Seconds 3
}

function Run-FurMark {
    if (-not (Test-ToolPath -Name 'FurMark' -Path $Paths.FurMark)) { return }
    Write-Host "`n=== FurMark GPU stress test: $($Durations.FurMarkMinutes) min ==="
    $maxTimeMs = $Durations.FurMarkMinutes * 60 * 1000
    $furLog = Join-Path $RunDir 'furmark_log.xml'
    # VERIFY against `FurMark.exe /?` for your installed version — flags below match recent
    # FurMark releases (Geeks3D): /nogui headless run, /max_time in ms, /log writes a result log.
    $args = @(
        '/nogui'
        '/width=1920', '/height=1080'
        '/msaa=4'
        "/max_time=$maxTimeMs"
        '/log_temp'
        "/log=$furLog"
        '/disable_catalyst_warning'
    )
    $proc = Start-Process -FilePath $Paths.FurMark -ArgumentList $args -PassThru
    $proc.WaitForExit(($Durations.FurMarkMinutes * 60 + 60) * 1000) | Out-Null
    Stop-ProcessTree -Name 'FurMark'
    Start-Sleep -Seconds 3
}

function Run-Cinebench {
    if (-not (Test-ToolPath -Name 'Cinebench' -Path $Paths.Cinebench)) { return }
    Write-Host "`n=== Cinebench: multi-core + single-core ==="
    # VERIFY: Cinebench 2024/R23 automation is driven via an ini file next to the exe rather than
    # pure CLI flags. Confirm the exact key names for your version (check Maxon's Cinebench docs
    # or the app's Help -> Command Line Options). This writes a minimal automation ini as a
    # best-effort default.
    $iniPath = Join-Path (Split-Path $Paths.Cinebench) 'Cinebench.ini'
    @"
[Benchmark]
g_CinebenchCpuXTest=true
g_CinebenchCpuTest=true
g_CinebenchAutoStart=true
g_CinebenchAutoExit=true
"@ | Set-Content -Path $iniPath -Encoding ASCII

    $proc = Start-Process -FilePath $Paths.Cinebench -PassThru
    $timedOut = -not $proc.WaitForExit(($Durations.CinebenchMinutes * 60 * 1000))
    if ($timedOut) {
        Write-Warning 'Cinebench exceeded timeout — killing.'
        Stop-ProcessTree -Name 'Cinebench'
    }
    Start-Sleep -Seconds 3
}

function Run-AIDA64 {
    if (-not (Test-ToolPath -Name 'AIDA64' -Path $Paths.AIDA64)) { return }
    Write-Host "`n=== AIDA64: memory benchmark + stability test: $($Durations.AIDA64Minutes) min total ==="
    $reportPath = Join-Path $RunDir 'aida64_memory_report.htm'

    # Memory benchmark via AIDA64's report-generation CLI (well-documented, reliable):
    # /R <file> /CUSTOM <profile.rpf> /SILENT runs a custom report defined by an .rpf profile.
    # You need to create MemBenchmark.rpf once via AIDA64's GUI: Report Wizard -> select only
    # "Cache & Memory Benchmark" page -> save as .rpf next to this script (or update path below).
    $rpfProfile = Join-Path $WorkDir 'MemBenchmark.rpf'
    if (Test-Path $rpfProfile) {
        Start-Process -FilePath $Paths.AIDA64 -ArgumentList @('/R', "`"$reportPath`"", '/CUSTOM', "`"$rpfProfile`"", '/SILENT') -Wait
    } else {
        Write-Warning "AIDA64 memory benchmark profile not found at $rpfProfile — skipping memory benchmark, run it manually via AIDA64 GUI (Benchmark -> Cache & Memory Benchmark)."
    }

    # System Stability Test (AIDA64 Extreme/Engineer): CLI start/stop for SST is NOT reliably
    # documented across versions — VERIFY. As a fallback, this pauses for you to start it manually
    # via AIDA64 GUI (Tools -> System Stability Test -> check CPU/FPU/Cache/Memory -> Start).
    $remainingMinutes = $Durations.AIDA64Minutes
    Write-Host "Launch AIDA64's System Stability Test now (Tools -> System Stability Test), enable CPU+FPU+Cache+Memory, click Start."
    Write-Host "Waiting $remainingMinutes minutes for it to run, then continuing automatically..."
    Start-Sleep -Seconds ($remainingMinutes * 60)
    Write-Host 'AIDA64 stress window complete — stop the test manually if it is still running.'
}

function Run-AntivirusScan {
    if ($SkipAntivirus) { Write-Host "`n=== Skipping antivirus scan (-SkipAntivirus) ==="; return }
    Write-Host "`n=== Full Windows Defender scan ==="
    try {
        Start-MpScan -ScanType FullScan
        Write-Host 'Full scan complete.'
    } catch {
        Write-Warning "Start-MpScan failed (Defender may be disabled/replaced by 3rd-party AV): $_"
    }
}

function Stop-HwInfoLogging {
    param($HwProc)
    Write-Host "`nStopping HWiNFO64..."
    Stop-ProcessTree -Name 'HWiNFO64'
}

function Parse-HwInfoLog {
    param([string]$CsvPath)

    if (-not (Test-Path $CsvPath)) {
        Write-Warning "HWiNFO CSV log not found at $CsvPath — set the log path in HWiNFO Settings -> Logging to match, or copy the log there manually."
        return $null
    }

    $data = Import-Csv -Path $CsvPath
    if (-not $data -or $data.Count -eq 0) {
        Write-Warning 'HWiNFO CSV log is empty.'
        return $null
    }

    # HWiNFO CSV columns are whatever sensors you had enabled — match by name substring since
    # exact column names vary by CPU/GPU vendor and HWiNFO version.
    $cols = $data[0].PSObject.Properties.Name

    function Get-MaxOfMatchingColumns {
        param([string[]]$Patterns)
        $matches = $cols | Where-Object { $c = $_; $Patterns | Where-Object { $c -match $_ } }
        $max = [double]::MinValue
        foreach ($col in $matches) {
            foreach ($row in $data) {
                $val = $row.$col -as [double]
                if ($val -ne $null -and $val -gt $max) { $max = $val }
            }
        }
        if ($max -eq [double]::MinValue) { return $null }
        return $max
    }

    [PSCustomObject]@{
        MaxCpuTempC     = Get-MaxOfMatchingColumns -Patterns @('CPU.*Temp', 'CPU Package')
        MaxGpuTempC     = Get-MaxOfMatchingColumns -Patterns @('GPU.*Temp')
        MaxCpuClockMHz  = Get-MaxOfMatchingColumns -Patterns @('CPU.*Clock', 'Core.*Clock')
        MaxGpuClockMHz  = Get-MaxOfMatchingColumns -Patterns @('GPU.*Clock')
        ThrottleColumns = ($cols | Where-Object { $_ -match 'Throttl' })
        SampleCount     = $data.Count
        RawColumns      = $cols
    }
}

function Write-HealthReport {
    param($HwStats)

    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("# PC Health Check Report — $RunStamp")
    $lines.Add('')
    $lines.Add('## Tests run')
    $lines.Add("- Prime95 torture test: $($Durations.Prime95Minutes) min")
    $lines.Add("- FurMark GPU stress: $($Durations.FurMarkMinutes) min")
    $lines.Add("- Cinebench: multi-core + single-core")
    $lines.Add("- AIDA64 memory benchmark + stability test: $($Durations.AIDA64Minutes) min")
    $lines.Add("- Full antivirus scan: $(if ($SkipAntivirus) {'skipped'} else {'run'})")
    $lines.Add('')
    $lines.Add('## HWiNFO sensor summary')

    $concerns = New-Object System.Collections.Generic.List[string]
    $strengths = New-Object System.Collections.Generic.List[string]

    if ($HwStats) {
        $lines.Add("- Samples logged: $($HwStats.SampleCount)")
        if ($HwStats.MaxCpuTempC)  { $lines.Add("- Max CPU temp: $($HwStats.MaxCpuTempC) C") }
        if ($HwStats.MaxGpuTempC)  { $lines.Add("- Max GPU temp: $($HwStats.MaxGpuTempC) C") }
        if ($HwStats.MaxCpuClockMHz) { $lines.Add("- Max CPU clock: $($HwStats.MaxCpuClockMHz) MHz") }
        if ($HwStats.MaxGpuClockMHz) { $lines.Add("- Max GPU clock: $($HwStats.MaxGpuClockMHz) MHz") }

        if ($HwStats.MaxCpuTempC -ge $Thresholds.CpuTempCritC) {
            $concerns.Add("CPU hit $($HwStats.MaxCpuTempC) C — at/above critical threshold ($($Thresholds.CpuTempCritC) C). Check cooling.")
        } elseif ($HwStats.MaxCpuTempC -ge $Thresholds.CpuTempWarnC) {
            $concerns.Add("CPU reached $($HwStats.MaxCpuTempC) C under load — elevated, worth monitoring.")
        } elseif ($HwStats.MaxCpuTempC) {
            $strengths.Add("CPU temps stayed under control (max $($HwStats.MaxCpuTempC) C).")
        }

        if ($HwStats.MaxGpuTempC -ge $Thresholds.GpuTempCritC) {
            $concerns.Add("GPU hit $($HwStats.MaxGpuTempC) C — at/above critical threshold ($($Thresholds.GpuTempCritC) C). Check cooling/airflow.")
        } elseif ($HwStats.MaxGpuTempC -ge $Thresholds.GpuTempWarnC) {
            $concerns.Add("GPU reached $($HwStats.MaxGpuTempC) C under load — elevated, worth monitoring.")
        } elseif ($HwStats.MaxGpuTempC) {
            $strengths.Add("GPU temps stayed under control (max $($HwStats.MaxGpuTempC) C).")
        }

        if ($HwStats.ThrottleColumns -and $HwStats.ThrottleColumns.Count -gt 0) {
            $lines.Add("- Throttling-related columns present in log: $($HwStats.ThrottleColumns -join ', ') — inspect these manually for any non-zero/active values during the run.")
            $concerns.Add('Throttling-indicator columns exist in the log — open the CSV and confirm none were active during the stress runs.')
        }
    } else {
        $lines.Add('- No HWiNFO data parsed (see warnings above). Fix logging path and re-run before trusting the score.')
        $concerns.Add('HWiNFO log could not be parsed — health score below is not reliable without it.')
    }

    $lines.Add('')
    $lines.Add('## Manual follow-ups')
    $lines.Add('- Check Prime95 window/log for any "FATAL ERROR" (indicates instability under stress).')
    $lines.Add('- Check FurMark log for artifacts/crashes and confirm no driver reset (TDR) occurred.')
    $lines.Add('- Confirm Cinebench multi-core score is in the expected range for your CPU model (compare to published benchmark databases).')
    $lines.Add('- Review Windows Defender scan results for any detections.')
    $lines.Add('- Subjectively note responsiveness/app load times during normal use after testing.')

    $lines.Add('')
    $lines.Add('## Concerns')
    if ($concerns.Count -eq 0) {
        $lines.Add('- None detected automatically.')
    } else {
        foreach ($c in $concerns) { $lines.Add("- $c") }
    }

    $lines.Add('')
    $lines.Add('## Strengths')
    if ($strengths.Count -eq 0) {
        $lines.Add('- (see manual follow-ups — not enough automated signal to list strengths confidently)')
    } else {
        foreach ($s in $strengths) { $lines.Add("- $s") }
    }

    $lines.Add('')
    $lines.Add('## Automated health score')
    $score = 10
    if ($HwStats) {
        if ($HwStats.MaxCpuTempC -ge $Thresholds.CpuTempCritC) { $score -= 3 }
        elseif ($HwStats.MaxCpuTempC -ge $Thresholds.CpuTempWarnC) { $score -= 1 }
        if ($HwStats.MaxGpuTempC -ge $Thresholds.GpuTempCritC) { $score -= 3 }
        elseif ($HwStats.MaxGpuTempC -ge $Thresholds.GpuTempWarnC) { $score -= 1 }
    } else {
        $score -= 4
    }
    if ($score -lt 1) { $score = 1 }
    $lines.Add("**Score: $score / 10** (automated triage only — this does NOT replace reading the Prime95/FurMark/Cinebench logs and Defender results yourself; combine with the manual follow-ups above for a real verdict.)")

    $lines -join "`n" | Set-Content -Path $ReportMd -Encoding UTF8
    Write-Host "`nReport written to: $ReportMd"
    Write-Host "`n--- SUMMARY ---"
    $lines | ForEach-Object { Write-Host $_ }
}

# ==================================== MAIN ====================================

New-RunDirectory

$hwProc = $null
if (-not $SkipStressTests) {
    $hwProc = Start-HwInfoLogging
    Run-Prime95
    Run-FurMark
    Run-Cinebench
    Run-AIDA64
    Stop-HwInfoLogging -HwProc $hwProc
}

Run-AntivirusScan

$hwStats = Parse-HwInfoLog -CsvPath $HwLogCsv
Write-HealthReport -HwStats $hwStats

Write-Host "`nDone. Review $ReportMd and the raw logs in $RunDir before trusting the score."
