#!/bin/bash


cartool=./cartool





#将新、旧 IPA 的内容解压到临时目录
OLD_DIR="/var/folders/kr/bz5jj3pj0z1116x1hk974prc0000gn/T/tmp.nCtJjAXAfP"
NEW_DIR="/var/folders/kr/bz5jj3pj0z1116x1hk974prc0000gn/T/tmp.gWXNeoOZrs"

echo "OLD_DIR:$OLD_DIR"
echo "NEW_DIR:$NEW_DIR"




echo -e "******** 开始检查新增的文件 ********"
find "$NEW_DIR" -type f | while IFS= read -r file; do

    # 检查文件名是否为 Asset.car
    if [[ "$(basename "$file")" == "Assets.car" ]]; then
        # 跳过 Assets.car 文件
        continue
    fi


  file_path_in_old="$OLD_DIR/${file#$NEW_DIR}"
  #检查文件是否存在于旧目录中
  if [ ! -f "$file_path_in_old" ]; then
    file_size=$(stat -f%z "$file")
    file_size_mb=$(awk "BEGIN{printf \"%.3f\", $file_size / (1024 * 1024)}")

    if [ "$file_size_mb" == "0.000" ]; then 
      continue
    fi 

    echo -e "\n新增 ${file#$NEW_DIR} ($file_size_mb MB)"
  fi
done
echo -e "\n******** 检查新增文件完成 ********\n\n"


