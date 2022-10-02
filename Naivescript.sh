# wget https://github.com/hiandy22/caddy/releases/download/ubuntu/caddy

config() {
    echo " "
    echo "NaiveProxy with Caddy,请确认以下条件"
    echo "域名指向当前ip，确认请按y"
    echo " "
    read -p " 请输入= " answer
    if [[ "${answer,,}" != "y" ]]; then
        exit 0
    fi

    echo " "
    while true
    do
        read -p "请输入域名：" DOMAIN
        read -p "默认用户名：（不输入将随机生成）" USER
        [[ -z "$USER" ]] && PASSWORD=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 4 | head -n 1`
        read -p "密码：（不输入将随机生成）" PASSWORD
        [[ -z "$PASSWORD" ]] && PASSWORD=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1`
        break
    done
    DOMAIN=${DOMAIN,,}
    USER=${USER,,}
    PASSWORD=${PASSWORD,,}
    echo "请确认域名：$DOMAIN"
    echo "请确认用户名：$USER"
    echo "请确认用户密码：$PASSWORD"
    cat > Caddyfile<<-EOF
:443, ${DOMAIN}
tls caddy@${DOMAIN} 
route {
 forward_proxy {
   basic_auth ${USER} ${PASSWORD} 
   hide_ip
   hide_via
   probe_resistance
  }
 reverse_proxy  https://www.aconvert.com { 
   header_up  Host  {upstream_hostport}
   header_up  X-Forwarded-Host  {host}
  }
}
EOF
cat > client.config<<-EOF
:443, ${DOMAIN}
tls caddy@${DOMAIN} 
route {
 forward_proxy {
   basic_auth ${USER} ${PASSWORD} 
   hide_ip
   hide_via
   probe_resistance
  }
 reverse_proxy  https://www.aconvert.com { 
   header_up  Host  {upstream_hostport}
   header_up  X-Forwarded-Host  {host}
  }
}
EOF
    wget -N https://github.com/hiandy22/caddy/releases/download/ubuntu/caddy && chmod 777 caddy
    ./caddy run
}

echo "{
  "listen": "socks://127.0.0.1:1080",
  "proxy": "https://$USER:$PASSWORD@$DOMAIN"
}"


config