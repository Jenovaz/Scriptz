@echo off
rem Starts Jenovaz "Top Deck" OS Optimizer. TopDeck.ps1 asks for admin rights itself.
powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -File "%~dp0TopDeck.ps1"
