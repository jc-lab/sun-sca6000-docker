# sca6000 (Sun Crypto Accelerator 6000) docker image based centos-5.3



## Example

```bash
# Build & Install driver
$ git clone https://github.com/jc-lab/sun-sca6000-drv.git
$ cd sun-sca6000-drv
$ make
$ sudo make install
# Now, sca6000 driver will be install to /opt/sun/sca6000/bin/drv

# You need to disable SELinux.

$ sudo docker build --tag=sca6000_base .
$ sudo docker run -it --name test --privileged --cap-add=ALL -v /dev:/dev -v /var/opt/sun/sca6000/:/var/opt/sun/sca6000/ -v /opt/sun/sca6000/bin/drv:/mnt/sun/sca6000/bin/drv sca6000_base /entrypoint.sh /bin/bash

# You can firmware upgrade or management by /opt/sun/sca6000/bin/scamgr.

bash-3.2# pkcs11-tool --module /usr/lib64/opencryptoki/PKCS11_API.so -L
Available slots:
Slot 0 (0x0): Linux 3.10.0-957.27.2.el7.x86_64.debug Linux (SCA)
  token label        : test_1
  token manufacturer : SUNWmca
  token model        : sca6000
  token flags        : login required, rng, SO PIN locked, token initialized, PIN initialized
  hardware version   : 0.0
  firmware version   : 0.0
  serial num         :
  pin min/max        : 0/253
Slot 1 (0x1): Linux 3.10.0-957.27.2.el7.x86_64.debug Linux (SCA)
  token state:   uninitialized
Slot 2 (0x2): Linux 3.10.0-957.27.2.el7.x86_64.debug Linux (SCA)
  token state:   uninitialized
```

## Thanks

* The Packages are from https://ftp.nohats.ca/sca6000/
