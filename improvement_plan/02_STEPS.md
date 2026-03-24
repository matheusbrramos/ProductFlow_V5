# ProductFlow_V5 — Steps Executáveis (02_STEPS.md)

## FASE 1: Infraestrutura + Streams Paralelos

### CHUNK 1.1 — Dashboard de Contexto Integrado

**Objetivo:** Criar ponto de entrada unificado mostrando pesquisa + protótipo + specs em paralelo.

#### Step 1.1.1: Criar estrutura de markdown
- **Ação:** Gerar `project_state.md` com template YAML
- **Tempo:** 15min
- **Resultado:** Arquivo markdown com 3 seções vazias (pesquisa, protótipo, specs)
- **Artefato:** `project_state.md`
- **Teste:** Verificar que arquivo existe e tem 3 seções principais

#### Step 1.1.2: Criar script `state.sh`
- **Ação:** Implementar bash script que lê `project_state.md` e exibe resumo formatado
- **Tempo:** 30min
- **Resultado:** Script executável que mostra status visual em terminal
- **Artefato:** `scripts/state.sh`
- **Teste:** Rodar `bash state.sh` e validar saída colorida com status

#### Step 1.1.3: Integrar em `start.sh`
- **Ação:** Modificar `start.sh` para gerar `project_state.md` automaticamente ao criar novo projeto
- **Tempo:** 20min
- **Resultado:** `start.sh "Nome Projeto"` cria estrutura completa com state.md pronto
- **Artefato:** Atualização de `start.sh`
- **Teste:** Rodar `bash start.sh "Test"` e validar que project_state.md é criado

---

### CHUNK 1.2 — Pesquisa de Mercado Integrada

**Objetivo:** Expandir entrevista PM para incluir dados estruturados (TAM, pain points, WTP).

#### Step 1.2.1: Criar template `market_data.md`
- **Ação:** Gerar markdown template com seções: TAM, pain points, concorrência, WTP, frequência, market_score
- **Tempo:** 20min
- **Resultado:** Template pronto para preenchimento com 7 seções principais
- **Artefato:** `templates/market_data.md`
- **Teste:** Validar que template tem todas as seções

#### Step 1.2.2: Implementar `research.sh` com entrevista interativa
- **Ação:** Criar bash script que faz 7 perguntas interativas e preenche `market_data.md`
- **Tempo:** 45min
- **Resultado:** Script que coleta TAM, pain score, competitors, WTP, frequency via stdin
- **Artefato:** `scripts/research.sh`
- **Teste:** Rodar `bash research.sh` e validar que `market_data.md` é populado com respostas

#### Step 1.2.3: Implementar cálculo de market_score
- **Ação:** Adicionar lógica em `research.sh` que calcula score 0-10 baseado em respostas
- **Tempo:** 20min
- **Resultado:** Cada `market_data.md` tem score calculado e recomendação de modelo (Haiku/Sonnet/Opus)
- **Artefato:** Função em `research.sh`
- **Teste:** Validar que diferentes entradas resultam em scores diferentes

#### Step 1.2.4: Integração com `project_state.md`
- **Ação:** `research.sh` atualiza `project_state.md` ao completar
- **Tempo:** 15min
- **Resultado:** Seção "PESQUISA" em project_state.md muda de ⏳ para ✅ após script
- **Artefato:** Atualização de ambos scripts
- **Teste:** Rodar `bash research.sh` e validar que `state.sh` mostra seção marcada como completa

---

### CHUNK 1.3 — Geração Automática de Wireframes FigJam

**Objetivo:** A partir de pesquisa + PRD, gerar protótipo navegável.

#### Step 1.3.1: Criar template `prd.md`
- **Ação:** Gerar markdown template com: objetivo, usuário, features, fluxos principais
- **Tempo:** 15min
- **Resultado:** Template PRD estruturado com placeholders
- **Artefato:** `templates/prd.md` (copiado para projeto)
- **Teste:** Validar estrutura do template

#### Step 1.3.2: Implementar `prototype_gen.sh`
- **Ação:** Criar script que lê `market_data.md` + `prd.md` e gera wireframe FigJam
- **Tempo:** 1h (inclui integração com MCP Figma)
- **Resultado:** Script que chama `get_design_context` para gerar wireframe low-fidelity
- **Artefato:** `scripts/prototype_gen.sh` + `scripts/lib/figma_generator.py`
- **Teste:** Rodar script e validar que link FigJam é criado em `prototypes/v1.figma`

#### Step 1.3.3: Criar template de feedback
- **Ação:** Gerar `prototype_feedback.md` com seções para coletar feedback de users
- **Tempo:** 15min
- **Resultado:** Template com checkboxes para "o que funcionou", "o que não funcionou", sugestões
- **Artefato:** `templates/prototype_feedback.md`
- **Teste:** Validar que template tem seções para 3-5 usuários

---

### CHUNK 1.4 — Checklist Automático de Validação de Specs

**Objetivo:** Garantir que PRD + protótipo cobrem edge cases e ambiguidades.

#### Step 1.4.1: Criar template `spec_checklist.md`
- **Ação:** Gerar markdown com categorias: ambiguidades, edge cases, dependências, gaps
- **Tempo:** 20min
- **Resultado:** Template com 30-40 checklist items padrão
- **Artefato:** `templates/spec_checklist.md`
- **Teste:** Validar estrutura e quantidade de items

#### Step 1.4.2: Implementar `spec_validator.sh`
- **Ação:** Criar script que lê PRD + protótipo e gera checklist preenchido
- **Tempo:** 1h
- **Resultado:** Script que usa Claude Sonnet para identificar ambiguidades e edge cases
- **Artefato:** `scripts/spec_validator.sh` + `scripts/lib/spec_checker.py`
- **Teste:** Rodar script com PRD e validar que checklist_*.md é criado com items identificados

#### Step 1.4.3: Validação de "cobertura 90%"
- **Ação:** Adicionar lógica que conta ✅ items e oferece "ir para codegen" só se > 90%
- **Tempo:** 15min
- **Resultado:** Script bloqueia codegen se menos de 90% de items validados
- **Artefato:** Função em `spec_validator.sh`
- **Teste:** Testar com diferentes níveis de completude

---

### CHUNK 1.5 — Loop de Feedback Entre Streams

**Objetivo:** Fechar loops — feedback do usuário atualiza pesquisa e specs.

#### Step 1.5.1: Implementar `feedback_loop.sh`
- **Ação:** Criar script que lê `prototype_feedback.md` (preenchido com feedback de users)
- **Tempo:** 45min
- **Resultado:** Script que extrai padrões (3/5 users disseram X) e sugere atualizações
- **Artefato:** `scripts/feedback_loop.sh` + `scripts/lib/feedback_analyzer.py`
- **Teste:** Rodar com feedback template preenchido e validar que market_data.md é atualizado

#### Step 1.5.2: Atualização automática de specs
- **Ação:** `feedback_loop.sh` identifica gaps descobertos e atualiza `spec_checklist.md`
- **Tempo:** 20min
- **Resultado:** Novos items aparecem em checklist após feedback processado
- **Artefato:** Lógica em `feedback_loop.sh`
- **Teste:** Adicionar feedback que revela novo edge case e validar que aparece em checklist

#### Step 1.5.3: Sugerir regeneração de protótipo
- **Ação:** `feedback_loop.sh` oferece rerun de `prototype_gen.sh` para criar v2
- **Tempo:** 15min
- **Resultado:** Após feedback, script sugere criar v2 do protótipo
- **Artefato:** Prompts em `feedback_loop.sh`
- **Teste:** Validar que output sugere próximas ações

---

## FASE 2: Context Rot Prevention

### CHUNK 2.1 — Detecção Automática de Context Rot

#### Step 2.1.1: Implementar `context_rot_detector.py`
- **Ação:** Criar Python script que estima tokens por fase (CLAUDE.md + blueprint + PRD + etc)
- **Tempo:** 1h
- **Resultado:** Script que marca ⚠️ se fase > 25k, 🔴 se > 35k
- **Artefato:** `scripts/lib/context_rot_detector.py`
- **Teste:** Rodar com diferentes tamanhos de PRD e validar warnings

#### Step 2.1.2: Integração com `orchestration_engine.sh`
- **Ação:** `orchestration_engine.sh` chama detector antes de gerar prompts
- **Tempo:** 20min
- **Resultado:** Workflow valida rot antes de executar
- **Artefato:** Integração em `orchestration_engine.sh`
- **Teste:** Rodar com grande PRD e validar que sistema recomenda split

---

### CHUNK 2.2 — Decision Tree para Orquestração de Modelos

#### Step 2.2.1: Implementar decision tree
- **Ação:** Criar `orchestration_engine.sh` com regras: TAM + market_score → modelo
- **Tempo:** 45min
- **Resultado:** Script que gera `orchestration.md` mostrando decisão para cada fase
- **Artefato:** `scripts/orchestration_engine.sh`
- **Teste:** Validar que diferentes market_scores resultam em diferentes modelos

---

## Timeline de Implementação

| Chunk | Semana | Duração | Prioridade |
|---|---|---|---|
| 1.1 | Semana 1 | 1h | 🔴 Crítico |
| 1.2 | Semana 1 | 1.5h | 🔴 Crítico |
| 1.3 | Semana 2 | 1.5h | 🟡 Alto |
| 1.4 | Semana 2 | 1.5h | 🟡 Alto |
| 1.5 | Semana 3 | 1.5h | 🟢 Médio |
| 2.1 | Semana 3-4 | 1.5h | 🟢 Médio |
| 2.2 | Semana 4 | 1h | 🟢 Médio |

**Total FASE 1:** ~9 horas de desenvolvimento
