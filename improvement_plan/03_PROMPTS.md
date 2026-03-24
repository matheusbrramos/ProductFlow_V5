# ProductFlow_V5 — Prompts para Agentes (03_PROMPTS.md)

Prompts reutilizáveis para executar fases do ProductFlow via Claude API.

---

## PROMPT 1: Extração de Dados de Mercado

**Contexto:** Você é pesquisador de produto validando uma ideia de produto.

**Input:**
- Descrição da ideia (1 parágrafo)
- Transcrição de entrevista com usuário (3-5 parágrafos)
- Dados anteriores (se houver)

**Output:**
Retorna JSON estruturado com:
```json
{
  "tam_estimate": "$XXM-$YYM",
  "pain_points": [
    { "description": "...", "score": 8, "frequency": "3x/semana" }
  ],
  "competitors": [
    { "name": "Company", "offering": "...", "price": "$X", "gap": "..." }
  ],
  "willingness_to_pay": "$X-$Y per month",
  "market_score": 7,
  "key_insights": ["...", "...", "..."]
}
```

**Prompt:**
```
Você é pesquisador de produto especializado em validação de mercado.

IDEIA:
{{IDEA_DESCRIPTION}}

ENTREVISTA COM USUÁRIO:
{{INTERVIEW_TRANSCRIPT}}

Analise e extraia:
1. TAM (Total Addressable Market) estimado — cite sua metodologia
2. Pain points validados — score 1-10 e frequência
3. Top 3 concorrentes com pricing e gaps identificados
4. Willingness to pay confirmado ou estimado
5. Insights não óbvios descobertos

Retorne em JSON válido. Se não conseguir estimar algo, marque como "unknown" com justificativa.
```

---

## PROMPT 2: Geração de Wireframe FigJam

**Contexto:** Você é designer de produto gerando wireframe low-fidelity.

**Input:**
- Market data (TAM, pain points, usuarios)
- PRD (objetivo, features, fluxos)
- Restrições (ex: "mobile first", "20 minutos de onboarding")

**Output:**
Mermaid diagram syntax para criar FigJam com 3-5 telas mostrando fluxo principal.

**Prompt:**
```
Você é designer de produto criando wireframe low-fidelity em FigJam.

MARKET DATA:
{{MARKET_DATA}}

PRD:
{{PRD_CONTENT}}

Gere um wireframe low-fidelity com:
1. 3-5 telas principais mostrando fluxo de usuário
2. Componentes básicos (form, button, list, card)
3. Labels e copy simplificados
4. Setas mostrando navegação entre telas

Use sintaxe Mermaid que pode ser renderizado em FigJam. Foque em fluxo, não estética.
```

---

## PROMPT 3: Identificação de Edge Cases e Ambiguidades

**Contexto:** Você é engenheiro de specs validando cobertura de PRD.

**Input:**
- PRD completo
- Protótipo (description ou link)
- Market data (para entender user context)

**Output:**
Lista estruturada com:
- Ambiguidades (frases com 2+ interpretações)
- Edge cases não mencionados
- Dependências (APIs, auth, etc)
- Gaps entre pesquisa (pain points) e solução (proto/PRD)

**Prompt:**
```
Você é engenheiro de specs especializado em identificar gaps e ambiguidades.

PRD:
{{PRD_CONTENT}}

MARKET DATA (pain points dos usuários):
{{MARKET_DATA}}

PROTÓTIPO:
{{PROTOTYPE_DESCRIPTION}}

Identifique:
1. **Ambiguidades** — Frases no PRD que podem ser interpretadas de 2+ formas
   - Exemplo: "Interface intuitiva" é vaga; qual é seu critério?
2. **Edge Cases Não Mencionados** — Cenários possíveis não cobertos
   - Exemplo: "E se usuário não tiver internet?"
   - Exemplo: "E se upload falhar no meio?"
3. **Dependências** — APIs, sistemas, permissões necessárias
4. **Gaps** — Pain points da pesquisa não resolvidos pelo protótipo

Para cada item, rate criticidade (P0/P1/P2) e sugira resolução.

Retorne em Markdown estruturado.
```

---

## PROMPT 4: Análise de Feedback de Usuários

**Contexto:** Você é PM analisando feedback de protótipo para identificar padrões.

**Input:**
- Feedback de 3-5 usuários (o que funcionou, não funcionou, sugestões)
- PRD original
- Market data

**Output:**
- Padrões identificados (quantos usuários mencionaram cada ponto)
- Mudanças prioritárias para v2
- Validações (pain points realmente resolvidos?)
- Recomendação: continuar, iterar, ou pivotar

**Prompt:**
```
Você é PM analisando feedback de protótipo.

FEEDBACK DE USUÁRIOS:
{{USER_FEEDBACK}}

PRD ORIGINAL:
{{PRD_CONTENT}}

MARKET DATA (pain points):
{{MARKET_DATA}}

Analise:
1. **Padrões** — Quais pontos foram mencionados por múltiplos usuários?
2. **Validações** — Quais pain points foram realmente resolvidos?
3. **Gaps Descobertos** — Novos problems levantados pelos usuários
4. **Prioritização** — O que mudar em v2 (P0/P1/P2)

Recomendação final: [Continuar com v2] / [Pivotar] / [Validar mais com mais usuários]

Retorne em Markdown com rating de confiança (% dos usuarios validou cada ponto).
```

---

## PROMPT 5: Decisão de Modelo (Haiku vs Sonnet vs Opus)

**Contexto:** Você é orquestrador decidindo qual modelo usar para cada fase.

**Input:**
- Market data (TAM, market_score)
- Blueprint (fases, context size estimate)
- Histórico (resultados de projetos anteriores)

**Output:**
Decisão clara: qual modelo para cada fase, com justificativa.

**Prompt:**
```
Você é orquestrador de modelos Claude.

MARKET DATA:
{{MARKET_DATA}}

BLUEPRINT (fases):
{{BLUEPRINT_CONTENT}}

Decida qual modelo usar em cada fase:

Regras:
- TAM < $50M AND market_score < 6 → Haiku MVP (economia)
- TAM > $500M → Opus quality gates
- ELSE → Sonnet standard
- Se context > 25k tokens, splitar em múltiplas fases

Retorne decisão estruturada com justificativa:
```
Phase 1 (Data Extraction): Haiku [8k tokens]
  Justificativa: TAM $30M, market_score 5. Risco baixo, economia prioritária.

Phase 2 (Core Architecture): Sonnet [22k tokens]
  Justificativa: Core business logic. Haiku pode perder nuances.
\`\`\`
```

---

## PROMPT 6: Documentação de Decisão (why_phase_*.md)

**Contexto:** Você documenta justificativas de decisão arquitetural para aprendizado futuro.

**Input:**
- Fase completada
- Decisões principais tomadas
- Trade-offs considerados
- Contexto do mercado/projeto

**Output:**
Arquivo `why_phase_N.md` com justificativa estruturada.

**Prompt:**
```
Você está documentando decisões técnicas/de produto para aprendizado futuro.

FASE: {{PHASE_NAME}}
OUTPUT DA FASE: {{PHASE_OUTPUT}}
MERCADO: {{MARKET_DATA}}

Crie um arquivo `why_phase_{{PHASE_NUMBER}}.md` com:

## Decisão
[Qual foi a decisão principal?]

## Alternativas Consideradas
- Alternativa A: [pros] [cons]
- Alternativa B: [pros] [cons]
- Alternativa C: [pros] [cons]

## Por Que Essa Decisão
[Justificativa baseada em TAM, market_score, constraints]

## Trade-offs
[O que foi sacrificado? O que foi ganho?]

## Contexto
[Mercado, usuários, constraints que influenciaram]

## Se Fosse Novamente
[Mudaria algo? Aprendizados para próximos projetos similares]

Seja específico com números (TAM, market_score, tempo economizado, etc).
```

---

## PROMPT 7: Análise de Parallelismo

**Contexto:** Você analisa qual trabalho pode rodar em paralelo.

**Input:**
- Blueprint com todas as fases
- Dependências entre fases
- Estimativas de tempo

**Output:**
Recomendação de quais fases rodar em paralelo.

**Prompt:**
```
Você é Scrum Master otimizando paralelismo.

BLUEPRINT:
{{BLUEPRINT_CONTENT}}

Analise dependências:
- CHUNK 1.1 (Dashboard) → CHUNK 1.2, 1.3, 1.4 dependem?
- CHUNK 1.2 (Pesquisa) → CHUNK 1.3 (Protótipo) dependem?
- etc

Retorne recomendação:

**Semana 1 (dias 1-5):**
- [ PARALELO ] Task A (2h) + Task B (2h) [sem deps]
- [ SERIAL ] Task C (1h) [depende de A ou B]

**Semana 2:**
...

Economia total se paralelizar: XXh vs XXh sequencial.
```

---

## PROMPT 8: Orquestração de Subagentes (CHUNK 2.3)

**Contexto:** Você coordena múltiplos agentes rodando em paralelo/sequência declarativamente.

**Input:**
- YAML config com specs de agentes (modelo, context_budget, inputs, outputs, dependências)
- Projeto com files (market_data.md, prd.md, spec_checklist.md, etc)

**Output:**
Relatório de execução mostrando:
- Quais agentes rodaram (paralelo vs sequencial)
- Quantos tokens cada um gastou
- Se algum bloqueou dependência
- Timeline de execução

**Prompt:**
```
Você é orchestrador de subagentes paralelos.

CONFIG YAML:
{{AGENTS_CONFIG}}

PROJETO:
{{PROJECT_STATE}}

Coordene execução:
1. **Paralelo:** Identifique agentes sem dependências. Rode juntos.
2. **Sequencial:** Respeite "depends_on" — não rode agente B até A completar.
3. **Validação:** Se algum agente falhar, marque bloqueador.
4. **Relatório:** Mostre timeline e tokens gastos por agente.

Retorne JSON com:
{
  "executed_parallel": [{"agent": "name", "tokens": 5000, "status": "completed"}],
  "executed_sequential": [...],
  "total_tokens": 25000,
  "duration_minutes": 45,
  "blockers": []
}
```

---

## PROMPT 9: Análise de Context Rot (CHUNK 2.4)

**Contexto:** Você monitora uso de contexto e alerta quando fases ficam muito grandes.

**Input:**
- JSONL log com entries: {timestamp, phase, model, content_chars, actual_tokens_used}
- Thresholds: warning = 25k, critical = 35k

**Output:**
Relatório agregado mostrando:
- Tokens por fase (qual ficou maior?)
- Tokens por modelo (Haiku vs Sonnet vs Opus)
- Alertas: ⚠️ se > 25k, 🔴 se > 35k
- Recomendações de split

**Prompt:**
```
Você é monitor de context health.

CONTEXT LOG:
{{CONTEXT_LOG_JSONL}}

Analise:
1. **Por Fase:** Qual gastou mais? Está acima de warning (25k)?
2. **Por Modelo:** Qual modelo gasta mais em média?
3. **Alertas:**
   - ⚠️ Fases > 25k tokens (aviso, considerar split)
   - 🔴 Fases > 35k tokens (crítico, MUST split)
4. **Recomendações:** Se fase X > 25k, sugira dividir em X.1 e X.2

Retorne Markdown com:
# Context Health Report

## Sumário
- Total tokens: XXX
- Fases: A (YYYk), B (ZZZk)
- Status: [🟢 Saudável] [🟡 Aviso] [🔴 Crítico]

## Recomendações
- Se fase > 25k: sugira split

## Timeline
Últimas 10 execuções com tokens gastos
```

---

## Como Usar Estes Prompts

1. **Pesquisa:** Usar PROMPT 1 após entrevista com usuário
2. **Protótipo:** Usar PROMPT 2 após PRD (dados alimentam design)
3. **Specs:** Usar PROMPT 3 após protótipo estar pronto
4. **Feedback:** Usar PROMPT 4 após coletar 3+ feedbacks
5. **Orquestração:** Usar PROMPT 5 no início do projeto
6. **Decisões:** Usar PROMPT 6 ao completar cada fase
7. **Timeline:** Usar PROMPT 7 para otimizar execution

**Template de Integração:**
```bash
# research.sh chama PROMPT 1
claude_api "PROMPT 1: Extração de Mercado" \
  --input idea="$IDEA" \
  --input transcript="$INTERVIEW" \
  --model haiku

# prototype_gen.sh chama PROMPT 2
claude_api "PROMPT 2: Geração de Wireframe" \
  --input market_data="$(cat market_data.md)" \
  --input prd="$(cat prd.md)" \
  --model haiku

# etc.
```
