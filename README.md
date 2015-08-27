[![Build Status](https://travis-ci.org/weldpua2008/fragroute.svg?branch=master)](https://travis-ci.org/weldpua2008/fragroute)

fragroute
=========
build fragroute on CentOs's from root with ipv6 support
Please use  build.sh but before see what inside

== Static build
preparetion step:
	 rm -rf build_static.sh;wget https://raw.githubusercontent.com/weldpua2008/fragroute/master/build_static.sh;chmod 755 build_static.sh


and do simply:
	./build_static.sh -s yes


    # ./build_static.sh -d yes
    started shared build
    install libevent-devel
    remove libpcap-*
    install repository
    install repository of EPEL for CentOs6...
    create rpmbuild stuff
    store spec files to /root/rpmbuild/SPECS
    get fragroute files from repositories
    get libdnet files from repositories
    build libdnet [OK]remove libdnet
    install /root/rpmbuild/RPMS/x86_64/libdnet-*.rpm [OK]
    build fragroute [OK]
     [done]

    # ./build_static.sh -s yes
    start static build
     install libevent-devel
    remove libpcap-*
    install repository
    install repository of EPEL for CentOs6...
    create rpmbuild stuff
    store spec files to /root/rpmbuild/SPECS
    get fragroute files from repositories
    get libdnet files from repositories
    build libdnet [OK]remove libdnet
    install /root/rpmbuild/RPMS/x86_64/libdnet-*.rpm [OK]
    build libpcap-static [OK]
    install /root/rpmbuild/RPMS/x86_64/libpcap*.rpm [OK]
    build fragroute-static [OK]
     [done]

==== OS dependencies
* tar
* wget
* git
* yum
