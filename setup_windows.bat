@echo off
chcp 65001 >nul
setlocal
cd /d "%~dp0"

echo ==========================================================
echo   Simulador de Frenagem - gerando o executavel do Windows
echo ==========================================================
echo.

where flutter >nul 2>nul
if errorlevel 1 (
  echo [ERRO] O Flutter nao foi encontrado no PATH.
  echo Instale em https://docs.flutter.dev/get-started/install/windows
  pause
  exit /b 1
)

if not exist "windows" (
  echo [1/4] Criando a pasta windows do projeto...
  call flutter create --platforms=windows --project-name simulador_frenagem .
  if errorlevel 1 goto erro
  powershell -NoProfile -Command "$a='windows\runner\main.cpp'; (Get-Content $a) -replace 'L\"simulador_frenagem\"','L\"Simulador de Frenagem\"' -replace 'Size size\(1280, 720\)','Size size(1360, 820)' | Set-Content $a -Encoding UTF8"
) else (
  echo [1/4] Pasta windows ja existe, seguindo.
)

echo [2/4] Baixando dependencias...
call flutter pub get
if errorlevel 1 goto erro

echo [3/4] Compilando em modo release (pode demorar alguns minutos)...
call flutter build windows --release
if errorlevel 1 goto erro

echo [4/4] Compactando para enviar ao professor...
powershell -NoProfile -Command "Compress-Archive -Force -Path 'build\windows\x64\runner\Release\*' -DestinationPath 'SimuladorFrenagem_Windows.zip'"

echo.
echo ==========================================================
echo   PRONTO!
echo   Executavel : build\windows\x64\runner\Release\simulador_frenagem.exe
echo   Para enviar: SimuladorFrenagem_Windows.zip
echo   (o professor extrai o zip e abre o simulador_frenagem.exe)
echo ==========================================================
pause
exit /b 0

:erro
echo.
echo [ERRO] Algo falhou. Rode "flutter doctor" e confira se o
echo Visual Studio tem a carga "Desenvolvimento para desktop com C++".
pause
exit /b 1
