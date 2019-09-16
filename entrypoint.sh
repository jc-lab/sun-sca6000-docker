#!/bin/bash

cp -rf /mnt/sun/sca6000/bin/drv/* /opt/sun/sca6000/bin/drv/

if [ ! -f /.sca-installed ]; then
	rpm -Uvh /opt/package/sun-sca6000-1.1-5.x86_64.rpm >> /var/log/sca-install.log
	pkcs11_startup
	touch /.sca-installed
fi

/etc/init.d/sca stop
/etc/init.d/rsyslog start
/etc/init.d/sca start >> /var/log/sca-install.log
/etc/init.d/pkcsslotd start

exec $@

