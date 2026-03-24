#!/usr/bin/env python3

"""
ProductFlow_V5 — Context Rot Detector (CHUNK 2.1)

Detecta se fases estão estourando o limite de context tokens (25k para degradação).
Recomenda splits se necessário.

Uso:
    python3 context_rot_detector.py --blueprint blueprint.md
    python3 context_rot_detector.py --analyze market_data.md prd.md
"""

import os
import sys
import json
import re
from pathlib import Path
from typing import Dict, List, Tuple

# Estimativas simples de tokens (1 token ≈ 4 caracteres em inglês, 3-5 em português)
TOKEN_PER_CHAR = {
    'en': 0.25,
    'pt': 0.20  # Português é mais compacto
}

class ContextRotDetector:
    def __init__(self, language='pt'):
        self.language = language
        self.token_ratio = TOKEN_PER_CHAR.get(language, 0.25)
        self.warning_threshold = 25000  # ⚠️ Alerta em 25k
        self.critical_threshold = 35000  # 🔴 Crítico em 35k

    def estimate_tokens(self, text: str) -> int:
        """Estimar tokens em um texto."""
        char_count = len(text)
        return int(char_count * self.token_ratio)

    def read_file(self, filepath: str) -> str:
        """Ler arquivo com tratamento de erros."""
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                return f.read()
        except FileNotFoundError:
            return ""
        except Exception as e:
            print(f"⚠️ Erro ao ler {filepath}: {e}", file=sys.stderr)
            return ""

    def analyze_file_tokens(self, filepath: str) -> Tuple[int, str]:
        """Analisar tokens de um arquivo."""
        content = self.read_file(filepath)
        tokens = self.estimate_tokens(content)
        return tokens, content

    def analyze_blueprint(self, blueprint_path: str) -> Dict:
        """Analisar blueprint.md e estimar tokens por fase."""
        content = self.read_file(blueprint_path)

        # Extrair seções de fases
        phases = {}
        phase_pattern = r'### Phase (\d+[a-z]?).*?\n(.*?)(?=### Phase|$)'

        for match in re.finditer(phase_pattern, content, re.IGNORECASE | re.DOTALL):
            phase_name = f"Phase {match.group(1)}"
            phase_content = match.group(2)
            tokens = self.estimate_tokens(phase_content)

            phases[phase_name] = {
                'tokens': tokens,
                'status': '✅ OK' if tokens < self.warning_threshold else (
                    '⚠️ CAUTION' if tokens < self.critical_threshold else '🔴 CRITICAL'
                ),
                'recommendation': self._recommend_action(tokens)
            }

        return phases

    def _recommend_action(self, tokens: int) -> str:
        """Recomendar ação baseado em token count."""
        if tokens < self.warning_threshold:
            return "OK — Continuar com modelo atual"
        elif tokens < self.critical_threshold:
            return "⚠️ Considere splitar fase em sub-fases"
        else:
            return "🔴 OBRIGATÓRIO splitar fase — risco de degradação"

    def analyze_project(self, project_dir: str) -> Dict:
        """Analisar contexto completo de um projeto."""
        analysis = {
            'project': os.path.basename(project_dir),
            'timestamp': self._get_timestamp(),
            'files': {},
            'total_tokens': 0,
            'warnings': [],
            'critical': []
        }

        # Analisar arquivos principais
        files_to_check = {
            'market_data.md': 'Pesquisa de Mercado',
            'prd.md': 'Product Requirements',
            'blueprint.md': 'Arquitetura',
            'spec_checklist.md': 'Validação de Specs'
        }

        for filename, description in files_to_check.items():
            filepath = os.path.join(project_dir, filename)
            if os.path.exists(filepath):
                tokens, _ = self.analyze_file_tokens(filepath)
                analysis['files'][filename] = {
                    'tokens': tokens,
                    'description': description,
                    'status': self._get_token_status(tokens)
                }
                analysis['total_tokens'] += tokens

                if tokens > self.critical_threshold:
                    analysis['critical'].append(f"{filename} ({tokens}k tokens)")
                elif tokens > self.warning_threshold:
                    analysis['warnings'].append(f"{filename} ({tokens}k tokens)")

        return analysis

    def _get_token_status(self, tokens: int) -> str:
        """Obter status visual baseado em tokens."""
        if tokens < self.warning_threshold:
            return "✅"
        elif tokens < self.critical_threshold:
            return "⚠️"
        else:
            return "🔴"

    def _get_timestamp(self) -> str:
        """Get ISO timestamp."""
        from datetime import datetime
        return datetime.now().isoformat()

    def suggest_splits(self, blueprint_path: str) -> List[str]:
        """Sugerir onde splitar fases baseado em tokens."""
        phases = self.analyze_blueprint(blueprint_path)
        suggestions = []

        for phase, data in phases.items():
            if data['tokens'] > self.critical_threshold:
                suggestions.append(
                    f"❌ {phase}: {data['tokens']}k tokens — SPLIT OBRIGATÓRIO\n"
                    f"   Sugestão: Dividir em {phase}a (primeira metade) e {phase}b (segunda metade)"
                )
            elif data['tokens'] > self.warning_threshold:
                suggestions.append(
                    f"⚠️ {phase}: {data['tokens']}k tokens — CONSIDERE SPLIT\n"
                    f"   Se tiver múltiplas tarefas, dividir melhoraria qualidade"
                )

        return suggestions

    def export_report(self, analysis: Dict, output_file: str = None):
        """Exportar relatório de análise."""
        report = f"""# Context Rot Analysis Report

**Projeto:** {analysis['project']}
**Timestamp:** {analysis['timestamp']}

## Resumo

- **Total de Tokens:** {analysis['total_tokens']:,}
- **Archivos Analisados:** {len(analysis['files'])}
- **Warnings:** {len(analysis['warnings'])}
- **Critical:** {len(analysis['critical'])}

## Análise por Arquivo

"""

        for filename, data in analysis['files'].items():
            report += f"""
### {filename} {data['status']}

- **Descrição:** {data['description']}
- **Tokens:** {data['tokens']:,}
- **Status:** {data['status']}
"""

        if analysis['warnings']:
            report += "\n## ⚠️ Avisos\n\n"
            for warning in analysis['warnings']:
                report += f"- {warning}\n"

        if analysis['critical']:
            report += "\n## 🔴 Críticos\n\n"
            for critical in analysis['critical']:
                report += f"- {critical}\n"

        report += "\n## Recomendações\n\n"
        if analysis['total_tokens'] > self.critical_threshold:
            report += "- ❌ Total de contexto CRÍTICO. Splitar fases obrigatoriamente.\n"
        elif analysis['total_tokens'] > self.warning_threshold:
            report += "- ⚠️ Contexto elevado. Considere splitar fases maiores.\n"
        else:
            report += "- ✅ Contexto dentro do limite seguro.\n"

        if output_file:
            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(report)
            print(f"✅ Report salvo em {output_file}")

        return report


def main():
    import argparse

    parser = argparse.ArgumentParser(description='Detect context rot in ProductFlow phases')
    parser.add_argument('--blueprint', help='Arquivo blueprint.md para analisar')
    parser.add_argument('--analyze', nargs='+', help='Analisar arquivos específicos')
    parser.add_argument('--project', help='Diretório do projeto para análise completa')
    parser.add_argument('--output', help='Salvar report em arquivo')
    parser.add_argument('--lang', default='pt', choices=['en', 'pt'], help='Idioma do conteúdo')

    args = parser.parse_args()

    detector = ContextRotDetector(language=args.lang)

    if args.blueprint:
        print("🔍 Analisando blueprint.md...")
        phases = detector.analyze_blueprint(args.blueprint)

        print("\n📊 Análise por Fase:\n")
        for phase, data in phases.items():
            print(f"{data['status']} {phase}: {data['tokens']:,} tokens")
            print(f"   → {data['recommendation']}\n")

        suggestions = detector.suggest_splits(args.blueprint)
        if suggestions:
            print("\n💡 Sugestões de Split:\n")
            for suggestion in suggestions:
                print(f"{suggestion}\n")

    elif args.analyze:
        print("🔍 Analisando arquivos...\n")
        total_tokens = 0
        for filepath in args.analyze:
            if os.path.exists(filepath):
                tokens, content = detector.analyze_file_tokens(filepath)
                total_tokens += tokens
                print(f"{detector._get_token_status(tokens)} {filepath}: {tokens:,} tokens")
            else:
                print(f"❌ Arquivo não encontrado: {filepath}")

        print(f"\n📊 Total: {total_tokens:,} tokens")
        if total_tokens > detector.critical_threshold:
            print("🔴 CRÍTICO: Contexto muito grande. Splitar obrigatoriamente.")
        elif total_tokens > detector.warning_threshold:
            print("⚠️ AVISO: Contexto elevado. Considere splitar.")

    elif args.project:
        print("🔍 Analisando projeto...\n")
        analysis = detector.analyze_project(args.project)

        for filename, data in analysis['files'].items():
            print(f"{data['status']} {filename}: {data['tokens']:,} tokens ({data['description']})")

        print(f"\n📊 Total: {analysis['total_tokens']:,} tokens")

        if analysis['critical'] or analysis['warnings']:
            if analysis['critical']:
                print(f"\n🔴 {len(analysis['critical'])} arquivo(s) crítico(s)")
            if analysis['warnings']:
                print(f"⚠️ {len(analysis['warnings'])} aviso(s)")
        else:
            print("\n✅ Todos os arquivos dentro dos limites")

        if args.output:
            detector.export_report(analysis, args.output)

    else:
        parser.print_help()


if __name__ == '__main__':
    main()
