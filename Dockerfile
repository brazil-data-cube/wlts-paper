# Image DIGEST:sha256:9a388da87e9d2b8019df20439977953d0576f6168348f621498ac62b45e2f88f
# Image URL: https://hub.docker.com/layers/jupyter/base-notebook/lab-3.1.13/images/sha256-9a388da87e9d2b8019df20439977953d0576f6168348f621498ac62b45e2f88f?context=explore
FROM jupyter/base-notebook:lab-3.1.13

#
# 1. Configuring the base dependencies
#
USER root
RUN apt-get update -y \
    && apt-get install -y git \
    && rm -rf /var/lib/apt/lists/*

#
# 2. Install the dependencies
#
COPY . wlts-paper

RUN cd wlts-paper \
   && conda env update --file environment.yml --prune \
   && Rscript -e "devtools::install_github('brazil-data-cube/rwlts@v0.8.0')"

#
# 3. Changing the user
#
RUN chown -R ${NB_USER} /home/${NB_USER}/

USER ${NB_USER}
