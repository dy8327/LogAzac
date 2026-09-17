from parsers.device_status_parser import parse_file
from rules.device_status_rules import analyze, has_corrupted_character
def analyze_file(file_path, active_rules):
    return analyze(parse_file(file_path), active_rules)
