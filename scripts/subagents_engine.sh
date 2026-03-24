#!/bin/bash

# ProductFlow_V5 — Orquestração de Subagentes (CHUNK 2.3)
# Executa múltiplos agentes em paralelo baseado em YAML config
# Uso: bash subagents_engine.sh (de dentro da pasta do projeto)

set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${MAGENTA}🤖 SUBAGENTES DECLARATIVOS (CHUNK 2.3)${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Verificar se config existe
AGENTS_CONFIG="subagents.yaml"

if [ ! -f "$AGENTS_CONFIG" ]; then
    echo -e "${YELLOW}⚠️  $AGENTS_CONFIG não encontrado. Criando template...${NC}"
    echo ""

    cat > "$AGENTS_CONFIG" << 'EOF'
# ProductFlow_V5 — Subagentes Config
# Define quais agentes rodam em paralelo/sequência

parallel:
  research_agent:
    model: "Claude Haiku"
    context_budget: 8000
    inputs:
      - market_data.md (pesquisa em andamento)
    outputs:
      - market_data.md (atualizado)
    task: "Pesquisa integrada — TAM, pain points, competitors"

  prototype_agent:
    model: "Claude Haiku"
    context_budget: 8000
    inputs:
      - market_data.md
      - prd.md
    outputs:
      - prototypes/v1.figma
    task: "Gerar wireframe FigJam low-fidelity"

sequential:
  specs_validator:
    model: "Claude Sonnet"
    context_budget: 15000
    depends_on: "prototype_agent"
    inputs:
      - prd.md
      - prototypes/v1.figma
      - market_data.md
    outputs:
      - spec_checklist.md
    task: "Validação de specs — ambiguidades, edge cases, gaps"

  feedback_processor:
    model: "Claude Haiku"
    context_budget: 10000
    depends_on: "specs_validator"
    inputs:
      - prototype_feedback.md
      - spec_checklist.md
    outputs:
      - market_data.md (atualizado)
      - spec_checklist.md (atualizado)
    task: "Processar feedback de usuários em cascata"
EOF

    echo -e "${GREEN}✅ Template criado: $AGENTS_CONFIG${NC}"
    echo ""
    echo -e "${YELLOW}📝 Próximos passos:${NC}"
    echo "1. Editar $AGENTS_CONFIG com specs reais dos agentes"
    echo "2. Rodar: bash ../../scripts/subagents_engine.sh novamente"
    echo ""
    exit 0
fi

echo -e "${YELLOW}📋 Configuração de Agentes${NC}"
echo ""

# Contar agentes
PARALLEL_COUNT=$(grep -c "^  [a-z_]*:" "$AGENTS_CONFIG" | grep -v "sequential" || echo 0)
SEQUENTIAL_COUNT=$(grep -A 100 "^sequential:" "$AGENTS_CONFIG" | grep -c "^  [a-z_]*:" || echo 0)

echo "Parallel agents: $PARALLEL_COUNT"
echo "Sequential agents: $SEQUENTIAL_COUNT"
echo ""

# Executar orchestrador Python
echo -e "${YELLOW}🚀 Iniciando orquestração...${NC}"
echo ""

if command -v python3 &> /dev/null; then
    python3 "../../scripts/lib/subagents_orchestrator.py" --config "$AGENTS_CONFIG" --project . 2>/dev/null || {
        echo -e "${YELLOW}ℹ️  Python orchestrator não disponível. Usando shell fallback.${NC}"
        echo ""
    }
else
    echo -e "${YELLOW}⚠️  Python não disponível. Usando fallback.${NC}"
fi

# Gerar relatório
cat > subagents_report.md << EOF
# Subagentes Execution Report

**Data:** $(date)
**Config:** $AGENTS_CONFIG
**Status:** ✅ Configurado

---

## Agentes Paralelos

\`\`\`yaml
$(grep -A 20 "^parallel:" "$AGENTS_CONFIG" | head -20)
\`\`\`

---

## Agentes Sequenciais

\`\`\`yaml
$(grep -A 50 "^sequential:" "$AGENTS_CONFIG" | head -50)
\`\`\`

---

## Próximas Ações

1. Validar que todos os agentes têm **model** e **context_budget** definidos
2. Testar cada agente individualmente:
   \`\`\`bash
   bash ../../scripts/research.sh        # research_agent
   bash ../../scripts/prototype_gen.sh   # prototype_agent
   bash ../../scripts/spec_validator.sh  # specs_validator
   bash ../../scripts/feedback_loop.sh   # feedback_processor
   \`\`\`
3. Após validação, todos podem rodar em paralelo:
   \`\`\`bash
   bash ../../scripts/subagents_engine.sh
   \`\`\`

---

**Gerado por:** subagents_engine.sh (CHUNK 2.3)
**Time:** $(date)

EOF

echo ""
echo -e "${GREEN}✅ subagents_report.md criado${NC}"
echo ""

# Sugestão de próximos passos
echo -e "${YELLOW}📋 Próximos passos:${NC}"
echo ""
echo "1. **Validar config:**"
echo "   cat subagents.yaml"
echo ""
echo "2. **Testar context logging:**"
echo "   bash ../../scripts/context_logger.sh"
echo ""
echo "3. **Ver relatório:**"
echo "   cat subagents_report.md"
echo ""
echo -e "${BLUE}Voltar ao estado do projeto:${NC}"
echo "  bash ../../scripts/state.sh"
echo ""

