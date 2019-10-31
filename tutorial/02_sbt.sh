# ============================================================================
# sbt



#

read -p 'sbt: Digite a versão a ser baixada: ' SBT_VERSION



# 
cd /usr/local/



#

wget -c https://piccolo.link/sbt-${SBT_VERSION}.tgz



# 

tar xf sbt-${SBT_VERSION}.tgz



#

mv sbt-${SBT_VERSION} sbt



# 

rm -f sbt-${SBT_VERSION}.tgz



#

cat << EOF > /etc/profile.d/sbt.sh
export SBT_HOME='/usr/local/sbt'
export PATH="\${PATH}:\${SBT_HOME}/bin"
EOF



# 

find sbt/ -name *.bat -delete
