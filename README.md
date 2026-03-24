# ProductFlow_V5

**Framework para validar ideias de produto em paralelo — Pesquisa + Protótipo + Specs simultâneos.**

[![GitHub](https://img.shields.io/badge/GitHub-ProductFlow_V5-black?logo=github)](https://github.com/matheusbrramos/ProductFlow_V5)
[![Status](https://img.shields.io/badge/Status-FASE%201%20Completa-brightgreen)](./DELIVERY.md)
[![License](https://img.shields.io/badge/License-MIT-blue)](./LICENSE)

---

## 🎯 O Problema

Produtos são desenvolvidos **sequencialmente**: ideia → entrevista → PRD → blueprint → código. Resultado: **70% fracassam** porque ninguém validou se o problema realmente existe ou se a solução funciona.

**ProductFlow_V5 resolve isso rodando tudo em paralelo:**

```
Pesquisa                Protótipo              Specs
(TAM, pain, WTP)  +     (wireframe)        +   (edge cases)
        │                    │                      │
        └────────────────┬───┴──────────────────┬──┘
                         │
                   ✅ 90% Validado?
                    SIM → Codegen
                    NÃO → Iterar
```

---

## ✨ O Que É

ProductFlow_V5 é um **framework completo** que:

- ✅ Roda **pesquisa, protótipo e specs em paralelo** (não sequencial)
- ✅ Valida ideias **com usuários antes de código**
- ✅ Calcula **market_score** (0-10) quantificável
- ✅ Decide automaticamente: **Haiku vs Sonnet vs Opus** (baseado em TAM)
- ✅ Detecta **context rot** (fases > 25k tokens)
- ✅ Bloqueia codegen se **< 90% specs validadas**
- ✅ Pronto para **múltiplos projetos** em paralelo

---

## 🚀 Quick Start

### 1. Clone
```bash
git clone https://github.com/matheusbrramos/ProductFlow_V5.git
cd ProductFlow_V5
```

### 2. Criar novo projeto
```bash
bash start.sh "Nome do Seu Produto"
cd projects/nome-do-seu-produto
```

### 3. Executar FASE 1 (2 horas)
```bash
# Pesquisa integrada (30min)
bash ../../scripts/research.sh

# Gerar protótipo FigJam (20min)
bash ../../scripts/prototype_gen.sh

# Validar specs (15min)
bash ../../scripts/spec_validator.sh

# Processar feedback (10min)
bash ../../scripts/feedback_loop.sh

# Decidir modelo (5min)
bash ../../scripts/orchestration_engine.sh

# Ver progresso
bash ../../scripts/state.sh
```

---

## 📊 Os 3 Streams

### 1️⃣ Pesquisa
```bash
bash research.sh
```
**Coleta interativamente:**
- TAM (Total Addressable Market)
- Pain points (score 1-10)
- Top 3 concorrentes
- Willingness to pay
- Frequência do problema
- Insights importantes

**Output:** `market_data.md` + market_score calculado (0-10)

---

### 2️⃣ Protótipo
```bash
bash prototype_gen.sh
```
**Gera:**
- `prd.md` (se não existir)
- Wireframe FigJam navegável
- Template de feedback

---

### 3️⃣ Specs
```bash
bash spec_validator.sh
```
**Identifica:**
- Ambiguidades no PRD
- Edge cases não cobertos
- Dependências técnicas
- Gaps (pain points vs solução)

**Bloqueador:** < 90% = não deixa rodar codegen

---

## 📁 Estrutura

```
ProductFlow_V5/
├── improvement_plan/              # Documentação técnica
│   ├── 00_BLUEPRINT.md           # Visão geral
│   ├── 01_CHUNKS.md              # Epics detalhadas
│   ├── 02_STEPS.md               # Steps práticos
│   ├── 03_PROMPTS.md             # Prompts para agentes
│   ├── 04_TODO.md                # Checklist executável
│   └── ARCHITECTURE.md           # Diagramas técnicos
│
├── scripts/                       # Automação
│   ├── start.sh                  # Iniciar projeto
│   ├── research.sh               # Pesquisa (CHUNK 1.2)
│   ├── prototype_gen.sh          # Protótipo (CHUNK 1.3)
│   ├── spec_validator.sh         # Validação (CHUNK 1.4)
│   ├── feedback_loop.sh          # Feedback (CHUNK 1.5)
│   ├── orchestration_engine.sh   # Orquestração (CHUNK 2.2)
│   ├── state.sh                  # Dashboard
│   └── lib/
│       └── context_rot_detector.py
│
├── templates/                     # Templates reutilizáveis
│   ├── market_data.md
│   ├── prd.md
│   ├── prototype_feedback.md
│   ├── spec_checklist.md
│   └── decisions/why_phase_N.md
│
├── projects/                      # Pasta raiz de projetos
│   └── [seu-produto]/
│       ├── project_state.md
│       ├── market_data.md
│       ├── prd.md
│       ├── spec_checklist.md
│       ├── prototypes/
│       ├── decisions/
│       └── ...
│
├── CLAUDE.md                      # Config do projeto
├── README.md                      # Este arquivo
├── DELIVERY.md                    # Sumário de entrega
└── .gitignore
```

---

## 🎓 Fases Implementadas

### ✅ FASE 1: Infraestrutura + Streams Paralelos
- [x] CHUNK 1.1 — Dashboard Integrado
- [x] CHUNK 1.2 — Pesquisa de Mercado
- [x] CHUNK 1.3 — Prototipagem FigJam
- [x] CHUNK 1.4 — Validação de Specs
- [x] CHUNK 1.5 — Loop de Feedback

### ✅ FASE 2: Context Rot Prevention (Parcial)
- [x] CHUNK 2.1 — Context Rot Detection
- [x] CHUNK 2.2 — Orquestração de Modelos
- [ ] CHUNK 2.3 — Subagentes Declarativos
- [ ] CHUNK 2.4 — Logging de Contexto

### 🔲 FASE 3: Loop de Aprendizado (Planejado)
- [ ] CHUNK 3.1 — Persistência de Decisões
- [ ] CHUNK 3.2 — Git Hooks
- [ ] CHUNK 3.3 — Outcomes Tracking
- [ ] CHUNK 3.4 — Learning Loop

---

## 💡 Como Funciona

### Exemplo: Validar ideia de "Dashboard para Startups"

```bash
# 1. Criar projeto
bash start.sh "Dashboard para Startups"
cd projects/dashboard-para-startups

# 2. Pesquisa (PM responde 7 perguntas)
bash ../../scripts/research.sh
# → Extrai: TAM $200M, pain score 8, 3 competitors, WTP $50-200/mês
# → Calcula: market_score = 7/10 (boa oportunidade)

# 3. Protótipo (gera wireframe low-fi)
bash ../../scripts/prototype_gen.sh
# → Cria FigJam com 5 telas principais
# → PM compartilha com 5 usuários (coleta feedback)

# 4. Specs (identifica gaps)
bash ../../scripts/spec_validator.sh
# → Encontra: "Integração com Stripe?" (ambiguidade)
# → Encontra: "E se usuário deletar conta?" (edge case)
# → Marca: 85% validado (precisa mais)

# 5. Feedback loop (atualiza specs)
bash ../../scripts/feedback_loop.sh
# → PM coloca feedback dos usuários
# → Sistema atualiza market_data.md + spec_checklist.md
# → Agora 92% validado ✅

# 6. Orquestração (decide modelo)
bash ../../scripts/orchestration_engine.sh
# → Decisão: market_score=7 + TAM=$200M → Use Sonnet
# → Gera: orchestration.md com justificativa

# 7. Pronto para codegen!
bash codegen.sh  # (próxima versão)
```

---

## 📊 Impacto Esperado

| Métrica | Antes | Depois | Ganho |
|---------|-------|--------|-------|
| **Tempo até codegen** | 4 semanas | 2 semanas | -50% ⏱️ |
| **Hit rate** (produtos que vendem) | 30% | 70%+ | +140% 🎯 |
| **Desperdício de contexto** | Alto | Gerenciado | Controlado 🤖 |
| **Validação com usuários** | Pós-código | Pré-código | Antecipado ✅ |

---

## 🛠️ Tech Stack

- **Orquestração:** Bash + Python3
- **Protótipos:** FigJam (via MCP Figma)
- **Storage:** Markdown + Git
- **Agentes:** Claude Haiku (research), Sonnet (specs), Opus (review)
- **Analytics:** Python + CSV/JSON

---

## 📖 Documentação

| Documento | Para |
|-----------|------|
| [README.md](./README.md) | Começar aqui |
| [DELIVERY.md](./DELIVERY.md) | Sumário de entrega |
| [improvement_plan/00_BLUEPRINT.md](./improvement_plan/00_BLUEPRINT.md) | Visão geral arquitetural |
| [improvement_plan/02_STEPS.md](./improvement_plan/02_STEPS.md) | Steps práticos de cada chunk |
| [improvement_plan/03_PROMPTS.md](./improvement_plan/03_PROMPTS.md) | Prompts para agentes |
| [improvement_plan/04_TODO.md](./improvement_plan/04_TODO.md) | Checklist de implementação |
| [improvement_plan/ARCHITECTURE.md](./improvement_plan/ARCHITECTURE.md) | Diagramas técnicos e DAGs |
| [CLAUDE.md](./CLAUDE.md) | Configuração do projeto |

---

## 🚀 Roadmap

**v1.0 (Agora):** FASE 1 + 2 (Infraestrutura + Context Rot)
**v1.1 (Próximas 2 semanas):** `codegen.sh` + MCP Figma integração completa
**v1.2 (Semana 5-6):** FASE 2 completa (logging, git hooks)
**v2.0 (Semana 7+):** FASE 3 (outcomes tracking, learning loop, sugestões automáticas)

---

## 💬 Princípios

1. **Paralelismo** — Pesquisa, protótipo e specs rodam juntos
2. **Validação Early** — Testar com usuários antes de código
3. **Context Awareness** — Fases < 25k tokens para evitar degradação
4. **Transparência** — Logs de "por quê" cada decisão
5. **Learning Loop** — Histórico alimenta próximos projetos

---

## 👥 Contribuindo

Este é um projeto pessoal de [Matheus Ramos](https://github.com/matheusbrramos), Head de Produtos na Q2 Ingressos.

Sugestões? Abra uma [issue](https://github.com/matheusbrramos/ProductFlow_V5/issues).

---

## 📄 License

MIT — Use livremente, credite quando usar em público.

---

**ProductFlow_V5** — Building Products That Matter ✨

*Reduzir 70% de produtos que ninguém quer através de validação paralela.*

---

**v1.0.0** • [2026-03-24](./DELIVERY.md) • [GitHub](https://github.com/matheusbrramos/ProductFlow_V5)
