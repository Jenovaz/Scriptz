@echo off
rem Starts the Zomboid Mod Enabler. No admin rights needed.
powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -File "%~dp0ZomboidModEnabler.ps1" %*
