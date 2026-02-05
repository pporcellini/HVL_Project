FROM ubuntu:22.04

SHELL ["/bin/bash", "-c"]

RUN apt-get update

ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

#RUN yes | unminimize
# Install prerequisites
# zephyr install script requires cmake and file
# Our build of Xilinx qemu needs libpixman libslirp etc
#RUN apt-get install --assume-yes sudo

# setup a no password required sudo group
#RUN addgroup --system sudo_nopwd; echo "%sudo_nopwd ALL=(ALL:ALL) NOPASSWD:ALL" >/etc/sudoers.d/20-sudo_nopwd; chmod 600 /etc/sudoers.d/*

# add the dev user
#RUN adduser --gecos "dev" --disabled-password dev; adduser dev sudo_nopwd
#RUN su -l dev
#USER dev
ENV HOME=/home
ENV WS=/home/hypervisorless_virtio_zcu102/hvlws

#RUN apt-get update
RUN apt-get update && apt-get upgrade --assume-yes
WORKDIR "$HOME"
#COPY hypervisorless_virtio_zcu102 $HOME/hypervisorless_virtio_zcu102
RUN apt-get install --assume-yes \
    ca-certificates \
    apt-transport-https \
    git \
    wget
RUN git clone https://github.com/pporcellini/hypervisorless_virtio_zcu102.git
COPY dl $HOME/hypervisorless_virtio_zcu102/dl
RUN chmod -R 777 $HOME/hypervisorless_virtio_zcu102
WORKDIR "$HOME/hypervisorless_virtio_zcu102"

RUN apt-get install --assume-yes python3-sphinx qemu-user qemu-user-static libpixman-1-dev libssl-dev ca-certificates apt-transport-https build-essential 

#altre dipendenze
RUN apt-get install --assume-yes wget nano telnet openssh-client
#per sd
RUN apt-get install --assume-yes fdisk mtools dosfstools
#per qemu 2024.1
RUN sed -i.bak 's/^# *deb-src/deb-src/g' /etc/apt/sources.list
RUN apt-get update
RUN apt-get build-dep -y qemu
#da sito xilinx
RUN apt-get install --assume-yes libglib2.0-dev libgcrypt20-dev zlib1g-dev autoconf automake libtool bison flex

#kpartx
RUN wget https://apt.kitware.com/kitware-archive.sh
RUN bash kitware-archive.sh
RUN apt-get install --assume-yes --no-install-recommends git cmake ninja-build gperf \
  ccache dfu-util device-tree-compiler wget \
  python3-dev python3-pip python3-setuptools python3-tk python3-wheel xz-utils file \
  make gcc gcc-multilib g++-multilib libsdl2-dev

#dipendenze mancanti
RUN apt-get install --assume-yes bc python3-venv libmagic1

#creazione environment python
RUN python3 -m venv $WS/zephyrenv/.venv
RUN source $WS/zephyrenv/.venv/bin/activate 
RUN pip install west
RUN pip install wheel
#RUN pip3 install --user -U west
#RUN echo 'export PATH=/home/.local/bin:$PATH' >> /home/root/.bashrc
#RUN source /home/root/.bashrc
#RUN export PATH=/home/.local/bin:"$PATH"
#RUN echo "PS1='\[\e[38;5;39m\]\w\[\e[0m\] \[\e[38;5;46;1m\]>\[\e[0m\] '" >> /home/root/.bashrc

#RUN echo "source /home/root/.bashrc" >> /home/root/.profile

#RUN apt-get install -y software-properties-common 

#RUN source /home/root/.bashrc
# Set the entry point to source .bashrc and start bash

CMD ["bash", "-c", " exec /bin/bash -il"]
#source /home/root/.bashrc &&
#RUN source /root/.bashrc
