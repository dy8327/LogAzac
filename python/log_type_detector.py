DEVICE_STATUS = "DEVICE_STATUS"
EXTERNAL_RETRANSMISSION = "EXTERNAL_RETRANSMISSION"
EXTERNAL_INTEGRATION = "EXTERNAL_INTEGRATION"
UNKNOWN = "UNKNOWN"

LOG_TYPE_SIGNATURES = {
    DEVICE_STATUS: {
        "CSTA=": 1,
        "TOYG": 1,
        " PS ": 1
    },
    EXTERNAL_RETRANSMISSION: {
        "JOUN RESPONSE=": 2,
        "SENDJOUNSYSTEM": 2,
        "JOUN:": 1,
        "<RESULTS>": 1,
        "<CODE>": 1
    },
    EXTERNAL_INTEGRATION: {
        "SELECTPRODUCTDB(": 2,
        "SELECTPAYMENTDB(": 2,
        "INSERTPRODUCTPAYMENT(": 2,
        "INSERTPAYMENT(": 2,
        "SETQUERY SUCCESS": 1,
        "DBCOUNT=[": 1,
        "ORA-": 1
    }
}

def detect_log_type(lines):
    text = "\n".join(lines).upper()
    scores = {log_type: 0 for log_type in LOG_TYPE_SIGNATURES}
    for log_type, signatures in LOG_TYPE_SIGNATURES.items():
        for signature, score in signatures.items():
            if signature in text:
                scores[log_type] += score
    detected_type = max(scores, key=scores.get)
    return detected_type if scores[detected_type] > 0 else UNKNOWN