@echo off
setlocal
cd /d "%~dp0"
node scripts\build.mjs
if errorlevel 1 (
  pause
  exit /b 1
)
node scripts\preview.mjs --open
if errorlevel 1 (
  echo.
  echo Khong mo duoc app. Xem thong bao ben tren.
  pause
)
endlocal
