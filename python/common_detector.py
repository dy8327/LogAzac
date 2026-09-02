def read_all_lines(file_path):
    encodings = ["utf-8", "cp949", "euc-kr"]
    for encoding in encodings:
        try:
            with open(file_path, "r", encoding=encoding) as file:
                return file.readlines()
        except UnicodeDecodeError:
            continue
    raise ValueError("지원하지 않는 파일 인코딩입니다.")

def analyze_common(file_path, active_rules):
    lines = read_all_lines(file_path)
    results = []

    for line_no, line in enumerate(lines, start=1):
        text = line.strip()
        if not text:
            continue

        if "DUPLICATE_ERROR" in active_rules and (
            "ORA-00001" in text
            or "SQLIntegrityConstraintViolationException" in text
        ):
            results.append({
                "log_no": line_no,
                "line_no": line_no,
                "device_id": "",
                "rule_type": "DUPLICATE_ERROR",
                "slot_code": None,
                "detected_value": "무결성 제약조건 위배",
                "raw_log": text
            })

        if "NULL_ERROR" in active_rules and "ORA-01400" in text:
            results.append({
                "log_no": line_no,
                "line_no": line_no,
                "device_id": "",
                "rule_type": "NULL_ERROR",
                "slot_code": None,
                "detected_value": "필수값 NULL 오류",
                "raw_log": text
            })

        if "CLOSED_BUSINESS_ERROR" in active_rules and (
            "ORA-20001" in text
            and "일마감처리된 영업장" in text
        ):
            results.append({
                "log_no": line_no,
                "line_no": line_no,
                "device_id": "",
                "rule_type": "CLOSED_BUSINESS_ERROR",
                "slot_code": None,
                "detected_value": "일마감처리된 영업장",
                "raw_log": text
            })

        if "SEND_SUCCESS" in active_rules and (
            "setQuery Success" in text
            or "dbCount=[1]" in text
        ):
            results.append({
                "log_no": line_no,
                "line_no": line_no,
                "device_id": "",
                "rule_type": "SEND_SUCCESS",
                "slot_code": None,
                "detected_value": "정상 전송",
                "raw_log": text
            })

    return results