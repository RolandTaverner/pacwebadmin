################# Dlang compiler image
FROM ubuntu:24.04 AS dlang

ENV D_VERSION=dmd-2.111.0
ENV BIN_FOLDER=linux/bin64
ENV LIB_FOLDER=linux/lib64
ENV DEBIAN_FRONTEND=noninteractive
ENV DPATH=/dlang

RUN set -ex && \
	apt-get update && \
	apt-get install --no-install-recommends -y \
	ca-certificates \
	curl \
	libc6-dev \
	gcc \
	libevent-dev \
	libssl-dev \
	libxml2 \
	libz-dev \
	gpg \
	make \
	xz-utils \
	&& update-alternatives --install "/usr/bin/ld" "ld" "/usr/bin/ld.gold" 20 \
	&& update-alternatives --install "/usr/bin/ld" "ld" "/usr/bin/ld.bfd" 10

# Ubuntu 24.04 has user ubuntu with uid=1000
RUN touch /var/mail/ubuntu && chown ubuntu /var/mail/ubuntu && userdel -r ubuntu

RUN groupadd --gid 1000 dlang \
  && useradd --uid 1000 --gid dlang --shell /bin/bash --create-home dlang

RUN mkdir ${DPATH}\
    && chown dlang ${DPATH}

USER dlang

RUN curl -fsS https://dlang.org/install.sh -o /tmp/install.sh
RUN chmod +x /tmp/install.sh
RUN /tmp/install.sh ${D_VERSION} -p ${DPATH}

USER root

RUN chmod 755 -R ${DPATH}
RUN ln -s ${DPATH}/${D_VERSION} ${DPATH}/dc && ls ${DPATH}

ENV PATH="${DPATH}/${D_VERSION}/${BIN_FOLDER}:${PATH}"
ENV LIBRARY_PATH="${DPATH}/${D_VERSION}/${LIB_FOLDER}:${LIBRARY_PATH}"
ENV LD_LIBRARY_PATH="${DPATH}/${D_VERSION}/${LIB_FOLDER}:${LD_LIBRARY_PATH}"

################# Build D app
FROM dlang AS dlang_builder
USER dlang
WORKDIR /src

COPY --chown=dlang:dlang --chmod=644 ./source ./source
COPY --chown=dlang:dlang --chmod=644 ./dub.json .
COPY --chown=dlang:dlang --chmod=644 ./dub.selections.json .
RUN find . -type d -exec chmod 755 {} \;

RUN dub build --parallel --build=release

######### Node & npm
FROM node:24 AS web_builder
RUN npm install -g typescript
WORKDIR /src
COPY ./web-admin .
RUN npm install
RUN npm run build

