import requests
 
url = 'http://cms.flatincbr.com:8000/api/app-version/get-apk-url'
data = {
        "access_key": "muZd08g0_A4ucMCz",  # 暂时加鉴权参数避免打包错误
        "pkg_name": "com.carni.voice",
        "orderBy": "id",
        "pf": "ios",
        "online": 0,
        "page_size": 50,
        "extra_field": "extra,ipa_url"
    }
    
headers = {
        "Content-Type": "application/x-www-form-urlencoded",
        "Cache-Control": "no-cache"
    }

req = requests.get(url=url, params=data, headers=headers)

response = requests.post(url, data=data)

content = req.json()
 
if content["status"] == 1:
    data = content["data"]
    print("data:" +str(data))
else:
    print("请求失败")
