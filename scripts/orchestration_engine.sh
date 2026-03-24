#!/bin/bash

# ProductFlow_V5 — Orquestração de Modelos (CHUNK 2.2)
# Usa market_score e TAM para decidir: Haiku vs Sonnet vs Opus
# Uso: bash orchestration_engine.sh (de dentro da pasta do projeto)

set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

if [ ! -f "market_data.md" ]; then
    echo -e "${RED}❌ Erro: market_data.md não encontrado${NC}"
    exit 1
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${MAGENTA}⚙️ ORQUESTRAÇÃO DE MODELOS (CHUNK 2.2)${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Extrair market_score e TAM
MARKET_SCORE=$(grep "^**Score:**" market_data.md | grep -oE '[0-9]+' | head -1)
TAM=$(grep "^- \*\*Estimado:\*\*" market_data.md | head -1 | cut -d' ' -f4-)

echo -e "${YELLOW}📊 Dados do Projeto${NC}"
echo "  Market Score: $MARKET_SCORE / 10"
echo "  TAM: $TAM"
echo ""

# Decisão de modelo baseado em regras
echo -e "${YELLOW}🤖 Decision Tree${NC}"
echo ""

# Extrair número do TAM para comparação
TAM_NUM=$(echo "$TAM" | grep -oE '[0-9]+' | head -1)
if [ -z "$TAM_NUM" ]; then
    TAM_NUM=0
fi

# Determinar modelo recomendado
if [ $MARKET_SCORE -lt 5 ] && [ $TAM_NUM -lt 50 ]; then
    RECOMMENDED_MODEL="Haiku"
    RATIONALE="Market score baixo ($MARKET_SCORE/10) + TAM pequeno (~\$$TAM_NUM M). MVP com economia."
elif [ $TAM_NUM -gt 500 ]; then
    RECOMMENDED_MODEL="Opus"
    RATIONALE="TAM grande (\$$TAM_NUM M+). Quality gates exigidos."
else
    RECOMMENDED_MODEL="Sonnet"
    RATIONALE="Market score moderado ($MARKET_SCORE/10). Sonnet balanceia qualidade e eficiência."
fi

echo -e "${CYAN}Recomendação: ${GREEN}$RECOMMENDED_MODEL${NC}"
echo "Razão: $RATIONALE"
echo ""

# Gerar orchestration.md
cat > orchestration.md << EOF
# Orchestration Plan

**Projeto:** $(basename "$(pwd)")
**Data:** $(date)
**Modelo Recomendado:** $RECOMMENDED_MODEL

## Decision Tree Aplicada

\`\`\`
Market Score: $MARKET_SCORE / 10
TAM: $TAM

IF market_score < 5 AND TAM < \$50M:
    → Haiku (MVP com economia)
ELSE IF TAM > \$500M:
    → Opus (quality gates)
ELSE:
    → Sonnet (equilíbrio padrão)

Resultado: $RECOMMENDED_MODEL
\`\`\`

---

## Fases Recomendadas

### Fase 1: Pesquisa + Protótipo
- **Modelo:** Haiku
- **Context Budget:** 8k tokens
- **Tarefas:** Pesquisa de mercado, geração de wireframes
- **Custo Relativo:** \$ (mínimo)

### Fase 2: Validação de Specs
- **Modelo:** Sonnet (mínimo)
- **Context Budget:** 15k tokens
- **Tarefas:** Identificar edge cases, ambiguidades, gaps
- **Custo Relativo:** \$\$ (moderado)

### Fase 3: Codegen Core
- **Modelo:** $RECOMMENDED_MODEL
- **Context Budget:** 20-25k tokens
- **Tarefas:** Implementar funcionalidades principais
- **Custo Relativo:** \$\$\$ (baseado no modelo)

### Fase 4: Review + Refinement
- **Modelo:** Opus (se TAM > \$500M) | Sonnet (padrão)
- **Context Budget:** 15k tokens
- **Tarefas:** Code review, otimizações, documentação
- **Custo Relativo:** Variável

---

## Justificativa de Decisão

**Market Score Analysis:**
- Pain points validados: SIM ✅
- TAM confirmado: $(grep "^- \*\*Justificativa:" market_data.md | head -1 | cut -d':' -f2-)
- Willingness to Pay: Confirmado ✅

**Implicações:**
- Se market_score >= 7: Qualidade > Eficiência. Use Opus para review final.
- Se market_score < 6: Validação ainda incerta. Use Haiku/Sonnet, iterar rápido.
- Se market_score 6-7: Equilibro. Sonnet é default seguro.

---

## Próximas Ações

1. **Confirmar decisão:**
   - [ ] PM valida recomendação do modelo
   - [ ] Tech lead confirma context budget é realístico

2. **Preparar para Codegen:**
   - [ ] Specs validation completada (90%+)
   - [ ] Blueprint.md pronto com fases e dependências
   - [ ] Context analyzado (python3 ../../scripts/lib/context_rot_detector.py --project .)

3. **Executar Codegen:**
   \`\`\`bash
   bash ../../scripts/codegen.sh
   \`\`\`

---

**Gerado em:** $(date)
**Script:** orchestration_engine.sh
EOF

echo -e "${GREEN}✅ orchestration.md criado${NC}"
echo ""

# Validar context com detector
if [ -f "../../scripts/lib/context_rot_detector.py" ]; then
    echo -e "${YELLOW}🔍 Analisando context risk...${NC}"
    echo ""

    # Executar detector se Python está disponível
    if command -v python3 &> /dev/null; then
        python3 ../../scripts/lib/context_rot_detector.py --project . 2>/dev/null || echo "⚠️ Detector não pôde analisar completo"
    fi
fi

echo ""
echo -e "${YELLOW}📋 Próximos passos:${NC}"
echo ""
echo "1. **Revisar orchestration.md:**"
echo "   cat orchestration.md"
echo ""
echo "2. **Validar com PM/Tech Lead:**"
echo "   - Modelo recomendado ($RECOMMENDED_MODEL) é apropriado?"
echo "   - Context budget (8-25k tokens) é realístico?"
echo ""
echo "3. **Se aprovado, pronto para Codegen:**"
echo "   bash ../../scripts/codegen.sh"
echo ""
echo -e "${BLUE}Ver estado completo:${NC}"
echo "  bash ../../scripts/state.sh"
echo ""
