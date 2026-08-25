
# aim_test_worker



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
RUN pip install pytest

# ----- COPY CODE FILES-----
RUN mkdir /home/$DOCKER_USER/test_files 
COPY ./Docker/worker/aim_runs.py ./Docker/worker/test_aim_runs.py /home/$DOCKER_USER/test_files/


# ----- CHECK AIM INIT -----
RUN mkdir /opt/aim
WORKDIR /opt/aim
RUN aim init -y



# CMD ["bash", "", "python3 -m  && sleep infinity"]






