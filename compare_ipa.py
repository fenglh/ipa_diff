import os
import subprocess

def compare_and_check_package_size_ios(old_ipa_path, new_ipa_path):
    sh_dir = os.path.dirname(__file__)
    cmd = 'sh -x {}/compare_ipa.sh {} {}'.format(sh_dir, old_ipa_path, new_ipa_path)
    p = subprocess.check_output(cmd, shell=True)
    ret = p.decode(encoding='utf-8').split('\n')
    

    print(ret)

    


compare_and_check_package_size_ios("./carne_1.14.00_11400023_20240904145811_prod.ipa", "./carne_1.15.00_11500033_20240926095007_prod.ipa")
