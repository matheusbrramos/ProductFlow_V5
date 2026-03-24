#!/bin/bash

# ProductFlow_V5 — CHUNK 1.5: Loop de Feedback Entre Streams
# Uso: bash feedback_loop.sh (de dentro da pasta do projeto)
# Requer: prototype_feedback.md (preenchido com feedback de users)

set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
NC='\033[0m'

if [ ! -f "prototype_feedback.md" ]; then
    echo -e "${YELLOW}⚠️  prototype_feedback.md não encontrado${NC}"
    echo "Execute prototype_gen.sh primeiro para criar template"
    exit 1
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${MAGENTA}🔄 LOOP DE FEEDBACK ENTRE STREAMS (CHUNK 1.5)${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${YELLOW}📖 Lendo feedback de usuários...${NC}"
echo ""

# Contar feedback entries (usuários com feedback)
USER_COUNT=$(grep -c "^### Usuário" prototype_feedback.md || echo "0")
echo -e "  👥 Feedback de $USER_COUNT usuários encontrado"
echo ""

# Analisar padrões simples
echo -e "${YELLOW}🔍 Analisando padrões...${NC}"
echo ""

# Contar "o que funcionou bem" vs "o que não funcionou"
POSITIVE_COUNT=$(grep -c "^\s*- \[x\]" prototype_feedback.md || echo "0")
NEGATIVE_COUNT=$(grep -c "^\s*- \[ \]" prototype_feedback.md 2>/dev/null || echo "0")

echo "  ✅ Pontos positivos: $POSITIVE_COUNT menções"
echo "  ❌ Problemas encontrados: $NEGATIVE_COUNT menções"
echo ""

# Atualizar market_data.md com validação
echo -e "${BLUE}💾 Atualizando market_data.md com validação...${NC}"

if grep -q "## Market Score" market_data.md; then
    # Adicionar seção de validação se não existir
    if ! grep -q "## Validação com Protótipo" market_data.md; then
        cat >> market_data.md << 'EOF'

---

## Validação com Protótipo

**Data de Validação:** $(date)
**Número de Users:** [user_count]
**Feedback Summary:**
- Pontos positivos: [positive_count]
- Problemas encontrados: [negative_count]

**Pain Points Validados:**
- [ ] Pain point 1 validado com usuários
- [ ] Pain point 2 validado com usuários
- [ ] Pain point 3 validado com usuários

**Novos Insights Descobertos:**
(Cole aqui insights descobertos durante feedback rounds)

**Recomendação:**
[ ] Continuar com v2 do protótipo
[ ] Pivotar feature X
[ ] Validar mais com mais usuários
EOF

        sed -i "s/\[user_count\]/$USER_COUNT/g" market_data.md 2>/dev/null || sed -i '' "s/\[user_count\]/$USER_COUNT/g" market_data.md
        sed -i "s/\[positive_count\]/$POSITIVE_COUNT/g" market_data.md 2>/dev/null || sed -i '' "s/\[positive_count\]/$POSITIVE_COUNT/g" market_data.md
        sed -i "s/\[negative_count\]/$NEGATIVE_COUNT/g" market_data.md 2>/dev/null || sed -i '' "s/\[negative_count\]/$NEGATIVE_COUNT/g" market_data.md
    fi
fi

echo -e "${GREEN}✅ market_data.md atualizado com validação${NC}"
echo ""

# Atualizar spec_checklist.md com novos gaps descobertos
echo -e "${BLUE}💾 Verificando spec_checklist.md...${NC}"

if [ -f "spec_checklist.md" ]; then
    # Adicionar seção "Feedback-Driven Gaps" se não existir
    if ! grep -q "## Gaps Descobertos em Feedback" spec_checklist.md; then
        cat >> spec_checklist.md << 'EOF'

---

## 🎯 Gaps Descobertos em Feedback Round

**Data:** $(date)
**Fonte:** prototype_feedback.md

(Adicione aqui edge cases e gaps descobertos durante feedback)

EOF
    fi
    echo -e "${GREEN}✅ spec_checklist.md pronto para atualizações${NC}"
else
    echo -e "${YELLOW}⚠️  spec_checklist.md não encontrado${NC}"
fi

echo ""
echo -e "${YELLOW}📋 Próximos passos:${NC}"
echo ""
echo "1. **Revisar feedback em detail:**"
echo "   cat prototype_feedback.md"
echo ""
echo "2. **Atualizar market_data.md:**"
echo "   - Marcar pain points validados"
echo "   - Adicionar novos insights descobertos"
echo ""
echo "3. **Atualizar spec_checklist.md:**"
echo "   - Adicionar novos edge cases descobertos"
echo "   - Re-priorizar P0/P1/P2"
echo ""
echo "4. **Decidir próxima ação:**"
echo "   a) Se < 90% cobertura: rodar spec_validator.sh"
echo "   b) Se >= 90%: bash ../../scripts/orchestration_engine.sh"
echo "   c) Se mais feedback needed: criar prototypes/v2.figma"
echo ""

# Sugerir próxima ação automática
echo -e "${BLUE}🤖 Sugestão Automática:${NC}"

if [ $NEGATIVE_COUNT -gt 5 ]; then
    echo -e "  ${YELLOW}Muitos problemas encontrados ($NEGATIVE_COUNT). Considere:${NC}"
    echo "  → Criar v2 do protótipo com mudanças"
    echo "  → Coletar mais feedback antes de codegen"
    echo ""
    echo "  Próxima ação: bash ../../scripts/prototype_gen.sh (v2)"
elif [ $POSITIVE_COUNT -ge $USER_COUNT ]; then
    echo -e "  ${GREEN}Excelente feedback! Usuários validaram solução.${NC}"
    echo "  → Pronto para revisar specs"
    echo ""
    echo "  Próxima ação: bash ../../scripts/spec_validator.sh"
else
    echo -e "  ${YELLOW}Feedback misto. Revise gaps e atualize PRD.${NC}"
    echo "  → Iterar uma vez mais ou prosseguir com specs"
fi

echo ""
echo -e "${BLUE}Ver estado:${NC}"
echo "  bash ../../scripts/state.sh"
echo ""
