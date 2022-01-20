IANA Poll
=========

北京时间每天 2:00 定时拉取 IANA 时区数据库，
校验其完整性，并发布至指定目录。

这个程序的目的是在网络受限的环境下，
让 Elixir 的 tzdata 仍能自动更新。
具体做法见 [用法](#用法) 一节。

## Docker 容器化部署

    $ docker-compose up -d

## 用法

这个程序应配合 Nginx 或其他静态 HTTP 服务器使用。

### 1. 生成自签名的 TLS 证书

    $ openssl req -x509 \
                  -sha256 \
                  -nodes \
                  -days 3650 \
                  -newkey rsa:2048 \
                  -keyout iana-mirror.key \
                  -out iana-mirror.crt

被要求输入 FQDN 时，输入 **data.iana.org**，其他问题随意。

### 2. 在能够访问 IANA 的主机上启动 Nginx

Nginx 的网站配置如下：

```
server {
  server_name data.iana.org;
  listen 443 ssl;
  listen [::]:443 ssl;

  ssl_certificate <iana-mirror.crt 文件路径>;
  ssl_certificate_key <iana-mirror.key 文件路径>;

  location /time-zones/ {
    alias <tzdata-latest.tar.gz 发布目录（必须以 / 结尾）>;
  }
}
```

### 3. 把证书安装到所有需要 tzdata 自动更新的服务器上

把上述生成的证书 iana-mirror.crt 复制到每台依赖于 tzdata 的服务器上，
然后用 root 权限运行

    ./sbin/install-cert.sh ./iana-mirror.crt

### 4. 添加 hosts 记录

在每台需要 tzdata 自动更新的服务器上添加 hosts 记录。
具体添加方式要看 Elixir 服务的部署方式。

修改后需重启服务。

**3.1 非 Docker 部署**

修改 /etc/hosts 文件，添加记录

    <能够访问 IANA 官网的主机的 IP>  data.iana.org

**3.2 Docker 部署**

    $ docker run --add-host data.iana.org:<能够访问 IANA 官网的主机的 IP> ...

**3.3 Docker Compose 或 Docker Swarm 部署**

在 docker-compose.yml 中添加

```yml
services:
  my_elixir_app:
    extra_hosts:
      - "data.iana.org:<能够访问 IANA 官网的主机的 IP>"
    ...
```

