#!/bin/bash
#########################
# build fragroute on 
# CentOs
# from root
#
# version 0.2 <27.08.2015> <weldpua2008@gmail.com>
# - fixed errors on docker images
# - added a hack for CentOS 7  (RPM_EXTRA_OPTs=" --force"
# version 0.1 <09.12.2014> <weldpua2008@gmail.com>
#
#########################
# initial versions of fragroute 
# and libdnet placed into:
# https://code.google.com/p/fragroute-ipv6/
# and moved to	
#	https://github.com/stsi/fragroute-ipv6, 
#	https://github.com/stsi/libdnet-ipv6
#
###########################

# variables for getopts
# 
BUILD_STATIC=true
INSTALL_DEPENDENCES=true
INSTALL_REPOSITORY=true
GET_FILES_FROM_GIT=true
##########
OS_VERSION=`cat /etc/redhat-release | grep -oE '[0-9]+\.[0-9]+'|cut -d "." -f1 |head -n 1`

GITHUB_PREFIX="https://raw.githubusercontent.com/weldpua2008/fragroute/master"
FRAGROUTE_SPEC="${GITHUB_PREFIX}/SPECS/fragroute.spec"
FRAGROUTE_STATIC_SPEC="${GITHUB_PREFIX}/SPECS/fragroute-static.spec"
LIBDNET_SPEC="${GITHUB_PREFIX}/SPECS/libdnet.spec"
LIBPCAP_SPEC="${GITHUB_PREFIX}/SPECS/libpcap-static.spec"

SPEC_PATH=~/rpmbuild/SPECS
SOURCES_PATH=~/rpmbuild/SOURCES
RPMS_PATH=~/rpmbuild/RPMS/`arch`

WGET="wget --no-check-certificate"
RPM_EXTRA_OPTs=""

#FRAGROUTE_REPO="https://github.com/stsi/fragroute-ipv6"
FRAGROUTE_REPO="https://github.com/weldpua2008/fragroute-ipv6.git"
#LIBDNET_REPO="https://github.com/stsi/libdnet-ipv6"
LIBDNET_REPO="https://github.com/weldpua2008/libdnet-ipv6.git"

# variables
FRAGROUTE_FILE_NAME=fragroute-1.2.6-ipv6.tar.gz
LIBDNET_FILE_NAME=libdnet-1.12.tar.gz
LIBPCAP_SOURCES_FILES_T="libpcap-1.4.0.tar.gz libpcap-man.patch libpcap-multilib.patch libpcap-s390.patch"

# DST files
LIBDNET_DST_FILE="${GITHUB_PREFIX}/SOURCES/${LIBDNET_FILE_NAME}"
FRAGROUTE_DST_FILE="${GITHUB_PREFIX}/SOURCES/${FRAGROUTE_FILE_NAME}"
LIBPCAP_SOURCES_FILES=( $LIBPCAP_SOURCES_FILES_T )

# repository for all centos
EPEL_CENTOS5="http://dl.fedoraproject.org/pub/epel/5/x86_64/epel-release-5-4.noarch.rpm"
EPEL_CENTOS6="http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm"
EPEL_CENTOS7="http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-1.noarch.rpm"

if [[ $# -eq 0 ]] ; then
    echo "use $(basename $0) -h"
    exit 0
fi

while getopts ":s:d:n:r:h" opt; do
  case $opt in
    s)
	BUILD_STATIC=true	
      ;;
    d)
	BUILD_STATIC=false
	;;
    n)
	echo "build without dependencies"
	INSTALL_DEPENDENCES=false
	;;
    r)
	echo "without repository"
	INSTALL_REPOSITORY=false
	;;
    h)
	 echo "-s yes start to build static"
	 echo "-d yes start to build shared" 
	 echo "-n yes not install dependencies"
	 echo "-r yes not install repository"
	exit 0
	;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done

if [ $BUILD_STATIC == true ];then 
	echo "start static build"
else
	echo "started shared build"
fi

iSok() {
     if [ $1 -ne 0 ];then
              echo -n " [FAIL]"
              exit 1
     else
             echo -n " [OK]"
     fi
 
}


# added github.com to path
for (( i = 0 ; i < ${#LIBPCAP_SOURCES_FILES[@]} ; i++ )) do
    LIBPCAP_SOURCES_FILES[$i]=${GITHUB_PREFIX}/SOURCES/${LIBPCAP_SOURCES_FILES[$i]} 
done

if [ ${INSTALL_DEPENDENCES} == true ];then
	yum groupinstall "Development Tools" -y &> /dev/null
	yum install git tar wget -y &> /dev/null
	echo " install libevent-devel"
	yum remove libevent-devel -y &> /dev/null
	yum install libevent-devel -y &> /dev/null
	echo "remove libpcap-*"
	yum remove -y libpcap libpcap-devel libpcap-debuginfo &> /dev/null
	for libpcap_installed in `rpm -qa --queryformat '%{NAME}\n'|grep libpcap 2>/dev/null`;do
                yum remove ${libpcap_installed} -y  &> /dev/null
        done

	if [ $BUILD_STATIC == true ];then
		# needed for static compile
		yum install glibc-static.x86_64 bluez-libs-devel -y &> /dev/null
	else
		# needed for shared compile
		yum install libpcap libpcap-devel -y &> /dev/null
	fi
fi



echo "install repository"
if [ -f /etc/redhat-release  ] && [ $INSTALL_REPOSITORY == true ];then
	echo -n "install repository of EPEL for "	
    echo $OS_VERSION |grep 7 &> /dev/null
    if [ $? -eq 0 ];then
    echo -n "CentOs7"
            wget ${EPEL_CENTOS7} &> /dev/null
            rpm -Uvh epel-release*.rpm &> /dev/null
            rm epel-release*.rpm &> /dev/null
    fi

	echo $OS_VERSION |grep 6 &> /dev/null
	if [ $? -eq 0 ];then
		echo -n "CentOs6"
		wget ${EPEL_CENTOS6} &> /dev/null
		rpm -Uvh epel-release*.rpm &> /dev/null
		rm epel-release*.rpm &> /dev/null
	fi

	echo $OS_VERSION |grep 5 &> /dev/null
    if [ $? -eq 0 ];then
    echo -n "CentOs5"
            wget ${EPEL_CENTOS5} &> /dev/null
            rpm -Uvh epel-release*.rpm &> /dev/null
            rm epel-release*.rpm &> /dev/null
    fi

	echo  "..."
fi


echo " create rpmbuild stuff"
mkdir -p ~/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
echo '%_topdir %(echo $HOME)/rpmbuild' > ~/.rpmmacros

cd ${SPEC_PATH}
	echo "store spec files to ${SPEC_PATH}"
	rm -rf $(basename $FRAGROUTE_SPEC)* &> /dev/null 
	#${WGET} ${FRAGROUTE_SPEC} &> /dev/null
	rm -rf $(basename $FRAGROUTE_STATIC_SPEC)* &> /dev/null
	#${WGET} ${FRAGROUTE_STATIC_SPEC} &> /dev/null
	rm -rf $(basename $LIBDNET_SPEC)* &> /dev/null
	#${WGET} ${LIBDNET_SPEC} &> /dev/null
	rm -rf $(basename $LIBPCAP_SPEC)* &> /dev/null

	${WGET} ${FRAGROUTE_SPEC} &> /dev/null
	${WGET} ${FRAGROUTE_STATIC_SPEC} &> /dev/null
	${WGET} ${LIBDNET_SPEC} &> /dev/null
	${WGET} ${LIBPCAP_SPEC} &> /dev/null
	

cd ${OLDPWD}
cd ${SOURCES_PATH}
	echo "get fragroute files from repositories"
	filename=$(basename $FRAGROUTE_REPO)
	filename=${filename%.*}
	rm -rf ${filename} &> /dev/null
	rm -rf ${FRAGROUTE_FILE_NAME%.*.*} &> /dev/null
	rm -rf ${FRAGROUTE_FILE_NAME} &> /dev/null
	git clone ${FRAGROUTE_REPO} &> /dev/null
	mv ${filename} ${FRAGROUTE_FILE_NAME%.*.*} &> /dev/null
	tar czf ${FRAGROUTE_FILE_NAME} ${FRAGROUTE_FILE_NAME%.*.*} &> /dev/null

	echo "get libdnet files from repositories"
        filename=$(basename $LIBDNET_REPO)
        filename=${filename%.*}
	rm -rf ${filename} &> /dev/null
	rm -rf ${LIBDNET_FILE_NAME%.*.*} &> /dev/null
	rm -rf  ${LIBDNET_FILE_NAME} &> /dev/null


        git clone ${LIBDNET_REPO} &> /dev/null
        mv ${filename} ${LIBDNET_FILE_NAME%.*.*}
        tar czf ${LIBDNET_FILE_NAME} ${LIBDNET_FILE_NAME%.*.*} &> /dev/null


	#echo "get libpcap for static build"
	for (( i = 0 ; i < ${#LIBPCAP_SOURCES_FILES[@]} ; i++ )) do
		 rm -f ${LIBPCAP_SOURCES_FILES[$i]} &> /dev/null
		  ${WGET}  ${LIBPCAP_SOURCES_FILES[$i]} &> /dev/null
	done



cd ${OLDPWD}
cd ${SPEC_PATH}
	if [ ! -f  $(basename $LIBDNET_SPEC) ];then 
		echo " there aren't ${SPEC_PATH}/$(basename $LIBDNET_SPEC), exiting..."
		exit 1
	fi
	echo -n "build libdnet"
	rpmbuild -ba $(basename $LIBDNET_SPEC) &> /dev/null
	iSok $?
	echo "remove libdnet"
	yum remove -y libdnet libdnet-devel libdnet-debuginfo &>/dev/null
	for libdnet_installed in `rpm -qa --queryformat '%{NAME}\n'|grep libdnet 2>/dev/null`;do
		yum remove ${libdnet_installed} -y &> /dev/null
	done
	#echo ""
	echo -n "install ${RPMS_PATH}/libdnet-*.rpm"
	echo $OS_VERSION |grep 7 &> /dev/null
    if [ $? -eq 0 ];then
        echo -n " for CentOS 7"
        RPM_EXTRA_OPTs="$RPM_EXTRA_OPTs --force"
    fi
	rpm -Uvh ${RPM_EXTRA_OPTs} ${RPMS_PATH}/libdnet-*.rpm &> /dev/null
	iSok $?
	echo ""


	case "$BUILD_STATIC" in 
		"true")
			if [ ! -f $(basename $LIBPCAP_SPEC) ];then		
				echo " there aren't ${SPEC_PATH}/$(basename $LIBPCAP_SPEC), exiting..."
				exit 1
			fi
			echo -n "build libpcap-static"
			rpmbuild -ba $(basename $LIBPCAP_SPEC)  &> /dev/null
			iSok $?
			#echo ""
			#yum remove -y libpcap libpcap-devel libpcap-debuginfo &> /dev/null
			#for libpcap_installed in `rpm -qa --queryformat '%{NAME}\n'|grep libpcap 2>/dev/null`;do				
			#	yum remove ${libpcap_installed} -y  &> /dev/null
			#done

			echo ""
			echo -n "install ${RPMS_PATH}/libpcap*.rpm"
			rpm -Uvh ${RPMS_PATH}/libpcap*.rpm &> /dev/null
			iSok $?

		 	if [ ! -f  $(basename  $FRAGROUTE_STATIC_SPEC) ];then
                                echo " there aren't ${SPEC_PATH}/$(basename $FRAGROUTE_STATIC_SPEC), exiting..."
                                exit 1
                        fi
			echo ""
			echo -n  "build fragroute-static"
			rpmbuild -ba $(basename $FRAGROUTE_STATIC_SPEC) &> /dev/null
			iSok $?
		;;
		"false")

			if [ ! -f  $(basename  $FRAGROUTE_SPEC) ];then
				echo " there aren't ${SPEC_PATH}/$(basename $FRAGROUTE_SPEC), exiting..."
				exit 1
			fi
			echo -n "build fragroute"
			rpmbuild -ba $(basename $FRAGROUTE_SPEC) &> /dev/null
			iSok $?
			;;
	esac

cd ${OLDPWD}
echo ""
echo " [done]"

exit 0
