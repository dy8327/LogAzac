import re

START_PATTERN = re.compile(r"INFO\s+mysql\s+-\s+(?P<command>selectPaymentDB|selectProductDB|selectPayTypeDB)\((?P<device>[^)]+)\)", re.IGNORECASE)
INSERT_PATTERN = re.compile(r"DEBUG\s+oracle\s+-\s+(?P<command>InsertPayment|InsertProductPayment|InsertPaymentType)\(\)\s+SQL=", re.IGNORECASE)
SECTION_END_PATTERN = re.compile(r"INFO\s+mysql\s+-\s+(PAYMENT|PRODUCT|PAYTYPE):|INFO\s+main\s+-\s+.*finish", re.IGNORECASE)

OPERATION_MAP = {
    "selectpaymentdb": "PAYMENT",
    "selectproductdb": "PRODUCT",
    "selectpaytypedb": "PAYMENT_TYPE"
}

def read_lines(file_path):
    for encoding in ["utf-8", "cp949", "euc-kr"]:
        try:
            with open(file_path, "r", encoding=encoding) as file:
                return file.readlines()
        except UnicodeDecodeError:
            continue
    raise ValueError("지원하지 않는 파일 인코딩입니다.")

def create_record(match, line_no, text):
    command = match.group("command")
    return {
        "line_no": line_no,
        "device_id": match.group("device").strip(),
        "operation": OPERATION_MAP[command.lower()],
        "insert_executed": False,
        "completed": False,
        "errors": [],
        "raw_lines": [text]
    }

def finalize_record(record, records, completed):
    if record is None:
        return
    record["completed"] = completed
    record["raw_log"] = "\n".join(record["raw_lines"])
    records.append(record)

def parse_file(file_path):
    lines = read_lines(file_path)
    records = []
    current = None

    for line_no, line in enumerate(lines, start=1):
        text = line.strip()
        if not text:
            continue

        start_match = START_PATTERN.search(text)
        if start_match:
            finalize_record(current, records, True)
            current = create_record(start_match, line_no, text)
            continue

        if current is None:
            continue

        current["raw_lines"].append(text)

        if INSERT_PATTERN.search(text):
            current["insert_executed"] = True

        if "ERROR " in text.upper() or "ORA-" in text.upper():
            current["errors"].append(text)

        if SECTION_END_PATTERN.search(text):
            finalize_record(current, records, True)
            current = None

    if current is not None:
        finalize_record(current, records, False)

    return records