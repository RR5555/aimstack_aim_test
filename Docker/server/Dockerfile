
# aim_server

FROM python:3.14-slim

# ----- USER -----
ARG DOCKER_USER=blissfox
ARG DOCKER_USER_ID=1000
ARG DOCKER_USER_GID=1000

RUN addgroup --gid $DOCKER_USER_GID $DOCKER_USER && adduser --uid $DOCKER_USER_ID $DOCKER_USER -gid $DOCKER_USER_GID
USER $DOCKER_USER

# ----- PYTHON PKGs -----
ARG AIM_VERSION
RUN pip install Cython
RUN pip install aim==$AIM_VERSION
RUN pip install supervisor supervisor-stdout

# ----- CHECK AIM INIT -----
RUN mkdir /opt/aim
WORKDIR /opt/aim
RUN aim init -y

# ----- EXPOSE PORTS TO HOST -----
# Port for aim ui
EXPOSE 43800
# Port for aim server
EXPOSE 53800

# ----- CMD SUPERVISORD -----
RUN mkdir /opt/supervisord
COPY ./supervisord.conf /opt/supervisord/
CMD ["supervisord", "--configuration=/opt/supervisord/supervisord.conf"]

