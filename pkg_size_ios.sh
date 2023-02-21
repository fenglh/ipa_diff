#! /bin/bash

##
##  packsize.sh
##
##  Created by fenglh on 2023/02/13.
##


## 2867K 是Echo项目的SC_Info文件大小的估算值。每个App的SC_info大小不同


scInfoSize=$2

if [[ -z "$scInfoSize" ]];then
    scInfoSize='2867K'
fi


## work space
shellWorkPath=$(pwd)
buildPath="${shellWorkPath}/PackSize_Build"
payloadPath="${buildPath}/Payload"
thinPayloadPath="${buildPath}/Thin_Payload"
scInfoPath="${thinPayloadPath}/SC_info"


function unzipIpa() {
    local ipaPath="$1"
    if [[ ! -f "${ipaPath}" ]]; then
        exit 1
    fi
    unzip -oq "${ipaPath}" -d ${buildPath}
}


function makeBuildPath() {
    if [[ ! -d "${buildPath}" ]]; then
        mkdir -p "${buildPath}"
    fi
    
    if [[ -d "${payloadPath}" ]]; then
        rm -rf "${payloadPath}"
    fi
    
    if [[ -d "${thinPayloadPath}" ]]; then
        rm -rf "${thinPayloadPath}"
    fi
}


function makeSCInfo() {
    
    if [[ ! -d "${scInfoPath}" ]];then
        mkdir -p "${scInfoPath}"
    fi
    local file="${scInfoPath}/sc.info"
    local ret=`dd if=/dev/zero of="${file}" bs="${scInfoSize}" count=1 >/dev/null 2>&1 &`
    if [[ $? -ne 0 ]];then
        echo "Can't make SC_info:${file}"
        exit 1
    else
        echo "make SC_info :${file}"
    fi
    
}

function copyFile() {
    local file=$1
    local outputPath=$2
    cp "${file}" "${outputPath}"
    if [[ $? -ne 0 ]];then
        echo "Can't copy file:${file}"
        exit 1
    else
        echo "Copy file :${file}"
    fi
}


function slicingBinary() {
    local file=$1
    local outputPath=$2
    lipo "${file}" -thin arm64 -output "${outputPath}"
    if [[ $? -ne 0 ]];then
        echo "Can't not thin file:${file}"
        exit 1
    else
        echo "Thin file :${file}"
    fi
}


function slicingAsset() {
    local file=$1
    local outputPath=$2
    xcrun --sdk iphoneos assetutil --scale 3 --deployment-target 2019 --output "${outputPath}" "${file}" >/dev/null 2>&1 &
    if [[ $? -ne 0 ]];then
    echo "Can't not thin asset:${file}"
    exit 1
    else
        echo "Thin asset :${file}"
    fi
}

function slicingApp() {
    local appPath=$(find "${payloadPath}" -name "*.app" | head -1)
    if [[ ! -d "${appPath}" ]]; then
        echo "${appPath} not exist!"
        exit 1
    fi
    find "${appPath}" -type f -print0 | while read -d $'\0' file
    do
        ## make output path
        local relatePath="${file##*${payloadPath}/}"
        local outputPath="${thinPayloadPath}/${relatePath}"
        local outputDir="${outputPath%/*}"
        if [[ ! -d "${outputDir}" ]]; then
            mkdir -p "${outputDir}"
        fi
        
        # ignore swift lib
        if [[ "${relatePath}" == *.app/Frameworks/libswift*.dylib ]];then
            echo "Ignore file: ${relatePath}"
            continue
        fi
    
        ## slicing and copy
        local fileName=`basename ${file}`
        local fileTypeRet=`mdls -name kMDItemContentType "$file"`
        if [[ ${fileName} == "Assets.car" ]];then
            slicingAsset "${file}" "${outputPath}"
        elif [[ ${fileTypeRet} =~ "public.unix-executable" ]] || [[ ${fileTypeRet} =~ "com.apple.mach-o-dylib" ]];then
            local flatFileRet=`lipo -info "${file}"`
            if [[ ${flatFileRet} =~ "Architectures in the fat file" ]];then
                slicingBinary "${file}" "${outputPath}"
            else
                copyFile "${file}" "${outputPath}"
            fi
        else
            copyFile "${file}" "${outputPath}"
        fi
    done
}


function getSize() {
    local ret=`du -d 0 --si "${thinPayloadPath}"`
    echo "${ret%M*}M"
}

function cleanBuild() {
    if [[ -d "${buildPath}" ]]; then
        rm -rf "${buildPath}"
    fi
}




makeBuildPath
unzipIpa "$1"
slicingApp
makeSCInfo
ret=$(getSize)
cleanBuild
echo "$ret"




