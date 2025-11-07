FROM lukechilds/electrumx

COPY electrumx-patch/coins_btcp.py /electrumx/src/electrumx/lib/coins_btcp.py

RUN python3 - <<'PY'
import re, pathlib
p = pathlib.Path('/electrumx/src/electrumx/lib/coins.py')
s = p.read_text(encoding='utf-8')

if 'from electrumx.lib.coins_btcp import BitcoinPurple' not in s:
    s += '\nfrom electrumx.lib.coins_btcp import BitcoinPurple\n'

if '"BitcoinPurple": BitcoinPurple' not in s:
    s = re.sub(r'(COIN_CLASSES\s*=\s*\{)', r'\1\n    "BitcoinPurple": BitcoinPurple,', s)

p.write_text(s, encoding='utf-8')
print('>> Patched ElectrumX with BitcoinPurple coin')
PY

RUN python3 - <<'PY'
import re, pathlib

# Patch BlockProcessor to show KB for small blocks
bp_path = pathlib.Path('/electrumx/src/electrumx/server/block_processor.py')
if bp_path.exists():
    content = bp_path.read_text(encoding='utf-8')

    # Find and replace the block size formatting
    # Look for patterns like "f'{size:.2f} MB'" or similar
    pattern = r'(f["\'].*?)\{.*?size.*?:.2f\}\s*MB(.*?["\'])'

    def format_size_func(match):
        prefix = match.group(1)
        suffix = match.group(2)
        # Create a better format that shows KB when size < 1 MB
        return f"{prefix}{{size * 1024:.2f}} KB{suffix}" if 'size' in prefix else match.group(0)

    # Alternative: inject a helper function
    if 'def format_block_size' not in content:
        helper_func = '''
def format_block_size(size_mb):
    """Format block size - show KB if < 1 MB, otherwise MB"""
    if size_mb < 1.0:
        return f'{size_mb * 1024:.2f} KB'
    return f'{size_mb:.2f} MB'

'''
        # Add helper function at the beginning after imports
        import_end = content.rfind('import ')
        if import_end != -1:
            next_newline = content.find('\n', import_end)
            if next_newline != -1:
                content = content[:next_newline+1] + '\n' + helper_func + content[next_newline+1:]

        # Replace size formatting in log messages
        content = re.sub(
            r'f(["\'])(.+?)\{(size[^}]*?):.2f\}\s*MB(.+?)\1',
            r"f\1\2{format_block_size(\3)}\4\1",
            content
        )

        bp_path.write_text(content, encoding='utf-8')
        print('>> Patched BlockProcessor to show KB for small blocks')
PY

RUN mkdir -p /certs && \
    cat >/certs/openssl.cnf <<'EOF' && \
    openssl req -x509 -nodes -newkey rsa:4096 -days 3650 \
      -keyout /certs/server.key -out /certs/server.crt \
      -config /certs/openssl.cnf && \
    chmod 600 /certs/server.key && chmod 644 /certs/server.crt
[req]
distinguished_name = dn
x509_extensions = v3_req
prompt = no

[dn]
C  = IT
ST = -
L  = -
O  = ElectrumX
CN = btcp.local

[v3_req]
keyUsage         = keyEncipherment, dataEncipherment, digitalSignature
extendedKeyUsage = serverAuth
subjectAltName   = @alt_names

[alt_names]
DNS.1 = btcp.local
IP.1  = 127.0.0.1
EOF

ENV SSL_CERTFILE=/certs/server.crt
ENV SSL_KEYFILE=/certs/server.key
