FROM voidlinux/voidlinux-musl
MAINTAINER Janne K. Olesen <janne.olesen@um-orange.com>

RUN xbps-install -u xbps -Sy
RUN xbps-install -Sy make gcc libtool autoconf automake pkg-config wget ncurses ncurses-devel sudo file upx

ENV user core

RUN useradd -d /home/$user -m -s /bin/bash $user
RUN echo "$user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$user
RUN chmod 0440 /etc/sudoers.d/$user

USER $user

ENV VER 4.9.0

WORKDIR /home/$user
RUN wget http://ftp.gnu.org/gnu/screen/screen-$VER.tar.gz
RUN tar -xvzf screen-$VER.tar.gz
WORKDIR /home/$user/screen-$VER
RUN ./autogen.sh
RUN ./configure
RUN make LDFLAGS="-static"

# ldd returns an exit code of 0 if the binary is dynamic, 1 if it is a static, here the "!" reverts the test to make it successful if it is a static
RUN ! ldd screen
RUN file screen

RUN upx -v --lzma -9 -o screen-upx screen
RUN ! ldd screen-upx
RUN file screen-upx
