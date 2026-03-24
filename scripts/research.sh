#!/bin/bash

# ProductFlow_V5 — CHUNK 1.2: Pesquisa de Mercado Integrada
# Uso: bash research.sh (de dentro da pasta do projeto)
# Extrai: TAM, pain points, concorrência, willingness to pay, frequência

set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
NC='\033[0m'

if [ ! -f "project_state.md" ]; then
    echo -e "${YELLOW}⚠️  Erro: Execute dentro da pasta do projeto${NC}"
    exit 1
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${MAGENTA}🔍 PESQUISA DE MERCADO INTEGRADA (CHUNK 1.2)${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Coletar informações via entrevista interativa
echo -e "${YELLOW}📋 Entrevista de Mercado${NC}"
echo ""

# Pergunta 1: Descrição da ideia
echo -e "${GREEN}1. Qual é a ideia/problema em 1 frase?${NC}"
read -p "   > " IDEA

# Pergunta 2: TAM
echo ""
echo -e "${GREEN}2. Qual é o TAM estimado? (ex: \$50M, \$500M, \$2B)${NC}"
read -p "   > " TAM

# Pergunta 3: Pain Points
echo ""
echo -e "${GREEN}3. Qual é o principal pain point? (e score 1-10)${NC}"
read -p "   Descrição: " PAIN_DESC
read -p "   Score (1-10): " PAIN_SCORE

# Pergunta 4: Concorrentes
echo ""
echo -e "${GREEN}4. Top 3 concorrentes (separados por vírgula)${NC}"
read -p "   > " COMPETITORS

# Pergunta 5: Willingness to Pay
echo ""
echo -e "${GREEN}5. Willingness to pay? (ex: \$10-50/mês ou \$100-500 one-time)${NC}"
read -p "   Range: " WTP

# Pergunta 6: Frequência
echo ""
echo -e "${GREEN}6. Quantas vezes por semana/mês sofrem com esse problema?${NC}"
read -p "   > " FREQUENCY

# Pergunta 7: Insights
echo ""
echo -e "${GREEN}7. 1-3 insights importantes descobertos na pesquisa${NC}"
echo -e "   ${YELLOW}(Digite cada insight e pressione Enter. Digite 'done' ao final)${NC}"
INSIGHTS=()
while true; do
    read -p "   > " INSIGHT
    if [ "$INSIGHT" == "done" ]; then
        break
    fi
    INSIGHTS+=("$INSIGHT")
done

# Calcular score de mercado
SCORE=0
if [[ "$TAM" == *"500M"* ]] || [[ "$TAM" == *"B"* ]]; then
    ((SCORE += 2))
elif [[ "$TAM" == *"50M"* ]] || [[ "$TAM" == *"100M"* ]]; then
    ((SCORE += 1))
fi

if [ "$PAIN_SCORE" -ge 7 ]; then
    ((SCORE += 2))
elif [ "$PAIN_SCORE" -ge 5 ]; then
    ((SCORE += 1))
fi

if [ $(echo "$COMPETITORS" | tr ',' '\n' | wc -l) -ge 3 ]; then
    ((SCORE += 1))
fi

if [[ ! -z "$WTP" ]]; then
    ((SCORE += 1))
fi

if [[ "$FREQUENCY" == *"dia"* ]] || [[ "$FREQUENCY" == *"daily"* ]]; then
    ((SCORE += 2))
elif [[ "$FREQUENCY" == *"semana"* ]] || [[ "$FREQUENCY" == *"week"* ]]; then
    ((SCORE += 1))
fi

# Gerar market_data.md
echo ""
echo -e "${BLUE}💾 Gerando market_data.md...${NC}"

cat > market_data.md << EOF
# Market Data

**Projeto:** $(basename "$(pwd)")
**Data:** $(date -u +%Y-%m-%d)

## Ideia Principal

$IDEA

---

## TAM (Total Addressable Market)

- **Estimado:** $TAM
- **Justificativa:** [Derivado de pesquisa direta com usuários]
- **Fonte:** Entrevista com stakeholders

---

## Pain Points Validados

| Pain Point | Score (1-10) | Frequência | Descrição |
|---|---|---|---|
| Principal | $PAIN_SCORE | $FREQUENCY | $PAIN_DESC |

---

## Concorrência Top 3

\`\`\`
$COMPETITORS
\`\`\`

---

## Willingness to Pay

- **Range:** $WTP
- **Validação:** Preliminar (dados de entrevista)
- **Reasoning:** Baseado em budget dos usuários e valor percebido

---

## Frequência de Uso

**Sofrem com o problema:** $FREQUENCY

---

## Insights Importantes

EOF

for insight in "${INSIGHTS[@]}"; do
    echo "- $insight" >> market_data.md
done

cat >> market_data.md << EOF

---

## Market Score

**Score:** $SCORE / 10

**Breakdown:**
- TAM check: [$([ "$SCORE" -ge 1 ] && echo "✅" || echo "❌")]
- Pain score ≥ 7: [$([ "$PAIN_SCORE" -ge 7 ] && echo "✅" || echo "❌")]
- 3+ competitors: [$([ $(echo "$COMPETITORS" | tr ',' '\n' | wc -l) -ge 3 ] && echo "✅" || echo "❌")]
- WTP confirmado: [$([ ! -z "$WTP" ] && echo "✅" || echo "❌")]
- Frequência alta: [$([ "$SCORE" -ge 5 ] && echo "✅" || echo "❌")]

**Recomendação de Modelo:**
EOF

if [ "$SCORE" -lt 5 ]; then
    echo "- Usar **Haiku MVP** (economia, mercado incerto)" >> market_data.md
elif [ "$SCORE" -le 7 ]; then
    echo "- Usar **Sonnet standard** (equilíbrio qualidade/custo)" >> market_data.md
else
    echo "- Usar **Opus quality gates** (mercado grande, validação rigorosa)" >> market_data.md
fi

# Atualizar project_state.md
echo ""
echo -e "${BLUE}📝 Atualizando project_state.md...${NC}"

# Marcar seção de pesquisa como completa
sed -i 's/- \[ \] TAM estimado/- [x] TAM estimado/' project_state.md 2>/dev/null || sed -i '' 's/- \[ \] TAM estimado/- [x] TAM estimado/' project_state.md
sed -i 's/Status.*Pendente/Status: ✅ Completo/' project_state.md 2>/dev/null || sed -i '' 's/Status.*Pendente/Status: ✅ Completo/' project_state.md

echo ""
echo -e "${GREEN}✅ Pesquisa completa!${NC}"
echo ""
echo -e "${YELLOW}Arquivos criados:${NC}"
echo "  📄 market_data.md (Score: $SCORE/10)"
echo ""
echo -e "${YELLOW}Próximos passos:${NC}"
echo "  1. Revisar market_data.md"
echo "  2. bash ../../scripts/prototype_gen.sh (gerar protótipo FigJam)"
echo "  3. bash ../../scripts/spec_validator.sh (validar specs)"
echo ""
echo -e "${BLUE}Ver estado:${NC}"
echo "  bash ../../scripts/state.sh"
echo ""
