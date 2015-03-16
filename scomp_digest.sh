#!/bin/bash
USAGE=`cat <<EOF

Make digest of Server Compaire Tool

Usage : $0 -c conf_file [-i ignore_file] [-o output_file] [-vh]

option

  -c conf_file :

       Specify config file.
       Config file format is as follows.
         ---
         /etc/
         /usr/local/
         /home/myapp/myapp.conf
         ---

  -i ignore_file :

        Specify ignore file.
        Default none.
        Ignore file format is as follows.
         ---
         /etc/hosts
         /usr/local/tmp/
         ---

  -o output_file :

        Specify output digest file.
        Default "./scomp-HOSTNAME-DATETIME.tar.gz"

  -v :
        Output debug information.

  -h :
        Display this massage.

EOF
`
export LANG=C

BASE="scomp-`hostname`-`date +""%Y%m%d_%H%M%S""`"
OUTPUT_FILE="${BASE}.tar.gz"
OUTPUT_PATH="`pwd`/${OUTPUT_FILE}"

TMP_DIR=/tmp
WORK_DIR=${TMP_DIR}/${BASE}
ORG_DIR=${WORK_DIR}/org
MD5_TMP=${WORK_DIR}/md5list.tmp
MD5_FILE=${WORK_DIR}/md5list.txt

# check command
which md5sum > /dev/null || exit 1
which tar    > /dev/null || exit 1
which awk    > /dev/null || exit 1

# parse option

while getopts c:o:i:vh OPT
do
  case $OPT in
    "v" ) OPT_V="TRUE" ;;
    "c" ) OPT_C="TRUE"
          CONF_TARGET="$OPTARG"
          if [ ! -e "$OPTARG" ] ; then
              echo "config file does not exist" >&2
              exit 2
          fi
          ;;
    "i" )
          OPT_I="TRUE"
          CONF_IGNORE="$OPTARG"
          if [ ! -e "$OPTARG" ] ; then
              echo "ignore file does not exist" >&2
              exit 3
          fi
          ;;
    "o" ) OPT_O="TRUE" ; OUTPUT_PATH=`pwd`/"$OPTARG" ;;
    "h" ) OPT_H="TRUE" ; echo "${USAGE}" ; exit 0 ;;
  esac
done


if [ "${OPT_C}" == "" ] ; then
    echo "argument error" >&2
    echo "${USAGE}"
    exit 4
fi

# main
mkdir ${WORK_DIR} || exit 5
for target in `cat ${CONF_TARGET}`
do
    [ "${OPT_V}" == "TRUE" ] && echo ${target}
    for file in `find ${target} -type f`
    do
        # write md5 and ls-l info to md5list.txt
        lsstr=`ls -l ${file} | awk '{print $1" "$3" "$4}'`
        md5str=`md5sum ${file} | awk '{print $1}'`
        echo ${file} ${md5str} ${lsstr} >> ${MD5_TMP}
        # if file type is text, then copy file to archive
        IS_A_TEXT=`file ${file} | grep text`
        if [[ "${IS_A_TEXT}" != ""  ]] ; then
            tmp=${ORG_DIR}${file}
            mkdir -p ${tmp%/*}
            cp ${file} ${tmp}
        fi
    done
done

sort ${MD5_TMP} > ${MD5_FILE}
rm ${MD5_TMP}

(cd ${WORK_DIR} ; tar zcf ${OUTPUT_PATH} ./*)

echo "make digest archive file : ${OUTPUT_PATH}"

