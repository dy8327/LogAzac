def classify_error(errors):
    upper_errors = "\n".join(errors).upper()

    if "ORA-00001" in upper_errors:
        return "CONSTRAINT_ERROR", "중복 데이터 오류"
    if "ORA-01400" in upper_errors:
        return "CONSTRAINT_ERROR", "필수값 누락 오류"
    if "ORA-20001" in upper_errors and "일마감처리된 영업장" in "\n".join(errors):
        return "BUSINESS_PROCESS_ERROR", "마감 후 처리 오류"
    return "DB_TRANSFER_FAILED", "DB 처리 실패"

def analyze(records, active_rules):
    results = []

    for record in records:
        if record["insert_executed"] and record["completed"] and not record["errors"]:
            if "DB_TRANSFER_SUCCESS" in active_rules:
                results.append({
                    "log_no": record["line_no"],
                    "line_no": record["line_no"],
                    "device_id": record["device_id"],
                    "rule_type": "DB_TRANSFER_SUCCESS",
                    "slot_code": None,
                    "detected_value": f'{record["operation"]} 정상 처리',
                    "raw_log": record["raw_log"],
                    "result_status": "SUCCESS"
                })
            continue

        if record["errors"]:
            rule_type, message = classify_error(record["errors"])
            if rule_type in active_rules:
                results.append({
                    "log_no": record["line_no"],
                    "line_no": record["line_no"],
                    "device_id": record["device_id"],
                    "rule_type": rule_type,
                    "slot_code": None,
                    "detected_value": f'{record["operation"]} - {message}',
                    "raw_log": record["raw_log"],
                    "result_status": "ERROR"
                })
            elif "DB_TRANSFER_FAILED" in active_rules:
                results.append({
                    "log_no": record["line_no"],
                    "line_no": record["line_no"],
                    "device_id": record["device_id"],
                    "rule_type": "DB_TRANSFER_FAILED",
                    "slot_code": None,
                    "detected_value": f'{record["operation"]} - {message}',
                    "raw_log": record["raw_log"],
                    "result_status": "ERROR"
                })
            continue

        if "DB_TRANSFER_FAILED" in active_rules:
            results.append({
                "log_no": record["line_no"],
                "line_no": record["line_no"],
                "device_id": record["device_id"],
                "rule_type": "DB_TRANSFER_FAILED",
                "slot_code": None,
                "detected_value": f'{record["operation"]} - 처리 완료 여부 확인 불가',
                "raw_log": record["raw_log"],
                "result_status": "ERROR"
            })

    return results