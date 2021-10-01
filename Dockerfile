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
COPY . wlts-article

RUN cd wlts-article \
   && conda env update --file environment.yml --prune

#
# 3. Changing the user
#
RUN chown -R ${NB_USER} /home/${NB_USER}/

USER ${NB_USER}
