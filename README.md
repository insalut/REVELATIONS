# REVELATIONS
Post-exploitation persistance script

Revelations.sh es el script que he desarrollado para tener un recurso que de forma rápida cree una serie de puertas traseras muy difíciles de detectar, además de autorenovables, camufladas y recíprocas. 

Mis objetivos a la hora de programar este script eran:

Crear una serie de puertas traseras redundantes.


Crear un agente que contrarreste la posible eliminación de estas.


Camuflar estas puertas traseras y el agente autoreplicante

# Replicación
La primera función del script es replicarse a través de una serie de carpetas ocultas llamadas “...”, distribuidas por diferentes partes del sistema. Además, las copias que crea estarán cifradas mediante shc, para evitar ingeniería inversa. Por último, estas copias estarán ocultas empezando por un punto.

# Ocultación
La ofuscación de las copias del script se realiza mediante una corrupción del binario ls, que es sustituido por un impostor, que funciona tal y como ls, pero oculta de su output los archivos que nosotros queramos, en este caso, las carpetas de rootkit “...” y los archivos .x.c, resultado del cifrado de shc. 

Para ocultar posibles indicios del cambiazo, el script lee la fecha de modificación del binario ls original y la añade al impostor.


# Autoreparación
El script repara posibles daños realizados a las puertas traseras mediante la corrupción de una tarea de cron.daily: logrotate. Modifica uno de los archivos de configuración de este trabajo diario (rsyslog) para que además de usar su postscript, ejecute también arbitrariamente uno de los nuestros, reparando todas las puertas traseras.

Además, en cron.d creamos un trabajo que se ejecuta cada hora, y que también repara las puertas traseras, pero este es más bien un cebo para que el administrador del sistema piense que ha limpiado el sistema.




# PERSISTENCIA

Las capacidades de persistencia de este script están divididas en varias puertas traseras:

Se añade la clave pública de la máquina atacante a las claves autorizadas de root de la máquina víctima. De esta forma, la máquina atacante se puede conectar por ssh a la víctima independientemente de conocer las contraseñas del sistema.


Se crea un usuario que finge ser de servicio, para tener una puerta abierta para incorporarse al sistema.


Se inserta una shell inversa en la configuración de bash.bashrc, para que cada vez que un usuario inicie sesión en el sistema, se lance una sesión remota a la máquina atacante. Esta sesión además es invisible. 


En la configuración de sudo.conf, se redirige el archivo sudoers a uno que hemos modificado dentro de nuestro rootkit. Esto cambia la configuración, dado que normalmente la mayoría de usuarios de servicio solo pueden hacer sudo en comandos limitados. Ahora, todos los sudoers pueden hacer sudo en todos los comandos. Esto nos permite, en caso de reparación del resto de puertas traseras, volver a escalar privilegios.


# Próximos cambios

- Corromper las funciones de grep y find.

- Añadir sección de limpieza de huellas.
