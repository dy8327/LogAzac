"""SQL transfer adapter. Historical module/type names remain API-compatible."""
import re
import hashlib
from log_reader import read_all_lines, TIMESTAMP
SQL = re.compile(r'INSERT\s+INTO\s+[^\s(]+\s*\((.*?)\)\s*VALUES\s*\((.*)\)', re.I)
CALL = re.compile(r'(InsertPaymentType|InsertProductPayment|InsertPayment)\(([^)]*)\)', re.I)
SELECT = re.compile(r'(selectPaymentDB|selectProductDB|selectPayTypeDB)\(([A-Za-z0-9]+)\)', re.I)
OPS = {'insertpayment': 'PAYMENT', 'insertproductpayment': 'PRODUCT_SALES', 'insertpaymenttype': 'PAYMENT_METHOD_TOTAL', 'selectpaymentdb': 'PAYMENT', 'selectproductdb': 'PRODUCT_SALES', 'selectpaytypedb': 'PAYMENT_METHOD_TOTAL'}
ERROR_CODE = re.compile(r'ORA-\d{5}')

def sql_fields(text):
    match = SQL.search(text)
    if not match:
        return {}
    columns = [c.strip().lower() for c in match[1].split(',')]
    values = re.findall(r"\s*('(?:''|[^'])*'|[^,']+)\s*(?:,|$)", match[2])
    if len(columns) != len(values):
        return {}
    return {key: value.strip().strip("'").replace("''", "'") for key, value in zip(columns, values)}

def parse_file(file_path=None, lines=None):
    lines = read_all_lines(file_path) if lines is None else lines
    records, context = [], None
    batch = 0
    last_sql, last_error = None, None
    def append(record, number, text):
        if number not in record['line_numbers']:
            record['line_numbers'].append(number)
            record['raw_lines'].append(text)
            record['line_end'] = number
    def create(number, text, operation, device, fields=None):
        fields = fields or {}
        date = fields.get('sale_dt') or fields.get('tran_date')
        key = '|'.join(fields.get(k, '') for k in ('machine_id', 'dept_cd', 'sale_dt', 'sale_no', 'column_no', 'tran_date', 'tran_time', 'term_no', 'mem_no'))
        record = {'batch': batch, 'line_no': number, 'line_end': number, 'line_numbers': [number], 'raw_lines': [text], 'device_id': device or '', 'operation': operation, 'business_date': date, 'transaction_key': hashlib.sha256(key.encode()).hexdigest()[:24] if fields else None, 'operation_id': f'SQL:{number}', 'errors': [], 'success_marker': False, 'db_count': None, 'ambiguous': False}
        records.append(record)
        return record
    for number, line in enumerate(lines, 1):
        text = line.strip()
        if not text:
            continue
        if re.search(r'\b(?:start|finish)\b', text, re.I) and not SQL.search(text):
            batch += 1
            context = last_sql = last_error = None
        start = SELECT.search(text)
        if start and 'ERROR' not in text.upper():
            context = (OPS[start[1].lower()], start[2])
            last_sql = last_error = None
            continue
        fields = sql_fields(text)
        call = CALL.search(text)
        if SQL.search(text):
            operation = OPS[call[1].lower()] if call else ('PRODUCT_SALES' if 'item_cd' in fields else 'PAYMENT_METHOD_TOTAL' if 'total_amt' in fields else 'PAYMENT')
            device = fields.get('machine_id') or (context[1] if context and context[0] == operation else '')
            signature = hashlib.sha256(SQL.search(text)[0].encode()).hexdigest()
            if 'setquery success' in text.lower() and last_sql and last_sql.get('sql_signature') == signature and last_sql['line_end'] == number - 1 and not last_sql['success_marker']:
                append(last_sql, number, text)
            else:
                last_sql = create(number, text, operation, device, fields)
            last_sql['sql_signature'] = signature
            last_sql['success_marker'] = 'setquery success' in text.lower()
            last_sql['ambiguous'] = not bool(fields) or bool(context and context[0] == operation and fields.get('machine_id') and context[1] != fields['machine_id'])
            context = None
            last_error = None
            continue
        count = re.search(r'dbCount=\[(-?\d+)\]', text, re.I)
        if count:
            # This legacy format has no request id: only the immediately preceding SQL is safe.
            if last_sql and last_sql['line_end'] == number - 1:
                append(last_sql, number, text)
                last_sql['db_count'] = int(count[1])
            else:
                orphan = create(number, text, 'UNLINKED', '')
                orphan['ambiguous'] = True
            last_sql = last_error = None
            continue
        if (TIMESTAMP.match(text) and (ERROR_CODE.search(text) or ('ERROR' in text.upper() and (call or SELECT.search(text))))) or (last_error and re.match(r'^ORA-\d{5}:', text)):
            identity = call or SELECT.search(text)
            if identity and identity[2]:
                operation, device = OPS[identity[1].lower()], identity[2]
                candidates = [r for r in records if r['batch'] == batch and r['device_id'] == device and r['operation'] == operation and not r['errors'] and not r['success_marker']]
                if last_sql and last_sql['device_id'] == device and last_sql['operation'] == operation and last_sql['success_marker']:
                    last_error = last_sql
                elif len(candidates) == 1:
                    last_error = candidates[0]
                elif SELECT.search(text) and last_error and last_error['device_id'] == device and last_error['operation'] == operation:
                    pass  # Upper-layer duplicate of the immediately observed database failure.
                else:
                    last_error = create(number, text, operation, device)
                    for candidate in candidates:
                        candidate['ambiguous'] = True
            elif not TIMESTAMP.match(text) and last_error:
                pass  # Stack continuation belongs only to an already observed error.
            else:
                last_error = create(number, text, 'UNLINKED', '')
            append(last_error, number, text)
            last_error['errors'].append(text)
            last_sql = None
            continue
        last_sql = last_error = None
        context = None
    for record in records:
        record['raw_log'] = '\n'.join(record.pop('raw_lines'))
        record['reason_code'] = ','.join(sorted(set(ERROR_CODE.findall('\n'.join(record['errors']))))) or None
        conflict = bool(record['errors'] and record['success_marker']) or (record['success_marker'] and record['db_count'] is not None and record['db_count'] != 1)
        record['result_status'] = 'UNKNOWN' if conflict or record['ambiguous'] else 'ERROR' if record['errors'] else 'SUCCESS' if record['success_marker'] or record['db_count'] == 1 else 'UNKNOWN'
    return records
