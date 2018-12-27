# OpenJDK ====================================================================

# Supondo que o nome do arquivo seja jdk-${JDK_VERSION}_linux-x64_bin.tar.gz:

tar xvf /tmp/openjdk-${JDK_VERSION}_linux-x64_bin.tar.gz -C /usr/local/

# Mude o nome do diretório tirando a versão:

mv /usr/local/jdk-${JDK_VERSION} /usr/local/jdk

# Crie o arquivo e variáveis de ambiente Java

cat << EOF > /etc/profile.d/jdk.sh
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
