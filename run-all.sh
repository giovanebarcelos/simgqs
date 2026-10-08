#!/bin/bash

# Script unificado para executar componentes individuais

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

WORKSPACE_ROOT=$(pwd)
FITNESSE_PORT=${FITNESSE_PORT:-8082}
NODE_PORT=${NODE_PORT:-3000}
PYTHON_PORT=${PYTHON_PORT:-5000}

show_help() {
    echo -e "${BLUE}â•”â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•—${NC}"
    echo -e "${BLUE}â•‘              Script Unificado de ExecuÃ§Ã£o                  â•‘${NC}"
    echo -e "${BLUE}â•šâ•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•${NC}"
    echo ""
    echo "Uso: $0 <componente> <comando> [opÃ§Ãµes]"
    echo ""
    echo -e "${GREEN}Componentes:${NC}"
    echo "  all     - Inicia todos os componentes"
    echo "  junit   - Executa testes JUnit"
    echo "  fitnesse- Gerencia FitNesse"
    echo "  node    - Inicia API Node.js"
    echo "  python  - Inicia API Python"
    echo ""
    echo -e "${GREEN}Comandos:${NC}"
    echo ""
    echo -e "${YELLOW}junit:${NC}"
    echo "  test    - Executa todos os testes"
    echo "  clean   - Limpa artefatos build"
    echo ""
    echo -e "${YELLOW}fitnesse:${NC}"
    echo "  start   - Inicia servidor FitNesse (padrÃ£o: porta 8082)"
    echo "  test    - Executa testes FitNesse e gera relatÃ³rio"
    echo "  clean   - Remove arquivos gerados"
    echo ""
    echo -e "${YELLOW}node:${NC}"
    echo "  start   - Inicia servidor Node.js (padrÃ£o: porta 3000)"
    echo ""
    echo -e "${YELLOW}python:${NC}"
    echo "  start   - Inicia servidor Python (padrÃ£o: porta 5000)"
    echo ""
    echo -e "${YELLOW}all:${NC}"
    echo "  start   - Inicia todos os servidores em background"
    echo "  stop    - Para todos os servidores"
    echo "  status  - Mostra status dos servidores"
    echo ""
    echo -e "${GREEN}Exemplos:${NC}"
    echo "  $0 junit test"
    echo "  $0 fitnesse start 9090"
    echo "  $0 node start"
    echo "  $0 python start"
    echo "  $0 all start"
    echo ""
}

# ========================
# JUNIT
# ========================
run_junit() {
    case "$1" in
        test)
            echo -e "${YELLOW}Executando testes JUnit...${NC}"
            cd "$WORKSPACE_ROOT/1-JUnit"
            mvn clean test
            ;;
        clean)
            echo -e "${YELLOW}Limpando JUnit...${NC}"
            cd "$WORKSPACE_ROOT/1-JUnit"
            mvn clean
            echo -e "${GREEN}âœ“ Limpeza concluÃ­da${NC}"
            ;;
        *)
            echo -e "${RED}Comando desconhecido para junit: $1${NC}"
            echo "Comandos disponÃ­veis: test, clean"
            exit 1
            ;;
    esac
}

# ========================
# FITNESSE
# ========================
run_fitnesse() {
    FITNESSE_JAR="$WORKSPACE_ROOT/2-FitNesse/fitnesse.jar"
    FITNESSE_PORT=${2:-8082}
    
    if [ ! -f "$FITNESSE_JAR" ]; then
        echo -e "${RED}âœ— fitnesse.jar nÃ£o encontrado em: $FITNESSE_JAR${NC}"
        echo "Execute: ./setup-all.sh"
        exit 1
    fi
    
    case "$1" in
        start)
            echo -e "${YELLOW}Iniciando FitNesse na porta $FITNESSE_PORT...${NC}"
            cd "$WORKSPACE_ROOT/2-FitNesse"
            java -jar fitnesse.jar -p $FITNESSE_PORT
            ;;
        test)
            echo -e "${YELLOW}Executando testes FitNesse...${NC}"
            mkdir -p "$WORKSPACE_ROOT/2-FitNesse/reports"
            cd "$WORKSPACE_ROOT/2-FitNesse"
            java -jar fitnesse.jar -c FrontPage.SuiteSimuladoA1 -o reports/
            echo -e "${GREEN}âœ“ RelatÃ³rio gerado em: 2-FitNesse/reports/${NC}"
            ;;
        clean)
            echo -e "${YELLOW}Limpando FitNesse...${NC}"
            cd "$WORKSPACE_ROOT/2-FitNesse"
            rm -rf reports/ fitnesse.log FitNesseRoot/files/
            echo -e "${GREEN}âœ“ Limpeza concluÃ­da${NC}"
            ;;
        *)
            echo -e "${RED}Comando desconhecido para fitnesse: $1${NC}"
            echo "Comandos disponÃ­veis: start, test, clean"
            exit 1
            ;;
    esac
}

# ========================
# NODE.JS
# ========================
run_node() {
    NODE_PORT=${2:-3000}
    
    case "$1" in
        start)
            echo -e "${YELLOW}Iniciando API Node.js na porta $NODE_PORT...${NC}"
            cd "$WORKSPACE_ROOT/3-Bruno/api-node"
            PORT=$NODE_PORT node index.js
            ;;
        *)
            echo -e "${RED}Comando desconhecido para node: $1${NC}"
            echo "Comandos disponÃ­veis: start"
            exit 1
            ;;
    esac
}

# ========================
# PYTHON
# ========================
run_python() {
    PYTHON_PORT=${2:-5000}
    
    case "$1" in
        start)
            echo -e "${YELLOW}Iniciando API Python na porta $PYTHON_PORT...${NC}"
            cd "$WORKSPACE_ROOT/3-Bruno/api-python"
            FLASK_PORT=$PYTHON_PORT python app.py --host 0.0.0.0 --port $PYTHON_PORT
            ;;
        *)
            echo -e "${RED}Comando desconhecido para python: $1${NC}"
            echo "Comandos disponÃ­veis: start"
            exit 1
            ;;
    esac
}

# ========================
# TODOS OS SERVIDORES
# ========================
run_all() {
    case "$1" in
        start)
            echo -e "${YELLOW}Iniciando todos os servidores...${NC}"
            echo ""
            
            # Node.js
            echo -e "${BLUE}â–¶ Iniciando Node.js na porta $NODE_PORT...${NC}"
            cd "$WORKSPACE_ROOT/3-Bruno/api-node"
            PORT=$NODE_PORT nohup node index.js > "$WORKSPACE_ROOT/.node.log" 2>&1 &
            NODE_PID=$!
            echo $NODE_PID > "$WORKSPACE_ROOT/.node.pid"
            sleep 1
            echo -e "${GREEN}âœ“ Node.js iniciado (PID: $NODE_PID)${NC}"
            
            # Python
            echo -e "${BLUE}â–¶ Iniciando Python na porta $PYTHON_PORT...${NC}"
            cd "$WORKSPACE_ROOT/3-Bruno/api-python"
            nohup python app.py --host 0.0.0.0 --port $PYTHON_PORT > "$WORKSPACE_ROOT/.python.log" 2>&1 &
            PYTHON_PID=$!
            echo $PYTHON_PID > "$WORKSPACE_ROOT/.python.pid"
            sleep 1
            echo -e "${GREEN}âœ“ Python iniciado (PID: $PYTHON_PID)${NC}"
            
            # FitNesse
            if [ -f "$WORKSPACE_ROOT/2-FitNesse/fitnesse.jar" ]; then
                echo -e "${BLUE}â–¶ Iniciando FitNesse na porta $FITNESSE_PORT...${NC}"
                cd "$WORKSPACE_ROOT/2-FitNesse"
                nohup java -jar fitnesse.jar -p $FITNESSE_PORT > "$WORKSPACE_ROOT/.fitnesse.log" 2>&1 &
                FITNESSE_PID=$!
                echo $FITNESSE_PID > "$WORKSPACE_ROOT/.fitnesse.pid"
                sleep 2
                echo -e "${GREEN}âœ“ FitNesse iniciado (PID: $FITNESSE_PID)${NC}"
            else
                echo -e "${YELLOW}âš  FitNesse nÃ£o disponÃ­vel (fitnesse.jar nÃ£o encontrado)${NC}"
            fi
            
            echo ""
            echo -e "${GREEN}â•”â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•—${NC}"
            echo -e "${GREEN}â•‘              Todos os servidores iniciados!               â•‘${NC}"
            echo -e "${GREEN}â•šâ•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•${NC}"
            echo ""
            echo -e "  ${BLUE}Node.js:${NC}  http://localhost:$NODE_PORT"
            echo -e "  ${BLUE}Python:${NC}   http://localhost:$PYTHON_PORT"
            [ -f "$WORKSPACE_ROOT/2-FitNesse/fitnesse.jar" ] && echo -e "  ${BLUE}FitNesse:${NC}  http://localhost:$FITNESSE_PORT/FrontPage"
            echo ""
            echo -e "Para parar: $0 all stop"
            echo ""
            ;;
        stop)
            echo -e "${YELLOW}Parando todos os servidores...${NC}"
            
            if [ -f "$WORKSPACE_ROOT/.node.pid" ]; then
                NODE_PID=$(cat "$WORKSPACE_ROOT/.node.pid")
                kill $NODE_PID 2>/dev/null || true
                rm "$WORKSPACE_ROOT/.node.pid"
                echo -e "${GREEN}âœ“ Node.js parado${NC}"
            fi
            
            if [ -f "$WORKSPACE_ROOT/.python.pid" ]; then
                PYTHON_PID=$(cat "$WORKSPACE_ROOT/.python.pid")
                kill $PYTHON_PID 2>/dev/null || true
                rm "$WORKSPACE_ROOT/.python.pid"
                echo -e "${GREEN}âœ“ Python parado${NC}"
            fi
            
            if [ -f "$WORKSPACE_ROOT/.fitnesse.pid" ]; then
                FITNESSE_PID=$(cat "$WORKSPACE_ROOT/.fitnesse.pid")
                kill $FITNESSE_PID 2>/dev/null || true
                rm "$WORKSPACE_ROOT/.fitnesse.pid"
                echo -e "${GREEN}âœ“ FitNesse parado${NC}"
            fi
            
            echo -e "${GREEN}Todos os servidores foram parados${NC}"
            ;;
        status)
            echo -e "${BLUE}Status dos servidores:${NC}"
            echo ""
            
            if [ -f "$WORKSPACE_ROOT/.node.pid" ]; then
                NODE_PID=$(cat "$WORKSPACE_ROOT/.node.pid")
                if ps -p $NODE_PID > /dev/null; then
                    echo -e "  ${GREEN}âœ“${NC} Node.js (PID: $NODE_PID) - http://localhost:$NODE_PORT"
                else
                    echo -e "  ${RED}âœ—${NC} Node.js (PID nÃ£o existe)"
                    rm "$WORKSPACE_ROOT/.node.pid"
                fi
            else
                echo -e "  ${RED}âœ—${NC} Node.js - nÃ£o estÃ¡ rodando"
            fi
            
            if [ -f "$WORKSPACE_ROOT/.python.pid" ]; then
                PYTHON_PID=$(cat "$WORKSPACE_ROOT/.python.pid")
                if ps -p $PYTHON_PID > /dev/null; then
                    echo -e "  ${GREEN}âœ“${NC} Python (PID: $PYTHON_PID) - http://localhost:$PYTHON_PORT"
                else
                    echo -e "  ${RED}âœ—${NC} Python (PID nÃ£o existe)"
                    rm "$WORKSPACE_ROOT/.python.pid"
                fi
            else
                echo -e "  ${RED}âœ—${NC} Python - nÃ£o estÃ¡ rodando"
            fi
            
            if [ -f "$WORKSPACE_ROOT/.fitnesse.pid" ]; then
                FITNESSE_PID=$(cat "$WORKSPACE_ROOT/.fitnesse.pid")
                if ps -p $FITNESSE_PID > /dev/null; then
                    echo -e "  ${GREEN}âœ“${NC} FitNesse (PID: $FITNESSE_PID) - http://localhost:$FITNESSE_PORT/FrontPage"
                else
                    echo -e "  ${RED}âœ—${NC} FitNesse (PID nÃ£o existe)"
                    rm "$WORKSPACE_ROOT/.fitnesse.pid"
                fi
            else
                echo -e "  ${RED}âœ—${NC} FitNesse - nÃ£o estÃ¡ rodando"
            fi
            echo ""
            ;;
        *)
            echo -e "${RED}Comando desconhecido para all: $1${NC}"
            echo "Comandos disponÃ­veis: start, stop, status"
            exit 1
            ;;
    esac
}

# ========================
# MAIN
# ========================
if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

COMPONENT=$1
COMMAND=$2
OPTION=$3

case "$COMPONENT" in
    junit)
        run_junit "$COMMAND" "$OPTION"
        ;;
    fitnesse)
        run_fitnesse "$COMMAND" "$OPTION"
        ;;
    node)
        run_node "$COMMAND" "$OPTION"
        ;;
    python)
        run_python "$COMMAND" "$OPTION"
        ;;
    all)
        run_all "$COMMAND"
        ;;
    help|-h|--help)
        show_help
        ;;
    *)
        echo -e "${RED}âœ— Componente desconhecido: $COMPONENT${NC}"
        show_help
        exit 1
        ;;
esac

