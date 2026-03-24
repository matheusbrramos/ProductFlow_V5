# ProductFlow_V5 — Arquitetura Técnica (ARCHITECTURE.md)

---

## 1. Visão Geral — Os 3 Streams em Paralelo

```
┌─────────────────────────────────────────────────────────────┐
│                   PROJECT INITIALIZATION                     │
│                    bash start.sh "Nome"                      │
└────────────────────┬────────────────────────────────────────┘
                     │
       ┌─────────────┴─────────────┬──────────────────┐
       ▼                           ▼                  ▼
   PESQUISA (1h)          PROTÓTIPO (2h)      SPECS (1h)
   Stream 1               Stream 2             Stream 3

research.sh         prototype_gen.sh      spec_validator.sh
   │                     │                    │
   ▼                     ▼                    ▼
market_data.md    prototypes/v*.figma  spec_checklist.md
(TAM, pain,       (wireframe)          (edge cases, gaps)
 WTP, score)
   │                     │                    ▼
   └────────────────┬────┴──────────────────┬─┘
                    │
              ✅ 90% Validação?
              SIM → Pronto para Codegen
              NÃO → feedback_loop.sh (volta aos 3 streams)

        ┌────────────────────────────────────┐
        ▼                                    ▼
   orchestration_engine.sh         codegen.sh
   (Haiku vs Sonnet vs Opus)        (Build MVP)
```

---

## 2. Fluxo de Dados Detalhado

### 2.1 Pesquisa (CHUNK 1.2)

**Input:** Entrevista interativa do PM
**Output:** `market_data.md`

```
research.sh
├── Pergunta 1: Ideia
├── Pergunta 2: TAM
├── Pergunta 3: Pain points (1-10)
├── Pergunta 4: Competitors
├── Pergunta 5: Willingness to Pay
├── Pergunta 6: Frequência
└── Pergunta 7: Insights
    │
    ├─→ Calcula market_score (0-10)
    │
    └─→ Gera market_data.md
        ├── TAM section
        ├── Pain points table
        ├── Competitors table
        ├── WTP range
        ├── Frequency
        ├── Insights list
        └── Market score + recomendação de modelo

Tempo: 30min
Owner: PM + Claude Haiku (extração automática opcional)
```

---

### 2.2 Protótipo (CHUNK 1.3)

**Input:** `market_data.md` + `prd.md` (ou template)
**Output:** FigJam wireframe em `prototypes/v1.figma`

```
prototype_gen.sh
├── Lê: market_data.md (pain points → features)
├── Lê: prd.md (objetivo, features, fluxos)
│
├─→ Claude Haiku extrai:
│   ├── User personas (de pain points)
│   ├── User journeys (de fluxos no PRD)
│   ├── Key screens (de features)
│   └── Wireframe structure
│
├─→ MCP Figma: generate_diagram (wireframe low-fi)
│   └── Cria FigJam navegável
│
├─→ Salva em prototypes/v1.figma
│
└─→ Cria prototype_feedback.md template

Tempo: 20min (após pesquisa/PRD pronto)
Owner: Claude Haiku (via MCP Figma)
Context: 5-8k tokens
```

---

### 2.3 Validação de Specs (CHUNK 1.4)

**Input:** `prd.md` + `prototypes/v1.figma` + `market_data.md`
**Output:** `spec_checklist.md` com % de cobertura

```
spec_validator.sh
├── Lê: prd.md (requirements)
├── Lê: prototypes/v1.figma (design)
├── Lê: market_data.md (pain points, goals)
│
├─→ Claude Sonnet identifica:
│   ├── Ambiguidades (frases com 2+ interpretações)
│   ├── Edge cases (cenários não cobertos)
│   ├── Dependências (APIs, auth, integrations)
│   └── Gaps (pain points não resolvidos)
│
├─→ Gera spec_checklist.md
│   ├── 40-50 checklist items
│   ├── Status: ✅ OK / ❌ Problem / ❓ Needs clarification
│   ├── Criticidade: P0 / P1 / P2
│   └── % de cobertura calculado
│
└─→ Bloqueia codegen se < 90%

Tempo: 15min
Owner: Claude Sonnet
Context: 10-15k tokens (PRD + proto description + market data)
Bloqueador: Só roda após protótipo pronto
```

---

### 2.4 Loop de Feedback (CHUNK 1.5)

**Input:** `prototype_feedback.md` (preenchido por PM com feedback de users)
**Output:** Atualizações em cascata (market_data.md, spec_checklist.md, novo protótipo)

```
feedback_loop.sh
├── Lê: prototype_feedback.md (3-5 usuarios, feedbacks)
│
├─→ Claude Haiku analisa padrões:
│   ├── Quantos usuarios mencionaram cada ponto?
│   ├── Pain points foram realmente resolvidos? (validação)
│   ├── Novos problems descobertos?
│   └── Prioridade de mudanças (P0/P1/P2)
│
├─→ Atualiza market_data.md:
│   ├── Adiciona "Validated: Yes/No" para pain points
│   ├── Adiciona novos insights descobertos
│   └── Recalcula market_score se necessário
│
├─→ Atualiza spec_checklist.md:
│   ├── Marca items que foram validados ✅
│   ├── Adiciona novos edge cases descobertos
│   └── Recalcula % de cobertura
│
└─→ Sugere:
    ├── Mudanças para v2 do protótipo
    ├── Se cobertura < 90%, quais gaps resolver
    └── Próximos passos (mais iterações? pronto para codegen?)

Tempo: 10min (assincrono)
Owner: Claude Haiku (análise), PM (decisions)
Context: 8-12k tokens
Trigger: PM roda após coletar feedback
```

---

## 3. Dependências de Scripts (DAG)

```
start.sh (cria projeto)
    ↓
research.sh (entrevista, market_data.md)
    ├─→ state.sh (mostra progress)
    │
    ├─→ prototype_gen.sh (precisa market_data.md)
    │   ├─→ state.sh
    │   └─→ feedback_loop.sh (após protótipo)
    │
    └─→ spec_validator.sh (precisa prd.md + protótipo)
        ├─→ state.sh
        └─→ feedback_loop.sh (após feedback)
            ├─→ Atualiza market_data.md
            ├─→ Atualiza spec_checklist.md
            └─→ Sugere prototype_gen.sh v2

orchestration_engine.sh (após specs validadas)
    ├─→ context_rot_detector.py (verifica tokens)
    └─→ Decide: Haiku / Sonnet / Opus

codegen.sh (após orquestração)
    └─→ decision_logger.py (gera why_phase_*.md)
```

---

## 4. Decision Tree — Orquestração de Modelos

```
START: Projeto novo
    │
    ├─→ Ler market_data.md
    │   ├── TAM
    │   └── market_score
    │
    ├─→ Ler blueprint.md (fases, estimated context)
    │
    ├─→ context_rot_detector.py
    │   ├── Phase 1: 8k tokens ✅ OK
    │   ├── Phase 2: 22k tokens ✅ OK
    │   └── Phase 3: 28k tokens ⚠️ CAUTION (> 25k)
    │       └─→ Recomenda: splittar em Phase 3a + 3b
    │
    └─→ Decision Tree:

    IF market_score < 5 AND TAM < $50M:
        → Fase 1: Haiku (economia)
        → Fase 2: Haiku (se context < 15k)
        → Fase 3+: Sonnet (if context grows)

    IF market_score 5-7 OR TAM $50M-$500M:
        → Fase 1: Sonnet (quality)
        → Fase 2: Sonnet
        → Fase 3+: Opus (review/refinement)

    IF market_score > 8 OR TAM > $500M:
        → Fase 1: Opus (quality gates)
        → Fase 2: Opus
        → Fase 3+: Opus + human review
        → Considera: Human PdM involvement na decisão

Output: orchestration.md
├── Phase 1: Model, Context tokens, Rationale
├── Phase 2: Model, Context tokens, Rationale
├── Phase 3: Model, Context tokens, Rationale, Splits recomendados
└── Total cost estimate
```

---

## 5. Paralelismo Possível

### Semana 1-2 (FASE 1 Foundation)

```
Dia 1:
  research.sh (1h)
  └─ market_data.md criado

Dia 2-3:
  ┌─ prototype_gen.sh (paralelo com specs prep)
  │ └─ FigJam v1 criado
  │
  └─ PM prepara PRD (paralelo com pesquisa cleanup)

Dia 4:
  spec_validator.sh (depende de protótipo)
  └─ spec_checklist.md criado

Dia 5:
  feedback_loop.sh (coleta feedback, processa)
  └─ Updates em cascata
```

**Economia com paralelismo:** 8h → 5h (37.5% mais rápido)

---

## 6. Storage Layout e Conventions

```
ProjectFlow_V5/
├── improvement_plan/
│   ├── 00_BLUEPRINT.md       ← Visão geral
│   ├── 01_CHUNKS.md          ← Epics
│   ├── 02_STEPS.md           ← Steps executáveis
│   ├── 03_PROMPTS.md         ← Prompts para agentes
│   ├── 04_TODO.md            ← Checklist
│   └── ARCHITECTURE.md       ← Este arquivo
│
├── scripts/
│   ├── start.sh              ← Iniciar projeto novo
│   ├── research.sh           ← CHUNK 1.2: Pesquisa
│   ├── prototype_gen.sh      ← CHUNK 1.3: Protótipo
│   ├── spec_validator.sh     ← CHUNK 1.4: Specs
│   ├── feedback_loop.sh      ← CHUNK 1.5: Feedback
│   ├── orchestration_engine.sh ← CHUNK 2.2: Orquestração
│   ├── state.sh              ← Ver progresso
│   └── lib/
│       ├── context_rot_detector.py    ← CHUNK 2.1
│       ├── market_research.py         ← Analytics de mercado
│       ├── figma_generator.py         ← MCP Figma integration
│       ├── spec_checker.py            ← Edge cases
│       ├── feedback_analyzer.py       ← Pattern detection
│       └── decision_logger.py         ← why_phase_*.md
│
├── templates/
│   ├── market_data.md        ← Template de pesquisa
│   ├── prd.md                ← Template de PRD
│   ├── prototype_feedback.md ← Template de feedback
│   ├── spec_checklist.md     ← Template de validação
│   └── decisions/
│       └── why_phase_N.md    ← Template de decisão
│
├── projects/                 ← Pasta raiz de todos os projetos
│   └── [project-slug]/
│       ├── project_state.md  ← Dashboard de status
│       ├── market_data.md    ← Dados de mercado
│       ├── prd.md            ← Product requirements
│       ├── blueprint.md      ← Arquitetura técnica
│       ├── spec_checklist.md ← Validação
│       ├── prototypes/       ← FigJam links (v1, v2, etc)
│       ├── decisions/        ← why_phase_1.md, etc
│       ├── outcomes/         ← Resultados 3-6mo depois
│       ├── logs/             ← Context logs, etc
│       └── code/             ← Código gerado
│
└── docs/
    ├── INTEGRATION_GUIDE.md  ← Como usar o sistema
    ├── TROUBLESHOOTING.md    ← FAQs e debug
    └── examples/
        ├── market_data_example.md
        └── spec_checklist_example.md
```

**Convenção:** Cada projeto em `projects/[project-slug]/` é standalone e completo.

---

## 7. Context Management

```
Por Fase (Estimativa Haiku/Sonnet):

CHUNK 1.1 (Dashboard):
  - CLAUDE.md: 0.5k
  - Código: 0.5k
  Total: ~1k ✅ Haiku OK

CHUNK 1.2 (Pesquisa):
  - CLAUDE.md: 0.5k
  - Interview script: 1k
  - market_data template: 0.5k
  - Analise: 2k
  Total: ~4k ✅ Haiku OK

CHUNK 1.3 (Protótipo):
  - CLAUDE.md: 0.5k
  - market_data.md: 1.5k
  - PRD: 2-3k
  - Gen wireframe: 3k
  Total: ~8k ✅ Haiku OK (< 15k limit)

CHUNK 1.4 (Specs):
  - CLAUDE.md: 0.5k
  - PRD: 2-3k
  - Protótipo description: 1.5k
  - market_data.md: 1.5k
  - Edge cases analysis: 4k
  Total: ~10k ✅ Sonnet OK (< 25k limit)

CHUNK 1.5 (Feedback):
  - CLAUDE.md: 0.5k
  - Feedback x3 users: 2k
  - Previous market_data: 1.5k
  - Pattern analysis: 2k
  Total: ~6k ✅ Haiku OK
```

**Regra:** Se fase > 25k tokens, splitar ou usar Opus.

---

## 7. Orquestração de Subagentes (CHUNK 2.3)

```
subagents_engine.sh lê YAML config e coordena múltiplos agentes:

subagents.yaml
├── parallel:
│   ├── research_agent (Claude Haiku, 8k tokens)
│   └── prototype_agent (Claude Haiku, 8k tokens)
│       [rodam juntos, sem dependência]
│
└── sequential:
    ├── specs_validator (Claude Sonnet, 15k tokens)
    │   [depends_on: prototype_agent]
    │
    └── feedback_processor (Claude Haiku, 10k tokens)
        [depends_on: specs_validator]

Orquestrador:
1. Inicia agentes paralelos em threads
2. Aguarda conclusão
3. Inicia sequenciais em ordem de dependência
4. Retorna relatório: {completed, tokens, timeline}

Arquivo de execução: subagents_orchestrator.py
- Lê YAML config
- Executa via ThreadPoolExecutor
- Respeita depends_on
- Agrega relatório de tokens
```

---

## 8. Logging de Contexto (CHUNK 2.4)

```
context_logger.py registra JSONL com cada execução:

project_context.jsonl
└── [
    {"timestamp": "...", "phase": "pesquisa", "model": "Haiku",
     "content_chars": 5000, "actual_tokens_used": 1250, "metadata": {...}},
    {"timestamp": "...", "phase": "protótipo", "model": "Haiku",
     "content_chars": 8000, "actual_tokens_used": 2000, "metadata": {...}},
    ...
  ]

Análise agregada:
- Por fase: {count, total_tokens, avg_tokens}
- Por modelo: {count, total_tokens}
- Alertas:
  * ⚠️ Se fase > 25k tokens (warning)
  * 🔴 Se fase > 35k tokens (crítico, MUST split)

Relatório: context_usage_report.md
├── Total tokens gastos
├── Breakdown por fase + modelo
├── Timeline de últimas 10 execuções
└── Recomendações de split

context_logger.sh chama Python lib com fallback para sem-Python.
```

---

## 9. Métricas e Health Check

```
Scripts agregam dados em `logs/`:

logs/
├── context_stats.json     ← Tokens por fase por modelo
├── execution_times.json   ← Tempo real vs estimado
├── validation_rates.json  ← % de specs validadas por projeto
└── model_costs.json       ← Custo relativo Haiku vs Sonnet vs Opus

Dashboard simples em state.sh:
├── Status das 3 streams (% completo)
├── Market score (0-10)
├── Specs coverage (%)
├── Context usage (tokens)
└── Recomendação de próxima ação
```

---

## 10. Fluxo de Aprovação para Codegen

```
spec_validator.sh: coverage < 90%
    ↓
❌ BLOQUEADO
    ↓
feedback_loop.sh (resolve gaps)
    ↓
spec_validator.sh: coverage >= 90%
    ↓
✅ DESBLOQUEADO
    ↓
orchestration_engine.sh: decide modelo
    ↓
codegen.sh: gera código MVP
    ↓
decision_logger.py: documenta why_phase_*
```

---

*Última atualização: 2026-03-24*
*Próxima review: Após FASE 1 MVP implementado*
