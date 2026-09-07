import re

RESPONSE_PATTERN = re.compile(r"<CODE>(?P<code>.*?)</CODE>.*?<MESSAGE>(?P<message>.*?)</MESSAGE>", re.IGNORECASE)

def read_lines(file_path):
    for encoding in ["utf-8", "cp949", "euc-kr"]:
        try:
            with open(file_path, "r", encoding=encoding) as file:
                return file.readlines()
        except UnicodeDecodeError:
            continue
    raise ValueError("지원하지 않는 파일 인코딩입니다.")

def parse_file(file_path):
    lines = read_lines(file_path)
    records = []
    current_request = None

    for line_no, line in enumerate(lines, start=1):
        text = line.strip()
        if not text:
            continue
        upper = text.upper()

        if "START SENDJOUNSYSTEM" in upper or "JOUN:" in upper:
            current_request = {
                "line_no": line_no,
                "request": text,
                "response_code": None,
                "response_message": None,
                "raw_log": text
            }
            continue

        if "JOUN RESPONSE=" not in upper:
            continue

        match = RESPONSE_PATTERN.search(text)
        if not match:
            continue

        record = current_request.copy() if current_request else {
            "line_no": line_no,
            "request": None,
            "response_code": None,
            "response_message": None,
            "raw_log": ""
        }

        record["response_code"] = match.group("code").strip()
        record["response_message"] = match.group("message").strip()
        record["raw_log"] = (record["raw_log"] + " " + text).strip()
        records.append(record)
        current_request = None

    return records