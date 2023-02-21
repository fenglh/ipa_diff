import os
import sys
import subprocess



## 2867K 是Echo项目的SC_Info文件大小的估算值。每个App的SC_info大小不同

def get_ipa_size(ipa_path):
	scInfoSize = '2867K'
	p = subprocess.check_output(['sh pkg_size_ios.sh', ipa_path, scInfoSize], shell=True)
	ret = p.decode(encoding='utf-8').split('\n')
	size = ret[-2]
	return size