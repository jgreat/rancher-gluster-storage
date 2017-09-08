FROM ubuntu:16.04

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F7C73FCC930AC9F83B387A5613E01B7B3FE869A9 && \
    echo "deb http://ppa.launchpad.net/gluster/glusterfs-3.12/ubuntu xenial main" > /etc/apt/sources.list.d/gluster.list && \
    apt-get update && \
    apt-get install -y glusterfs-server=3.12.0-ubuntu1~xenial2 curl jq && \
    curl -sS -o /usr/local/bin/wait-for-it.sh https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh && \
    chmod +x /usr/local/bin/wait-for-it.sh

ADD entry.sh /usr/local/bin/entry.sh

ENTRYPOINT "/usr/local/bin/entry.sh"
CMD ["/usr/sbin/glusterd", "-N", "--log-file=/dev/stdout"]

