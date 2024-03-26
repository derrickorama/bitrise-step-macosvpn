#!/bin/bash
set -ex

sudo macosvpn create --l2tp Default --endpoint $vpn_endpoint --username $vpn_user_name --password $vpn_password --sharedsecret $vpn_shared_secret

networksetup -connectpppoeservice Default

sleep 5

# One more time, to be sure
networksetup -connectpppoeservice Default

function isnt_connected () {
    scutil --nc status "Default" | sed -n 1p | grep -qv Connected
}

function poll_until_connected () {
    let loops=0 || true
    let max_loops=50

    while isnt_connected "Default"; do
        sleep 1
        let loops=$loops+1
        [ $loops -gt $max_loops ] && break
    done

    [ $loops -le $max_loops ]
}

if poll_until_connected "Default"; then
    echo "Connected to Default."
    exit 0
else
    echo "Timed out while connecting to VPN."
    exit 1
fi
