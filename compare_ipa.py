import os
import subprocess
import urllib.request
from urllib.parse import urlparse


# 生成包体积大小报告
def generate_build_file_report_ios(old_ipa_url, new_ipa_path, project_path):
    
    # 解析url、下载ipa
    parsed_url = urlparse(ipa_url)

    # ipa文件名
    ipa_name = parsed_url.path.split('/')[-1]
    
    # ipa缓存目录
    ipa_caches_dir = os.path.join(project_path, "ipa_caches")
    
    # 是否存在目录
    is_exists = os.path.exists(ipa_caches_dir)
    if not is_exists:
        os.mkdir(ipa_caches_dir)
    
    # 下载ipa，保存到old_ipa_path 路径
    old_ipa_path = os.path.join(ipa_caches_dir, ipa_name)
    urllib.request.urlretrieve(ipa_url,old_ipa_path)

    # 调用脚本对比ipa
    sh_dir = os.path.dirname(__file__)
    cmd = 'sh {}/compare_ipa.sh {} {}'.format(sh_dir, old_ipa_path, new_ipa_path)
    p = subprocess.check_output(cmd, shell=True)
    ret = p.decode(encoding='utf-8').split('\n')
    
    # 生成报告文件

    report_file_path = os.path.join(ipa_caches_dir, "{}.txt".format(ipa_name))
    
    with open(report_file_path, 'w', encoding='utf-8') as file:
        # 遍历文本数组，将每一行写入文件
        for line in ret:
            file.write(line + '\n')
    

def compare_ipa(old_ipa_path, new_ipa_path):
    sh_dir = os.path.dirname(__file__)
    cmd = 'sh {}/compare_ipa.sh {} {}'.format(sh_dir, old_ipa_path, new_ipa_path)
    p = subprocess.check_output(cmd, shell=True)
    ret = p.decode(encoding='utf-8').split('\n')
    print(ret)




ipa_url = "https://dl.pkgs.cc:20001/upload/pkgs/carne_1.17.00_11700012_20241018110541_prod.ipa"



generate_build_file_report_ios("https://dl.pkgs.cc:20001/upload/pkgs/carne_1.17.00_11700012_20241018110541_prod.ipa", "./carne_1.15.00_11500033_20240926095007_prod.ipa", "./")
