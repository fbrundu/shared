############################################################
# Dockerfile for SingleR
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

RUN R -e "BiocManager::install('multtest')"
RUN R -e "BiocManager::install('SingleR')"
RUN R -e "install.packages('dplyr', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('tibble', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('purrr', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('tidyr', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "BiocManager::install('scran')"
RUN R -e "BiocManager::install('BiocParallel')"
RUN R -e "install.packages('arrow', dependencies=TRUE, repos='http://cran.rstudio.com/')"

############################################################

ADD script.R /home/ubuntu/script.R
RUN chmod a+x /home/ubuntu/script.R
ADD steps.sh /home/ubuntu/steps.sh
RUN chmod a+x /home/ubuntu/steps.sh
ENTRYPOINT [ "/home/ubuntu/steps.sh" ]
