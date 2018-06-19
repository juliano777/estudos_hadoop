# ============================================================================
# Scala

cd /usr/local/

wget -c https://downloads.lightbend.com/scala/2.12.4/scala-2.12.4.tgz

tar xf scala-2.12.4.tgz

mv scala-2.12.4 scala

rm -f scala-2.12.4.tgz

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
