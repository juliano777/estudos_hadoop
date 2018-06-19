# 52.15.45.98  ${SRV_1}
# 18.218.252.98  ${SRV_2}
# 18.218.143.108  ${SRV_3}



# JAVA =======================================================================

# Baixe o "Java SE Development Kit" em formato .tar.gz.
# Envie via SSH este arquivo baixado para o /tmp do seu servidor.
# ssh -i aula01.pem ubuntu@52.15.45.98
# https://www.tutorialspoint.com/hadoop/hadoop_enviornment_setup.htm
# https://www.tecmint.com/install-configure-apache-hadoop-centos-7/3/oop
# https://www.tutorialspoint.com/hive/index.htm

# http://www.oracle.com/technetwork/java/javase/downloads/index.html

# Supondo que o nome do arquivo seja jdk-9.0.4_linux-x64_bin.tar.gz:

tar xvf /tmp/jdk-9.0.4_linux-x64_bin.tar.gz -C /usr/local/



# Mude o nome do diretório tirando a versão:

mv /usr/local/jdk-9.0.4 /usr/local/jdk



# Crie o arquivo e variáveis de ambiente Java

cat << EOF > /etc/profile.d/java.sh
#!/bin/bash
export JAVA_HOME='/usr/local/jdk'
export JRE_HOME="\${JAVA_HOME}"
export PATH="\${PATH}:\${JAVA_HOME}/bin"

if [ -z \${CLASSPATH} ]; then
    export CLASSPATH=".:\${JAVA_HOME}/lib"
else
    export CLASSPATH=".:\${JAVA_HOME}/lib:\${CLASSPATH}"
fi

EOF


rm -fr ${JAVA_HOME}/lib/i386
