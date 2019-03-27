FROM debian:testing

RUN apt-get -y update
RUN apt-get -y dist-upgrade
RUN apt-get -y install binutils-dev binutils-gold clang-6.0 clisp cmake \
  curl ecl g++ gcc libboost-date-time-dev libboost-filesystem-dev \
  libboost-iostreams-dev libboost-program-options-dev libboost-regex-dev \
  libboost-system-dev libbsd-dev libclang-6.0-dev libcurl3-gnutls libelf-dev \
  libelf1 libgc-dev libgmp-dev liblzma-dev libncurses-dev libunwind-dev \
  libzmq3-dev llvm nano openjdk-8-jre python3 python3-pip sbcl wget zlib1g-dev

RUN curl -L -O https://github.com/roswell/roswell/releases/download/v19.3.10.97/roswell_19.3.10.97-1_amd64.deb
RUN dpkg -i roswell_19.3.10.97-1_amd64.deb
RUN rm roswell_19.3.10.97-1_amd64.deb

ARG NB_USER=app
ARG NB_UID=1000

ENV USER ${NB_USER}
ENV HOME /home/${NB_USER}
ENV PATH="${HOME}/.local/bin:${HOME}/.roswell/bin:${PATH}"

RUN useradd --create-home --shell=/bin/false --uid=${NB_UID} ${NB_USER}
RUN chown -R ${NB_UID} ${HOME}
RUN chgrp -R ${NB_USER} ${HOME}

WORKDIR ${HOME}
USER ${NB_USER}
RUN pip3 install jupyter

RUN ros version
RUN ros install abcl-bin
RUN ros install ccl-bin
RUN ros install clasp
RUN ros install clisp
RUN ros install cmu-bin
RUN ros use sbcl-bin
