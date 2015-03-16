#!/bin/bash
USAGE=`cat <<EOF

diff of Server Compaire Tools

Usage : $0 fileA fileB

  fileA, fileB  : Server Compaire Tool's archive file

EOF
`
export LANG=C

TMP=/tmp/
DIR_A=${TMP}a/
DIR_B=${TMP}b/
MD5FILE=md5list.txt
ORG_DIR=org
DIGEST_A=${DIR_A}${MD5FILE}
DIGEST_B=${DIR_B}${MD5FILE}
ORG_A=${DIR_A}${ORG_DIR}
ORG_B=${DIR_B}${ORG_DIR}

# perse argument
if [[ $1 == "" || $2 == "" ]] ; then
    echo "argument error" >&2
    echo "${USAGE}"
    exit 1
fi

ARC_A=$1
ARC_B=$2

# main
rm -rf ${DIR_A} || exit 2
rm -rf ${DIR_B} || exit 3
mkdir ${DIR_A} || exit 4
mkdir ${DIR_B} || exit 5
cp ${ARC_A} ${DIR_A} || exit 6
cp ${ARC_B} ${DIR_B} || exit 7

(cd ${DIR_A} ; tar zxf ${ARC_A})
(cd ${DIR_B} ; tar zxf ${ARC_B})

# read argument 1
LIST_A=()
while read line
do
    LIST_A=("${LIST_A[@]}" "${line}")
done < ${DIGEST_A}

# read argument 2
LIST_B=()
while read line
do
    LIST_B=("${LIST_B[@]}" "${line}")
done < ${DIGEST_B}

# diff
IA=0
IB=0
SIZE_A=${#LIST_A[*]}
SIZE_B=${#LIST_B[*]}
while  [[  ${IA} -lt ${SIZE_A} || ${IB} -lt ${SIZE_B}  ]]
do
    LINE_A=${LIST_A[$IA]}
    LINE_B=${LIST_B[$IB]}
    FILE_A=`echo ${LINE_A} | awk '{print $1}'`
    FILE_B=`echo ${LINE_B} | awk '{print $1}'`
    if   [[ ${IB} == ${SIZE_B} || ${IA} -lt ${SIZE_A} && "${FILE_A}" < "${FILE_B}" ]] ; then
        echo "----------------------------------------"
        echo "only exist in arg1 : ${FILE_A}"
        (( IA++ ))
    elif [[ ${IA} == ${SIZE_A} || ${IB} -lt ${SIZE_B} && "${FILE_A}" > "${FILE_B}" ]] ; then
        echo "----------------------------------------"
        echo "only exist in arg2 : ${FILE_B}"
        (( IB++ ))
    else
        if [[ "${LINE_A}" != "${LINE_B}" ]] ; then
            echo "----------------------------------------"
            echo "has difference     : ${FILE_A}"
            echo ""
            echo "[arg1]  ${LINE_A}"
            echo "[arg2]  ${LINE_B}"
            MD5_A=`echo ${LINE_A} | awk '{print $2}'`
            MD5_B=`echo ${LINE_B} | awk '{print $2}'`
            IS_A_TEXT=`file ${ORG_A}${FILE_A} | grep text`
            if [[ ( "${MD5_A}" != "${MD5_B}" ) && ( "${IS_A_TEXT}" != "" ) ]] ; then
                echo "[diff]"
                diff ${ORG_A}${FILE_A} ${ORG_B}${FILE_B}
            fi
        fi
        (( IA++ ))
        (( IB++ ))
    fi
done

