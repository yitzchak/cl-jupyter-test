FROM debian:testing

ARG APP_USER=app
ARG APP_UID=1000

RUN apt-get -y update
RUN apt-get -y dist-upgrade
RUN apt-get -y install binutils-dev binutils-gold clang-6.0 clisp cmake \
  curl ecl g++ gcc git libboost-date-time-dev libboost-filesystem-dev \
  libboost-iostreams-dev libboost-program-options-dev libboost-regex-dev \
  libboost-system-dev libbsd-dev libclang-6.0-dev libcurl3-gnutls libelf-dev \
  libelf1 libgc-dev libgmp-dev liblzma-dev libncurses-dev libunwind-dev \
  libzmq3-dev llvm nano openjdk-8-jre python3 python3-github python3-pip \
  python3-wget sbcl wget zlib1g-dev

ENV USER ${APP_USER}
ENV HOME /home/${APP_USER}
ENV PATH="${HOME}/.local/bin:${HOME}/.roswell/bin:${PATH}"

RUN useradd --create-home --shell=/bin/false --uid=${APP_UID} ${APP_USER}
COPY . ${HOME}
RUN chown -R ${APP_UID} ${HOME}
RUN chgrp -R ${APP_USER} ${HOME}

WORKDIR ${HOME}
USER ${APP_USER}

RUN git clone https://github.com/clasp-developers/clasp.git
WORKDIR ${HOME}/clasp
RUN git checkout dev
RUN ./waf configure
RUN ./waf build_cboehm

USER root
RUN ./waf install_cboehm

WORKDIR ${HOME}
RUN rm -rf clasp

RUN python3 get-roswell.py
RUN dpkg -i *.deb
RUN rm *.deb

USER ${APP_USER}

RUN pip3 install jupyter

RUN ros install sbcl-bin
RUN ros install abcl-bin
RUN ros install ccl-bin
RUN ros install cmu-bin
RUN ros install clisp
RUN ros use sbcl-bin

RUN wget https://beta.quicklisp.org/quicklisp.lisp
RUN sbcl --load quicklisp.lisp --load install-quicklisp.lisp
