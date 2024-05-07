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

	// 自定义配置开始
	"derpMap": {
		//"OmitDefaultRegions": true, //禁用其他中转服务器
		"Regions": {
			"1":  null,
			"2":  null,
			"3":  null,
			"4":  null,
			"5":  null,
			"6":  null,
			"7":  null,
			"8":  null,
			"9":  null,
			"10": null,
			"11": null,
			"12": null,
			"13": null,
			"14": null,
			"15": null,
			"16": null,
			"17": null,
			"18": null,
			"19": null,
			//"20": null, 香港V6不禁用
			"21": null,
			"22": null,
			"23": null,
			"24": null,
			"25": null,
			"901": {
				"RegionID":   901,
				"RegionCode": "Myself",
				"RegionName": "Myself Derper",
				"Nodes": [
					{
						"Name":             "901a",
						"RegionID":         901,
						"DERPPort":         50443, //服务器的端口
						"IPv4":             "00000", //服务器的IP
						"InsecureForTests": true,
					},
				],
			},
		},
	},
	// 自定义配置结束
	// Define users and devices that can use Tailscale SSH.
	"ssh": [


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
```
docker build --no-cache -t yujibuzailai/ip_derper .
```
