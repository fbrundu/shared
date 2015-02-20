FROM ubuntu:20.04

RUN apt-get update --fix-missing
RUN apt-get upgrade -y
ADD cellranger-5.0.1 /opt/cellranger-5.0.1

ENV HOME /root
ENV PATH="/opt/cellranger-5.0.1:${PATH}"

WORKDIR /root

CMD ["bash"]