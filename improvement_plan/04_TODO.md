# ProductFlow_V5 — Checklist de Implementação (04_TODO.md)

**Data de Criação:** 2026-03-24
**Status Geral:** 0/47 completo — 0%
**Prazo FASE 1:** 2-3 semanas

---

## 🔴 FASE 1: Infraestrutura + Streams Paralelos

### CHUNK 1.1 — Dashboard de Contexto (Foundation)
**Status:** 0/4 | Owner: Dev | Bloqueado por: — | Est. 1h

- [ ] Criar template `project_state.md` | 15min | Dev
- [ ] Implementar `scripts/state.sh` | 30min | Dev
- [ ] Integrar state.sh em `start.sh` | 15min | Dev
- [ ] Testar: rodar `start.sh` e validar project_state.md gerado | 20min | QA

**Critério de sucesso:** `bash start.sh "Test"` cria project com state.md pronto

---

### CHUNK 1.2 — Pesquisa de Mercado (Foundation)
**Status:** 0/5 | Owner: Dev + PM | Bloqueado por: CHUNK 1.1 | Est. 1.5h

- [ ] Criar template `templates/market_data.md` | 20min | Dev
- [ ] Implementar `scripts/research.sh` com entrevista interativa | 45min | Dev
- [ ] Adicionar cálculo de market_score em research.sh | 20min | Dev
- [ ] Integrar atualização de project_state.md em research.sh | 15min | Dev
- [ ] Testar: `bash research.sh` preenche market_data.md e atualiza state | 20min | QA

**Critério de sucesso:** PM executa entrevista interativa, market_score é calculado, project_state.md muda para ✅

---

### CHUNK 1.3 — Geração de Protótipo (Pesquisa + Proto)
**Status:** 0/4 | Owner: Dev | Bloqueado por: CHUNK 1.2 | Est. 1.5h

- [ ] Criar template `templates/prd.md` | 15min | Dev
- [ ] Implementar `scripts/prototype_gen.sh` com MCP Figma integration | 1h | Dev
- [ ] Criar template `templates/prototype_feedback.md` | 15min | Dev
- [ ] Testar: `bash prototype_gen.sh` gera FigJam link e templates | 20min | QA

**Critério de sucesso:** FigJam wireframe é gerado, link salvo em prototypes/v1.figma, feedback template criado

---

### CHUNK 1.4 — Validação de Specs (Pesquisa + Proto + Specs)
**Status:** 0/4 | Owner: Dev | Bloqueado por: CHUNK 1.3 | Est. 1.5h

- [ ] Criar template `templates/spec_checklist.md` com 40+ items | 20min | Dev
- [ ] Implementar `scripts/spec_validator.sh` | 1h | Dev
- [ ] Adicionar bloqueio de codegen se < 90% validado | 15min | Dev
- [ ] Testar: `bash spec_validator.sh` identifica gaps e calcula % | 20min | QA

**Critério de sucesso:** Script gera checklist com ambiguidades, edge cases, gaps. Bloqueia codegen < 90%

---

### CHUNK 1.5 — Loop de Feedback (Paralelo com Proto + Specs)
**Status:** 0/3 | Owner: Dev + PM | Bloqueado por: CHUNK 1.3 + 1.4 | Est. 1.5h

- [ ] Implementar `scripts/feedback_loop.sh` | 45min | Dev
- [ ] Adicionar atualização automática de market_data.md e spec_checklist.md | 30min | Dev
- [ ] Testar: preencher feedback e validar atualizações em cascata | 20min | QA

**Critério de sucesso:** PM preenche feedback, feedback_loop.sh atualiza market_data.md e specs, sugere v2

---

## 🟡 FASE 2: Context Rot Prevention

### CHUNK 2.1 — Detecção de Context Rot
**Status:** 0/2 | Owner: Dev | Bloqueado por: FASE 1 completa | Est. 1.5h

- [ ] Implementar `scripts/lib/context_rot_detector.py` | 1h | Dev
- [ ] Integrar detector em `orchestration_engine.sh` com alerts ⚠️/🔴 | 30min | Dev

**Critério de sucesso:** Detector marca ⚠️ se phase > 25k, 🔴 se > 35k tokens

---

### CHUNK 2.2 — Orquestração de Modelos
**Status:** 0/2 | Owner: Dev | Bloqueado por: CHUNK 2.1 | Est. 1h

- [ ] Implementar decision tree em `scripts/orchestration_engine.sh` | 45min | Dev
- [ ] Gerar `orchestration.md` com decisões de modelo por fase | 15min | Dev

**Critério de sucesso:** Script decide Haiku vs Sonnet vs Opus baseado em TAM + market_score

---

## 🟢 FASE 3: Loop de Aprendizado (Futuro)

### CHUNK 3.1 — Persistência de Decisões
**Status:** 0/2 | Owner: Dev | Bloqueado por: FASE 2 completa | Est. 1h

- [ ] Implementar `scripts/lib/decision_logger.py` | 30min | Dev
- [ ] Integrar em codegen.sh para gerar `decisions/why_phase_*.md` | 30min | Dev

**Critério de sucesso:** Após cada fase, why_phase_N.md é gerado com justificativas

---

### CHUNK 3.2 — Git Hooks
**Status:** 0/1 | Owner: Dev | Bloqueado por: Projeto em git | Est. 30min

- [ ] Implementar `.git/hooks/pre-commit` que valida PRD/specs | 30min | Dev

**Critério de sucesso:** Commit bloqueado se PRD mudar sem validação de specs

---

### CHUNK 3.3 — Outcomes Tracking
**Status:** 0/1 | Owner: PM | Bloqueado por: Produto launched | Est. 30min (executada após 3-6mo)

- [ ] Implementar `scripts/outcomes_tracker.sh` com form simples | 30min | Dev

**Critério de sucesso:** PM coleta dados de uso após produto rodando 3-6 meses

---

### CHUNK 3.4 — Learning Loop
**Status:** 0/1 | Owner: Dev | Bloqueado por: CHUNK 3.3 (após 5+ projetos) | Est. 1.5h

- [ ] Implementar `scripts/analytics.sh` agregando histórico | 1h | Dev
- [ ] Gerar `suggestions.md` comparando novos projetos com histórico | 30min | Dev

**Critério de sucesso:** Sistema detecta padrões (ex: "market_score 8+ → 75% sucesso") e sugere estratégias

---

## 📋 Tarefas de Infraestrutura

### Setup Inicial
**Status:** 0/5 | Owner: Dev | Est. 1h

- [x] Criar estrutura de pastas (ProductFlow_V5) | ✅ Feito
- [x] Copiar improvement_plan/ | ✅ Feito
- [ ] Criar todos os templates em `templates/` | 20min | Dev
- [ ] Implementar `install.sh` para setup de novo projeto | 20min | Dev
- [ ] Criar `.gitignore` e README.md | 15min | Dev

---

### Documentação
**Status:** 0/3 | Owner: PM + Dev | Est. 1.5h

- [ ] Escrever INTEGRATION_GUIDE.md (como usar o sistema) | 45min | PM
- [ ] Criar exemplos de uso em `docs/examples/` | 30min | Dev
- [ ] Documentar troubleshooting em `docs/TROUBLESHOOTING.md` | 15min | Dev

---

## 📊 Legenda de Status

| Ícone | Significado |
|-------|------------|
| `[ ]` | Pendente (não iniciado) |
| `[x]` | Completo ✅ |
| `[?]` | Bloqueado (aguardando dependência) |
| `[!]` | Em Progresso (WIP) |

---

## 🎯 Milestone de Conclusão

| Milestone | Prazo | Dependências | Owner |
|-----------|-------|---|---|
| **FASE 1 Pronto** | Semana 3 | Todos CHUNKs 1.1-1.5 | Dev + PM |
| **FASE 2 Pronto** | Semana 5 | FASE 1 + CHUNKs 2.1-2.2 | Dev |
| **FASE 3 Pronto** | Semana 7+ | Após 5+ projetos | Dev + PM |
| **Produção** | ∞ | Todas as fases | Everyone |

---

## 📈 Progresso Visual

```
FASE 1: ████░░░░░░░░░░░░░░░░░░░░░░░░ 14% (13/92 tasks)
FASE 2: ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  0%
FASE 3: ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  0%
```

---

## 🚀 Como Usar Este Checklist

1. **Standup diário:** Revisar `[?]` items (blockers)
2. **Daily sync:** PM atualiza status em sync matutino
3. **Friday review:** Atualizar este arquivo com avanços
4. **Sprint planning:** Re-estimar próxima sprint com learnings

**Próxima ação:** Implementar CHUNK 1.1 (começar segunda-feira)

---

*Atualizado pela última vez: 2026-03-24*
*Próxima review: 2026-03-28 (sexta)*
