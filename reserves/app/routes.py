import os
from flask import abort
from flask import make_response

from app import app
from app import utils

TXT_RESP = {"Content-Type": "text/plain"}


@app.route("/")
def index():
    return os.environ.get("MSG", "Welcome to OVSCON 2022!")


@app.route("/vm/<email>", methods=["GET"])
def get_vm(email):
    if not utils.validate_email(email):
        return make_response(
            f"error: bad format attribute: email {email}", 400, TXT_RESP
        )

    vm, msg = utils.allocate_vm_for_email(email)
    if msg:
        return make_response(f"error: email {email}: {msg}", 400, TXT_RESP)
    if not vm:
        abort(500)

    return make_response(f"ssh vagrant@{vm} -i $priv_ssh_key_file", 200, TXT_RESP)


@app.route("/vm/<email>", methods=["DELETE"])
def del_vm(email):
    if not utils.validate_email(email):
        return make_response(
            f"error: bad format attribute: email {email}", 400, TXT_RESP
        )

    msg = utils.deallocate_email(email)
    if msg:
        return make_response(f"error: email {email}: {msg}", 400, TXT_RESP)
    return make_response(f"{email} de-allocated", 200, TXT_RESP)


@app.route("/key/<email>", methods=["GET"])
def get_key(email):
    if not utils.validate_email(email):
        return make_response(
            f"error: bad format attribute: email {email}", 400, TXT_RESP
        )

    if not utils.get_email(email):
        return make_response(f"forbidden: obtain /vm/{email} first", 403, TXT_RESP)
    return make_response(utils.get_key(email), 200, TXT_RESP)
