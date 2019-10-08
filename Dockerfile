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
  libzmq3-dev llvm nano openjdk-13-jre python3 python3-github python3-pip \
  python3-wget sbcl wget zlib1g-dev npm

ENV USER ${APP_USER}
ENV HOME /home/${APP_USER}
ENV PATH="${HOME}/.local/bin:${HOME}/.roswell/bin:${PATH}"

RUN useradd --create-home --shell=/bin/false --uid=${APP_UID} ${APP_USER}

WORKDIR ${HOME}
USER ${APP_USER}

RUN git clone https://github.com/clasp-developers/clasp.git
WORKDIR ${HOME}/clasp
RUN ./waf configure
RUN ./waf build_cboehm

USER root
RUN ./waf install_cboehm

WORKDIR ${HOME}
RUN rm -rf clasp

RUN wget https://github.com/roswell/roswell/releases/download/v19.09.12.102/roswell_19.09.12.102-1_amd64.deb && \
  dpkg -i *.deb && rm *.deb

USER ${APP_USER}

RUN pip3 install --user jupyter jupyterlab jupyter_kernel_test && \
  jupyter serverextension enable --user --py jupyterlab && \
  jupyter labextension install @jupyter-widgets/jupyterlab-manager && \
  jupyter nbextension enable --user --py widgetsnbextension

RUN ros install sbcl-bin && ros install abcl-bin && ros install ccl-bin && \
  ros install cmu-bin && ros install clisp && ros use sbcl-bin

RUN wget https://beta.quicklisp.org/quicklisp.lisp && \
  sbcl --load quicklisp.lisp --eval "(quicklisp-quickstart:install)" --quit && \
  rm quicklisp.lisp && \
  git clone https://github.com/sionescu/bordeaux-threads.git ~/quicklisp/local-projects/bordeaux-threads

COPY --chown=${APP_UID}:${APP_USER} home ${HOME}

