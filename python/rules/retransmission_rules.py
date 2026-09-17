def analyze(records, active_rules):
    results = []
    for r in records:
        status = r['result_status']
        message = r.get('response_message') or '응답 미확인'
        rule = 'RETRANSMISSION_UNKNOWN' if status == 'UNKNOWN' else 'RETRANSMISSION_SUCCESS' if status == 'SUCCESS' else 'DUPLICATE_RESPONSE' if 'DUPLICATE' in message.upper() else 'RETRANSMISSION_FAILED'
        if rule not in active_rules and status == 'ERROR' and 'RETRANSMISSION_FAILED' in active_rules:
            rule = 'RETRANSMISSION_FAILED'
        if rule in active_rules:
            results.append({'log_no': r['line_no'], 'line_no': r['line_no'], 'line_end': r['line_end'], 'device_id': r['device_id'], 'rule_type': rule, 'slot_code': None, 'detected_value': message, 'raw_log': r['raw_log'], 'result_status': status, 'category': 'EXTERNAL_DATA', 'finding_type': 'PROCESS_RESULT', 'operation_id': r['operation_id'], 'operation_type': r['operation'], 'business_date': r['business_date']})
    return results
