# ProductFlow_V5 — Framework de Validação de Produtos

**Versão:** 5.0 (Implementação de FASE 1)
**Status:** 🟡 Em Desenvolvimento
**Last Updated:** 2026-03-24

---

## 🎯 Objetivo

Transformar o processo de desenvolvimento de produtos de **linear** (ideia → entrevista → PRD → blueprint → codegen) para **paralelo** (pesquisa ↔ protótipo ↔ validação de specs em simultaneamente), **reduzindo 70% de "produtos que ninguém quer"**.

---

## ⚡ Quick Start

### Criar novo projeto
```bash
cd ProductFlow_V5
bash start.sh "Nome do Seu Produto"
cd projects/nome-do-seu-produto
```

### Executar pesquisa integrada
```bash
bash ../../scripts/research.sh
```

### Ver progresso
```bash
bash ../../scripts/state.sh
```

### Validar specs
```bash
bash ../../scripts/spec_validator.sh
```

---

## 📊 Os 3 Streams em Paralelo

```
PESQUISA                    PROTÓTIPO                   SPECS
(TAM, pain points,    +     (wireframe FigJam)     +    (edge cases,
 WTP, market_score)         (user journeys)             ambiguidades)
         │                         │                        │
         └────────────────┬────────┘                        │
                          │                                 │
                    ✅ 90% Validação?
                          │
                      Pronto para Codegen
                          │
                    orchestration_engine.sh
                          │
                      codegen.sh (Haiku/Sonnet/Opus)
```

---

## 📁 Estrutura

### `/improvement_plan`
Documentação do sistema (read-only, referência):
- `00_BLUEPRINT.md` — Visão geral de 3 fases
- `01_CHUNKS.md` — Epics detalhadas (1.1-3.4)
- `02_STEPS.md` — Steps práticos de implementação
- `03_PROMPTS.md` — Prompts reutilizáveis para agentes
- `04_TODO.md` — Checklist de progresso
- `ARCHITECTURE.md` — Diagramas técnicos e DAGs

### `/scripts`
Shell scripts para automação:
- `start.sh` — Inicializar novo projeto
- `research.sh` — Pesquisa integrada (CHUNK 1.2)
- `prototype_gen.sh` — Gerar wireframes FigJam (CHUNK 1.3)
- `spec_validator.sh` — Validar specs (CHUNK 1.4)
- `feedback_loop.sh` — Processar feedback (CHUNK 1.5)
- `orchestration_engine.sh` — Decidir modelo (CHUNK 2.2)
- `state.sh` — Ver progresso visual
- `/lib` — Python libs (context_rot_detector.py, etc)

### `/templates`
Templates de markdown para projetos:
- `market_data.md` — Estrutura de pesquisa
- `prd.md` — Product requirements
- `prototype_feedback.md` — Coletar feedback
- `spec_checklist.md` — Validação de specs

### `/projects`
Pasta raiz onde cada projeto vira um subdiretório:
```
projects/
├── seu-produto-1/
│   ├── project_state.md      (dashboard)
│   ├── market_data.md        (pesquisa)
│   ├── prd.md                (requirements)
│   ├── blueprint.md          (arquitetura)
│   ├── spec_checklist.md     (validação)
│   ├── prototypes/v*.figma   (wireframes)
│   ├── decisions/why_phase_*.md
│   ├── outcomes/             (resultados 3-6mo)
│   └── code/                 (código gerado)
└── seu-produto-2/
    └── ...
```

---

## 🚀 Como Usar

### 1. Iniciar Projeto
```bash
bash start.sh "API de Dashboards para Startups"
cd projects/api-de-dashboards-para-startups
```

Gera:
- `project_state.md` (dashboard visual)
- `market_data.md` (template)

### 2. Pesquisa de Mercado
```bash
bash ../../scripts/research.sh
```

Coleta interativamente:
- TAM (Total Addressable Market)
- Pain points (score 1-10)
- Top 3 concorrentes
- Willingness to pay
- Frequência do problema
- Insights importantes

Calcula automaticamente:
- Market score (0-10)
- Recomendação de modelo

### 3. Protótipo (Wireframe)
```bash
bash ../../scripts/prototype_gen.sh
```

Gera:
- `prd.md` (se não existir)
- `prototypes/v1.figma` (wireframe FigJam)
- `prototype_feedback.md` (template para feedback)

### 4. Validar Specs
```bash
bash ../../scripts/spec_validator.sh
```

Identifica:
- Ambiguidades no PRD
- Edge cases não cobertos
- Dependências técnicas
- Gaps (pain points vs solução)

Gera `spec_checklist.md` com % de cobertura.

**Bloqueador:** < 90% = não pode rodar codegen

### 5. Loop de Feedback
```bash
# PM preenche prototype_feedback.md com feedback de 3-5 users
# Depois executa:
bash ../../scripts/feedback_loop.sh
```

Atualiza em cascata:
- `market_data.md` (insights validados)
- `spec_checklist.md` (novos edge cases)
- Sugere v2 do protótipo

### 6. Orquestração de Modelos
```bash
bash ../../scripts/orchestration_engine.sh
```

Decide baseado em market_score + TAM:
- **Haiku:** market_score < 5 + TAM < $50M (MVP economia)
- **Sonnet:** Default padrão (equilíbrio)
- **Opus:** TAM > $500M ou market_score > 8 (quality gates)

Gera `orchestration.md` com justificativa.

### 7. Ver Progresso
```bash
bash ../../scripts/state.sh
```

Mostra:
- Status de cada stream (%)
- Market score
- Specs coverage
- Próximos passos

---

## 📊 Métricas Chave

| Métrica | Objetivo | Atual |
|---------|----------|-------|
| Pesquisa → PRD | < 30min | — |
| PRD → Protótipo | < 20min | — |
| Protótipo → Specs validadas | < 15min | — |
| % Specs coverage | ≥ 90% | — |
| Market score | ≥ 7 | — |
| Produtos "hit" (3-6mo) | ≥ 70% | — |

---

## 🧠 Princípios

1. **Parallelismo** — Pesquisa, protótipo e specs rodam juntos, não sequencial
2. **Validação Early** — Testar com usuários ANTES de investir em código
3. **Context Awareness** — Fases < 25k tokens para evitar degradação
4. **Transparência** — Logs de "por que" cada decisão foi tomada
5. **Learning Loop** — Histórico de decisões alimenta próximos projetos

---

## 📚 Documentação

- `CLAUDE.md` — Configuração do projeto
- `improvement_plan/00_BLUEPRINT.md` — Visão arquitetural
- `improvement_plan/ARCHITECTURE.md` — Diagramas técnicos
- `docs/INTEGRATION_GUIDE.md` — Como integrar com seus workflows (em desenvolvimento)

---

## 🔄 Status de Implementação

### ✅ Completo (FASE 1 Foundation)
- [x] `00_BLUEPRINT.md` — Visão geral
- [x] `01_CHUNKS.md` — Epics detalhadas
- [x] `02_STEPS.md` — Steps práticos
- [x] `03_PROMPTS.md` — Prompts para agentes
- [x] `04_TODO.md` — Checklist
- [x] `ARCHITECTURE.md` — Diagramas
- [x] `start.sh` — Inicializar projeto
- [x] `research.sh` — Pesquisa integrada
- [x] `prototype_gen.sh` — Gerar wireframes
- [x] `spec_validator.sh` — Validação
- [x] `feedback_loop.sh` — Loop de feedback
- [x] `state.sh` — Dashboard
- [x] `context_rot_detector.py` — Detector de rot
- [x] `orchestration_engine.sh` — Orquestração de modelos

### 🟡 Em Desenvolvimento
- [ ] `codegen.sh` — Gerador de código (próxima semana)
- [ ] Integração MCP Figma completa
- [ ] `decision_logger.py` — why_phase_*.md automático
- [ ] `analytics.sh` — Agregação de histórico

### 🔲 Futuro (FASE 2-3)
- [ ] Git hooks para validação PRD
- [ ] Outcomes tracking (3-6mo)
- [ ] Learning loop automático
- [ ] Sugestões baseadas em histórico

---

## 🐛 Troubleshooting

### "project_state.md não encontrado"
```bash
# Você não está dentro da pasta do projeto
cd projects/seu-projeto
bash ../../scripts/state.sh
```

### "market_data.md não populado"
```bash
# Rodar research.sh dentro da pasta do projeto
cd projects/seu-projeto
bash ../../scripts/research.sh
```

### "spec_validator.sh bloqueia em < 90%"
Isso é intencional. Ações:
1. Revisar gaps identificados em `spec_checklist.md`
2. Atualizar PRD com clarificações
3. Rodar `spec_validator.sh` novamente

---

## 📞 Suporte

Para dúvidas ou issues:
1. Revisar `improvement_plan/ARCHITECTURE.md` para entender fluxo
2. Conferir `04_TODO.md` para ver checklist de implementação
3. Executar `bash ../../scripts/state.sh` para diagnosticar progresso

---

## 📈 Roadmap

**Semana 1-3 (Agora):** Implementar FASE 1 (pesquisa + proto + specs)
**Semana 3-4:** Implementar FASE 2 (context rot prevention + orquestração)
**Semana 5-7:** Implementar FASE 3 (loop de aprendizado + outcomes)

---

*ProductFlow_V5 — Transformando ideias em produtos validados*

**Criado:** 2026-03-24
**Mantido por:** Claude Code + Matheus Ramos
