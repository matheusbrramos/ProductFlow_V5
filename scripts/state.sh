#!/bin/bash

# ProductFlow_V5 — Ver estado atual do projeto
# Uso: bash state.sh (de dentro da pasta do projeto)

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

if [ ! -f "project_state.md" ]; then
    echo -e "${RED}❌ Erro: project_state.md não encontrado${NC}"
    echo "Execute este script de dentro da pasta do projeto."
    exit 1
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}📊 PROJECT STATE$(NC)"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Pesquisa
echo -e "${YELLOW}1. PESQUISA (Research Stream)${NC}"
if [ -f "market_data.md" ]; then
    SCORE=$(grep "^**Score:**" market_data.md | grep -oE '[0-9]+' | head -1)
    echo -e "   ${GREEN}✅ market_data.md criado${NC}"
    [ ! -z "$SCORE" ] && echo -e "   📈 Market Score: ${GREEN}$SCORE/10${NC}"
else
    echo -e "   ${RED}⏳ market_data.md não pronto${NC}"
    echo -e "   ${YELLOW}Próximo passo:${NC} bash ../../scripts/research.sh"
fi
echo ""

# Protótipo
echo -e "${YELLOW}2. PROTÓTIPO (Prototype Stream)${NC}"
if [ -f "spec_checklist.md" ]; then
    echo -e "   ${GREEN}✅ spec_checklist.md criado${NC}"
else
    echo -e "   ${RED}⏳ spec_checklist.md não pronto${NC}"
fi

if [ -d "prototypes" ] && [ "$(ls -A prototypes/ 2>/dev/null | wc -l)" -gt 0 ]; then
    PROTO_COUNT=$(ls prototypes/ 2>/dev/null | wc -l)
    echo -e "   ${GREEN}✅ $PROTO_COUNT protótipos gerados${NC}"
else
    echo -e "   ${RED}⏳ Protótipos não gerados${NC}"
    echo -e "   ${YELLOW}Próximo passo:${NC} bash ../../scripts/prototype_gen.sh"
fi
echo ""

# Specs
echo -e "${YELLOW}3. SPECS (Specs Stream)${NC}"
if [ -f "prd.md" ]; then
    echo -e "   ${GREEN}✅ prd.md criado${NC}"
else
    echo -e "   ${RED}⏳ prd.md não criado${NC}"
fi

if [ -f "spec_checklist.md" ]; then
    VALID_COUNT=$(grep -c "✅" spec_checklist.md 2>/dev/null || echo "0")
    TOTAL_COUNT=$(grep -c "^- " spec_checklist.md 2>/dev/null || echo "1")
    PCT=$((VALID_COUNT * 100 / TOTAL_COUNT))
    echo -e "   ${GREEN}✅ spec_checklist.md: $VALID_COUNT/$TOTAL_COUNT validado ($PCT%)${NC}"
else
    echo -e "   ${RED}⏳ spec_checklist.md não pronto${NC}"
    echo -e "   ${YELLOW}Próximo passo:${NC} bash ../../scripts/spec_validator.sh"
fi
echo ""

# Logs/Decisões
echo -e "${YELLOW}Decisões Documentadas${NC}"
if [ -d "decisions" ] && [ "$(ls -A decisions/ 2>/dev/null | wc -l)" -gt 0 ]; then
    DECISIONS=$(ls decisions/ 2>/dev/null | wc -l)
    echo -e "   ${GREEN}✅ $DECISIONS decision files${NC}"
    ls -1 decisions/ | sed 's/^/   /'
else
    echo -e "   ${YELLOW}⏳ Nenhuma decisão documentada ainda${NC}"
fi
echo ""

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Arquivo de referência: project_state.md${NC}"
echo ""
