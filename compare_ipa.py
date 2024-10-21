import os
import subprocess
import urllib.request
from urllib.parse import urlparse


# 生成包体积大小报告
def generate_build_file_report_ios(old_ipa_url, new_ipa_path, project_path):

    # ipa缓存目录
    ipa_caches_dir = os.path.join(project_path, "ipa_caches")
    
    # 解析url、下载ipa
    parsed_old_ipa_url = urlparse(old_ipa_url)

    # ipa文件名
    old_ipa_name = parsed_old_ipa_url.path.split('/')[-1]

    # 是否存在目录
    is_exists = os.path.exists(ipa_caches_dir)
    if not is_exists:
        os.mkdir(ipa_caches_dir)
    
    # 下载ipa，保存到old_ipa_path 路径
    old_ipa_path = os.path.join(ipa_caches_dir, old_ipa_name)
    urllib.request.urlretrieve(old_ipa_url,old_ipa_path)

    # 调用脚本对比ipa
    ret = compare_ipa(old_ipa_path, new_ipa_path)
    

    # 生成报告文件
    parsed_new_ipa_path = urlparse(new_ipa_path)
    new_ipa_name = parsed_new_ipa_path.path.split('/')[-1]
    titles = ['{} 相对 {} ,包体变化如下:'.format(new_ipa_name, old_ipa_name)]
    report_lines = titles + ret
    
    report_file_path = os.path.join(ipa_caches_dir, "{}.txt".format(new_ipa_name))
      
    with open(report_file_path, 'w', encoding='utf-8') as file:
        # 遍历文本数组，将每一行写入文件
        for line in report_lines:
            file.write(line + '\n')
    return report_file_path

# 删除缓存目录文件
def cleanCaches(folder_path):
    files = os.listdir(folder_path)
    for file in files:
        file_path = os.path.join(folder_path, file)
        if os.path.isfile(file_path):
            os.remove(file_path)

def compare_ipa(old_ipa_path, new_ipa_path):
    sh_dir = os.path.dirname(__file__)
    cmd = 'sh {}/compare_ipa.sh {} {}'.format(sh_dir, old_ipa_path, new_ipa_path)
    p = subprocess.check_output(cmd, shell=True)
    ret = p.decode(encoding='utf-8').split('\n')
    return ret

