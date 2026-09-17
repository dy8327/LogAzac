# Legacy source codes are retained for stored-history compatibility.
DEVICE_STATUS = "DEVICE_STATUS"
EXTERNAL_RETRANSMISSION = "EXTERNAL_RETRANSMISSION"
EXTERNAL_INTEGRATION = "EXTERNAL_INTEGRATION"
UNKNOWN = "UNKNOWN"

def detect_log_types(lines):
    from parsers.device_status_parser import parse_file as device
    from parsers.integration_parser import parse_file as sql
    from parsers.retransmission_parser import parse_file as response
    return [kind for kind, parser in [(DEVICE_STATUS, device), (EXTERNAL_INTEGRATION, sql), (EXTERNAL_RETRANSMISSION, response)] if parser(lines=lines)]

def detect_log_type(lines):
    types = detect_log_types(lines)
    return types[0] if len(types) == 1 else 'MIXED' if types else UNKNOWN
