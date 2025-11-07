from electrumx.lib.coins import Bitcoin
from electrumx.lib import tx as lib_tx

class BitcoinPurple(Bitcoin):
    NAME = "BitcoinPurple"
    SHORTNAME = "BTCP"
    NET = "mainnet"

    # === Prefix address ===
    P2PKH_VERBYTE = bytes([0x00])
    P2SH_VERBYTE  = bytes([0x05])
    WIF_BYTE      = bytes([0x80])

    # === bech32 prefix ===
    HRP = "btcp"

    # === Genesis hash ===
    GENESIS_HASH = "000003823fbf82ea4906cbe214617ce7a70a5da29c19ecb1d65618bcf04ec015"

    # === Deserializer ===
    DESERIALIZER = lib_tx.DeserializerSegWit

