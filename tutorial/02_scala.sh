# ============================================================================
# Scala

read -p 'Digite a versão de Scala a ser baixada: ' SCALA_VERSION

cd /usr/local/

wget -c https://downloads.lightbend.com/scala/${SCALA_VERSION}/scala-${SCALA_VERSION}.tgz

tar xf scala-${SCALA_VERSION}.tgz

mv scala-${SCALA_VERSION} scala

rm -f scala-${SCALA_VERSION}.tgz

cat << EOF > /etc/profile.d/scala.sh
export SCALA_HOME='/usr/local/scala'
export MANPATH="\${MANPATH}:\${SCALA_HOME}/man"
export PATH="\${PATH}:\${SCALA_HOME}/bin"
if [ -z \${CLASSPATH} ]; then
    export CLASSPATH="\${SCALA_HOME}/lib"
else
    export CLASSPATH="\${CLASSPATH}:\${SCALA_HOME}/lib"
fi
EOF


find scala/ -name *.bat -delete
