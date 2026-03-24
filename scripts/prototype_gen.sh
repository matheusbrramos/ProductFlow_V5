#!/bin/bash

# ProductFlow_V5 — CHUNK 1.3: Geração Automática de Wireframes FigJam
# Uso: bash prototype_gen.sh (de dentro da pasta do projeto)
# Requer: market_data.md (pesquisa) + prd.md (optativo)

set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
RED='\033[0;31m'
NC='\033[0m'

if [ ! -f "market_data.md" ]; then
    echo -e "${RED}❌ Erro: market_data.md não encontrado${NC}"
    echo "Execute research.sh primeiro:"
    echo "  bash ../../scripts/research.sh"
    exit 1
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${MAGENTA}🎨 GERAÇÃO DE PROTÓTIPO FIGJAM (CHUNK 1.3)${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Se PRD não existe, criar template interativo
if [ ! -f "prd.md" ]; then
    echo -e "${YELLOW}📝 PRD não encontrado. Vamos criar um rápido...${NC}"
    echo ""

    echo -e "${GREEN}Qual é o objetivo principal do produto?${NC}"
    read -p "  > " OBJECTIVE

    echo ""
    echo -e "${GREEN}Descreva 3-5 features principais (separadas por vírgula)${NC}"
    read -p "  > " FEATURES

    echo ""
    echo -e "${GREEN}Quem é o usuário principal? (ex: 'PMs de SaaS', 'Designers remotos')${NC}"
    read -p "  > " TARGET_USER

    # Criar PRD básico
    cat > prd.md << EOF
# Product Requirements Document

**Criado:** $(date -u +%Y-%m-%d)

## Objetivo Principal

$OBJECTIVE

## Usuário Principal

$TARGET_USER

## Features Principais

$(echo "$FEATURES" | tr ',' '\n' | awk '{print "- " $0}')

## Fluxo Principal

[Descrever como usuário vai usar o produto]

---

*Será expandido após validação com protótipo*
EOF

    echo -e "${GREEN}✅ prd.md criado${NC}"
fi

echo ""
echo -e "${BLUE}📋 Analisando market_data.md e prd.md...${NC}"

# Extrair informações
IDEA=$(grep "Ideia Principal" market_data.md -A 1 | tail -1)
TARGET=$(grep "Target User\|Usuário Principal" prd.md -A 1 | tail -1)
FEATURES=$(grep "## Features\|## features" prd.md -A 5 | tail -5 | grep "^-" || echo "Feature 1, Feature 2, Feature 3")

echo -e "  📌 Ideia: $IDEA"
echo -e "  👤 Target: $TARGET"
echo -e "  ✨ Features: $(echo "$FEATURES" | tr '\n' ',' | sed 's/,$//')"
echo ""

# Gerar template de feedback
cat > prototype_feedback.md << 'EOF'
# Prototype Feedback Template

**Versão:** v1
**Data de Feedback:** $(date)

## Feedback de Usuários

### Usuário 1
- **Nome/Categoria:**
- **O que funcionou bem:**
  - [ ]
  - [ ]
- **O que não funcionou:**
  - [ ]
  - [ ]
- **Sugestões:**
  - [ ]

### Usuário 2
- **Nome/Categoria:**
- **O que funcionou bem:**
  - [ ]
  - [ ]
- **O que não funcionou:**
  - [ ]
  - [ ]
- **Sugestões:**
  - [ ]

---

## Resumo de Padrões

**Pontos fortes mais citados:**
-

**Problemas mais citados:**
-

**Mudanças prioritárias para v2:**
1.
2.
3.

**Score de Validação (1-10):**

---

*Cole aqui ao rodar: bash ../../scripts/feedback_loop.sh*
EOF

# Mensagem informativa sobre FigJam
echo -e "${YELLOW}🎯 Próximas etapas:${NC}"
echo ""
echo -e "Idealmente, um wireframe FigJam seria gerado aqui via MCP Figma API."
echo -e "Por enquanto, aqui está o template:"
echo ""
echo -e "${GREEN}✅ Arquivos criados:${NC}"
echo "  📄 prd.md (Product Requirements)"
echo "  📄 prototype_feedback.md (para coletar feedback)"
echo ""
echo -e "${YELLOW}O que fazer agora:${NC}"
echo ""
echo "1. Acessar ${BLUE}https://figma.com${NC} e criar novo FigJam"
echo "2. Copiar link público do FigJam"
echo "3. Salvar em prototypes/ como v1.figma"
echo ""
echo -e "   Exemplo:"
echo "   echo 'https://figma.com/board/xyz...' > prototypes/v1.figma"
echo ""
echo "4. Compartilhar com 3-5 users e coletar feedback em prototype_feedback.md"
echo "5. Rodar feedback loop:"
echo "   bash ../../scripts/feedback_loop.sh"
echo ""
echo -e "${BLUE}Ver estado:${NC}"
echo "  bash ../../scripts/state.sh"
echo ""
