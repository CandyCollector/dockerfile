FROM oraclelinux:8-slim

ARG MYSQL_SERVER_PACKAGE=mysql-community-server-minimal-8.0.25
ARG MYSQL_SHELL_PACKAGE=mysql-shell-8.0.25

# Setup repositories for minimal packages (all versions)
RUN rpm -U https://repo.mysql.com/mysql-community-minimal-release-el8.rpm \
  && rpm -U https://repo.mysql.com/mysql80-community-release-el8.rpm \
  && rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

# Install server and shell 8.0
RUN microdnf update && echo "[main]" > /etc/dnf/dnf.conf \
  && microdnf install -y $MYSQL_SHELL_PACKAGE \
  && microdnf install -y --disablerepo=ol8_appstream \
   --enablerepo=mysql80-server-minimal $MYSQL_SERVER_PACKAGE \
  && microdnf install -y java \
  && microdnf install -y yum \
  && yum install -y htop \
  && microdnf clean all \
  && mkdir /docker-entrypoint-initdb.d \
  && pip3 install supervisor \
  && mkdir -p /etc/supervisor/ \
  && mkdir -p /etc/supervisord.d/ \
  && mkdir -p /var/run/log/

COPY prepare-image.sh /
RUN /prepare-image.sh && rm -f /prepare-image.sh

ENV MYSQL_UNIX_PORT /var/lib/mysql/mysql.sock

COPY docker-entrypoint.sh /entrypoint.sh
COPY healthcheck.sh /healthcheck.sh


# 复制 jar 包、waresql、supervisor 配置文件到容器内
COPY warehouse-0.0.1-SNAPSHOT.jar /warehouse-0.0.1-SNAPSHOT.jar
COPY warehouse.sql /docker-entrypoint-initdb.d/warehouse.sql
COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY mysql.conf /etc/supervisord.d/mysql.conf
COPY java.conf /etc/supervisord.d/java.conf


# RUN /entrypoint.sh mysqld
HEALTHCHECK CMD /healthcheck.sh
# ENTRYPOINT ["mysqld"]
# CMD ["mysql","-uroot","-p123456","<","warehouse.sql"]
EXPOSE 8080
# CMD ["java","-jar","warehouse-0.0.1-SNAPSHOT.jar","--server.port=8080"]
CMD ["supervisord","-n","-c","/etc/supervisor/supervisord.conf"]
