# Base Image
FROM ubuntu:latest

MAINTAINER thenakliman@gmail.com

# Update repository
RUN apt-get update

# Install necessary packages
RUN apt-get install -y \
    python2.7 \
    python3.5 \
    python-pip \
    vim \
    git \
    curl \
    openssh-server

# ************* Configure pip *************************
# Install python packages using pip
ENV LC_ALL=C

RUN pip install git-review \
                tox

# Networking Debug tools
RUN apt-get install -y net-tools \
                       iputils-ping

# *************  Setup sshd *************************
RUN mkdir /var/run/sshd
RUN echo 'root:password' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

RUN ssh-keygen -A

# *************** Configuring vim *******************
# Create bundle directory for pathogen
RUN mkdir -p ~/.vim/autoload ~/.vim/bundle

# Install pathogen
RUN curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

# Add vimrc file
COPY lib/vim/vimrc /root/.vimrc

WORKDIR /root/.vim/bundle
RUN git clone https://github.com/vim-syntastic/syntastic.git
RUN git clone https://github.com/scrooloose/nerdtree.git
RUN git clone https://github.com/vim-scripts/vcscommand.vim.git

RUN apt-get -y install ctags

# **************** Beautify Bash ********************
COPY lib/bash/bash_aliases /root/.bash_aliases
COPY  lib/bash/bash_profile /root/.my_profile
RUN echo "source /root/.my_profile" >> /root/.bash_profile

# *************** config for git *******************
# Add git config
COPY lib/git/gitconfig /root/.gitconfig

# Add link for hooks of repositories
COPY lib/git/setup_hooks.sh /root/setup_hooks.sh
RUN /root/setup_hooks.sh && rm /root/setup_hooks.sh

WORKDIR /root/work

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
