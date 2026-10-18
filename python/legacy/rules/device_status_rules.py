def has_corrupted_character(text):
    if not text:
        return False
    if "\ufffd" in text:
        return True
    for ch in text:
        if ord(ch) < 32 and ch not in ("\t", "\n", "\r"):
            return True
    return False

def detect_basic_errors(parsed, active_rules):
    errors = []
    corrupted_found = False

    for slot in parsed["slots"]:
        if "MISSING_PRODUCT_NAME" in active_rules and slot["product_name"] == "":
            errors.append({
                "rule_type": "MISSING_PRODUCT_NAME",
                "slot_code": slot["slot_code"],
                "detected_value": f'{slot["slot_code"]}={slot["stock"]},{slot["price"]},'
            })

        if "CORRUPTED_DATA" in active_rules and has_corrupted_character(slot["product_name"]):
            errors.append({
                "rule_type": "CORRUPTED_DATA",
                "slot_code": slot["slot_code"],
                "detected_value": slot["product_name"]
            })
            corrupted_found = True

    if "CORRUPTED_DATA" in active_rules and not corrupted_found and has_corrupted_character(parsed["raw_log"]):
        errors.append({
            "rule_type": "CORRUPTED_DATA",
            "slot_code": None,
            "detected_value": "로그 내 비정상 문자 발견"
        })

    return errors

def compare_with_previous(current, previous, active_rules):
    errors = []
    if previous is None:
        return errors

    current_slots = {slot["slot_code"]: slot for slot in current["slots"]}
    previous_slots = {slot["slot_code"]: slot for slot in previous["slots"]}

    missing_slots = set(previous_slots) - set(current_slots)
    if "MISSING_SLOT" in active_rules and missing_slots:
        errors.append({
            "rule_type": "MISSING_SLOT",
            "slot_code": None,
            "detected_value": ", ".join(sorted(missing_slots))
        })

    common_slots = set(previous_slots) & set(current_slots)

    for slot_code in sorted(common_slots):
        old = previous_slots[slot_code]
        new = current_slots[slot_code]

        if "PRICE_CHANGED" in active_rules and old["price"] and new["price"] and old["price"] != new["price"]:
            errors.append({
                "rule_type": "PRICE_CHANGED",
                "slot_code": slot_code,
                "detected_value": f'{old["price"]} -> {new["price"]}',
                "line_no": previous["line_no"],
                "raw_log": previous["raw_log"]
            })

        if "PRODUCT_NAME_CHANGED" in active_rules and old["product_name"] and new["product_name"] and old["product_name"] != new["product_name"]:
            errors.append({
                "rule_type": "PRODUCT_NAME_CHANGED",
                "slot_code": slot_code,
                "detected_value": f'{old["product_name"]} -> {new["product_name"]}',
                "line_no": previous["line_no"],
                "raw_log": previous["raw_log"]
            })

    return errors

def analyze(records, active_rules):
    previous_by_device = {}
    results = []

    for parsed in records:
        errors = []
        errors.extend(detect_basic_errors(parsed, active_rules))

        previous = previous_by_device.get(parsed["device_id"])
        errors.extend(compare_with_previous(parsed, previous, active_rules))

        for error in errors:
            results.append({
                "log_no": parsed["log_no"],
                "line_no": error.get("line_no", parsed["line_no"]),
                "device_id": parsed["device_id"],
                "rule_type": error["rule_type"],
                "slot_code": error["slot_code"],
                "detected_value": error["detected_value"],
                "raw_log": error.get("raw_log", parsed["raw_log"])
            })

        previous_by_device[parsed["device_id"]] = parsed

    return results