FROM rocker/rstudio

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get install -y --no-install-recommends \
    libglpk40 \
    libudunits2-dev \
    libgdal-dev \
    libgeos-dev \
    libproj-dev

