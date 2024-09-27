#!/bin/bash


cartool=./cartool


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

unzip -q "$OLD_IPA" -d "$OLD_DIR"
unzip -q "$NEW_IPA" -d "$NEW_DIR"

echo -e "******** 解压 IPAS 完成 ********"


echo "******** 解压旧IPA的 Asset.car ********"
find "$OLD_DIR" -type f -name "Assets.car" | while IFS= read -r file; do

  echo "解压${file}"
  file_dir=${file%/*}
  $cartool $file $file_dir >/dev/null 2>&1

done
echo "******** 解压旧IPA的 Asset.car 完成 ********"



echo "******** 解压新IPA的 Asset.car ********"
find "$NEW_DIR" -type f -name "Assets.car" | while IFS= read -r file; do

  echo "解压${file}"
  file_dir=${file%/*}
  $cartool $file $file_dir >/dev/null 2>&1

done
echo "******** 解压新IPA的 Asset.car 完成 ********"




# 累计大小
total_add_size_mb=0.0
total_del_size_mb=0.0
total_update_size_mb=0.0




echo -e "\n\n******** 开始检查新增的文件 ********"

while IFS= read -r file; do

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

    # 更新累积的总大小
    total_add_size_mb=$(awk "BEGIN{printf \"%.3f\", $total_add_size_mb + $file_size_mb}")

  fi
done < <(find "$NEW_DIR" -type f )

echo -e "\n******** 检查新增文件完成（累计新增大小:${total_add_size_mb} MB） ********"


echo -e "\n\n******** 开始检查删除的文件 ********"
while IFS= read -r file; do

    # 检查文件名是否为 Asset.car
    if [[ "$(basename "$file")" == "Assets.car" ]]; then
        # 跳过 Assets.car 文件
        continue
    fi

  file_path_in_new="$NEW_DIR/${file#$OLD_DIR}"
  #检查文件是否存在于新目录中
  if [ ! -f "$file_path_in_new" ]; then
    file_size=$(stat -f%z "$file")
    file_size_mb=$(awk "BEGIN{printf \"%.3f\", $file_size / (1024 * 1024)}")
    if [ "$file_size_mb" == "0.000" ]; then 
      continue
    fi 
    echo -e "\n删除 ${file#$OLD_DIR} ($file_size_mb MB)"

    total_del_size_mb=$(awk "BEGIN{printf \"%.3f\", $total_del_size_mb + $file_size_mb}")

  fi
done < <(find "$OLD_DIR" -type f )
echo -e "\n******** 检查删除的文件完成（累计删除大小:${total_del_size_mb} MB） ********"



echo -e "\n\n******** 开始检查修改过的文件 ********"
#遍历新目录中的文件
while IFS= read -r file; do

  # 检查文件名是否为 Asset.car
  if [[ "$(basename "$file")" == "Assets.car" ]]; then
      # 跳过 Assets.car 文件
      continue
  fi

  file_path_in_old="$OLD_DIR/${file#$NEW_DIR}"
  #检查文件是否存在于旧目录中
  if [ -f "$file_path_in_old" ]; then
    old_size=$(stat -f%z "$file_path_in_old")
    new_size=$(stat -f%z "$file")

    if [ "$new_size" -gt "$old_size" ]; then
      old_size_mb=$(awk "BEGIN{printf \"%.3f\", $old_size / (1024 * 1024)}")
      new_size_mb=$(awk "BEGIN{printf \"%.3f\", $new_size / (1024 * 1024)}")
      size_difference=$(awk "BEGIN{printf \"%.3f\", $new_size_mb - $old_size_mb}")
      if [ "$size_difference" == "0.000" ]; then 
        continue
      fi 
      echo -e "\n修改 ${file#$NEW_DIR} (大小增加:$size_difference MB)"

      # 更新累积的总大小
      total_update_size_mb=$(awk "BEGIN{printf \"%.3f\", $total_update_size_mb + $size_difference}")

    fi
  fi
done < <(find "$NEW_DIR" -type f )
echo -e "******** 检查修改过的文件完成（累计增加大小:${total_update_size_mb} MB） ********"


# 清理临时目录
rm -rf "$OLD_DIR" "$NEW_DIR"