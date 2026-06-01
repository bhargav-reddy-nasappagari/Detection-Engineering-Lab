import base64
import os
import subprocess

ENCODED_FILE = "/home/bunny/Detection-Engineering-Lab/scenarios/encoded-command-execution/encoded_payload.txt"
PAYLOAD_PATH = "/tmp/python_payload.sh"

with open(ENCODED_FILE, "r") as f:
    encoded_payload = f.read()

decoded_payload = base64.b64decode(encoded_payload)

with open(PAYLOAD_PATH, "wb") as f:
    f.write(decoded_payload)

os.chmod(PAYLOAD_PATH, 0o755)

subprocess.run(
["/bin/bash", PAYLOAD_PATH],
check=False
)
