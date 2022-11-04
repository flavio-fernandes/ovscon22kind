from ipaddress import IPv4Address
from flask import abort
import re
from shelljob import proc

DB_FILE = "./db.ini"
KEY_FILE = "./key.txt"


def validate_email(email):
    regex = r"\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b"
    return re.fullmatch(regex, email)


def get_email(email):
    return _lookup_crudini_section("emails", email)


def get_vm(vm):
    return _lookup_crudini_section("vms", vm)


def get_vm_from_email(email):
    vm = get_email(email)
    if vm:
        vm_ip = get_vm(vm)
        if not vm_ip:
            # weird: should never be able to have an allocation
            # email for a non-existing vm
            abort(500)
        return vm_ip


def _lookup_crudini_section(section, value):
    params = ["crudini", "--get", DB_FILE, section, value]
    raw_value, exit_code = proc.call(params, shell=False, check_exit_code=False)
    if not exit_code:
        try:
            return raw_value.split("\n")[0]
        except Exception:
            pass
        return raw_value


def allocate_vm_for_email(email):
    vm = get_vm_from_email(email)
    if vm:
        # already allocated
        return vm, None

    db = _read_dbfile()
    db_vms = db["vms"]
    db_emails = db["emails"]

    if email in db_emails:
        # bug: email is not expected to be in allocations
        abort(500)

    # special emails use vms with private ips
    use_private_ip = email.lower().endswith("@redhat.com")

    vms_in_use = frozenset(db_emails.values())
    for vm, vm_ip in db_vms.items():
        if vm in vms_in_use:
            continue

        # https://realpython.com/python-ipaddress-module/#special-address-ranges
        if IPv4Address(vm_ip).is_private != use_private_ip:
            continue

        params = ["crudini", "--set", DB_FILE, "emails", email, vm]
        proc.call(params, shell=False, check_exit_code=True)
        return vm_ip, None

    msg = "Sorry, no vms available.\nFancy spawing one manually?!?\n"
    msg += "Check https://github.com/flavio-fernandes/ovscon22kind/blob/main/docs/provisioning.md for info."
    return None, msg


def deallocate_email(email):
    params = ["crudini", "--del", DB_FILE, "emails", email]
    _raw_output, exit_code = proc.call(params, shell=False, check_exit_code=False)
    if exit_code:
        return f"db delete operation failed: {exit_code}"


def _read_dbfile():
    db_raw = ""
    params = ["crudini", "--get", "--format=lines", DB_FILE]
    output, exit_code = proc.call(params, shell=False, check_exit_code=False)
    if output and exit_code == 0:
        db_raw = str(output)
    try:
        db_raw_lines = db_raw.split("\n")
    except Exception:
        db_raw_lines = []
    # Initialize db with the sections we care about
    db = {"vms": {}, "emails": {}}
    for cidr in db_raw_lines:
        # Parse line from crudini output. It should look like this:
        # [id] key = value  ==> [vms] ovscon1 = 10.10.10.10
        # [id] key = value  ==> [emails] foo@mail.com = ovscon1
        match = re.search(r"^\s*\[\s*(\S+)\s*\]\s*(\S+)\s*=\s*(.+)$", cidr)
        if match:
            section = match.group(1).lower()
            if section in db:
                db_section = db[section]
                db_section[match.group(2)] = match.group(3)
                db[section] = db_section
    return db


def get_key(email):
    with open(KEY_FILE, "r") as infile:
        return "".join(infile.readlines())
