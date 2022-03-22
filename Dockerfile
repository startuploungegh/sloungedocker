FROM python:3.8-slim

# to install python package psycopg2 (for postgres)
#RUN apt-get update
#RUN apt-get install -y postgresql libpq-dev postgresql-client postgresql-client-common gcc

# add user (change to whatever you want)
# prevents running sudo commands
RUN useradd -r -s /bin/bash adminkutana

# set current env
ENV HOME /src
WORKDIR /src
ENV PATH="/src/.local/bin:${PATH}"

RUN chown -R adminkutana:adminkutana /src
USER adminkutana

# set app config option
ENV FLASK_ENV=production

# set argument vars in docker-run command
ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ARG AWS_DEFAULT_REGION
# flask form key
ARG FLASK_SECRET_KEY
# AWS RDS vars
#ARG POSTGRES_USER
#ARG POSTGRES_PW
#ARG POSTGRES_URL
#ARG POSTGRES_DB

ENV AWS_ACCESS_KEY_ID $AWS_ACCESS_KEY_ID
ENV AWS_SECRET_ACCESS_KEY $AWS_SECRET_ACCESS_KEY
ENV AWS_DEFAULT_REGION $AWS_DEFAULT_REGION
ENV FLASK_SECRET_KEY $FLASK_SECRET_KEY
#ENV POSTGRES_USER $POSTGRES_USER
#ENV POSTGRES_PW $POSTGRES_PW
#ENV POSTGRES_URL $POSTGRES_URL
#ENV POSTGRES_DB $POSTGRES_DB

# Avoid cache purge by adding requirements first
ADD ./requirements.txt ./requirements.txt

RUN pip install --no-cache-dir -r ./requirements.txt --user

# Add the rest of the files
COPY . /src
WORKDIR /src

# start web server
CMD ["gunicorn", "-b", "0.0.0.0:5000", "app:app", "--workers=4", "--threads=4", "--timeout", "120"]