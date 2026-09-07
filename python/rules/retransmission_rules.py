SUCCESS_CODES = {"1"}
DUPLICATE_KEYWORDS = ["KEY DUPLICATE ERROR", "DUPLICATE"]

def analyze(records, active_rules):
    results = []

    for record in records:
        code = (record.get("response_code") or "").strip()
        message = (record.get("response_message") or "").strip()
        upper_message = message.upper()

        if "RETRANSMISSION_SUCCESS" in active_rules and code in SUCCESS_CODES:
            results.append({
                "log_no": record["line_no"],
                "line_no": record["line_no"],
                "device_id": record.get("device_id") or "",
                "rule_type": "RETRANSMISSION_SUCCESS",
                "slot_code": None,
                "detected_value": message or "정상 응답",
                "raw_log": record["raw_log"],
                "result_status": "SUCCESS"
            })
            continue

        if "DUPLICATE_RESPONSE" in active_rules and any(keyword in upper_message for keyword in DUPLICATE_KEYWORDS):
            results.append({
                "log_no": record["line_no"],
                "line_no": record["line_no"],
                "device_id": record.get("device_id") or "",
                "rule_type": "DUPLICATE_RESPONSE",
                "slot_code": None,
                "detected_value": message,
                "raw_log": record["raw_log"],
                "result_status": "ERROR"
            })
            continue

        if "RETRANSMISSION_FAILED" in active_rules and code not in SUCCESS_CODES:
            results.append({
                "log_no": record["line_no"],
                "line_no": record["line_no"],
                "device_id": record.get("device_id") or "",
                "rule_type": "RETRANSMISSION_FAILED",
                "slot_code": None,
                "detected_value": f"CODE={code}, MESSAGE={message}",
                "raw_log": record["raw_log"],
                "result_status": "ERROR"
            })

    return results