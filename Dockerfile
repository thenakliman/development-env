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
    openssh-server

# Install python packages using pip
RUN pip install git-review \
                tox

# Networking Debug tools
RUN apt-get install -y net-tools \
                       iputils-ping

# Setup sshd
RUN mkdir /var/run/sshd
RUN echo 'root:password' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

RUN ssh-keygen -A

# Add vimrc file
COPY lib/vim/vimrc /root/.vimrc

WORKDIR /root/work

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
