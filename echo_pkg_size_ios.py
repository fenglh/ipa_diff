import os
import sys
import subprocess



## 2867K 是Echo项目的SC_Info文件大小的估算值。每个App的SC_info大小不同

def get_ipa_size(ipa_path):
	scInfoSize = '2867K'
	p = subprocess.check_output(['./pkg_size_ios.sh', ipa_path, scInfoSize])
	ret = p.decode(encoding='utf-8').split('\n')
	size = ret[-2]
	return size




ret=get_ipa_size('/Users/fenglh/Desktop/包大小/echo_1.20.01_12001002_20230118121523_release.ipa')
print(ret)