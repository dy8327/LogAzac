import re
from decimal import Decimal, InvalidOperation
from rule_registry import CATALOG

def has_corrupted_character(text):
    return bool(text) and ('\ufffd' in text or any(ord(c) < 32 and c not in '\t\n\r' for c in text))

def number(value):
    if not re.fullmatch(r'\d+(?:\.\d+)?', value):
        return None
    try:
        return Decimal(value)
    except InvalidOperation:
        return None

def analyze(records, active_rules):
    previous, missing, results = {}, {}, []
    def emit(record, rule, slot=None, value='', old=None, before=None, after=None):
        if rule not in active_rules:
            return
        change = rule in {'PRICE_CHANGED', 'PRODUCT_NAME_CHANGED', 'STOCK_CHANGED', 'SLOT_RESTORED'}
        results.append({'log_no': record['log_no'], 'line_no': record['line_no'], 'line_end': record['line_end'], 'device_id': record['device_id'], 'slot_code': slot, 'rule_type': rule, 'detected_value': value, 'raw_log': record['raw_log'], 'result_status': 'CHANGE' if change else 'ERROR', 'category': 'DEVICE_STATE', 'severity': CATALOG[rule]['severity'], 'finding_type': 'CHANGE' if change else 'ANOMALY', 'previous_line_no': old['line_no'] if old else None, 'previous_raw_log': old['raw_log'] if old else None, 'previous_value': before, 'current_value': after, 'event_time': record.get('event_time')})
    for record in records:
        for slot in record['slots']:
            if not slot['product_name']:
                emit(record, 'MISSING_PRODUCT_NAME', slot['slot_code'], '상품명 누락 후보 (사용 슬롯 여부 확인 필요)')
            if has_corrupted_character(slot['product_name']):
                emit(record, 'CORRUPTED_DATA', slot['slot_code'], slot['product_name'])
        old = previous.get(record['device_id'])
        if not record['complete']:
            previous.pop(record['device_id'], None)
            missing.pop(record['device_id'], None)
            continue
        # Out-of-order observations cannot establish a new baseline.
        if old and old.get('event_time') and record.get('event_time') and record['event_time'] <= old['event_time']:
            continue
        if old:
            old_slots = {s['slot_code']: s for s in old['slots']}
            current = {s['slot_code']: s for s in record['slots']}
            absent = missing.setdefault(record['device_id'], {})
            for code in sorted(old_slots.keys() - current.keys()):
                absent[code] = old
                emit(record, 'MISSING_SLOT', code, '이전 관측 슬롯 미수신 (설정 변경/부분 수신 확인 필요)', old)
            for code in sorted(current.keys() & absent.keys()):
                emit(record, 'SLOT_RESTORED', code, '누락 후 다시 관측됨', absent.pop(code))
            for code in sorted(old_slots.keys() & current.keys()):
                for key, rule in [('price', 'PRICE_CHANGED'), ('product_name', 'PRODUCT_NAME_CHANGED'), ('stock', 'STOCK_CHANGED')]:
                    before, after = old_slots[code][key], current[code][key]
                    if not before or not after:
                        continue
                    if key != 'product_name':
                        a, b = number(before), number(after)
                        changed = a is not None and b is not None and a != b
                    else:
                        changed = before != after and not has_corrupted_character(before + after)
                    if changed:
                        emit(record, rule, code, f'{before} -> {after}', old, before, after)
        previous[record['device_id']] = record
    return results
