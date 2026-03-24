#!/usr/bin/env python3

"""
ProductFlow_V5 — Subagentes Declarativos (CHUNK 2.3)
Orchestrador que executa múltiplos agentes em paralelo baseado em YAML config.

Uso:
    python3 subagents_orchestrator.py --config agents.yaml --project .
"""

import json
import yaml
import subprocess
import sys
import os
from datetime import datetime
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

class SubagentsOrchestrator:
    """Orchestrador declarativo de subagentes."""

    def __init__(self, config_path):
        """Carrega configuração de agentes."""
        self.config_path = config_path
        self.agents_config = self._load_config()
        self.execution_log = []

    def _load_config(self):
        """Lê YAML com specs dos agentes."""
        try:
            with open(self.config_path, 'r', encoding='utf-8') as f:
                return yaml.safe_load(f) or {}
        except FileNotFoundError:
            print(f"❌ Erro: {self.config_path} não encontrado")
            return {}

    def _execute_agent(self, agent_name, agent_spec):
        """Executa um agente individual."""
        print(f"  🤖 Iniciando: {agent_name}")

        execution = {
            "agent": agent_name,
            "started_at": datetime.now().isoformat(),
            "status": "pending",
            "model": agent_spec.get("model", "unknown"),
            "inputs": agent_spec.get("inputs", []),
            "outputs": agent_spec.get("outputs", []),
        }

        try:
            # Simular execução (em produção, seria chamada real de API)
            context_budget = agent_spec.get("context_budget", 10000)
            inputs_str = ", ".join(agent_spec.get("inputs", []))

            # Aqui a lógica real chamaria Claude API
            # Por agora, apenas simular sucesso
            execution["status"] = "completed"
            execution["context_used"] = int(context_budget * 0.7)  # 70% do budget
            execution["tokens_estimated"] = int(execution["context_used"] / 4)  # 1 token ~= 4 chars

            print(f"    ✅ Completado: {agent_name}")
        except Exception as e:
            execution["status"] = "failed"
            execution["error"] = str(e)
            print(f"    ❌ Erro em {agent_name}: {e}")

        execution["completed_at"] = datetime.now().isoformat()
        return execution

    def execute_parallel(self):
        """Executa agentes paralelos (sem dependências)."""
        print("\n📊 Executando Subagentes em Paralelo...")
        print("━" * 50)

        parallel_agents = self.agents_config.get("parallel", {})

        if not parallel_agents:
            print("  (nenhum agente paralelo configurado)")
            return

        with ThreadPoolExecutor(max_workers=4) as executor:
            futures = {
                executor.submit(self._execute_agent, name, spec): name
                for name, spec in parallel_agents.items()
            }

            for future in as_completed(futures):
                execution = future.result()
                self.execution_log.append(execution)

    def execute_sequential(self):
        """Executa agentes sequenciais (com dependências)."""
        print("\n📊 Executando Subagentes em Sequência...")
        print("━" * 50)

        sequential_agents = self.agents_config.get("sequential", {})

        for agent_name, agent_spec in sequential_agents.items():
            execution = self._execute_agent(agent_name, agent_spec)
            self.execution_log.append(execution)

            # Validar dependência
            if "depends_on" in agent_spec:
                dep_status = next(
                    (e["status"] for e in self.execution_log if e["agent"] == agent_spec["depends_on"]),
                    None
                )
                if dep_status != "completed":
                    print(f"  ⚠️  Dependência {agent_spec['depends_on']} não completa. Pulando {agent_name}.")
                    execution["status"] = "skipped"

    def generate_report(self, output_file="subagents_report.md"):
        """Gera relatório de execução."""
        total_agents = len(self.execution_log)
        completed = sum(1 for e in self.execution_log if e["status"] == "completed")
        total_tokens = sum(e.get("tokens_estimated", 0) for e in self.execution_log)

        report = f"""# Subagentes Execution Report

**Data:** {datetime.now().isoformat()}
**Total Agentes:** {total_agents}
**Completados:** {completed}/{total_agents}
**Tokens Gastos:** {total_tokens:,}

---

## Execução Paralela
"""

        parallel_execs = [e for e in self.execution_log if e.get("status") == "completed"]
        for execution in parallel_execs:
            report += f"\n### {execution['agent']}\n"
            report += f"- Model: {execution['model']}\n"
            report += f"- Status: ✅ {execution['status']}\n"
            report += f"- Context usado: {execution.get('context_used', 0):,} chars\n"
            report += f"- Tokens: {execution.get('tokens_estimated', 0):,}\n"

        report += "\n---\n\n## Timeline\n"
        for execution in self.execution_log:
            started = execution.get("started_at", "?")
            completed = execution.get("completed_at", "?")
            report += f"- {execution['agent']}: {started} → {completed}\n"

        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(report)

        print(f"\n📄 Relatório salvo em {output_file}")
        return report

    def run(self):
        """Orquestra execução completa."""
        print("\n" + "="*50)
        print("SUBAGENTES DECLARATIVOS (CHUNK 2.3)")
        print("="*50)

        # Executar paralelos primeiro
        self.execute_parallel()

        # Depois sequenciais
        self.execute_sequential()

        # Gerar relatório
        self.generate_report()

        # Sumário
        print("\n" + "="*50)
        completed = sum(1 for e in self.execution_log if e["status"] == "completed")
        print(f"✅ {completed}/{len(self.execution_log)} agentes completados")
        print("="*50)


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Orchestrador de Subagentes")
    parser.add_argument("--config", default="subagents.yaml", help="Path to agents config YAML")
    parser.add_argument("--project", default=".", help="Project directory")
    args = parser.parse_args()

    orchestrator = SubagentsOrchestrator(args.config)
    orchestrator.run()
