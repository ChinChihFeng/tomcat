FROM centos:7.5.1804

LABEL Component="tomcat" \ 
      Name="customized tomcat"

# Install packages before running script
RUN yum -y install epel-release && \
    yum -y install ansible && \
    yum -y install git iproute sudo vim net-tools screen man wget curl && \
    yum -y update; yum clean all


#https://download.oracle.com/otn-pub/java/jdk/12.0.1+12/69cfe15208a647278a19ef0990eea691/jdk-12.0.1_linux-x64_bin.rpm
# Install Oracle JavaJDK
#COPY jdk-8u211-linux-x64.rpm /tmp
RUN VERSION=12.0.1 && \
    BUILD=12 && \
    SIG=69cfe15208a647278a19ef0990eea691 && \
    wget --tries=3 --no-cookies --no-check-certificate \
        --header "Cookie: oraclelicense=accept-securebackup-cookie;" \
        https://download.oracle.com/otn-pub/java/jdk/"${VERSION}"+"${BUILD}"/"${SIG}"/jdk-"${VERSION}"_linux-x64_bin.rpm -P /tmp && \
    rpm -ivh /tmp/jdk-"${VERSION}"_linux-x64_bin.rpm   

ENV JAVA_HOME="/usr/java/latest" \
    CATALINA_PID="/opt/tomcat/temp/tomcat.pid" \
    CATALINA_HOME="/opt/tomcat" \
    CATALINA_BASE="/opt/tomcat" \
    CATALINA_OPTS='-server -Xss256k -Xms1975m -Xmx1975m -verbose:gc -Xloggc:${CATALINA_HOME}/logs/gc.log -Djava.awt.headless=true -XX:+UseNUMA -XX:+PrintGCDetails -XX:+DisableExplicitGC -XX:+PrintGCApplicationStoppedTime -XX:+UseG1GC -XX:MaxGCPauseMillis=500 -XX:G1HeapRegionSize=32M -XX:MetaspaceSize=256m -XX:MaxMetaspaceSize=512m -XX:+ParallelRefProcEnabled -XX:PerfDataSamplingInterval=500 -Djava.awt.headless=true -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=9010 -Dcom.sun.management.jmxremote.rmi.port=9010 -Dcom.sun.management.jmxremote.authenticate=true -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.access.file=${CATALINA_HOME}/conf/jmxremote.access -Dcom.sun.management.jmxremote.password.file=${CATALINA_HOME}/conf/jmxremote.password -Djava.rmi.server.hostname=10.1.31.65 -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/opt/tomcat/logs' \
    JAVA_OPTS='-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'

# Disable requiretty
RUN sed -i -e 's/^\(Defaults\s*requiretty\)/#--- \1/'  /etc/sudoers

# Install Ansible and inventory file
RUN echo -e '[local]\nlocalhost ansible_connection=local' > /etc/ansible/hosts


# Start to install tomcat by Ansible
RUN git clone -b develop https://github.com/ChinChihFeng/tomcat.git /etc/ansible/roles/tomcat; \
    ansible-playbook /etc/ansible/roles/nginx/tomcat/test.yml --syntax-check; \
    ansible all -m setup -i /etc/ansible/roles/tomcat/tests/inventory; \
    ansible-playbook /etc/ansible/roles/tomcat/tests/test.yml

#RUN ln -sf /dev/stdout /usr/local/nginx/logs/access.log \
#	&& ln -sf /dev/stderr /usr/local/nginx/logs/error.log

USER tomcat:tomcat

EXPOSE 8080

STOPSIGNAL SIGTERM

CMD ["/opt/tomcat/bin/startup.sh"]
