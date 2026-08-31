import re


# 실제 로그 시작 형태
# 예:
# 1382    0024950017    PS    CSTA=...
RECORD_START = re.compile(
    r"^\s*(\d+)\s+(\d+)\s+PS\s+CSTA="
)


# TOYG 형식
# 예:
# TOYG01=69,2500,쫀득쫀득닭연골
TOYG_PATTERN = re.compile(
    r"TOYG(?P<slot>\d{2})="
    r"(?P<stock>[^,\s]*),"
    r"(?P<price>[^,\s]*),"
    r"(?P<name>.*?)"
    r"(?=\s+TOYG\d{2}=|\s+\d{4}-\d{2}-\d{2}\s+(?:오전|오후)|$)"
)


def read_records(file_path):
    records = []

    encodings = ["utf-8", "cp949", "euc-kr"]
    lines = None

    # 파일 인코딩 자동 시도
    for encoding in encodings:
        try:
            with open(file_path, "r", encoding=encoding) as file:
                lines = file.readlines()

            break

        except UnicodeDecodeError:
            continue

    if lines is None:
        raise ValueError("지원하지 않는 파일 인코딩입니다.")

    current_record = ""
    current_line_no = None

    for line_no, line in enumerate(lines, start=1):
        line = line.strip()

        if not line:
            continue

        # 새로운 로그 시작
        if RECORD_START.match(line):
            if current_record:
                records.append({
                    "line_no": current_line_no,
                    "content": current_record
                })

            current_record = line
            current_line_no = line_no

        # 이전 로그의 이어지는 내용
        elif current_record:
            # 실제 로그 이후의 설명/메일 내용 제외
            if line.startswith("그리고") or line.startswith("혹시"):
                records.append({
                    "line_no": current_line_no,
                    "content": current_record
                })

                current_record = ""
                current_line_no = None
                continue

            current_record += " " + line

    if current_record:
        records.append({
            "line_no": current_line_no,
            "content": current_record
        })

    return records

def parse_record(record):
    """
    로그 한 건에서 기본정보와 TOYG 슬롯을 추출한다.
    """

    start_match = RECORD_START.match(record)

    if not start_match:
        return None

    log_no = int(start_match.group(1))

    # 장비번호는 앞의 0이 중요하므로 int로 변환하지 않는다.
    device_id = start_match.group(2)

    # CSTA 추출
    csta_match = re.search(r"CSTA=([GX]+)", record)

    csta = None

    if csta_match:
        csta = csta_match.group(1)

    slots = []

    for match in TOYG_PATTERN.finditer(record):

        slot_code = "TOYG" + match.group("slot")

        stock_raw = match.group("stock").strip()
        price_raw = match.group("price").strip()
        product_name = match.group("name").strip()

        slot = {
            "slot_code": slot_code,
            "stock": stock_raw,
            "price": price_raw,
            "product_name": product_name
        }

        slots.append(slot)

    return {
        "log_no": log_no,
        "device_id": device_id,
        "csta": csta,
        "slots": slots,
        "raw_log": record
    }


def main():

    file_path = "02021070138상품명및금액변경건.txt"

    records = read_records(file_path)

    print("읽은 로그 수:", len(records))
    print("=" * 70)

    for record in records:

        parsed = parse_record(record["content"])

        if parsed is None:
            continue

        parsed["line_no"] = record["line_no"]

        print("로그번호 :", parsed["log_no"])
        print("장비번호 :", parsed["device_id"])
        print("CSTA     :", parsed["csta"])
        print("슬롯 수  :", len(parsed["slots"]))

        for slot in parsed["slots"]:
            print(
                slot["slot_code"],
                "재고 =", slot["stock"],
                "가격 =", slot["price"],
                "상품명 =", slot["product_name"]
            )

        print("=" * 70)


if __name__ == "__main__":
    main()