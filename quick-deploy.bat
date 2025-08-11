@echo off
REM Quick deployment helper for Windows

echo =====================================
echo   Nook Typewriter Quick Deploy
echo =====================================
echo.

echo Checking drives...
if exist D:\ (
    echo [OK] D: drive found - QuillOS
) else (
    echo [ERROR] D: drive not found!
    pause
    exit /b 1
)

if exist E:\ (
    echo [OK] E: drive found - Kernel
) else (
    echo [ERROR] E: drive not found!
    pause
    exit /b 1
)

echo.
echo Starting WSL deployment...
echo.

wsl bash -c "cd /mnt/c/Users/%USERNAME%/projects/personal/nook && ./deploy-to-nook.sh /mnt/d /mnt/e nook-deploy.tar.gz"

echo.
echo =====================================
echo Deployment complete!
echo.
echo Don't forget to:
echo 1. Add kernel (uImage) to E: drive
echo 2. Safely eject SD card
echo 3. Insert into Nook
echo 4. Connect USB keyboard
echo 5. Power on
echo =====================================
pause