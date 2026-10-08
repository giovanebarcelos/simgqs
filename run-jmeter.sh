#!/bin/bash

# Script para executar testes JMeter e gerar relatórios HTML

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configurações
WORKSPACE_ROOT=$(pwd)
JMETER_DIR="$WORKSPACE_ROOT/4-JMeter"
TEST_FILE="$JMETER_DIR/testes/simuladoA1.jmx"
REPORTS_DIR="$JMETER_DIR/reports"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

show_help() {
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║          Executor de Testes JMeter - Simulado A1           ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Uso: $0 <comando> [opções]"
    echo ""
    echo -e "${GREEN}Comandos:${NC}"
    echo "  q15         - Executa Q15 (Teste de Carga - 100 threads por 60s)"
    echo "  q16         - Executa Q16 (Teste de Estresse - Rampa 500 threads)"
    echo "  q17         - Executa Q17 (Teste de Cenário - POST /api/process)"
    echo "  all         - Executa todos os testes sequencialmente"
    echo "  gui         - Abre JMeter em modo GUI"
    echo "  report      - Gera relatório HTML do último teste"
    echo ""
    echo -e "${GREEN}Exemplos:${NC}"
    echo "  $0 q15"
    echo "  $0 q16"
    echo "  $0 q17"
    echo "  $0 all"
    echo "  $0 gui"
    echo ""
}

check_jmeter() {
    if ! command -v jmeter &> /dev/null; then
        echo -e "${RED}✗ JMeter não encontrado!${NC}"
        echo -e "${YELLOW}Instale com:${NC}"
        echo "  - Download: https://jmeter.apache.org/download_jmeter.cgi"
        echo "  - Linux/Mac: brew install jmeter (ou apache-jmeter)"
        echo "  - Windows: Download e extraia o .zip"
        exit 1
    fi
}

check_api() {
    local port=$1
    local name=$2
    
    if ! curl -s http://localhost:$port/api/ping > /dev/null 2>&1; then
        echo -e "${RED}✗ API $name não está rodando na porta $port${NC}"
        echo -e "${YELLOW}Inicie com:${NC}"
        echo "  ./run-all.sh all start"
        exit 1
    fi
}

create_report_dir() {
    mkdir -p "$REPORTS_DIR"
    mkdir -p "$REPORTS_DIR/html"
}

run_test() {
    local test_name=$1
    local output_file="$REPORTS_DIR/${test_name}_${TIMESTAMP}.jtl"
    local html_dir="$REPORTS_DIR/html/${test_name}_${TIMESTAMP}"
    
    echo -e "${BLUE}▶ Executando $test_name...${NC}"
    echo -e "  Arquivo de saída: $output_file"
    echo ""
    
    # Executar teste em modo não-interativo
    jmeter -n \
        -t "$TEST_FILE" \
        -Jthreadgroup="$test_name" \
        -l "$output_file" \
        -j "$REPORTS_DIR/${test_name}_${TIMESTAMP}.log" \
        2>&1 | grep -E "(Starting|Completed|Throughput|Average|Min|Max|Error)"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Teste concluído${NC}"
        
        # Gerar relatório HTML
        echo -e "${YELLOW}▶ Gerando relatório HTML...${NC}"
        jmeter -g "$output_file" \
            -o "$html_dir" \
            -j "$REPORTS_DIR/${test_name}_report_${TIMESTAMP}.log" 2>&1 | grep -i "Jmeter"
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ Relatório HTML gerado em: $html_dir${NC}"
            echo -e "${YELLOW}  Abra em navegador: file://$html_dir/index.html${NC}"
        fi
        
        return 0
    else
        echo -e "${RED}✗ Erro ao executar teste${NC}"
        return 1
    fi
}

run_all_tests() {
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║            Executando Todos os Testes                     ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    check_jmeter
    check_api 5000 "API Python"
    create_report_dir
    
    echo -e "${YELLOW}Pré-requisitos verificados!${NC}"
    echo ""
    
    # Executar Q15
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}Q15 - Teste de Carga (100 threads, 60s)${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}"
    run_test "Q15_Carga"
    sleep 2
    
    # Executar Q16
    echo ""
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}Q16 - Teste de Estresse (Rampa 500 threads)${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}"
    run_test "Q16_Estresse"
    sleep 2
    
    # Executar Q17
    echo ""
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}Q17 - Teste de Cenário (POST /api/process, 50 threads)${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}"
    run_test "Q17_Cenario"
    
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║              Todos os testes concluídos!                  ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "Relatórios disponíveis em: ${YELLOW}$REPORTS_DIR${NC}"
}

run_single_test() {
    local test_name=$1
    
    check_jmeter
    check_api 5000 "API Python"
    create_report_dir
    
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║               Teste: $test_name${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    run_test "$test_name"
}

open_gui() {
    check_jmeter
    
    echo -e "${BLUE}Abrindo JMeter GUI...${NC}"
    echo -e "${YELLOW}Arquivo: $TEST_FILE${NC}"
    echo ""
    
    # Abrir JMeter em modo GUI
    jmeter -t "$TEST_FILE" &
    
    sleep 2
    echo -e "${GREEN}✓ JMeter aberto${NC}"
    echo ""
    echo -e "${YELLOW}Instruções:${NC}"
    echo "  1. No painel esquerdo, veja os 3 Thread Groups (Q15, Q16, Q17)"
    echo "  2. Para executar um teste específico:"
    echo "     - Selecione o Thread Group"
    echo "     - Clique em Run → Start (ou Ctrl+Enter)"
    echo "  3. Os resultados aparecem em 'Summary Report'"
}

generate_report() {
    check_jmeter
    
    # Encontrar o arquivo .jtl mais recente
    local latest_jtl=$(ls -t "$REPORTS_DIR"/*.jtl 2>/dev/null | head -1)
    
    if [ -z "$latest_jtl" ]; then
        echo -e "${RED}✗ Nenhum arquivo .jtl encontrado em $REPORTS_DIR${NC}"
        echo "Execute um teste primeiro com: $0 all"
        exit 1
    fi
    
    local test_name=$(basename "$latest_jtl" .jtl)
    local html_dir="$REPORTS_DIR/html/${test_name}"
    
    echo -e "${YELLOW}Gerando relatório para: $latest_jtl${NC}"
    
    jmeter -g "$latest_jtl" \
        -o "$html_dir" 2>&1 | grep -i "Jmeter"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Relatório gerado em: $html_dir${NC}"
        echo ""
        echo -e "${YELLOW}Para visualizar, abra:${NC}"
        echo "  file://$html_dir/index.html"
    else
        echo -e "${RED}✗ Erro ao gerar relatório${NC}"
    fi
}

# ========================
# MAIN
# ========================

if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

COMMAND=$1

case "$COMMAND" in
    q15)
        run_single_test "Q15_Carga"
        ;;
    q16)
        run_single_test "Q16_Estresse"
        ;;
    q17)
        run_single_test "Q17_Cenario"
        ;;
    all)
        run_all_tests
        ;;
    gui)
        open_gui
        ;;
    report)
        generate_report
        ;;
    help|-h|--help)
        show_help
        ;;
    *)
        echo -e "${RED}✗ Comando desconhecido: $COMMAND${NC}"
        show_help
        exit 1
        ;;
esac
