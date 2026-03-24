#!/bin/bash

# ProductFlow_V5 — Context Logging (CHUNK 2.4)
# Registra uso de contexto por fase, analisa e gera relatório
# Uso: bash context_logger.sh (de dentro da pasta do projeto)

set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${MAGENTA}📊 LOGGING DE CONTEXTO (CHUNK 2.4)${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

LOG_FILE="project_context.jsonl"
REPORT_FILE="context_usage_report.md"

# Se Python disponível, usar logger completo
if command -v python3 &> /dev/null; then
    echo -e "${YELLOW}🔍 Analisando context usage...${NC}"
    echo ""

    python3 "../../scripts/lib/context_logger.py" \
        --log "$LOG_FILE" \
        --analyze \
        --report

    echo ""
    echo -e "${GREEN}✅ Relatório gerado: $REPORT_FILE${NC}"

else
    echo -e "${YELLOW}⚠️  Python não disponível. Criando relatório manual...${NC}"
    echo ""

    # Fallback: criar relatório básico em bash
    cat > "$REPORT_FILE" << EOF
# Context Usage Report

**Gerado:** $(date)
**Log File:** $LOG_FILE

---

## Sumário

Este relatório seria populado automaticamente com dados de context usage.

Para análise completa, certifique-se de ter Python3 instalado:
\`\`\`bash
python3 --version
\`\`\`

---

## Como Funciona CHUNK 2.4

### Objetivo
Registrar cada uso de contexto durante fases, tokens gastos, e alertar se exceder 25k (⚠️) ou 35k (🔴).

### Log Format
JSONL (JSON Lines) — cada linha é uma entrada de contexto:
\`\`\`json
{
  "timestamp": "2026-03-24T10:00:00",
  "phase": "pesquisa",
  "model": "Claude Haiku",
  "content_chars": 15000,
  "content_tokens": 3750,
  "actual_tokens_used": 3800,
  "metadata": { "attempt": 1 }
}
\`\`\`

### Integração
Cada script (research.sh, prototype_gen.sh, spec_validator.sh) registra:
1. Quanto contexto foi enviado
2. Qual modelo processou
3. Quantos tokens foram estimados/gastos

### Análise
\`\`\`bash
python3 ../../scripts/lib/context_logger.py --log $LOG_FILE --analyze
\`\`\`

Retorna:
- Total de tokens gastos
- Por fase / por modelo
- Alertas se > 25k ou > 35k

### Relatório
\`\`\`bash
python3 ../../scripts/lib/context_logger.py --log $LOG_FILE --report
\`\`\`

Gera: context_usage_report.md com visualização de timeline

---

## Próximos Passos

1. **Instalar Python3:**
   \`\`\`bash
   python3 --version  # Deve ser >= 3.8
   \`\`\`

2. **Rerun com Python:**
   \`\`\`bash
   bash ../../scripts/context_logger.sh
   \`\`\`

3. **Monitor context em tempo real:**
   \`\`\`bash
   tail -f $LOG_FILE | jq '.actual_tokens_used'
   \`\`\`

---

**CHUNK 2.4 — Logging de Contexto**
*Rastreie, analise e otimize uso de contexto em cada fase*

EOF

    echo -e "${GREEN}✅ Relatório template criado: $REPORT_FILE${NC}"
    echo ""
    echo -e "${YELLOW}💡 Dica: Instale Python3 para análise completa${NC}"

fi

echo ""

# Mostrar arquivo de log atual
if [ -f "$LOG_FILE" ]; then
    ENTRY_COUNT=$(wc -l < "$LOG_FILE")
    echo -e "${CYAN}📝 Log atual:${NC}"
    echo "  Arquivo: $LOG_FILE"
    echo "  Entradas: $ENTRY_COUNT"
    echo ""
fi

echo -e "${YELLOW}📋 Próximos passos:${NC}"
echo ""
echo "1. **Ver relatório:**"
echo "   cat $REPORT_FILE"
echo ""
echo "2. **Analisar context por fase:**"
echo "   python3 ../../scripts/lib/context_logger.py --log $LOG_FILE --analyze"
echo ""
echo "3. **Log test entry:**"
echo "   python3 ../../scripts/lib/context_logger.py --log $LOG_FILE --phase test_phase --model Haiku --tokens 5000"
echo ""
echo -e "${BLUE}Voltar ao estado do projeto:${NC}"
echo "  bash ../../scripts/state.sh"
echo ""

