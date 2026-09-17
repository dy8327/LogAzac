import json
from pathlib import Path
CATALOG = {r['ruleType']: r for r in json.loads((Path(__file__).resolve().parent.parent / 'src/main/resources/analysis-rules.json').read_text(encoding='utf-8'))}
def validate_rules(active_rules):
    unsupported = active_rules - CATALOG.keys()
    if unsupported:
        raise ValueError('지원하지 않는 분석 규칙: ' + ', '.join(sorted(unsupported)))
