from parser import read_records, parse_record


def has_corrupted_character(text):
    if not text:
        return False

    # 파일 디코딩 실패 시 생기는 replacement character
    if "\ufffd" in text:
        return True

    # 일반 문자열에 포함되면 이상한 제어문자
    for ch in text:
        if ord(ch) < 32 and ch not in ("\t", "\n", "\r"):
            return True

    return False


def detect_basic_errors(parsed):
    errors = []
    corrupted_found = False

    for slot in parsed["slots"]:

        if slot["product_name"] == "":
            errors.append({
                "rule_type": "MISSING_PRODUCT_NAME",
                "slot_code": slot["slot_code"],
                "detected_value": (
                    f'{slot["slot_code"]}='
                    f'{slot["stock"]},'
                    f'{slot["price"]},'
                )
            })

        if has_corrupted_character(slot["product_name"]):
            errors.append({
                "rule_type": "CORRUPTED_DATA",
                "slot_code": slot["slot_code"],
                "detected_value": slot["product_name"]
            })

            corrupted_found = True

    # 슬롯에서 잡히지 않은 깨진 문자만 전체 로그 검사
    if (
        not corrupted_found
        and has_corrupted_character(parsed["raw_log"])
    ):
        errors.append({
            "rule_type": "CORRUPTED_DATA",
            "slot_code": None,
            "detected_value": "로그 내 비정상 문자 발견"
        })

    return errors

def compare_with_previous(current, previous):
    """
    동일 장비의 이전 로그와 비교해서 판단
    """
    errors = []

    if previous is None:
        return errors

    current_slots = {
        slot["slot_code"]: slot
        for slot in current["slots"]
    }

    previous_slots = {
        slot["slot_code"]: slot
        for slot in previous["slots"]
    }

    # 1. 이전 로그에 있었는데 현재 사라진 슬롯
    missing_slots = (
        set(previous_slots.keys())
        - set(current_slots.keys())
    )

    # 몇 개 빠진 정도가 아니라 대량으로 사라진 경우 우선 탐지
    if missing_slots:
        errors.append({
            "rule_type": "MISSING_SLOT",
            "slot_code": None,
            "detected_value": ", ".join(sorted(missing_slots))
        })

    # 2. 같은 슬롯의 가격 / 상품명 변경
    common_slots = (
        set(previous_slots.keys())
        & set(current_slots.keys())
    )

    for slot_code in sorted(common_slots):

        old = previous_slots[slot_code]
        new = current_slots[slot_code]

        if (
            old["price"]
            and new["price"]
            and old["price"] != new["price"]
        ):
            errors.append({
                "rule_type": "PRICE_CHANGED",
                "slot_code": slot_code,
                "detected_value": (
                    f'{old["price"]} -> {new["price"]}'
                )
            })

        if (
            old["product_name"]
            and new["product_name"]
            and old["product_name"] != new["product_name"]
        ):
            errors.append({
                "rule_type": "PRODUCT_NAME_CHANGED",
                "slot_code": slot_code,
                "detected_value": (
                    f'{old["product_name"]} -> '
                    f'{new["product_name"]}'
                )
            })

    return errors


def analyze_file(file_path):

    records = read_records(file_path)

    # 장비별 직전 로그 보관
    previous_by_device = {}

    results = []

    for record in records:

        # 실제 로그 문자열만 parser로 전달
        parsed = parse_record(record["content"])

        if parsed is None:
            continue

        # txt 파일 실제 라인 번호 저장
        parsed["line_no"] = record["line_no"]

        errors = []

        # 로그 자체 검사
        errors.extend(
            detect_basic_errors(parsed)
        )

        # 동일 장비의 이전 로그 가져오기
        previous = previous_by_device.get(
            parsed["device_id"]
        )

        # 이전 로그와 비교
        errors.extend(
            compare_with_previous(
                parsed,
                previous
            )
        )

        # 탐지 결과 저장
        for error in errors:
            results.append({
                "log_no": parsed["log_no"],
                "line_no": parsed["line_no"],
                "device_id": parsed["device_id"],
                "rule_type": error["rule_type"],
                "slot_code": error["slot_code"],
                "detected_value": error["detected_value"],
                "raw_log": parsed["raw_log"]
            })

        # 현재 로그를 다음 로그의 비교 기준으로 저장
        previous_by_device[
            parsed["device_id"]
        ] = parsed

    return results


def main():

    file_path = "02021070138상품명및금액변경건.txt"

    results = analyze_file(file_path)

    print()
    print("===== 이상 탐지 결과 =====")
    print("총 탐지 건수:", len(results))
    print()

    for result in results:

        print(
            f'로그번호 : {result["log_no"]}'
        )
        print(
            f'장비번호 : {result["device_id"]}'
        )
        print(
            f'탐지규칙 : {result["rule_type"]}'
        )
        print(
            f'슬롯     : {result["slot_code"]}'
        )
        print(
            f'탐지값   : {result["detected_value"]}'
        )
        print("-" * 60)


if __name__ == "__main__":
    main()  