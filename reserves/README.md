# reserves
OVS Conf 2022: Web service for managing users to VMs

A basic implementation of a flask app used for tracking ovscon attendees to
a VM deployed with ovscon22kind.

## Quickstart

```bash
$ # cd ${this_repo}/reserves

$ # create pip environment
  python3 -m venv .env && source ./.env/bin/activate && pip install -U pip setuptools wheels &> /dev/null ; \
  pip install --upgrade pip

$ # install deps
  pip install -r requirements.txt

$ # before starting the app, ensure that key.txt and db.ini are available
  cp -v ./db.ini{.orig,} ; \
  cp -v ~/.ssh/id_rsa_ovscon key.txt

$ # example on running app in debug mode
  H=0.0.0.0 ; P=8888 ; \
  export FLASK_APP=reserves.py && FLASK_DEBUG=1 flask run --host $H --port $P --without-threads
```

## Example usage:

```bash
$ # set ip and port of where the reserves app is running
  RESERVES='127.0.0.1:8888'

$ # reserving a vm and getting the ssh command to be used
  curl http://${RESERVES}/vm/email@example.com

$ # getting a private ssh key to connect to the reserved vm
  curl http://${RESERVES}/key/email@example.com --silent > top_secret

$ # ssh connect
  chmod 400 top_secret ; \
  ssh vagrant@${IP} -i top_secret

$ # un-reserving ...
  curl -X DELETE http://${RESERVES}/vm/email@example.com
```

### Forwarding to port 8888

A little trick we can use in order to keep Flask app running on non-reserved ports,
yet connecting to it from such. [socat](https://www.cyberciti.biz/faq/linux-unix-tcp-port-forwarding/)!

```bash
$ sudo dnf -y install socat
$ sudo socat TCP-LISTEN:80,fork TCP:127.0.0.1:8888    
```
