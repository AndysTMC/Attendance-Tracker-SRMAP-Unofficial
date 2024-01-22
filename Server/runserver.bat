@echo off
setlocal enabledelayedexpansion

python --version > nul 2>&1
if %errorlevel% neq 0 (
    echo Python is not installed. Please install Python to proceed.
    exit /b 1
) else (
    echo Python is already installed.
    :: Check if Python is in the PATH
    python -c "import sys; print('Python is in PATH')" > nul 2>&1
    if %errorlevel% neq 0 (
        echo Python is not in the PATH. Please add Python to your system PATH manually.
        exit /b 1
    ) else (
        echo Python is in the PATH.
    )
)

echo Please install all the requirements by running 'install_requirements.bat' script before running this script (Ignore if already done)

set "outputFile=ipv4_addrs.txt"

del "%outputFile%" 2>nul

set "ipAddresses="

for /f "tokens=2 delims=:" %%a in ('ipconfig ^| find "IPv4 Address"') do (
    set "ipAddress=%%a"
    set "ipAddress=!ipAddress:~1!"
    set "ipAddresses=!ipAddresses!,!ipAddress!"
)

set "ipAddresses=!ipAddresses:~1!"

echo %ipAddresses%>>"%outputFile%"

echo Activating your virtual environment...
call .\venv\Scripts\activate
echo Virtual environment activated.

echo Starting Django server..
python manage.py runserver 0.0.0.0:8000

echo Server started. Press Ctrl+C to quit.
pause >nul

REM Cleanup and deactivate virtual environment
deactivate

if exist "qr_code.png" (
	echo Server Closed. Deleting QR
	del "qr_code.png"
)

endlocal
