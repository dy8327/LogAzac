import sys
import json
from log_type_detector import detect_log_type, DEVICE_STATUS, EXTERNAL_RETRANSMISSION, EXTERNAL_INTEGRATION
from parsers.device_status_parser import parse_file as parse_device_status
from parsers.retransmission_parser import parse_file as parse_retransmission
from parsers.integration_parser import parse_file as parse_integration
from rule_engine import analyze

sys.stdout.reconfigure(encoding="utf-8")

def read_all_lines(file_path):
    for encoding in ["utf-8", "cp949", "euc-kr"]:
        try:
            with open(file_path, "r", encoding=encoding) as file:
                return file.readlines()
        except UnicodeDecodeError:
            continue
    raise ValueError("지원하지 않는 파일 인코딩입니다.")

def parse_by_log_type(log_type, file_path):
    if log_type == DEVICE_STATUS:
        return parse_device_status(file_path)
    if log_type == EXTERNAL_RETRANSMISSION:
        return parse_retransmission(file_path)
    if log_type == EXTERNAL_INTEGRATION:
        return parse_integration(file_path)
    return []

def main():
    if len(sys.argv) < 2:
        print(json.dumps({
            "success": False,
            "message": "분석할 로그파일 경로가 없습니다.",
            "results": []
        }, ensure_ascii=False))
        return

    file_path = sys.argv[1]

    try:
        lines = read_all_lines(file_path)
        if not any(line.strip() for line in lines):
            raise ValueError("빈 로그 파일입니다.")

        log_type = detect_log_type(lines)
        active_rules = set(sys.argv[2].split(",")) if len(sys.argv) >= 3 and sys.argv[2] else set()
        records = parse_by_log_type(log_type, file_path)
        results = analyze(log_type, records, active_rules)

        json_results = []
        for result in results:
            json_results.append({
                "logNo": result["log_no"],
                "lineNo": result["line_no"],
                "deviceId": result["device_id"],
                "ruleType": result["rule_type"],
                "slotCode": result["slot_code"],
                "detectedValue": result["detected_value"],
                "rawLog": result["raw_log"],
                "resultStatus": result.get("result_status", "ERROR")
            })

        success_count = sum(1 for result in results if result.get("result_status") == "SUCCESS")
        error_count = sum(1 for result in results if result.get("result_status") != "SUCCESS")
        success_devices = {
            result["device_id"]
            for result in results
            if result.get("result_status") == "SUCCESS" and result.get("device_id")
        }
        failure_devices = {
            result["device_id"]
            for result in results
            if result.get("result_status") != "SUCCESS" and result.get("device_id")
        }

        print(json.dumps({
            "success": True,
            "logType": log_type,
            "totalLines": len(lines),
            "successDeviceCount": len(success_devices),
            "successCount": success_count,
            "failureDeviceCount": len(failure_devices),
            "errorCount": error_count,
            "results": json_results
        }, ensure_ascii=False))

    except ValueError as e:
        print(json.dumps({
            "success": False,
            "message": str(e),
            "results": []
        }, ensure_ascii=False))
    except Exception:
        print(json.dumps({
            "success": False,
            "message": "로그 분석 중 오류가 발생했습니다.",
            "results": []
        }, ensure_ascii=False))

if __name__ == "__main__":
    main()