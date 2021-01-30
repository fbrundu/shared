############################################################
# Dockerfile for MAST
############################################################

FROM fbrundu/bioconductor-nox:3.12
LABEL author=fbrundu

############################################################

## Silence interactive warnings for container build
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install -U awscli

WORKDIR /home/ubuntu/

RUN R -e "BiocManager::install('MAST')" 
RUN R -e "install.packages('feather', dependencies=TRUE, repos='http://cran.rstudio.com/')"

############################################################

WORKDIR /home/ubuntu
ADD script.R /home/ubuntu/script.R
RUN chmod a+x /home/ubuntu/script.R
ADD steps.sh /home/ubuntu/steps.sh
RUN chmod a+x /home/ubuntu/steps.sh
ENTRYPOINT [ "/home/ubuntu/steps.sh" ]
