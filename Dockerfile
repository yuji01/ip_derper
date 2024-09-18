# 来源：https://www.nodeseek.com/post-146521-1
# 编译
FROM golang:alpine AS builder

# 切换模块源为中国Go模块代理服务器
# RUN go env -w GOPROXY=https://goproxy.cn,direct

# 拉取代码
RUN go install tailscale.com/cmd/derper@latest

# 去除域名验证（删除cmd/derper/cert.go文件的91~93行）
RUN find /go/pkg/mod/tailscale.com@*/cmd/derper/cert.go -type f -exec sed -i '91,93d' {} +

# 编译
RUN derper_dir=$(find /go/pkg/mod/tailscale.com@*/cmd/derper -type d) && \
	cd $derper_dir && \
    go build -o /etc/derp/derper

# 生成最终镜像
FROM alpine:latest

WORKDIR /app

ENV LANG C.UTF-8 \
    DERP_PORT 443 \
    DERP_STUN true \
    DERP_STUN_PORT 3478 \
    DERP_VERIFY_CLIENTS false
    
COPY --from=builder /etc/derp/derper .

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo 'Asia/Shanghai' > /etc/timezone \
    && mkdir /lib64 \
    && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2 \
    && apk add openssl \
    && mkdir -p /app/certs \
    && openssl req -x509 -newkey rsa:4096 -sha256 -days 36500 -nodes -keyout /app/certs/derp.narutos.top.key -out /app/certs/derp.narutos.top.crt -subj "/CN=derp.narutos.top" -addext "subjectAltName=DNS:derp.narutos.top"

# 命令解释：
# 创建软链接 解决二进制无法执行问题 Amd架构必须执行，Arm不需要执行
# mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2

# 添加源
#RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories

# 安装openssl
#RUN apk add openssl && mkdir /ssl

# 生成自签10年证书
#RUN openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes -keyout /ssl/derp.javaow.com.key -out /ssl/derp.javaow.com.crt -subj "/CN=derp.javaow.com" -addext "subjectAltName=DNS:derp.javaow.com"

# 启动命令
CMD ./derper -a :$DERP_PORT -certdir /app/certs -certmode manual -derp -hostname derp.narutos.top -http-port -1 -stun $DERP_STUN -stun-port $DERP_STUN_PORT -verify-clients $DERP_VERIFY_CLIENTS
