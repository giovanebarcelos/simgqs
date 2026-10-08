#!/bin/bash

# Script unificado para setup e execuÃ§Ã£o de todos os componentes:
# - JUnit (1-JUnit)
# - FitNesse (2-FitNesse)
# - API Node.js (3-Bruno/api-node)
# - API Python (3-Bruno/api-python)

set -e  # Exit on error

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ConfiguraÃ§Ãµes
WORKSPACE_ROOT=$(pwd)
FITNESSE_JAR="$WORKSPACE_ROOT/2-FitNesse/fitnesse.jar"
FITNESSE_PORT=${FITNESSE_PORT:-8082}
NODE_PORT=${NODE_PORT:-3000}
PYTHON_PORT=${PYTHON_PORT:-5000}

# Banner
echo -e "${BLUE}â•”â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•—${NC}"
echo -e "${BLUE}â•‘          Setup Unificado - Simulado A1                     â•‘${NC}"
echo -e "${BLUE}â•šâ•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•${NC}"
echo ""

# FunÃ§Ã£o para exibir seÃ§Ãµes
show_section() {
    echo -e "${BLUE}â–¶ $1${NC}"
}

# FunÃ§Ã£o para exibir sucesso
success() {
    echo -e "${GREEN}âœ“ $1${NC}"
}

# FunÃ§Ã£o para exibir erro
error() {
    echo -e "${RED}âœ— $1${NC}"
    exit 1
}

# FunÃ§Ã£o para exibir aviso
warning() {
    echo -e "${YELLOW}âš  $1${NC}"
}

# ========================
# 1. COMPILAÃ‡ÃƒO JUNIT
# ========================
show_section "Compilando 1-JUnit (Maven)..."
cd "$WORKSPACE_ROOT/1-JUnit"
if mvn clean compile -q 2>/dev/null; then
    success "CompilaÃ§Ã£o JUnit bem-sucedida"
else
    error "Erro na compilaÃ§Ã£o do JUnit"
fi

# ========================
# 2. SETUP FITNESSE
# ========================
show_section "Configurando FitNesse..."

# Verificar/baixar fitnesse.jar
if [ ! -f "$FITNESSE_JAR" ]; then
    warning "fitnesse.jar nÃ£o encontrado. Tentando baixar..."
    mkdir -p "$(dirname "$FITNESSE_JAR")"
    
    # URLs de fallback
    URLS=(
        "https://raw.githubusercontent.com/fitnesse/fitnessedotorg/master/releases/20250223/fitnesse-standalone.jar"
        "https://github.com/fitnesse/fitnesse/releases/download/20250223/fitnesse-standalone.jar"
    )
    
    DOWNLOADED=0
    for URL in "${URLS[@]}"; do
        if wget -q "$URL" -O "$FITNESSE_JAR" 2>/dev/null; then
            DOWNLOADED=1
            success "FitNesse baixado com sucesso"
            break
        fi
    done
    
    if [ $DOWNLOADED -eq 0 ]; then
        warning "NÃ£o foi possÃ­vel baixar FitNesse"
        warning "InstruÃ§Ãµes alternativas:"
        warning "  1. Download manual: https://github.com/fitnesse/fitnesse/releases"
        warning "  2. Docker: docker pull fitnesse/fitnesse"
        warning "  3. Coloque fitnesse.jar em: $FITNESSE_JAR"
    fi
else
    success "fitnesse.jar encontrado"
fi

# Compilar fixtures FitNesse
cd "$WORKSPACE_ROOT/2-FitNesse"
mkdir -p target/classes
if javac -cp "$WORKSPACE_ROOT/1-JUnit/target/classes:./src" -d ./target/classes ./src/*.java 2>/dev/null; then
    success "Fixtures FitNesse compiladas"
else
    warning "Erro na compilaÃ§Ã£o das fixtures FitNesse (nÃ£o crÃ­tico)"
fi

# ========================
# 3. SETUP API NODE.JS
# ========================
show_section "Configurando API Node.js..."
cd "$WORKSPACE_ROOT/3-Bruno/api-node"

if [ -f "package.json" ]; then
    if npm install -q 2>/dev/null; then
        success "DependÃªncias Node.js instaladas"
    else
        warning "Erro ao instalar dependÃªncias Node.js"
    fi
else
    warning "package.json nÃ£o encontrado em api-node"
fi

# ========================
# 4. SETUP API PYTHON
# ========================
show_section "Configurando API Python..."
cd "$WORKSPACE_ROOT/3-Bruno/api-python"

if [ -f "requirements.txt" ]; then
    if pip install -q -r requirements.txt 2>/dev/null; then
        success "DependÃªncias Python instaladas"
    else
        warning "Erro ao instalar dependÃªncias Python"
    fi
else
    warning "requirements.txt nÃ£o encontrado em api-python"
fi

# ========================
# Resumo Final
# ========================
echo ""
echo -e "${BLUE}â•”â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•—${NC}"
echo -e "${BLUE}â•‘                    Setup ConcluÃ­do!                        â•‘${NC}"
echo -e "${BLUE}â•šâ•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•${NC}"
echo ""
echo -e "${GREEN}PrÃ³ximos passos:${NC}"
echo ""
echo -e "  ${YELLOW}1. Executar JUnit:${NC}"
echo -e "     cd 1-JUnit && mvn clean test"
echo ""
echo -e "  ${YELLOW}2. Iniciar API Node.js:${NC}"
echo -e "     cd 3-Bruno/api-node && node index.js"
echo -e "     (RodarÃ¡ na porta $NODE_PORT)"
echo ""
echo -e "  ${YELLOW}3. Iniciar API Python:${NC}"
echo -e "     cd 3-Bruno/api-python && python app.py"
echo -e "     (RodarÃ¡ na porta $PYTHON_PORT)"
echo ""
echo -e "  ${YELLOW}4. Iniciar FitNesse:${NC}"
echo -e "     ./run-all.sh fitnesse start"
echo -e "     (RodarÃ¡ na porta $FITNESSE_PORT)"
echo ""
echo -e "${BLUE}Endpoints disponÃ­veis:${NC}"
echo ""
echo -e "  ${GREEN}Node.js/Python (porta $NODE_PORT / $PYTHON_PORT):${NC}"
echo "    GET  /api/ping"
echo "    GET  /api/status"
echo "    POST /api/orders"
echo "    POST /api/process"
echo ""
echo -e "  ${GREEN}FitNesse (porta $FITNESSE_PORT):${NC}"
echo "    http://localhost:$FITNESSE_PORT/FrontPage"
echo ""

