@echo off
color 0a
title MultiTool
cls
:top
echo.
echo ===================== MultiTool =====================
echo 1 SystemInfo   2 FullReport   3 DiskUsage   4 LargeFiles
echo 5 NetInfo      6 PingTrace    7 PortCheck   8 Procs
echo 9 KillProc     10 ProdKey     11 FindFiles   12 Backup
echo 13 Note        14 Tools       15 EventLog    16 ToggleWifi
echo 17 Health      18 SelfSave    19 DevConsole  20 ScanPorts
echo 21 Progress    22 Exit
echo.
set /p c=Choose:
if "%c%"=="1" goto sysinfo
if "%c%"=="2" goto fullreport
if "%c%"=="3" goto diskusage
if "%c%"=="4" goto largefiles
if "%c%"=="5" goto netinfo
if "%c%"=="6" goto pingtrace
if "%c%"=="7" goto portcheck
if "%c%"=="8" goto procs
if "%c%"=="9" goto killproc
if "%c%"=="10" goto prodkey
if "%c%"=="11" goto findfiles
if "%c%"=="12" goto backup
if "%c%"=="13" goto note
if "%c%"=="14" goto tools
if "%c%"=="15" goto eventlog
if "%c%"=="16" goto togglewifi
if "%c%"=="17" goto health
if "%c%"=="18" goto selfsave
if "%c%"=="19" goto devconsole
if "%c%"=="20" goto scanports
if "%c%"=="21" goto progress
if "%c%"=="22" goto finish
cls
goto top
:sysinfo
cls
systeminfo | findstr /B /C:"Host Name" /C:"OS Name" /C:"OS Version" /C:"System Type" /C:"Total Physical Memory"
wmic cpu get name
wmic path win32_videocontroller get name
pause
cls
goto top
:fullreport
cls
set out=%~dp0report.html
powershell -NoProfile -Command "Get-ComputerInfo | ConvertTo-Html -Title 'System Report' -PreContent '<h1>System Report</h1>' | Out-File -FilePath '%out%' -Encoding UTF8"
if exist "%out%" start "" "%out%"
echo Saved %out%
pause
cls
goto top
:diskusage
cls
wmic logicaldisk get name,size,freespace
powershell -NoProfile -Command "Get-Volume | Select DriveLetter,@{N='FreeGB';E={[math]::Round($_.SizeRemaining/1GB,2)}},@{N='SizeGB';E={[math]::Round($_.Size/1GB,2)}} | Format-Table -AutoSize"
pause
cls
goto top
:largefiles
cls
powershell -NoProfile -Command "Get-ChildItem -Path . -Recurse -File -ErrorAction SilentlyContinue | Sort-Object Length -Descending | Select-Object -First 20 | Select @{N='MB';E={[math]::Round($_.Length/1MB,2)}},FullName | Format-Table -AutoSize"
pause
cls
goto top
:netinfo
cls
ipconfig /all
echo.
echo DNS cache (first 40 lines):
ipconfig /displaydns | more +0
pause
cls
goto top
:pingtrace
cls
set /p h=Host or IP:
if "%h%"=="" goto top
ping -n 4 %h%
tracert %h%
pause
cls
goto top
:portcheck
cls
set /p ph=Host:
set /p pp=Port:
if "%ph%"=="" goto top
if "%pp%"=="" set pp=80
powershell -NoProfile -Command "Test-NetConnection -ComputerName '%ph%' -Port %pp% | Format-List"
pause
cls
goto top
:procs
cls
tasklist | more
pause
cls
goto top
:killproc
cls
set /p k=Name or PID to kill:
if "%k%"=="" goto top
tasklist | findstr /I "%k%"
set /p y=Kill? (y/N): 
if /I "%y%"=="y" (taskkill /F /IM "%k%" 2>nul || taskkill /F /PID %k% 2>nul & echo Killed) else echo Aborted
pause
cls
goto top
:prodkey
cls
wmic path SoftwareLicensingService get OA3xOriginalProductKey 2>nul
powershell -NoProfile -Command "Try{ $dp=(Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name 'DigitalProductId' -ErrorAction Stop).DigitalProductId }Catch{ Exit };$chars='BCDFGHJKMPQRTVWXY2346789';$key='';for($i=24;$i -ge 0;$i--){$k=0;for($j=14;$j -ge 0;$j--){$k=$k*256 -bxor $dp[$j+52];$dp[$j+52]=[math]::Floor($k/24);$k=$k%24}$key=$chars[$k]+$key};$key= $key.Substring(1,5)+'-'+$key.Substring(6,5)+'-'+$key.Substring(11,5)+'-'+$key.Substring(16,5)+'-'+$key.Substring(21,5);Write-Output $key"
pause
cls
goto top
:findfiles
cls
set /p f=Pattern (eg *.iso):
if "%f%"=="" goto top
dir /s /b "%f%"
pause
cls
goto top
:backup
cls
set /p s=Source folder:
set /p d=Destination folder:
if "%s%"=="" goto top
if "%d%"=="" set d=%s%_backup_%date:~10,4%-%date:~4,2%-%date:~7,2%
robocopy "%s%" "%d%" /MIR /ETA
echo Done
pause
cls
goto top
:note
cls
set /p nf=Note file (default notes.txt):
if "%nf%"=="" set nf=notes.txt
set /p txt=Note (single line):
echo %date% %time% - %txt%>>"%nf%"
echo Saved
pause
cls
goto top
:tools
cls
echo 1 Notepad 2 Calc 3 Explorer 4 PowerShell
set /p t=:
if "%t%"=="1" start notepad
if "%t%"=="2" start calc
if "%t%"=="3" start explorer "%cd%"
if "%t%"=="4" start powershell
pause
cls
goto top
:eventlog
cls
wevtutil qe System /f:text /c:50
pause
cls
goto top
:togglewifi
cls
powershell -NoProfile -Command "Get-NetAdapter | Format-Table -AutoSize"
set /p a=Adapter name to toggle:
if "%a%"=="" goto top
set /p s=on/off:
if /I "%s%"=="on" powershell -NoProfile -Command "Enable-NetAdapter -Name '%a' -Confirm:$false"
if /I "%s%"=="off" powershell -NoProfile -Command "Disable-NetAdapter -Name '%a' -Confirm:$false"
echo Done
pause
cls
goto top
:health
cls
powershell -NoProfile -Command "Get-Volume | Select DriveLetter,@{N='FreeGB';E={[math]::Round($_.SizeRemaining/1GB,2)}},@{N='SizeGB';E={[math]::Round($_.Size/1GB,2)}} | Format-Table -AutoSize"
powershell -NoProfile -Command "Get-Service -Name wuauserv,w32time,bits -ErrorAction SilentlyContinue | Format-Table -AutoSize"
echo Quick health done
pause
cls
goto top
:selfsave
cls
set d=%USERPROFILE%\Documents\MultiTool_%date:~10,4%-%date:~4,2%-%date:~7,2%.bat
copy "%~f0" "%d%"
echo Saved %d%
pause
cls
goto top
:devconsole
cls
start cmd /k "cd /d %cd%"
cls
goto top
:scanports
cls
set /p sh=Host:
set /p sp=StartPort:
set /p ep=EndPort:
if "%sp%"=="" set sp=1
if "%ep%"=="" set ep=1024
for /L %%p in (%sp%,1,%ep%) do (powershell -NoProfile -Command "try{ $c=New-Object System.Net.Sockets.TcpClient(); $a = $c.BeginConnect('%sh%',%%p,$null,$null); if($a.AsyncWaitHandle.WaitOne(100)){ $c.EndConnect($a); Write-Output 'OPEN: %%p' }; $c.Close() } catch{}")
echo Done
pause
cls
goto top
:progress
cls
for /L %%i in (1,1,30) do (
 set /a bar=%%i*3
 <nul set /p ="["
 for /L %%j in (1,1,%%j) do <nul set /p ="#"
 <nul set /p ="] %%i%%`r"
 ping -n 1 -w 100 127.0.0.1 >nul
)
echo.
echo Complete!
pause
cls
goto top
:finish
cls
color 07
exit /b
