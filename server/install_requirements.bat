@echo off
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

echo Creating Virtual Environment
python -m venv venv

echo Updating pip to latest version
python -m pip install --upgrade pip

echo Activating Virtual Environment...
call .\venv\Scripts\activate

echo Installing project dependencies...
pip install -r requirements.txt

echo Setup complete.
