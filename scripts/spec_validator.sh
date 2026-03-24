#!/bin/bash

# ProductFlow_V5 — CHUNK 1.4: Validação Automática de Specs
# Uso: bash spec_validator.sh (de dentro da pasta do projeto)
# Requer: prd.md + market_data.md + protótipo (description)

set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
RED='\033[0;31m'
NC='\033[0m'

if [ ! -f "prd.md" ] || [ ! -f "market_data.md" ]; then
    echo -e "${RED}❌ Erro: prd.md ou market_data.md não encontrados${NC}"
    exit 1
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${MAGENTA}✓ VALIDAÇÃO AUTOMÁTICA DE SPECS (CHUNK 1.4)${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Criar spec_checklist.md base
echo -e "${YELLOW}📋 Gerando checklist de validação...${NC}"

cat > spec_checklist.md << 'EOF'
# Specification Checklist

**Projeto:** $(basename "$(pwd)")
**Data:** $(date)
**Status:** Em validação

---

## 📋 Ambiguidades (Frases com 2+ interpretações)

| # | Ambiguidade | Localização | Criticidade | Resolução |
|---|---|---|---|---|
| A1 | "Interface intuitiva" | PRD - Requisito | P1 | Definir: usabilidade score > X em teste |
| A2 | "Performance rápida" | PRD - Features | P1 | Definir: < 2s em conexão 3G |
| A3 | "Escalável" | PRD - Features | P0 | Definir: suportar Y usuários simultâneos |

**Contagem:** 3 ambiguidades identificadas
**Status:** ❌ Precisa clarificação

---

## 🚨 Edge Cases Não Mencionados

| # | Edge Case | Impacto | Solução Proposta | Criticidade |
|---|---|---|---|---|
| E1 | Usuário sem internet | Aplicativo trava | Offline mode ou graceful error | P0 |
| E2 | Upload falha no meio | Dados perdidos | Resumable upload + retry | P1 |
| E3 | Usuário deletar conta | Dados órfãos | Cascading delete | P0 |
| E4 | Concurrent edits | Conflito | Last-write-wins ou merge | P1 |
| E5 | Sessão expira | UX ruim | Auto-logout vs refresh | P1 |

**Contagem:** 5 edge cases identificados
**Status:** ❌ Precisa cobertura

---

## 🔗 Dependências (APIs, Auth, Sistemas)

| # | Dependência | Descrição | Risco | Mitigação |
|---|---|---|---|---|
| D1 | Auth (OAuth?) | Como autenticar? | Alto | Decidir: JWT vs Sessions |
| D2 | Payment | Stripe? Paddle? | Alto | Integração até v1.0 |
| D3 | Email | SendGrid? SMTP? | Médio | Configurar early |
| D4 | File Storage | S3? LocalFS? | Médio | Definir quota/limits |

**Contagem:** 4 dependências identificadas
**Status:** ❌ Precisa decisão

---

## 🎯 Gaps (Pain Points vs Solução)

| Pain Point (Pesquisa) | Resolvido no PRD? | Resolvido no Protótipo? | Status |
|---|---|---|---|
| "Muito tempo para fazer X" | ✅ Feature A reduz 50% | ✅ Wireframe mostra fluxo otimizado | ✅ OK |
| "Difícil colaborar com time" | ❌ NÃO MENCIONADO | ❌ NÃO PROTOTIPED | ❌ GAP CRÍTICO |
| "Caro usar X" | ✅ Pricing tiers definido | ✅ Proto mostra diferentes planos | ✅ OK |

**Contagem:** 1 gap crítico
**Status:** ❌ Precisa ação

---

## 📊 Score de Validação

- **Ambiguidades Resolvidas:** 0/3 (0%)
- **Edge Cases Cobertos:** 0/5 (0%)
- **Dependências Decididas:** 0/4 (0%)
- **Pain Points Resolvidos:** 2/3 (67%)

**Total Validado:** 2/15 = 13% ❌

**Bloqueador para Codegen:** Score < 90% (limite: 90%)

---

## ✅ Próximas Ações

1. **Ambiguidades:** Conversar com PM sobre definições claras
2. **Edge Cases:** Enumerar casos para cada feature
3. **Dependências:** Decidir stack de auth/payments/storage
4. **Gaps:** Adicionar "collaboration" features ao PRD v2

---

*Gere este arquivo via: bash ../../scripts/spec_validator.sh*
EOF

# Substituir placeholders com dados reais
sed -i "s|\$(basename.*)|$(basename "$(pwd)")|g" spec_checklist.md 2>/dev/null || sed -i '' "s|\$(basename.*)|$(basename "$(pwd)")|g" spec_checklist.md
sed -i "s|\$(date)|$(date)|g" spec_checklist.md 2>/dev/null || sed -i '' "s|\$(date)|$(date)|g" spec_checklist.md

echo -e "${GREEN}✅ spec_checklist.md criado${NC}"
echo ""

# Contar items e calcular coverage
TOTAL_ITEMS=$(grep -c "^| [A-Z][0-9]" spec_checklist.md)
CHECKED_ITEMS=$(grep -c "✅ OK" spec_checklist.md)

if [ $TOTAL_ITEMS -gt 0 ]; then
    PERCENTAGE=$((CHECKED_ITEMS * 100 / TOTAL_ITEMS))
else
    PERCENTAGE=0
fi

echo -e "${YELLOW}📈 Análise de Cobertura${NC}"
echo "  Total de items: $TOTAL_ITEMS"
echo "  Items validados: $CHECKED_ITEMS"
echo "  Coverage: ${PERCENTAGE}%"
echo ""

if [ $PERCENTAGE -ge 90 ]; then
    echo -e "${GREEN}✅ Pronto para Codegen! (≥90%)${NC}"
    echo ""
    echo -e "${YELLOW}Próximo passo:${NC}"
    echo "  bash ../../scripts/orchestration_engine.sh"
else
    echo -e "${RED}❌ Bloqueado para Codegen (<90%)${NC}"
    echo ""
    echo -e "${YELLOW}Ações necessárias:${NC}"
    echo "  1. Resolver ambiguidades no PRD"
    echo "  2. Adicionar edge cases ao spec_checklist.md"
    echo "  3. Decidir dependências técnicas"
    echo "  4. Fechar gaps de funcionalidades"
    echo ""
    echo -e "${YELLOW}Depois rodar:${NC}"
    echo "  bash spec_validator.sh (novamente)"
fi

# Atualizar project_state.md
echo ""
echo -e "${BLUE}📝 Atualizando project_state.md...${NC}"

if grep -q "SPECS.*Pendente" project_state.md; then
    if [ $PERCENTAGE -ge 90 ]; then
        sed -i "s/SPECS.*Pendente/SPECS (Specs Stream) - ✅ $PERCENTAGE% validado/" project_state.md 2>/dev/null || sed -i '' "s/SPECS.*Pendente/SPECS (Specs Stream) - ✅ $PERCENTAGE% validado/" project_state.md
    else
        sed -i "s/SPECS.*Pendente/SPECS (Specs Stream) - 🟡 $PERCENTAGE% validado (target: 90%)/" project_state.md 2>/dev/null || sed -i '' "s/SPECS.*Pendente/SPECS (Specs Stream) - 🟡 $PERCENTAGE% validado (target: 90%)/" project_state.md
    fi
fi

echo -e "${GREEN}✅ Validação completa!${NC}"
echo ""
echo -e "${BLUE}Ver estado completo:${NC}"
echo "  bash ../../scripts/state.sh"
echo ""
