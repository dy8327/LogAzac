from log_reader import read_all_lines
from parsers.integration_parser import parse_file
from rules.integration_rules import analyze
def analyze_common(file_path, active_rules):
    return analyze(parse_file(file_path), active_rules)
