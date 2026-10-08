@echo off
REM Script unificado para setup - Simulado A1 (Windows)

setlocal enabledelayedexpansion
cd /d "%~dp0"

set FITNESSE_JAR=2-FitNesse\fitnesse.jar
set FITNESSE_PORT=8082
set NODE_PORT=3000
set PYTHON_PORT=5000

REM Detectar JAVA_HOME
if not defined JAVA_HOME (
    for /f "tokens=*" %%i in ('where java 2^>nul') do (
        set "JAVA_PATH=%%i"
        goto :found_java
    )
    :found_java
    if defined JAVA_PATH (
        for %%A in ("!JAVA_PATH!") do set "JAVA_BIN=%%~dpA"
        for %%A in ("!JAVA_BIN!..") do set "JAVA_HOME=%%~fA"
        echo [+] Java encontrado em: !JAVA_HOME!
    ) else (
        echo [-] Java nao encontrado. Instale o Java 21 ou superior.
        exit /b 1
    )
)

echo.
echo ================================================================
echo           Setup Unificado - Simulado A1 (Windows)
echo ================================================================
echo.

echo [*] Compilando 1-JUnit (Maven)...
cd 1-JUnit
if exist mvnw.cmd (
    echo [*] Usando Maven Wrapper...
    call mvnw.cmd clean compile -q 2>nul
) else (
    call mvn clean compile -q 2>nul
)
if %ERRORLEVEL% EQU 0 (
    echo [+] Compilacao JUnit bem-sucedida
) else (
    echo [-] Erro na compilacao do JUnit
    exit /b 1
)
cd ..

echo [*] Configurando FitNesse...
if not exist "%FITNESSE_JAR%" (
    echo [!] fitnesse.jar nao encontrado
) else (
    echo [+] fitnesse.jar encontrado
)

cd 2-FitNesse
if not exist target\classes mkdir target\classes
echo [*] Compilando fixtures FitNesse...
javac -cp "..\1-JUnit\target\classes;.\src" -d .\target\classes .\src\*.java 2>nul
if %ERRORLEVEL% EQU 0 (
    echo [+] Fixtures FitNesse compiladas
) else (
    echo [!] Erro na compilacao das fixtures (nao critico)
)
cd ..

echo [*] Configurando API Node.js...
cd 3-Bruno\api-node
if exist package.json (
    call npm install -q 2>nul
    if %ERRORLEVEL% EQU 0 (
        echo [+] Dependencias Node.js instaladas
    ) else (
        echo [!] Erro ao instalar dependencias Node.js
    )
)
cd ..\..

echo [*] Configurando API Python...
cd 3-Bruno\api-python
if exist requirements.txt (
    pip install -q -r requirements.txt 2>nul
    if %ERRORLEVEL% EQU 0 (
        echo [+] Dependencias Python instaladas
    ) else (
        echo [!] Erro ao instalar dependencias Python
    )
)
cd ..\..

echo.
echo ================================================================
echo                     Setup Concluido!
echo ================================================================
echo.
echo Proximos passos:
echo.
echo   1. Executar JUnit:
echo      cd 1-JUnit ^&^& mvnw.cmd clean test
echo.
echo   2. Iniciar API Node.js:
echo      cd 3-Bruno\api-node ^&^& node index.js
echo      (Rodara na porta %NODE_PORT%)
echo.
echo   3. Iniciar API Python:
echo      cd 3-Bruno\api-python ^&^& python app.py
echo      (Rodara na porta %PYTHON_PORT%)
echo.
echo   4. Iniciar FitNesse:
echo      run-all.bat fitnesse start
echo      (Rodara na porta %FITNESSE_PORT%)
echo.
echo Endpoints disponiveis:
echo.
echo   Node.js/Python (porta %NODE_PORT% / %PYTHON_PORT%):
echo     GET  /api/ping
echo     GET  /api/status
echo     POST /api/orders
echo     POST /api/process
echo.
echo   FitNesse (porta %FITNESSE_PORT%):
echo     http://localhost:%FITNESSE_PORT%/FrontPage
echo.
