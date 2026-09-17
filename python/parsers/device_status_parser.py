import re
from datetime import datetime
from log_reader import read_all_lines, TIMESTAMP
RECORD_START = re.compile(r"^\s*(\d+)\s+([A-Za-z0-9]+)\s+PS\s+CSTA=")
TOYG_PATTERN = re.compile(r"TOYG(?P<slot>\d{2})=(?P<stock>[^,\s]*),(?P<price>[^,\s]*),(?P<name>.*?)(?=\s+TOYG\d{2}=|\s+\d{4}-\d{2}-\d{2}\s+(?:오전|오후)|\s+[A-Z][A-Z0-9_]*=|$)")
DATE = re.compile(r'(\d{4}-\d{2}-\d{2})\s+(오전|오후)\s+(\d{1,2}):(\d{2}):(\d{2})')
def event_time(text):
    match = re.search(r'\bTIME=(\d{14})\b', text)
    try:
        if match:
            return datetime.strptime(match[1], '%Y%m%d%H%M%S').isoformat()
        match = DATE.search(text)
        if match:
            hour = int(match[3]) % 12 + (12 if match[2] == '오후' else 0)
            return datetime.fromisoformat(f'{match[1]}T{hour:02}:{match[4]}:{match[5]}').isoformat()
    except ValueError:
        pass
    return None

def read_records(file_path=None, lines=None):
    lines = read_all_lines(file_path) if lines is None else lines
    records, current = [], None
    for number, line in enumerate(lines, 1):
        text = line.strip()
        dump = RECORD_START.match(text)
        comm = TIMESTAMP.match(text) and 'CSTA=' in text and re.search(r'\bCATSN=[A-Za-z0-9]+', text)
        if dump or comm:
            if current:
                records.append(current)
            current = {'line_no': number, 'line_end': number, 'content': text, 'line_numbers': [number]}
        elif current and text and (text.startswith('TOYG') or DATE.match(text) or re.fullmatch(r'(?:OK|smartm|kya)', text, re.I)):
            current['content'] += ' ' + text
            current['line_end'] = number
            current['line_numbers'].append(number)
        elif text and current:
            records.append(current)
            current = None
    if current:
        records.append(current)
    return records

def parse_record(record):
    start = RECORD_START.match(record)
    device = re.search(r'\bCATSN=([A-Za-z0-9]+)', record)
    if not start and not device:
        return None
    slots = [{'slot_code': 'TOYG' + m['slot'], 'stock': m['stock'].strip(), 'price': m['price'].strip(), 'product_name': m['name'].strip()} for m in TOYG_PATTERN.finditer(record)]
    codes = [s['slot_code'] for s in slots]
    complete = bool(slots) and len(slots) == len(re.findall(r'TOYG\d{2}=', record)) and len(codes) == len(set(codes))
    complete = complete and all(re.fullmatch(r'\d+(?:\.\d+)?', s['stock']) and re.fullmatch(r'\d+(?:\.\d+)?', s['price']) for s in slots)
    csta = re.search(r'\bCSTA=([A-Z]+)', record)
    return {'log_no': int(start[1]) if start else 0, 'device_id': start[2] if start else device[1], 'csta': csta[1] if csta else None, 'slots': slots, 'raw_log': record, 'event_time': event_time(record), 'complete': complete}

def parse_file(file_path=None, lines=None):
    results = []
    for record in read_records(file_path, lines):
        parsed = parse_record(record['content'])
        if parsed:
            parsed.update({k: record[k] for k in ('line_no', 'line_end', 'line_numbers')})
            parsed['log_no'] = parsed['log_no'] or record['line_no']
            results.append(parsed)
    return results
