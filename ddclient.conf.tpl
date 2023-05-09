daemon=5m \
protocol=dyndns2 \
use=web, web=checkip.dy.fi \
server=www.dy.fi \
login=${dyfi_username} \
password='${dyfi_password}' \
ssl=yes \
max-interval=6d \
${dyfi_hostname}
