############################################################
# Dockerfile for Bioconductor (R version 4)
############################################################

FROM fbrundu/env-r-4-nox:4.0.3
LABEL author=fbrundu

############################################################

## Silence interactive warnings for container build
ARG DEBIAN_FRONTEND=noninteractive

############################################################

WORKDIR /home/ubuntu/

RUN R -e "install.packages('BiocManager', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "BiocManager::install(version = '3.12')"

ENTRYPOINT [ "bash" ]
