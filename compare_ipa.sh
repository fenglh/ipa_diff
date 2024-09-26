#!/bin/bash

#检查旧 IPA 路径是否作为第一个输入参数提供
if [ -z "$1" ]; then
  echo "请提供旧 IPA 文件的路径。" 
  exit 1
fi

#检查新 IPA 路径是否作为第二个输入参数提供
if [ -z "$2" ]; then
  echo "请提供新 IPA 文件的路径。" 
  exit 1
fi

#将输入参数分配给变量
OLD_IPA="$1"
NEW_IPA="$2"

#验证旧 IPA 文件是否存在
if [ ! -f "$OLD_IPA" ]; then
  echo "未找到旧 IPA 文件：$OLD_IPA"
  exit 1
fi

#验证新 IPA 文件是否存在
if [ ! -f "$NEW_IPA" ]; then
  echo "未找到新 IPA 文件：$NEW_IPA" 
  exit 1
fi

#将新、旧 IPA 的内容解压到临时目录
OLD_DIR=$(mktemp -d)
NEW_DIR=$(mktemp -d)

echo "OLD_DIR:$OLD_DIR"
echo "NEW_DIR:$NEW_DIR"

echo "******** 解压 IPAS ********"

unzip -q "$OLD_IPA" -d "$OLD_DIR"
unzip -q "$NEW_IPA" -d "$NEW_DIR"

echo -e "******** 解压 IPAS 完成 ********\n\n"



echo -e "******** 开始检查新增的文件 ********"

find "$NEW_DIR" -type f | while IFS= read -r file; do
  file_path_in_old="$OLD_DIR/${file#$NEW_DIR}"

  #检查文件是否存在于旧目录中
  if [ ! -f "$file_path_in_old" ]; then
    file_size=$(stat -f%z "$file")
    file_size_mb=$(awk "BEGIN{printf \"%.3f\", $file_size / (1024 * 1024)}")
    echo -e "\n${file#$NEW_DIR} (Size: $file_size_mb MB)"
  fi
done

echo -e "\n******** 检查新增文件完成 ********\n\n"


echo -e "******** 开始检查删除的文件 ********"

find "$OLD_DIR" -type f | while IFS= read -r file; do
  file_path_in_new="$NEW_DIR/${file#$OLD_DIR}"

  #检查文件是否存在于新目录中
  if [ ! -f "$file_path_in_new" ]; then
    file_size=$(stat -f%z "$file")
    file_size_mb=$(awk "BEGIN{printf \"%.3f\", $file_size / (1024 * 1024)}")
    echo -e "\n${file#$OLD_DIR} (Size: $file_size_mb MB)"
  fi
done

echo -e "\n******** 检查删除的文件完成 ********\n\n"



echo -e "******** 检查修改过的文件 ********"

#遍历新目录中的文件
find "$NEW_DIR" -type f | while IFS= read -r file; do
  file_path_in_old="$OLD_DIR/${file#$NEW_DIR}"


  #检查文件是否存在于旧目录中
  if [ -f "$file_path_in_old" ]; then
    old_size=$(stat -f%z "$file_path_in_old")
    new_size=$(stat -f%z "$file")

    if [ "$new_size" -gt "$old_size" ]; then
      old_size_mb=$(awk "BEGIN{printf \"%.3f\", $old_size / (1024 * 1024)}")
      new_size_mb=$(awk "BEGIN{printf \"%.3f\", $new_size / (1024 * 1024)}")
      size_difference=$(awk "BEGIN{printf \"%.3f\", $new_size_mb - $old_size_mb}")
      echo -e "\n${file#$NEW_DIR} (大小增加了: $size_difference MB)"
    fi
  fi
done

echo -e "\n******** 检查修改过的文件完成 ********\n"

# 清理临时目录
# rm -rf "$OLD_DIR" "$NEW_DIR"