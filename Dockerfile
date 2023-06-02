FROM rocker/tidyverse:latest

COPY src /root

RUN apt-get update -y \
  && apt-get install -y \
  unzip \
  curl \
  bash

WORKDIR /root

RUN curl -o plink_linux_x86_64.zip http://s3.amazonaws.com/plink1-assets/plink_linux_x86_64_latest.zip \
  && unzip plink_linux_x86_64.zip \
  && chmod +x plink \
  && mv plink /usr/bin/plink \
  && rm plink_linux_x86_64.zip prettify toy*

RUN unzip -d ppmi_data "ppmi_data/*.zip" \
  && rm ppmi_data/PPMI*

RUN mkdir -p temp \
  && echo 'alias ll="ls -lah"' >> .bashrc
