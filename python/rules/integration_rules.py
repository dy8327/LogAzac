LABELS = {'PAYMENT': '결제 전송', 'PRODUCT_SALES': '상품 매출 전송', 'PAYMENT_METHOD_TOTAL': '결제수단 집계 전송', 'UNLINKED': '연결 미확인 작업'}

def classify_error(errors):
    text = '\n'.join(errors)
    if 'ORA-00001' in text or 'ORA-01400' in text:
        return 'CONSTRAINT_ERROR', '중복 데이터 또는 필수값 NULL 오류 (원인 컬럼은 근거 확인 필요)'
    if 'ORA-20001' in text and '일마감처리된 영업장' in text:
        return 'BUSINESS_PROCESS_ERROR', '일마감 처리 오류'
    return 'DB_TRANSFER_FAILED', '명시적인 DB 처리 실패'

def analyze(records, active_rules):
    results = []
    for r in records:
        status = r['result_status']
        rule, message = ('DB_TRANSFER_SUCCESS', 'SQL 실행 성공') if status == 'SUCCESS' else ('DB_TRANSFER_UNKNOWN', '처리 결과 미확인') if status == 'UNKNOWN' else classify_error(r['errors'])
        if rule not in active_rules and status == 'ERROR' and 'DB_TRANSFER_FAILED' in active_rules:
            rule = 'DB_TRANSFER_FAILED'
        if rule in active_rules:
            results.append({'log_no': r['line_no'], 'line_no': r['line_no'], 'line_end': r['line_end'], 'device_id': r['device_id'], 'slot_code': None, 'rule_type': rule, 'detected_value': f"{LABELS.get(r['operation'], '처리 작업')} - {message}", 'raw_log': r['raw_log'], 'result_status': status, 'category': 'EXTERNAL_RESEND', 'finding_type': 'PROCESS_RESULT', 'operation_id': r['operation_id'], 'operation_type': r['operation'], 'business_date': r['business_date'], 'transaction_key': r['transaction_key'], 'reason_code': r['reason_code']})
    return results
