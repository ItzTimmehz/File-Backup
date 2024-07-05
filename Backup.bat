:: Made by ItzTimmehz (https://github.com/ItzTimmehz)

@echo off
setlocal enabledelayedexpansion

:: Prompt for the source directory
set /p "source=Enter the source directory to back up: "
if "%source%"=="" (
    echo No source directory specified. Exiting...
    exit /b
)

:: Check if the source directory exists
if not exist "%source%" (
    echo Source directory does not exist. Exiting...
    pause
    exit /b
)

:: Prompt for the backup directory
set /p "backup_base=Enter the destination directory: "
if "%backup_base%"=="" (
    echo No backup directory specified. Exiting...
    pause
    exit /b
)

:: Add timestamp to the backup directory
call :timestamp
set backup=%backup_base%\backup_%current_timestamp%
mkdir "%backup%"
if %errorlevel% neq 0 (
    echo Failed to create backup directory. Exiting...
    pause
    exit /b
)

:: Prompt for the type of backup (full or incremental)
set /p "backup_type=Enter the type of backup (full/incremental): "
if /i "%backup_type%"=="full" (
    set robocopy_options=/MIR
) else if /i "%backup_type%"=="incremental" (
    set robocopy_options=/E /XC /XN /XO
) else (
    echo Invalid backup type specified. Exiting...
    pause
    exit /b
)

:: Perform the backup using robocopy
echo Starting backup from %source% to %backup%...
robocopy "%source%" "%backup%" %robocopy_options% /FFT /Z /XA:H /W:5 /R:3 /NP /NDL /NFL /LOG:backup_log.txt

:: Check the exit code of robocopy
if %errorlevel% lss 8 (
    echo Backup completed successfully.
) else (
    echo Errors occurred during backup. Please check the log file: backup_log.txt
)

:: Verify the integrity of the backup
echo Verifying the integrity of the backup...
robocopy "%source%" "%backup%" /E /L /NJH /NJS /FP /BYTES /NP /NS > verify_log.txt

:: Check for differences
findstr /C:" 100% " verify_log.txt > nul
if %errorlevel% neq 0 (
    echo Verification failed. Differences found between source and backup.
    echo Please check the verification log: verify_log.txt
) else (
    echo Verification completed successfully. No differences found.
)

pause
exit /b

:: Made by ItzTimmehz (https://github.com/ItzTimmehz)