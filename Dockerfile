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

# *************** Create user for development purpose ***********************
# This user is needed, seems like /root/.* files are deleted therefore all bash aliases
# and customization(vim) etc are gone.
RUN useradd -ms /bin/bash ubuntu
RUN echo "ubuntu ALL=(ALL) NOPASSWD: ALL" | tee -a /etc/sudoers
RUN echo 'ubuntu:password' | chpasswd

# *************** Configuring vim *******************
# Create bundle directory for pathogen
RUN mkdir -p /home/ubuntu/.vim/autoload /home/ubuntu/.vim/bundle

# Install pathogen
RUN curl -LSso /home/ubuntu/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

# Add vimrc file
COPY lib/vim/vimrc /home/ubuntu/.vimrc

WORKDIR /home/ubuntu/.vim/bundle
RUN git clone https://github.com/vim-syntastic/syntastic.git
RUN git clone https://github.com/scrooloose/nerdtree.git
RUN git clone https://github.com/vim-scripts/vcscommand.vim.git

RUN apt-get -y install ctags

# **************** Beautify Bash ********************
COPY lib/bash/bash_aliases "/home/ubuntu/.bash_aliases"
COPY lib/bash/bash_profile "/home/ubuntu/.mybashrc"
RUN echo "source /home/ubuntu/.mybashrc" | tee -a /home/ubuntu/.profile

# *************** config for git *******************
# Add git config
COPY lib/git/gitconfig /home/ubuntu/.gitconfig

# Add link for hooks of repositories
COPY lib/git/setup_hooks.sh /home/ubuntu/setup_hooks.sh
RUN /home/ubuntu/setup_hooks.sh && rm /home/ubuntu/setup_hooks.sh

WORKDIR /home/ubuntu

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
