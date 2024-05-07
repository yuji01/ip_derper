# ip-derper

1. build

```
docker build --no-cache -t yujibuzailai/ip_derper .
```

2. run

```
docker run --rm -d -p 50443:443 -p 3478:3478/udp yujibuzailai/ip_derper
```

3. modify tailscale ACLs

inserts this into tailscale ACLs: https://login.tailscale.com/admin/acls
```json
"derpMap": {
    "Regions": {
        "900": {
            "RegionID": 900,
            "RegionCode": "my_private_derper",
            "Nodes": [
                {
                    "Name": "1",
                    "RegionID": 900,
                    "HostName": "YOUR_SERVER_IP",
                    "IPv4": "YOUR_SERVER_IP",
                    "InsecureForTests": true,
                    "DERPPort": 50443
                }
            ]
        }
    }
}
```

enjoy :)

1. 下载并修改
```
git clone https://github.com/yuji01/ip_derper.git
cd ip_derper
git clone https://github.com/tailscale/tailscale.git tailscale --depth 1
```
2. 找到 tailscale 仓库中的 cmd/derper/cert.go 文件，将与域名验证相关的内容删除或注释：

```
...
func (m *manualCertManager) getCertificate(hi *tls.ClientHelloInfo) (*tls.Certificate, error) {
	//if hi.ServerName != m.hostname {
	//	return nil, fmt.Errorf("cert mismatch with hostname: %q", hi.ServerName)
	//}
	return m.cert, nil
}
...
```
3. 编译
docker build --no-cache -t yujibuzailai/ip_derper .

