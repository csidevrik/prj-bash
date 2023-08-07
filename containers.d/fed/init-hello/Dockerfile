# This is a sample file for EMOV EP

# Set base image fedora why we love fedora
FROM fedora:latest as fedos


# Label to identify the creator 
LABEL maintainer='carlos.sigua@gmail.com'
LABEL version='1.0'
LABEL description='Mi primera imagen de fedora'
# Definiendo ARGUMENTOS DE CONSTRUCCION
ARG USERNADMIN=humancero
ARG PASSNADMIN=z0phermero.$


# Actualizamos el sistema y usamos los argumentos anteriores

RUN dnf update -y && dnf install -y sudo \
    && useradd -m -s /bin/bash ${USERNADMIN} \
    && echo "${USERNADMIN}:${PASSNADMIN}" | chpasswd \
    && usermod -aG wheel ${USERNADMIN}

RUN dnf install -y zsh git sqlite curl neovim iputils dnsutils net-tools

# Cambiamos al usuario por defecto
USER ${USERNADMIN}

# Se define el directorio de trabajo
ENV PATHUSER /home/${USERNADMIN}

# Establecer el shell deseado
SHELL ["/bin/bash", "-c"]

# Crear el directorio de trabajo dentro del contenedor
RUN mkdir -p ${PATHUSER}

WORKDIR ${PATHUSER}

# Copiar el archivo script.sh al directorio de trabajo dentro del contenedor.
COPY ./script.sh /home/humancero/script.sh



# Cambiar el contexto de SELinux para el archivo script.sh
# RUN chcon -Rt svirt_sandbox_file_t /home/humancero
# RUN chcon -R -t bin_t /home/humancero/script.sh

# Dar permisos de ejecución al archivo script.sh.
# RUN chmod +x /home/humnacero/script.sh

#Ejecuta un comando cuando se inicie el contenedor
CMD [ "./script.sh" ]
