#!/bin/bash
#########################
# build fragroute on 
# CentOs
# from root
#
# version 0.1 <09.12.2014>
# <weldpua2008@gmail.com>
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


FRAGROUTE_SPEC="https://raw.githubusercontent.com/weldpua2008/fragroute/master/SPECS/fragroute.spec"
LIBDNET_SPEC="https://raw.githubusercontent.com/weldpua2008/fragroute/master/SPECS/libdnet.spec"
SPEC_PATH=~/rpmbuild/SPECS
SOURCES_PATH=~/rpmbuild/SOURCES
RPMS_PATH=~/rpmbuild/RPMS/`arch`


#FRAGROUTE_REPO="https://github.com/stsi/fragroute-ipv6"
FRAGROUTE_REPO="https://github.com/weldpua2008/fragroute-ipv6.git"
#LIBDNET_REPO="https://github.com/stsi/libdnet-ipv6"
LIBDNET_REPO="https://github.com/weldpua2008/libdnet-ipv6.git"

FRAGROUTE_FILE_NAME=fragroute-1.2.6-ipv6.tar.gz
LIBDNET_FILE_NAME=libdnet-1.12.tar.gz
LIBDNET_DST_FILE="https://raw.githubusercontent.com/weldpua2008/fragroute/master/SOURCES/${LIBDNET_FILE_NAME}"
FRAGROUTE_DST_FILE="https://raw.githubusercontent.com/weldpua2008/fragroute/master/SOURCES/${FRAGROUTE_FILE_NAME}"
GET_FILES_FROM_GIT=true

EPEL_CENTOS5="http://dl.fedoraproject.org/pub/epel/5/x86_64/epel-release-5-4.noarch.rpm"
EPEL_CENTOS6="http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm"
EPEL_CENTOS7="http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-1.noarch.rpm"

yum groupinstall "Development Tools" -y 
yum install git -y

echo "install repository"
if [ -f /etc/redhat-release ];then
	echo ""
	echo -n "install repository of EPEL for "	
	 cat /etc/redhat-release|cut -d "." -f1 |grep 7 &> /dev/null
        if [ $? -eq 0 ];then
		echo -n "CentOs7"
                wget ${EPEL_CENTOS7}
                rpm -Uvh epel-release*.rpm
                rm epel-release*.rpm
        fi

	cat /etc/redhat-release|cut -d "." -f1 |grep 6 &> /dev/null
	if [ $? -eq 0 ];then
		echo -n "CentOs6"
		wget ${EPEL_CENTOS6}
		rpm -Uvh epel-release*.rpm
		rm epel-release*.rpm
	fi

	cat /etc/redhat-release|cut -d "." -f1 |grep 5 &> /dev/null
        if [ $? -eq 0 ];then
		echo -n "CentOs5"
                wget ${EPEL_CENTOS5}
                rpm -Uvh epel-release*.rpm
                rm epel-release*.rpm
        fi

	echo  "..."
fi
echo " install libpcap libevent-devel"
yum install libpcap libevent-devel libpcap-devel -y


mkdir -p ~/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
echo '%_topdir %(echo $HOME)/rpmbuild' > ~/.rpmmacros

cd ${SPEC_PATH}
	echo "store spec files to ${SPEC_PATH}"
	wget ${FRAGROUTE_SPEC} 
	wget ${LIBDNET_SPEC}

cd ${OLDPWD}
cd ${SOURCES_PATH}
	echo "get fragroute files from repositories"
	filename=$(basename $FRAGROUTE_REPO)
	filename=${filename%.*}
	rm -rf ${filename} &> /dev/null
	rm -rf ${FRAGROUTE_FILE_NAME%.*.*} &> /dev/null
	rm -rf ${FRAGROUTE_FILE_NAME} &> /dev/null
	git clone ${FRAGROUTE_REPO}
	mv ${filename} ${FRAGROUTE_FILE_NAME%.*.*}
	tar czf ${FRAGROUTE_FILE_NAME} ${FRAGROUTE_FILE_NAME%.*.*}

	echo "get libdnet files from repositories"
        filename=$(basename $LIBDNET_REPO)
        filename=${filename%.*}
	rm -rf ${filename} &> /dev/null
	rm -rf ${LIBDNET_FILE_NAME%.*.*} &> /dev/null
	rm -rf  ${LIBDNET_FILE_NAME} &> /dev/null


        git clone ${LIBDNET_REPO}
        mv ${filename} ${LIBDNET_FILE_NAME%.*.*}
        tar czf ${LIBDNET_FILE_NAME} ${LIBDNET_FILE_NAME%.*.*}

cd ${OLDPWD}

cd ${SPEC_PATH}
	if [ ! -f  $(basename $LIBDNET_SPEC) ];then 
		echo " there aren't ${SPEC_PATH}/$(basename $LIBDNET_SPEC), exiting..."
		exit 1
	fi
	echo "build libdnet"
	rpmbuild -ba $(basename $LIBDNET_SPEC)
	rpm -Uvh ${RPMS_PATH}/libdnet-*.rpm



	if [ ! -f  $(basename  $FRAGROUTE_SPEC) ];then
		echo " there aren't ${SPEC_PATH}/$(basename $FRAGROUTE_SPEC), exiting..."
		exit 1
	fi
	echo "build fragroute"
	rpmbuild -ba $(basename $FRAGROUTE_SPEC)

cd ${OLDPWD}

exit 0
