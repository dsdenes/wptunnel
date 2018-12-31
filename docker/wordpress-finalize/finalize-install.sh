#!/usr/bin/env sh
INSTALL_URL="http://wordpress:80/wp-admin/install.php?step=2"

isInstallPageLive() {
    curl --output /dev/null --silent --head --fail http://wordpress:80/wp-admin/install.php
}

isIndexPageLive() {
    curl --output /dev/null --silent --head --fail http://wordpress:80/index.php
}

while ! (( isIndexPageLive || isInstallPageLive )); do
    printf '.'
    sleep 1
done

if isInstallPageLive; then
    curl --insecure \
        --data-urlencode weblog_title=WPTunnel \
        --data-urlencode user_name=admin \
        --data-urlencode admin_password=admin \
        --data-urlencode admin_password2=admin \
        --data-urlencode pass1-text=admin \
        --data-urlencode pw_weak=on \
        --data-urlencode admin_email=dummy@wptunnel.com \
        --data-urlencode language= \
        ${INSTALL_URL}
fi