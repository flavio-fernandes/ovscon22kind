#!/usr/bin/env bash

[ $EUID -eq 0 ] || { echo 'must be root' >&2; exit 1; }

set -o xtrace
##set -o errexit

dnf install -y vim emacs-nox tmux curl wget tmate bat pip dnsutils make patch git jq bash-completion kubernetes-client
dnf groupinstall -y "Development Tools"

cat << EOT >> /root/.emacs
;; use C-x g for goto-line
(global-set-key "\C-xg" 'goto-line)
(setq line-number-mode t)
(setq column-number-mode t)
(setq make-backup-files nil)
;; tabs are evail
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(setq indent-line-function 'insert-tab)
(setq-default c-basic-offset 4)
EOT

[ -e /home/vagrant/.emacs ] || {
    cp -v {/root,/home/vagrant}/.emacs
    chown vagrant:vagrant /home/vagrant/.emacs
}

cat << EOT >> /root/.vimrc
set expandtab
set tabstop=2
set shiftwidth=2
EOT

[ -e /home/vagrant/.vimrc ] || {
    cp -v {/root,/home/vagrant}/.vimrc
    chown vagrant:vagrant /home/vagrant/.vimrc
}


echo ok
