#!/bin/bash

check() {
    return 0
}

depends() {
    return 0
}

install() {
    inst_multiple -o \
        "$systemdsystemunitdir/systemd-repart.service.d/*.conf"
}
