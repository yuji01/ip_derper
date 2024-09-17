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

WORKDIR /apps

ENV LANG C.UTF-8 \
    DERP_HOSTNAME derp.narutos.top \
    DERP_PORT 443 \
    DERP_CERTS /app/certs \
    DERP_STUN true \
    DERP_VERIFY_CLIENTS false
    
COPY --from=builder /etc/derp/derper .

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo 'Asia/Shanghai' > /etc/timezone \
    && mkdir /lib64 \
    && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2 \
    && apk add openssl \
    && mkdir -p /app/certs \
    && openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes -keyout $DERP_CERTS/derp.narutos.top.key -out $DERP_CERTS/derp.narutos.top.crt -subj "/CN=derp.narutos.top" -addext "subjectAltName=DNS:derp.narutos.top"

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
CMD ./derper -hostname derp.narutos.top -a :$DERP_PORT -certmode manual -certdir $DERP_CERTS --stun $DERP_STUN --verify-clients $DERP_VERIFY_CLIENTS
