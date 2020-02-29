import os
import sys
import base64
import hashlib
import sqlite3


import six
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives.ciphers import Cipher
from cryptography.hazmat.primitives.ciphers.algorithms import AES
from cryptography.hazmat.primitives.ciphers.modes import CFB8

padding_string = b'}'
iv_size = AES.block_size // 8

def pad(key):
    """Add padding to the key."""

    if isinstance(key, six.text_type):
        key = key.encode()

    # Key must be maximum 32 bytes long, so take first 32 bytes
    key = key[:32]

    # If key size is 16, 24 or 32 bytes then padding is not required
    if len(key) in (16, 24, 32):
        return key

    # Add padding to make key 32 bytes long
    return key.ljust(32, padding_string)



conn = sqlite3.connect('/data/config/pgadmin4.db')
c = conn.cursor()

i = 0

while True:

    i = i + 1

    sfx = str(i) if i>1 else ''

    name = os.getenv('SETUP_SERVER'+sfx+'_NAME')
    host = os.getenv('SETUP_SERVER'+sfx+'_HOST')
    port = os.getenv('SETUP_SERVER'+sfx+'_PORT')
    user = os.getenv('SETUP_SERVER'+sfx+'_USER')
    pwd  = os.getenv('SETUP_SERVER'+sfx+'_PASS')

    if not name or not host or not port or not user:
        break

    encpwd = None

    if pwd:
        key = c.execute("select password from user where id=1").fetchone()[0]
        iv = os.urandom(iv_size)
        cipher = Cipher(AES(pad(key)), CFB8(iv), default_backend())
        encryptor = cipher.encryptor()
        if isinstance(pwd, six.text_type):
            pwd = pwd.encode()
        encpwd = base64.b64encode(iv + encryptor.update(pwd) + encryptor.finalize())

    params = (i, name, host, port, user, encpwd)
    c.execute("""
    INSERT INTO server (
            id,
            user_id, servergroup_id, name, host, port, maintenance_db
            , username
            , password
            /*, role*/
            , ssl_mode
            /*, comment, discovery_id, hostaddr,
            db_res, passfile, sslcert, sslkey, sslrootcert, sslcrl,
            sslcompression, bgcolor, fgcolor, service, use_ssh_tunnel,
            tunnel_host, tunnel_port, tunnel_username, tunnel_authentication,
            tunnel_identity_file*/
    ) VALUES (
       ?,
       1, 1, ?, ?, ?, 'postgres'
       , ?
       , ?
       /*, NULL*/
       , 'prefer'
       /*, NULL, NULL, '',
       '', NULL, '<STORAGE_DIR>/.postgresql/postgresql.crt', '<STORAGE_DIR>/.postgresql/postgresql.key', NULL, NULL,
       0, NULL, NULL, NULL, 0,
       NULL, '22', NULL, 0,
       NULL*/
    )
    """, params)

conn.commit()
conn.close()
