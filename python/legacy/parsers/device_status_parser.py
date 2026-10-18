import re

RECORD_START = re.compile(r"^\s*(\d+)\s+(\d+)\s+PS\s+CSTA=")
TOYG_PATTERN = re.compile(r"TOYG(?P<slot>\d{2})=(?P<stock>[^,\s]*),(?P<price>[^,\s]*),(?P<name>.*?)(?=\s+TOYG\d{2}=|\s+\d{4}-\d{2}-\d{2}\s+(?:오전|오후)|$)")

def read_records(file_path):
    encodings = ["utf-8", "cp949", "euc-kr"]
    lines = None
    for encoding in encodings:
        try:
            with open(file_path, "r", encoding=encoding) as file:
                lines = file.readlines()
            break
        except UnicodeDecodeError:
            continue
    if lines is None:
        raise ValueError("지원하지 않는 파일 인코딩입니다.")

    records = []
    current_record = ""
    current_line_no = None

    for line_no, line in enumerate(lines, start=1):
        line = line.strip()
        if not line:
            continue
        if RECORD_START.match(line):
            if current_record:
                records.append({"line_no": current_line_no, "content": current_record})
            current_record = line
            current_line_no = line_no
        elif current_record:
            if line.startswith("그리고") or line.startswith("혹시"):
                records.append({"line_no": current_line_no, "content": current_record})
                current_record = ""
                current_line_no = None
                continue
            current_record += " " + line

    if current_record:
        records.append({"line_no": current_line_no, "content": current_record})
    return records

def parse_record(record):
    start_match = RECORD_START.match(record)
    if not start_match:
        return None

    log_no = int(start_match.group(1))
    device_id = start_match.group(2)

    csta_match = re.search(r"CSTA=([GX]+)", record)
    csta = csta_match.group(1) if csta_match else None

    slots = []
    for match in TOYG_PATTERN.finditer(record):
        slots.append({
            "slot_code": "TOYG" + match.group("slot"),
            "stock": match.group("stock").strip(),
            "price": match.group("price").strip(),
            "product_name": match.group("name").strip()
        })

    return {
        "log_no": log_no,
        "device_id": device_id,
        "csta": csta,
        "slots": slots,
        "raw_log": record
    }

def parse_file(file_path):
    parsed_records = []
    for record in read_records(file_path):
        parsed = parse_record(record["content"])
        if parsed is None:
            continue
        parsed["line_no"] = record["line_no"]
        parsed_records.append(parsed)
    return parsed_records