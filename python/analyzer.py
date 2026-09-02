import sys
import json

from detector import analyze_file
from common_detector import analyze_common, read_all_lines

sys.stdout.reconfigure(encoding="utf-8")

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
        active_rules = set(sys.argv[2].split(",")) if len(sys.argv) >= 3 and sys.argv[2] else set()
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

    except Exception as e:
        print(
            json.dumps({
                "success": False,
                "message": str(e),
                "results": []
            }, ensure_ascii=False)
        )


if __name__ == "__main__":
    main()