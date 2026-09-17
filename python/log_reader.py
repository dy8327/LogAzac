import re
TIMESTAMP = re.compile(r"^\[(?:\d{4}-)?\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2}(?:\.\d+)?\]")
def read_all_lines(file_path):
    for encoding in ("utf-8-sig", "cp949", "euc-kr"):
        try:
            with open(file_path, encoding=encoding) as stream:
                return stream.readlines()
        except UnicodeDecodeError:
            continue
    raise ValueError("지원하지 않는 파일 인코딩입니다.")
