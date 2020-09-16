import os
from pgadmin import create_app
import config
from pgadmin.utils.crypto import encrypt

from pgadmin.model import db, User, Server

app = create_app(config.APP_NAME)
with app.app_context():
    user = User.query.first()
    key = user.password
    i = 0
    while True:
        i = i + 1
        s = Server()
        sfx = str(i) if i>1 else ''
        s.name = os.getenv('SETUP_SERVER'+sfx+'_NAME')
        s.host = os.getenv('SETUP_SERVER'+sfx+'_HOST')
        s.port = os.getenv('SETUP_SERVER'+sfx+'_PORT')
        s.username = os.getenv('SETUP_SERVER'+sfx+'_USER')
        if not s.name or not s.host or not s.port or not s.username:
            break
        pwd  = os.getenv('SETUP_SERVER'+sfx+'_PASS')
        if pwd:
            s.password = encrypt(pwd, key)
            s.save_password = 1
        s.user_id = user.id
        s.servergroup_id = 1
        s.maintenance_db = 'postgres'
        s.ssl_mode = 'prefer'
        db.session.add(s)
    db.session.commit()

