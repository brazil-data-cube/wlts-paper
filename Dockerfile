# DIGEST:sha256:95a6f4fabd765de1c6a1302508de586c1090eaa64e05d315c9e93ac488f3e701
FROM jupyter/r-notebook:r-4.1.1

#
# 1. Base dependencies
#
USER root

RUN apt-get update -y \
    && apt-get install -y git \
    && rm -rf /var/lib/apt/lists/* \
    && pip3 install --upgrade \
      pip \ 
      setuptools \
      wheel \
      pandas \
      geopandas \
      matplotlib

#
# 2. Copy files
#
COPY . /home/jovyan/wlts-article

#
# 3. Update the permissions
#
RUN chown -R $NB_USER /home/jovyan/wlts-article

#
# 4. Install `wlts.py` and `lccs.py`
#
USER $NB_USER

RUN pip3 install git+https://github.com/brazil-data-cube/lccs.py@v0.8.0 \
  && pip3 install git+https://github.com/brazil-data-cube/wlts.py@v0.8.0

#
# 5. Install `rwlts`
#
RUN Rscript -e "devtools::install_github('brazil-data-cube/rwlts@v0.6.0')" \
  && conda install -c conda-forge r-sf r-geojsonio --yes \
  && Rscript -e "install.packages(c('cowplot', 'ggrepel', 'ggfittext', 'ggpubr', 'leaflet')"
