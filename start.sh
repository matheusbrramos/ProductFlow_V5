#!/bin/bash

# ProductFlow_V5 — Iniciar novo projeto
# Uso: bash start.sh "Nome do Projeto"

set -e

PROJECT_NAME="${1:-Nova Ideia}"
PROJECT_SLUG=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')
PROJECT_DIR="projects/$PROJECT_SLUG"

# Cores para output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 ProductFlow_V5 — Novo Projeto${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "Nome: ${GREEN}$PROJECT_NAME${NC}"
echo -e "Slug: ${GREEN}$PROJECT_SLUG${NC}"
echo -e "Pasta: ${YELLOW}$PROJECT_DIR${NC}"
echo ""

# Criar estrutura de pastas
mkdir -p "$PROJECT_DIR"/{prototypes,decisions,outcomes,logs,code}
cd "$PROJECT_DIR"

# Criar project_state.md inicial
cat > project_state.md << 'EOF'
# Project State — [PROJETO]

**Última atualização:** $(date)
**Status:** 🟡 Iniciado

## 1. PESQUISA (Research Stream)

- [ ] TAM estimado
- [ ] Pain points (1-10 validado)
- [ ] Top 3 concorrentes
- [ ] Willingness to pay
- [ ] Frequência do problema
- [ ] Insights importantes

**Arquivo:** `market_data.md`
**Status:** ⏳ Pendente

---

## 2. PROTÓTIPO (Prototype Stream)

- [ ] Wireframe FigJam gerado
- [ ] User flows definidos
- [ ] Feedback de usuários coletado
- [ ] Iterações completadas

**Arquivo:** `prototypes/v1.figma`
**Status:** ⏳ Pendente

---

## 3. SPECS (Specs Stream)

- [ ] PRD completo
- [ ] Ambiguidades resolvidas
- [ ] Edge cases documentados
- [ ] Checklist de validação 90%+

**Arquivo:** `spec_checklist.md`
**Status:** ⏳ Pendente

---

## Próximo Passo

Rodar pesquisa integrada:
```bash
bash ../../scripts/research.sh
```

EOF

# Criar market_data.md template
cat > market_data.md << 'EOF'
# Market Data

**Projeto:** [NOME]
**Data:** $(date -u +%Y-%m-%d)

## TAM (Total Addressable Market)

- **Estimado:** $[?] (range: $X — $Y)
- **Justificativa:** [Como chegou nesse número?]
- **Fonte:** [Pesquisa, analogia, validação?]

---

## Pain Points

| Pain Point | Score (1-10) | Frequência | Descrição |
|---|---|---|---|
| | | | |
| | | | |
| | | | |

---

## Concorrência Top 3

| Concorrente | Oferta | Preço | Gaps | Vantagem Nossa |
|---|---|---|---|---|
| | | | | |
| | | | | |
| | | | | |

---

## Willingness to Pay

- **Range:** $[X] — $[Y] / [mês/ano/one-time]
- **Validação:** [Quantos users confirmaram?]
- **Reasoning:** [Por que essa faixa?]

---

## Frequência de Uso

- **Sofre com problema:** [X] vezes por semana/mês
- **Severidade quando acontece:** [Descrição]
- **Impact de resolver:** [Tempo poupado, frustração reduzida, etc]

---

## Insights Importantes

- [Insight 1]
- [Insight 2]
- [Insight 3]

---

## Score de Mercado (0-10)

**Score:** [?]

Fórmula:
- TAM > $500M → +2
- TAM > $50M → +1
- Pain score > 7 → +2
- Willingness to pay confirmado → +1
- 3+ concorrentes com gaps → +1
- Frequência 3x+ por semana → +1

**Decisão de Modelo:**
- Score < 5 → Haiku MVP
- Score 5-7 → Sonnet standard
- Score > 8 → Opus quality gates

EOF

echo -e "${GREEN}✅ Estrutura criada${NC}"
echo ""
echo -e "${YELLOW}📋 Próximos passos:${NC}"
echo "1. Editar project_state.md com seus detalhes"
echo "2. Rodar pesquisa integrada:"
echo "   $ bash ../../scripts/research.sh"
echo ""
echo -e "${BLUE}📊 Ver estado atual:${NC}"
echo "   $ bash ../../scripts/state.sh"
echo ""
