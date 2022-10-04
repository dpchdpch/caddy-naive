latest = "https://github.com/hiandy22/caddy/releases/download/ubuntu/caddy"

config() {
    echo " "
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
cat > client<<-EOF
{
  "listen": "socks://127.0.0.1:1080",
  "proxy": "https://$USER:$PASSWORD@$DOMAIN"
}
EOF
    wget -N https://github.com/hiandy22/caddy-naive/releases/download/ubuntu/caddy && chmod 777 caddy
    ./caddy start
    echo "------------"
    cat client
    echo " "
    echo " "

}

menu(){
  result=$(id | awk '{print $1}')
    if [[ $result != "uid=0(root)" ]]; then
        echo " 请以root身份执行该脚本"
        exit 1
    fi
  clear
  echo " "
  echo "NaiveProxy+Caddy 简易安装脚本 "
  echo "作者：hiandy22 --github"
  echo " -------------"
  echo "0. 退出"
  echo "1. 安装服务端(脚本执行需要一定时间，最后的获取证书需要耐心等候)"
  echo "2. 重启服务端"
  echo "3. 停止服务端"
  echo "4. 查看服务端配置"
  echo "5. 查看客户端配置"
  echo " -------------"
  read -p "请选择：" answer

  case $answer in
  0)
    exit 0
    ;;
  1)
    config
    ;;
  2)
    ./caddy stop
    ./caddy reload
    ./caddy start
    ;;
  3)
    ./caddy stop
    ;;
  4)
    echo " -------------"
    cat Caddyfile
    echo " -------------"
    ;;
  5)
    echo " -------------"
    cat client
    echo " -------------"
    ;;
  *)
    echo "请重新选择"
    exit 1
    ;;
  esac

}


menu
