import sys
import json
from log_reader import read_all_lines
from parsers.device_status_parser import parse_file as parse_device
from parsers.integration_parser import parse_file as parse_sql
from parsers.retransmission_parser import parse_file as parse_response
from rules.device_status_rules import analyze as device_rules
from rules.integration_rules import analyze as sql_rules
from rules.retransmission_rules import analyze as response_rules
from rule_registry import CATALOG, validate_rules

FIELDS = {'log_no': 'logNo', 'line_no': 'lineNo', 'line_end': 'lineEnd', 'device_id': 'deviceId', 'rule_type': 'ruleType', 'slot_code': 'slotCode', 'detected_value': 'detectedValue', 'raw_log': 'rawLog', 'result_status': 'resultStatus', 'category': 'category', 'severity': 'severity', 'finding_type': 'findingType', 'operation_id': 'operationId', 'operation_type': 'operationType', 'business_date': 'businessDate', 'transaction_key': 'transactionKey', 'reason_code': 'reasonCode', 'previous_line_no': 'previousLineNo', 'previous_raw_log': 'previousRawLog', 'previous_value': 'previousValue', 'current_value': 'currentValue', 'event_time': 'eventTime'}

def analyze_file(file_path, active_rules):
    validate_rules(active_rules)
    lines = read_all_lines(file_path)
    if not any(line.strip() for line in lines):
        raise ValueError('빈 로그 파일입니다.')
    results, operations, types, covered = [], [], [], set()
    parsed_count = parse_failures = 0
    for log_type, category, parser, rules in [('DEVICE_STATUS', 'DEVICE_STATE', parse_device, device_rules), ('EXTERNAL_INTEGRATION', 'EXTERNAL_RESEND', parse_sql, sql_rules), ('EXTERNAL_RETRANSMISSION', 'EXTERNAL_DATA', parse_response, response_rules)]:
        records = parser(lines=lines)
        if not records:
            continue
        types.append(log_type)
        parsed_count += len(records)
        parse_failures += sum(not r.get('complete', True) for r in records)
        for record in records:
            covered.update(record['line_numbers'])
            if 'operation_id' in record:
                operations.append({'operationId': record['operation_id'], 'category': category, 'operationType': record['operation'], 'deviceId': record['device_id'], 'businessDate': record.get('business_date'), 'transactionKey': record.get('transaction_key'), 'resultStatus': record['result_status'], 'reasonCode': record.get('reason_code'), 'lineNo': record['line_no'], 'lineEnd': record['line_end'], 'rawLog': record['raw_log']})
        results.extend(rules(records, active_rules))
    if not types:
        raise ValueError('지원하는 업무 레코드를 찾지 못했습니다. 정상 판정할 수 없습니다.')
    for result in results:
        result['detected_value'] = result['detected_value'][:100]
        result.setdefault('severity', CATALOG[result['rule_type']]['severity'])
    serialized = [{target: r.get(source) for source, target in FIELDS.items()} for r in sorted(results, key=lambda r: (r['line_no'], r['rule_type']))]
    success_ops = [o for o in operations if o['resultStatus'] == 'SUCCESS']
    failed_ops = [o for o in operations if o['resultStatus'] == 'ERROR']
    return {'success': True, 'schemaVersion': 2, 'logType': types[0] if len(types) == 1 else 'MIXED', 'totalLines': len(lines), 'parsedRecordCount': parsed_count, 'unparsedLineCount': sum(bool(line.strip()) and n not in covered for n, line in enumerate(lines, 1)), 'parseFailureCount': parse_failures, 'changeCount': sum(r['result_status'] == 'CHANGE' for r in results), 'unknownCount': sum(o['resultStatus'] == 'UNKNOWN' for o in operations), 'failedOperationCount': len(failed_ops), 'successCount': len(success_ops), 'successDeviceCount': len({o['deviceId'] for o in success_ops if o['deviceId']}), 'failureDeviceCount': len({o['deviceId'] for o in failed_ops if o['deviceId']}), 'errorCount': sum(r['result_status'] == 'ERROR' for r in results), 'results': serialized, 'operations': operations}

def main():
    sys.stdout.reconfigure(encoding='utf-8')
    try:
        if len(sys.argv) < 2:
            raise ValueError('분석할 로그파일 경로가 없습니다.')
        active = set(filter(None, sys.argv[2].split(','))) if len(sys.argv) > 2 else set()
        result = analyze_file(sys.argv[1], active)
    except ValueError as error:
        result = {'success': False, 'message': str(error), 'results': []}
    except Exception:
        result = {'success': False, 'message': '로그 분석 중 오류가 발생했습니다.', 'results': []}
    print(json.dumps(result, ensure_ascii=False))

if __name__ == '__main__':
    main()
