FROM jclab/centos-new-5.3
MAINTAINER Joseph Lee <development@jc-lab.net>

ADD ["package/", "/tmp/"]

# Install SCA6000 Packages
RUN mkdir -p /mnt/sun/sca6000/bin/drv && \
    mkdir -p /opt/package/ && \
    mv /tmp/sun-sca6000-1.1-5.x86_64.rpm /opt/package/sun-sca6000-1.1-5.x86_64.rpm && \
    rpm -Uvh /tmp/sun-nspr-4.6.7-2.x86_64.rpm && \
    rpm -Uvh /tmp/sun-nss-3.11.7-2.x86_64.rpm && \
    rpm -Uvh /tmp/sun-sca6000-libs-1.1-2.x86_64.rpm && \
    rpm -Uvh /tmp/sun-sca6000-config-1.1-2.x86_64.rpm && \
    rpm -Uvh /tmp/sun-sca6000-var-1.1-2.x86_64.rpm && \
    rpm -Uvh /tmp/sun-sca6000-admin-1.1-3.x86_64.rpm && \
    rpm -Uvh /tmp/sun-sca6000-firmware-1.1-3.x86_64.rpm && \
    rm -f /tmp/sun-*.rpm && \
    mkdir -p /opt/sun/sca6000/bin/drv/

# Build softwares
RUN mkdir -p /usr/src/build

ARG AUTOCONF_VERSION=2.69
ARG AUTOMAKE_VERSION=1.5

RUN yum install -y make gcc gcc-c++ gettext m4 libtool zlib zlib-devel pkgconfig glib2-devel pcsc-lite-devel openCryptoki openCryptoki-devel bzip2 libtool-ltdl libtool-ltdl-devel

RUN cd /usr/src/build && \
    curl http://ftp.gnu.org/gnu/autoconf/autoconf-${AUTOCONF_VERSION}.tar.gz -o autoconf-${AUTOCONF_VERSION}.tar.gz && \
    echo "954bd69b391edc12d6a4a51a2dd1476543da5c6bbf05a95b59dc0dd6fd4c2969 *autoconf-${AUTOCONF_VERSION}.tar.gz" | sha256sum -c - && \
    tar -zxf autoconf-${AUTOCONF_VERSION}.tar.gz && \
    cd autoconf-${AUTOCONF_VERSION} && \
    ./configure --prefix=/usr --libdir=/usr/lib64 && \
    make && make install

RUN cd /usr/src/build/ && \
    curl http://ftp.gnu.org/gnu/automake/automake-${AUTOMAKE_VERSION}.tar.gz -o automake-${AUTOMAKE_VERSION}.tar.gz && \
    echo "24b4775e3143fd3e35db5cbaba80845d9359c7bfd751a6cebe3014fbf6115d78 *automake-${AUTOMAKE_VERSION}.tar.gz" | sha256sum -c - && \
    tar -zvxf automake-${AUTOMAKE_VERSION}.tar.gz && \
    cd automake-${AUTOMAKE_VERSION} && \
    ./configure --prefix=/usr --libdir=/usr/lib64 && \
    make && make install

ARG LIBP11_VERSION=0.4.10
ARG OPENSC_VERSION=0.19.0

COPY ["opensc-${OPENSC_VERSION}.tar.gz", "libp11-${LIBP11_VERSION}.tar.gz", "/usr/src/build/"]

COPY ["my_endian.h", "/usr/local/include"]

RUN cd /usr/src/build \
    && tar -zxf opensc-${OPENSC_VERSION}.tar.gz \
    && rm opensc-${OPENSC_VERSION}.tar.gz \
    && cd opensc-${OPENSC_VERSION} \
    && echo "" >> src/libopensc/internal.h \
    && echo "#include <my_endian.h>" >> src/libopensc/internal.h \
    && find -name "Makefile*" | xargs sed -i -e 's/-Wno-unused-but-set-variable//g' \
    && find -name "Makefile*" | xargs sed -i -e 's/-Wno-unknown-warning-option//g' \
    && ./configure \
        --prefix=/usr \
        --libdir=/usr/lib64 \
        --sysconfdir=/etc \
        --disable-man \
        --enable-zlib \
        --enable-openssl \
        --enable-sm \
        CC='gcc' CFLAGS='-I/usr/local/include -D_GNU_SOURCE' \
    && make \
    && make install
RUN cd /usr/src/build \
    && tar -zxf libp11-${LIBP11_VERSION}.tar.gz \
    && rm libp11-${LIBP11_VERSION}.tar.gz \
    && cd libp11-${LIBP11_VERSION} \
    && ./configure --prefix=/usr --libdir=/usr/lib64 \
    && make \
    && make install

RUN groupadd -r -g 901 opensc \
    && useradd -r -u 901 -g opensc -s /bin/sh -d /run/pcscd opensc \
    && mkdir -p /run/pcscd \
    && chown -R nobody:nobody /run/pcscd

RUN rm -r /usr/src/build && \
    yum remove -y make gcc make && \
    yum clean all && \
    mkdir -p /usr/lib64/opencryptoki/stdll/backup && \
    cd /usr/lib64/opencryptoki/stdll/ && \
    mv PKCS11_SW* libpkcs11_sw* libpkcs11_tpm* backup/

WORKDIR /
ADD ["entrypoint.sh", "/"]
RUN chmod +x /entrypoint.sh
CMD ["/entrypoint.sh"]

