#!/usr/bin/sh

# Verificando argumentos.
if [ -z $1 ]
then
  echo "Requires argument."
  exit 1
fi

# Verificando se o usuario esta logado como root
if [ `id -u` != 0 ]
then
  echo "This is script needs to be run as root."
  exit 1
fi 

# Criando diretorio temporario
echo "Making directory temp..."
out=`mkdir temp`

#Entrando em temp em movendo deb para lá
mv $1 temp
cd temp

#Descompctando deb.
out_deb=`ar x $1`
if [ $? != 0 ]
then
  echo "An error has occured, the file $1 may be corrupt."
  mv $1 ..
  cd ..
  sudo rm -rf temp/
  echo "$out_deb" > ERROR_EXTRACT_DEB.log
  exit 1
fi

mv $1 .. #Movendo deb original para fora da pasta temp.

echo "Extracting control.tar.xz"
tar xvf control.tar.*
if [ $? != 0 ]
then
  echo "An error has occured, the file $1 may be corrupt."
  mv $1 ..
  cd ..
  sudo rm -rf temp/
  echo "$out_deb" > ERROR_EXTRACT_DEB.log
  exit 1
fi

# Pegando caracteristicas do .deb, apartir do control.tar
name_package=`cat control | grep Package | cut -d " " -f 2`
requires_package=`cat control | grep Depends | cut -d " " -f 2`

tar xvf data.tar.*
if [ $? != 0 ]
then
  echo "An error has occured, the file $1 may be corrupt."
  mv $1 ..
  cd ..
  sudo rm -rf temp/
  echo "$out_deb" > ERROR_EXTRACT_DEB.log
  exit 1
fi

echo "Depends $requires_package"
if [ -z $2 ]
then 
  read -p "Want to install .deb?[Y/n]" cn </dev/tty
  if [ $cn == "n" | $cn == "N" ]
  then
    echo "Ok bye bye"
    exit 0
  fi
fi

# Copiando todo o diretorio de data.tar.xz para o /, o que termina o processo do instalação.
echo "Installing $name_package"
sudo cp -R ./* /

# Apagando /temp
cd ..
sudo rm -rf ./temp
