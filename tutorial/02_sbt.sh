# ============================================================================
# sbt

cd /usr/local/

wget -c https://piccolo.link/sbt-1.1.6.tgz

tar xf sbt-1.1.6.tgz

mv sbt-1.1.6 sbt

rm -f sbt-1.1.6.tgz

cat << EOF > /etc/profile.d/sbt.sh
export SBT_HOME='/usr/local/sbt'
export PATH="\${PATH}:\${SBT_HOME}/bin"
EOF


find sbt/ -name *.bat -delete
