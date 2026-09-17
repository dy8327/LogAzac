"""Existing external request/response support, with neutral public labels."""
import re
from log_reader import read_all_lines
RESPONSE = re.compile(r'<CODE>\s*(.*?)\s*</CODE>.*?<MESSAGE>(.*?)</MESSAGE>', re.I)
DEVICE = re.compile(r'\bCATSN=([A-Za-z0-9]+)', re.I)

def parse_file(file_path=None, lines=None):
    lines = read_all_lines(file_path) if lines is None else lines
    records, current, pending = [], None, ''
    previous_response = None
    def finish():
        nonlocal current
        if current:
            current['raw_log'] = '\n'.join(current.pop('raw_lines'))
            records.append(current)
            current = None
    for number, line in enumerate(lines, 1):
        text = line.strip()
        if 'INPUT:' in text.upper():
            finish()
            match = DEVICE.search(text)
            pending = match[1] if match else ''
            previous_response = None
        if re.search(r'[?&]BSN_DAY=', text) and '&BODYS=' in text:
            finish()
            current = {'line_no': number, 'line_end': number, 'line_numbers': [number], 'device_id': pending, 'operation_id': f'RESPONSE:{number}', 'operation': 'SALES_REQUEST', 'business_date': re.search(r'BSN_DAY=([^&\s]+)', text)[1], 'raw_lines': [text], 'response_code': None, 'response_message': None, 'result_status': 'UNKNOWN'}
            pending = ''
            previous_response = None
        match = RESPONSE.search(text)
        if match:
            response = (match[1], match[2])
            if not current and previous_response == response and records and number - records[-1]['line_end'] <= 3 and 'RESULT=' in text.upper():
                records[-1]['line_end'] = number
                records[-1]['line_numbers'].append(number)
                records[-1]['raw_log'] += '\n' + text
                continue
            if not current:
                current = {'line_no': number, 'line_end': number, 'line_numbers': [], 'device_id': '', 'operation_id': f'RESPONSE:{number}', 'operation': 'UNLINKED_RESPONSE', 'business_date': None, 'raw_lines': [], 'response_code': None, 'response_message': None, 'result_status': 'UNKNOWN'}
            current['line_end'] = number
            current['line_numbers'].append(number)
            current['raw_lines'].append(text)
            current['response_code'], current['response_message'] = response
            # An orphan response cannot establish the result of an unidentified request.
            if current['operation'] != 'UNLINKED_RESPONSE':
                current['result_status'] = 'SUCCESS' if match[1] == '1' else 'ERROR'
            finish()
            previous_response = response
    finish()
    return records
