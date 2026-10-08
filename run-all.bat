@echo off
REM Script unificado para executar componentes individuais no Windows
REM Gestao e Qualidade de Software - Simulado A1

setlocal enabledelayedexpansion
cd /d "%~dp0"

REM Configuracoes
set FITNESSE_PORT=8082
set NODE_PORT=3000
set PYTHON_PORT=5000

REM Help shortcuts
if "%1"=="" goto :show_help
if /i "%1"=="help" goto :show_help
if "%1"=="-h" goto :show_help
if "%1"=="--help" goto :show_help
goto :after_help

REM ========================
REM HELP
REM ========================
:show_help
echo.
echo ========================================================================
echo              Script Unificado de Execucao - Windows
echo ========================================================================
echo.
echo Uso: run-all.bat ^<componente^> ^<comando^> [opcoes]
echo.
echo Componentes:
echo   junit     - Executa testes JUnit
echo   fitnesse  - Gerencia FitNesse
echo   node      - Inicia API Node.js
echo   python    - Inicia API Python
echo   all       - Orquestra todos os servidores
echo.
echo Comandos:
echo.
echo [junit]
echo   test      - Executa todos os testes
echo   clean     - Limpa artefatos de build
echo.
echo [fitnesse]
echo   start     - Inicia servidor FitNesse (padrao: porta %FITNESSE_PORT%)
echo   test      - Executa testes FitNesse e gera relatorio
echo   clean     - Remove arquivos gerados
echo.
echo [node]
echo   start     - Inicia servidor Node.js (padrao: porta %NODE_PORT%)
echo.
echo [python]
echo   start     - Inicia servidor Python (padrao: porta %PYTHON_PORT%)
echo.
echo [all]
echo   start     - Inicia todos os servidores
echo   stop      - Para todos os servidores
echo   status    - Mostra status dos servidores
echo.
echo Exemplos:
echo   run-all.bat junit test
echo   run-all.bat fitnesse start 9090
echo   run-all.bat node start
echo   run-all.bat python start
echo   run-all.bat all start
echo.
exit /b 0

:after_help
set COMPONENT=%1
set ACTION=%2
set OPTION=%3

REM ========================
REM DISPATCH
REM ========================
:dispatch
if /i "%COMPONENT%"=="junit" goto :run_junit
if /i "%COMPONENT%"=="fitnesse" goto :run_fitnesse
if /i "%COMPONENT%"=="node" goto :run_node
if /i "%COMPONENT%"=="python" goto :run_python
if /i "%COMPONENT%"=="all" goto :run_all

echo [-] Componente desconhecido: %COMPONENT%
echo Componentes disponiveis: junit, fitnesse, node, python, all
exit /b 1

REM ========================
REM PYTHON
REM ========================
:run_python
if "%OPTION%"=="" (
    set PYTHON_PORT=5000
) else (
    set PYTHON_PORT=%OPTION%
)

if /i "%ACTION%"=="start" (
    echo [*] Iniciando API Python na porta %PYTHON_PORT%...
    cd 3-Bruno\api-python

    REM Garante dependencias
    python -c "import flask" 2>nul
    if errorlevel 1 (
        echo [!] Flask nao encontrado. Instalando dependencias...
        python -m pip install --upgrade -r requirements.txt
    )

    REM Inicia a API
    python app.py --host 0.0.0.0 --port %PYTHON_PORT%
    cd ..\..
) else (
    echo [-] Comando desconhecido para python: %ACTION%
    echo Comandos disponiveis: start
    exit /b 1
)
exit /b 0
REM ========================
REM JUNIT
REM ========================
:run_junit
if /i "%ACTION%"=="test" (
    echo [*] Executando testes JUnit...
    cd 1-JUnit
    if exist mvnw.cmd (
        call mvnw.cmd clean test
    ) else (
        call mvn clean test
    )
    set "ERR=%ERRORLEVEL%"
    cd ..
    exit /b %ERR%
) else if /i "%ACTION%"=="clean" (
    echo [*] Limpando JUnit...
    cd 1-JUnit
    if exist mvnw.cmd (
        call mvnw.cmd clean
    ) else (
        call mvn clean
    )
    set "ERR=%ERRORLEVEL%"
    cd ..
    echo [+] Limpeza concluida
    exit /b %ERR%
) else (
    echo [-] Comando desconhecido para junit: %ACTION%
    echo Comandos disponiveis: test, clean
    exit /b 1
)

REM ========================
REM FITNESSE
REM ========================
:run_fitnesse
if "%OPTION%"=="" (
    set FITNESSE_PORT=8082
) else (
    set FITNESSE_PORT=%OPTION%
)

if not exist "2-FitNesse\fitnesse.jar" (
    echo [-] fitnesse.jar nao encontrado em: 2-FitNesse\fitnesse.jar
    echo [*] Execute: setup-all.bat
    exit /b 1
)

if /i "%ACTION%"=="start" (
    echo [*] Iniciando FitNesse na porta %FITNESSE_PORT%...
    cd 2-FitNesse
    java -jar fitnesse.jar -p %FITNESSE_PORT%
    cd ..
) else if /i "%ACTION%"=="test" (
    echo [*] Executando testes FitNesse...
    if not exist "2-FitNesse\reports" mkdir "2-FitNesse\reports"
    cd 2-FitNesse
    java -jar fitnesse.jar -c FrontPage.Q11SuiteDeTeste -b reports\output.txt
    cd ..
    echo [+] Relatorio gerado em: 2-FitNesse\reports
) else if /i "%ACTION%"=="clean" (
    echo [*] Limpando FitNesse...
    if exist "2-FitNesse\reports" rmdir /s /q "2-FitNesse\reports"
    if exist "2-FitNesse\fitnesse.log" del "2-FitNesse\fitnesse.log"
    echo [+] Limpeza concluida
) else (
    echo [-] Comando desconhecido para fitnesse: %ACTION%
    echo Comandos disponiveis: start, test, clean
    exit /b 1
)
exit /b 0

REM ========================
REM NODE.JS
REM ========================
:run_node
if "%OPTION%"=="" (
    set NODE_PORT=3000
) else (
    set NODE_PORT=%OPTION%
)

if /i "%ACTION%"=="start" (
    echo [*] Iniciando API Node.js na porta %NODE_PORT%...
    cd 3-Bruno\api-node
    set PORT=%NODE_PORT%
    call node index.js
    cd ..\..
) else (
    echo [-] Comando desconhecido para node: %ACTION%
    echo Comandos disponiveis: start
    exit /b 1
)
exit /b 0

REM ========================
REM TODOS OS SERVIDORES
REM ========================
:run_all
if /i "%ACTION%"=="start" (
    echo [*] Iniciando todos os servidores...
    echo.
    
    REM Node.js
    echo [+] Iniciando Node.js na porta %NODE_PORT%...
    start "Node.js API" cmd /k "cd 3-Bruno\api-node && set PORT=%NODE_PORT% && node index.js"
    timeout /t 1 /nobreak >nul
    
    REM Python
    echo [+] Iniciando Python na porta %PYTHON_PORT%...
    start "Python API" cmd /k "cd 3-Bruno\api-python && python app.py --host 0.0.0.0 --port %PYTHON_PORT%"
    timeout /t 1 /nobreak >nul
    
    REM FitNesse
    if exist "2-FitNesse\fitnesse.jar" (
        echo [+] Iniciando FitNesse na porta %FITNESSE_PORT%...
        start "FitNesse" cmd /k "cd 2-FitNesse && java -jar fitnesse.jar -p %FITNESSE_PORT%"
        timeout /t 2 /nobreak >nul
    ) else (
        echo [!] FitNesse nao disponivel ^(fitnesse.jar nao encontrado^)
    )
    
    echo.
    echo ========================================================================
    echo               Todos os servidores iniciados!
    echo ========================================================================
    echo.
    echo   Node.js:  http://localhost:%NODE_PORT%
    echo   Python:   http://localhost:%PYTHON_PORT%
    if exist "2-FitNesse\fitnesse.jar" (
        echo   FitNesse: http://localhost:%FITNESSE_PORT%/FrontPage
    )
    echo.
    echo Para parar: feche as janelas de comando
    echo.
) else if /i "%ACTION%"=="stop" (
    echo [*] Parando todos os servidores...
    taskkill /f /im node.exe 2>nul
    if %ERRORLEVEL% EQU 0 echo [+] Node.js parado
    
    taskkill /f /im python.exe 2>nul
    if %ERRORLEVEL% EQU 0 echo [+] Python parado
    
    taskkill /f /im java.exe 2>nul
    if %ERRORLEVEL% EQU 0 echo [+] FitNesse parado
    
    echo [+] Todos os servidores foram parados
) else if /i "%ACTION%"=="status" (
    echo [*] Status dos servidores:
    echo.
    
    tasklist | find /i "node.exe" >nul
    if %ERRORLEVEL% EQU 0 (
        echo [+] Node.js esta rodando
    ) else (
        echo [-] Node.js nao esta rodando
    )
    
    tasklist | find /i "python.exe" >nul
    if %ERRORLEVEL% EQU 0 (
        echo [+] Python esta rodando
    ) else (
        echo [-] Python nao esta rodando
    )
    
    tasklist | find /i "java.exe" >nul
    if %ERRORLEVEL% EQU 0 (
        echo [+] FitNesse esta rodando
    ) else (
        echo [-] FitNesse nao esta rodando
    )
    echo.
) else (
    echo [-] Comando desconhecido para all: %ACTION%
    echo Comandos disponiveis: start, stop, status
    exit /b 1
)
exit /b 0
