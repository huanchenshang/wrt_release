    ./scripts/feeds update -a
}

remove_unwanted_packages() {
    local luci_packages=(
        "luci-app-passwall" "luci-app-smartdns" "luci-app-ddns-go" "luci-app-rclone"
        "luci-app-ssr-plus" "luci-app-vssr" "luci-theme-argon"
        "luci-app-alist" "luci-app-argon-config" "luci-app-homeproxy" "luci-app-haproxy-tcp"
        "luci-app-openclash" "luci-app-mihomo" "luci-app-appfilter" "luci-app-msd_lite"
    )
    local packages_net=(
        "haproxy" "xray-core" "xray-plugin" "dns2socks" "alist" "hysteria"
        "smartdns" "mosdns" "adguardhome" "ddns-go" "naiveproxy" "shadowsocks-rust"
        "sing-box" "v2ray-core" "v2ray-geodata" "v2ray-plugin" "tuic-client"
        "chinadns-ng" "ipt2socks" "tcping" "trojan-plus" "simple-obfs"
        "shadowsocksr-libev" "mihomo" "geoview" "tailscale" "open-app-filter"
        "msd_lite"
    )
    local packages_utils=(
        "cups"
        git clone --depth 1 $GOLANG_REPO -b $GOLANG_BRANCH ./feeds/packages/lang/golang
    fi
}

install_small8() {
    ./scripts/feeds install -p small8 -f xray-core xray-plugin dns2tcp dns2socks haproxy hysteria \
        naiveproxy shadowsocks-rust sing-box v2ray-core v2ray-geodata v2ray-geoview v2ray-plugin \
        tuic-client chinadns-ng ipt2socks tcping trojan-plus simple-obfs shadowsocksr-libev \
        luci-app-passwall smartdns luci-app-smartdns v2dat mosdns luci-app-mosdns \
        adguardhome luci-app-adguardhome ddns-go luci-app-ddns-go taskd luci-lib-xterm luci-lib-taskd \
        luci-app-store quickstart luci-app-quickstart luci-app-istorex luci-app-cloudflarespeedtest \
        luci-theme-argon netdata luci-app-netdata lucky luci-app-lucky luci-app-openclash luci-app-homeproxy \
        luci-app-amlogic nikki luci-app-nikki tailscale luci-app-tailscale oaf open-app-filter luci-app-oaf \
        easytier luci-app-easytier msd_lite luci-app-msd_lite cups luci-app-cupsd
}

install_feeds() {
    ./scripts/feeds update -i
    for dir in $BUILD_DIR/feeds/*; do
        # 检查是否为目录并且不以 .tmp 结尾，并且不是软链接
        \mv -f "$new_mk" "$makefile"
    fi
}

fix_mkpkg_format_invalid() {
    if [[ $BUILD_DIR =~ "imm-nss" ]]; then
        if [ -f $BUILD_DIR/feeds/small8/v2ray-geodata/Makefile ]; then
            sed -i 's/VER)-\$(PKG_RELEASE)/VER)-r\$(PKG_RELEASE)/g' $BUILD_DIR/feeds/small8/v2ray-geodata/Makefile
        fi
        if [ -f $BUILD_DIR/feeds/small8/luci-lib-taskd/Makefile ]; then
            sed -i 's/>=1\.0\.3-1/>=1\.0\.3-r1/g' $BUILD_DIR/feeds/small8/luci-lib-taskd/Makefile
        fi
        if [ -f $BUILD_DIR/feeds/small8/luci-app-openclash/Makefile ]; then
            sed -i 's/PKG_RELEASE:=beta/PKG_RELEASE:=1/g' $BUILD_DIR/feeds/small8/luci-app-openclash/Makefile
        fi
    local easytier_path="$BUILD_DIR/package/feeds/small8/luci-app-easytier/luasrc/model/cbi/easytier.lua"
    if [ -d "${easytier_path%/*}" ] && [ -f "$easytier_path" ]; then
        sed -i 's/util/xml/g' "$easytier_path"
    fi
}

update_geoip() {
    local geodata_path="$BUILD_DIR/package/feeds/small8/v2ray-geodata/Makefile"
    if [ -d "${geodata_path%/*}" ] && [ -f "$geodata_path" ]; then
        local GEOIP_VER=$(awk -F"=" '/GEOIP_VER:=/ {print $NF}' $geodata_path | grep -oE "[0-9]{1,}")
        if [ -n "$GEOIP_VER" ]; then
            local base_url="https://github.com/v2fly/geoip/releases/download/${GEOIP_VER}"
            # 下载旧的geoip.dat和新的geoip-only-cn-private.dat文件的校验和
            local old_SHA256=$(wget -qO- "$base_url/geoip.dat.sha256sum" | awk '{print $1}')
            local new_SHA256=$(wget -qO- "$base_url/geoip-only-cn-private.dat.sha256sum" | awk '{print $1}')
            # 更新Makefile中的文件名和校验和
            if [ -n "$old_SHA256" ] && [ -n "$new_SHA256" ]; then
                if grep -q "$old_SHA256" "$geodata_path"; then
                    sed -i "s|=geoip.dat|=geoip-only-cn-private.dat|g" "$geodata_path"
                    sed -i "s/$old_SHA256/$new_SHA256/g" "$geodata_path"
                fi
            fi
        fi
    fi
}

update_lucky() {
    local version=$(find "$BASE_PATH/patches" -name "lucky*" -printf "%f\n" | head -n 1 | awk -F'_' '{print $2}')
    local mk_dir="$BUILD_DIR/feeds/small8/lucky/Makefile"
    if [ -d "${mk_dir%/*}" ] && [ -f "$mk_dir" ]; then
        sed -i '/Build\/Prepare/ a\	[ -f $(TOPDIR)/../patches/lucky_'${version}'_Linux_$(LUCKY_ARCH)_wanji.tar.gz ] && install -Dm644 $(TOPDIR)/../patches/lucky_'${version}'_Linux_$(LUCKY_ARCH)_wanji.tar.gz $(PKG_BUILD_DIR)/$(PKG_NAME)_$(PKG_VERSION)_Linux_$(LUCKY_ARCH).tar.gz' "$mk_dir"
        sed -i '/wget/d' "$mk_dir"
    fi
    git clone --depth 1 -b master https://github.com/pymumu/luci-app-smartdns.git "$BUILD_DIR/feeds/small8/luci-app-smartdns"

    if [ -f "$BUILD_DIR/feeds/small8/luci-app-smartdns/Makefile" ]; then
        sed -i 's/\.\.\/\.\.\/luci\.mk/\$(TOPDIR)\/feeds\/luci\/luci\.mk/g' "$BUILD_DIR/feeds/small8/luci-app-smartdns/Makefile"
    fi
}


fix_nginx_ssl() {
    local nginx_conf_dir="$BUILD_DIR/files/etc/nginx/conf.d"
    mkdir -p "$nginx_conf_dir"
    # 只生成 http 配置，不生成证书
    cat >"$nginx_conf_dir/luci_http.conf" <<EOF
server {
    listen 80;
    server_name _;

    location / {
        ubus_interpreter;
        include uwsgi_params;
    }
}
EOF
}

main() {
    clone_repo
    clean_up
    reset_feeds_conf
    add_gecoosac
    update_lucky
    fix_rust_compile_error
    update_smartdns_luci
    install_feeds
    support_fw4_adg
    fix_nginx_ssl
    update_script_priority
    fix_easytier
    update_geoip
    update_package "runc" "releases" "v1.2.6"
    update_package "containerd" "releases" "v1.7.27"
    update_package "docker" "tags" "v28.2.2"
    update_package "dockerd" "releases" "v28.2.2"
    # update_package "xray-core"
    # update_proxy_app_menu_location
