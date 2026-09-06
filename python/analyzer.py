import sys
import json
import re

from detector import analyze_file
from common_detector import analyze_common, read_all_lines
from parser import RECORD_START

sys.stdout.reconfigure(encoding="utf-8")

COMMON_LOG_START = re.compile(
    r"^\[(?:\d{2}-\d{2}|\d{4}-\d{2}-\d{2})\s+"
    r"\d{2}:\d{2}:\d{2}(?:\.\d{3})?\]"
)

def validate_supported_log(file_path):
    lines = read_all_lines(file_path)
    non_empty_lines = [line.strip() for line in lines if line.strip()]

    if not non_empty_lines:
        raise ValueError("빈 로그 파일입니다.")

    if any(RECORD_START.match(line) for line in non_empty_lines):
        return

    if any(COMMON_LOG_START.match(line) for line in non_empty_lines):
        return

    raise ValueError(
        "지원하지 않는 로그 형식입니다. 파일 내용을 확인해 주세요."
    )

def main():
    if len(sys.argv) < 2:
        print(
            json.dumps({
                "success": False,
                "message": "분석할 로그파일 경로가 없습니다.",
                "results": []
            }, ensure_ascii=False)
        )
        return

    file_path = sys.argv[1]

    try:
        validate_supported_log(file_path)

        active_rules = (
            set(sys.argv[2].split(","))
            if len(sys.argv) >= 3 and sys.argv[2]
            else set()
        )

        results = analyze_file(file_path, active_rules)
        common_results = analyze_common(file_path, active_rules)
        results.extend(common_results)

        all_lines = read_all_lines(file_path)
        total_lines = len(all_lines)

        json_results = []

        for result in results:
            json_results.append({
                "logNo": result["log_no"],
                "lineNo": result["line_no"],
                "deviceId": result["device_id"],
                "ruleType": result["rule_type"],
                "slotCode": result["slot_code"],
                "detectedValue": result["detected_value"],
                "rawLog": result["raw_log"]
            })

        response = {
            "success": True,
            "totalLines": total_lines,
            "errorCount": len(json_results),
            "results": json_results
        }

        print(
            json.dumps(
                response,
                ensure_ascii=False
            )
        )

    except ValueError as e:
        print(
            json.dumps({
                "success": False,
                "message": str(e),
                "results": []
            }, ensure_ascii=False)
        )

    except Exception:
        print(
            json.dumps({
                "success": False,
                "message": "로그 분석 중 오류가 발생했습니다.",
                "results": []
            }, ensure_ascii=False)
        )

if __name__ == "__main__":
    main()