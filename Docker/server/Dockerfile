
# aim_server

# FROM python:3.14-slim
FROM python:3.12-slim

# ----- USER -----
ARG DOCKER_USER=blissfox
ARG DOCKER_USER_ID=1000
ARG DOCKER_USER_GID=1000

RUN addgroup --gid $DOCKER_USER_GID $DOCKER_USER && adduser --uid $DOCKER_USER_ID $DOCKER_USER -gid $DOCKER_USER_GID

# RUN mkdir /opt/aim && chown -R $DOCKER_USER /opt/aim && chmod 777 /opt/aim
RUN mkdir /opt/supervisord && chown -R $DOCKER_USER /opt/supervisord && chmod 777 /opt/supervisord

RUN apt update && apt install -y --no-install-recommends \
    curl \
    git \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*



USER $DOCKER_USER

# ----- PYTHON PKGs -----
ARG AIM_VERSION
RUN pip install Cython
# RUN pip install aim==$AIM_VERSION
RUN pip install aim
RUN pip install supervisor
# RUN pip install supervisor supervisor-stdout
RUN pip install git+https://github.com/coderanger/supervisor-stdout.git@973ba19967cdaf46d9c1634d1675fc65b9574f6e

ENV PATH="${PATH}:/home/$DOCKER_USER/.local/bin"


# ----- CHECK AIM INIT -----
# RUN mkdir /opt/aim
# WORKDIR /opt/aim
# WORKDIR /opt
# RUN python aim init -y --repo /opt/
# RUN aim init echo -e "\n"| aim init --repo /opt/aim; echo ""
WORKDIR /home/$DOCKER_USER

# ----- EXPOSE PORTS TO HOST -----
# Port for aim ui
EXPOSE 43800
# Port for aim server
EXPOSE 53800

# ----- CMD SUPERVISORD -----

COPY ./supervisord.conf /opt/supervisord/
CMD ["/bin/bash", "-c", "echo -e \"N\n\" | aim init --repo /opt/aim; echo \"\"; supervisord --configuration=/opt/supervisord/supervisord.conf"]


