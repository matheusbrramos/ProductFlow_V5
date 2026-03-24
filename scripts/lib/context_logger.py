#!/usr/bin/env python3

"""
ProductFlow_V5 — Logging de Contexto (CHUNK 2.4)
Registra uso de contexto por fase, token consumption, e gera relatórios.

Uso:
    python3 context_logger.py --log project_context.jsonl --analyze
"""

import json
import os
from datetime import datetime
from pathlib import Path
from typing import Dict, List

TOKEN_PER_CHAR = {"en": 0.25, "pt": 0.20}

class ContextLogger:
    """Logger estruturado de context usage."""

    def __init__(self, log_file="project_context.jsonl"):
        self.log_file = log_file
        self.entries = []
        self._load_log()

    def _load_log(self):
        """Carrega entries existentes do JSONL."""
        if os.path.exists(self.log_file):
            try:
                with open(self.log_file, 'r', encoding='utf-8') as f:
                    for line in f:
                        if line.strip():
                            self.entries.append(json.loads(line))
            except Exception as e:
                print(f"⚠️  Erro ao carregar log: {e}")

    def log_phase(self, phase_name: str, content: str, model: str, tokens_used: int, metadata: Dict = None):
        """Registra uso de contexto em uma fase."""
        estimated_chars = len(content)
        estimated_tokens = int(estimated_chars * TOKEN_PER_CHAR.get("pt", 0.20))

        entry = {
            "timestamp": datetime.now().isoformat(),
            "phase": phase_name,
            "model": model,
            "content_chars": estimated_chars,
            "content_tokens": estimated_tokens,
            "actual_tokens_used": tokens_used or estimated_tokens,
            "metadata": metadata or {},
        }

        self.entries.append(entry)
        self._append_to_file(entry)

        return entry

    def _append_to_file(self, entry: Dict):
        """Append entry to JSONL log."""
        try:
            with open(self.log_file, 'a', encoding='utf-8') as f:
                f.write(json.dumps(entry, ensure_ascii=False) + "\n")
        except Exception as e:
            print(f"❌ Erro ao escrever log: {e}")

    def analyze(self):
        """Analisa uso de contexto e retorna estatísticas."""
        if not self.entries:
            return {"error": "Nenhuma entry registrada"}

        by_phase = {}
        by_model = {}
        total_tokens = 0
        total_chars = 0

        for entry in self.entries:
            phase = entry["phase"]
            model = entry["model"]
            tokens = entry.get("actual_tokens_used", 0)
            chars = entry["content_chars"]

            # Agregação por fase
            if phase not in by_phase:
                by_phase[phase] = {"count": 0, "tokens": 0, "chars": 0}
            by_phase[phase]["count"] += 1
            by_phase[phase]["tokens"] += tokens
            by_phase[phase]["chars"] += chars

            # Agregação por modelo
            if model not in by_model:
                by_model[model] = {"count": 0, "tokens": 0}
            by_model[model]["count"] += 1
            by_model[model]["tokens"] += tokens

            total_tokens += tokens
            total_chars += chars

        return {
            "total_entries": len(self.entries),
            "total_tokens": total_tokens,
            "total_chars": total_chars,
            "by_phase": by_phase,
            "by_model": by_model,
            "average_tokens_per_entry": int(total_tokens / len(self.entries)) if self.entries else 0,
        }

    def generate_report(self, output_file="context_usage_report.md"):
        """Gera relatório visual de uso de contexto."""
        analysis = self.analyze()

        if "error" in analysis:
            report = f"# Context Usage Report\n\n{analysis['error']}\n"
        else:
            report = f"""# Context Usage Report

**Gerado:** {datetime.now().isoformat()}

---

## Sumário

- **Total Entradas:** {analysis['total_entries']}
- **Total Tokens:** {analysis['total_tokens']:,}
- **Total Chars:** {analysis['total_chars']:,}
- **Média Tokens/Entrada:** {analysis['average_tokens_per_entry']:,}

---

## Por Fase

| Fase | Execuções | Tokens | Chars | Média |
|------|-----------|--------|-------|-------|
"""

            for phase, data in analysis["by_phase"].items():
                avg_tokens = int(data["tokens"] / data["count"]) if data["count"] > 0 else 0
                report += f"| {phase} | {data['count']} | {data['tokens']:,} | {data['chars']:,} | {avg_tokens:,} |\n"

            report += "\n---\n\n## Por Modelo\n\n| Modelo | Execuções | Tokens | Média |\n|--------|-----------|--------|-------|\n"

            for model, data in analysis["by_model"].items():
                avg_tokens = int(data["tokens"] / data["count"]) if data["count"] > 0 else 0
                report += f"| {model} | {data['count']} | {data['tokens']:,} | {avg_tokens:,} |\n"

            # Warnings
            report += "\n---\n\n## ⚠️ Alertas\n\n"

            max_phase_tokens = max(
                (data["tokens"] for data in analysis["by_phase"].values()),
                default=0
            )

            if max_phase_tokens > 25000:
                max_phase = max(
                    ((k, v["tokens"]) for k, v in analysis["by_phase"].items()),
                    key=lambda x: x[1]
                )[0]
                report += f"- 🟡 **{max_phase}** excedeu 25k tokens ({max_phase_tokens:,})\n"

            if max_phase_tokens > 35000:
                report += f"- 🔴 **CRÍTICO**: Algumas fases excederam 35k tokens\n"

            report += "\n---\n\n## Timeline\n\n"
            for entry in self.entries[-10:]:  # Últimas 10 entradas
                report += f"- {entry['timestamp']}: {entry['phase']} ({entry['model']}) → {entry['actual_tokens_used']:,} tokens\n"

        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(report)

        print(f"📄 Relatório salvo em {output_file}")
        return report

    def get_phase_budget_remaining(self, phase: str, budget: int = 25000):
        """Retorna quanto contexto ainda está disponível em uma fase."""
        phase_tokens = sum(
            e.get("actual_tokens_used", 0)
            for e in self.entries
            if e["phase"] == phase
        )
        return budget - phase_tokens


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Context Logger & Analyzer")
    parser.add_argument("--log", default="project_context.jsonl", help="Log file path")
    parser.add_argument("--analyze", action="store_true", help="Show analysis")
    parser.add_argument("--report", action="store_true", help="Generate report")
    parser.add_argument("--phase", help="Log a test phase")
    parser.add_argument("--model", default="test", help="Model name for logging")
    parser.add_argument("--tokens", type=int, default=5000, help="Tokens to log")

    args = parser.parse_args()

    logger = ContextLogger(args.log)

    if args.phase:
        entry = logger.log_phase(args.phase, "test content" * 100, args.model, args.tokens)
        print(f"✅ Logged: {entry}")

    if args.analyze:
        analysis = logger.analyze()
        print("\n📊 Análise:")
        print(json.dumps(analysis, indent=2, ensure_ascii=False))

    if args.report:
        logger.generate_report()
