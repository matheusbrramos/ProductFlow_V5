# ProductFlow_V5 — CLAUDE.md

## Projeto
**Nome:** ProductFlow_V5 (Sistema Integrado de Pesquisa + Protótipo + Specs)
**Descrição:** Framework para validar ideias de produto em paralelo antes de codegen
**Tipo:** automacao
**Stakeholders:** PMs, Product Designers, Devs
**Status:** Em desenvolvimento — FASE 1 (Infraestrutura)

## Objetivos

1. **Reduzir 70% de produtos que ninguém quer** — validação de mercado/problema ANTES de codegen
2. **Pesquisa + Protótipo + Specs em paralelo** — não linear
3. **Context rot prevention** — cada fase recebe < 25k tokens
4. **Loop de aprendizado** — histórico de decisões + outcomes

## Stack

| Componente | Tech |
|---|---|
| Orquestração | Bash + Python3 |
| Protótipos | FigJam (via Claude API) |
| Storage | Markdown + Git |
| Agentes | Claude Haiku (research), Sonnet (specs), Opus (review) |
| Analytics | Python + simples CSV/JSON |

## Fluxo de Desenvolvimento

### Iniciar novo projeto
```bash
cd ProductFlow_V5
bash start.sh "Nome do Projeto"
```

### Fases (Rodam em paralelo onde possível)

| Fase | Script | Tempo | Owner |
|---|---|---|---|
| 1. Pesquisa | `bash scripts/research.sh` | 30m | PM + Claude Haiku |
| 2. Protótipo | `bash scripts/prototype_gen.sh` | 20m | Claude Haiku |
| 3. Validation | `bash scripts/spec_validator.sh` | 15m | Claude Sonnet |
| 4. Feedback Loop | `bash scripts/feedback_loop.sh` | 10m | PM + Claude |
| 5. Orquestração | `bash scripts/orchestration_engine.sh` | 5m | Claude |
| 6. Codegen | `bash scripts/codegen.sh` | 2-4h | Claude Sonnet/Opus |

## Estrutura de Pastas

```
ProductFlow_V5/
├── improvement_plan/          ← Documentação do sistema
│   ├── 00_BLUEPRINT.md        (Visão geral)
│   ├── 01_CHUNKS.md           (Epics detalhadas)
│   ├── 02_STEPS.md            (Steps práticos) [em geração]
│   ├── 03_PROMPTS.md          (Prompts para agentes) [em geração]
│   ├── 04_TODO.md             (Checklist executável) [em geração]
│   └── ARCHITECTURE.md        (Diagramas de fluxo) [em geração]
│
├── scripts/                   ← Shell scripts para automação
│   ├── start.sh               (Iniciar projeto novo)
│   ├── research.sh            (Pesquisa integrada)
│   ├── prototype_gen.sh       (Gerar wireframes FigJam)
│   ├── spec_validator.sh      (Validar specs)
│   ├── feedback_loop.sh       (Processar feedback)
│   ├── orchestration_engine.sh (Decidir modelo)
│   ├── codegen.sh             (Gerar código)
│   ├── state.sh               (Ver estado atual)
│   └── lib/
│       ├── market_research.py (Extração de mercado)
│       ├── figma_generator.py (Wireframe automático)
│       ├── spec_checker.py    (Edge cases)
│       └── context_rot_detector.py (Tokens > 25k?)
│
├── templates/                 ← Markdown templates
│   ├── market_data.md         (Dados de pesquisa)
│   ├── prototype_feedback.md  (Feedback de usuários)
│   ├── spec_checklist.md      (Validação de specs)
│   └── decisions/
│       └── why_phase_N.md     (Justificativas)
│
├── projects/                  ← Pasta raiz de projetos
│   └── [project-name]/
│       ├── project_state.md   (Status atual)
│       ├── market_data.md     (Pesquisa)
│       ├── prd.md             (Product Requirements)
│       ├── blueprint.md       (Arquitetura)
│       ├── spec_checklist.md  (Validation)
│       ├── prototypes/        (FigJam links)
│       ├── decisions/         (why_phase_*.md)
│       ├── outcomes/          (Resultados 3-6mo)
│       ├── logs/              (Context logs)
│       └── code/              (Código gerado)
│
├── docs/
│   └── INTEGRATION_GUIDE.md   (Como usar o sistema)
│
├── CLAUDE.md                  (Este arquivo)
└── .gitignore

```

## Regras de Execução

1. **Sempre rodar `.sh` scripts de dentro da pasta do projeto** — scripts referem contexto local
2. **Verificar `state.sh` antes de próxima fase** — garante que anterior foi concluído
3. **Não pular fases** — feedback loop é crítico para validação
4. **Atualizar `project_state.md` após cada script** — mantém visibilidade
5. **Commitar decisões** — cada `why_phase_*.md` deve ir pro git

## Checklist de Setup Inicial

- [ ] Copiar `improvement_plan/` completo
- [ ] Criar scripts base em `scripts/`
- [ ] Testar `bash start.sh "Test Project"` com projeto de exemplo
- [ ] Validar que `project_state.md` é gerado automaticamente
- [ ] Testar parallelismo: rodar CHUNK 1.2 + 1.3 simultâneamente

## Próximos Passos

1. Agentes gerando: 02_STEPS.md, 03_PROMPTS.md, 04_TODO.md, ARCHITECTURE.md
2. Criar scripts iniciais (start.sh, state.sh, research.sh)
3. Testar CHUNK 1.1 + 1.2 com projeto exemplo
4. Rodar FASE 1 completa
