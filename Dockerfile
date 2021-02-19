FROM ubuntu:16.04

WORKDIR /home/crv

RUN apt-get update && \
    apt-get install -y \
    wget unzip curl vim \
    build-essential cmake git libgmp3-dev libprocps4-dev python-markdown libboost-all-dev libssl-dev pkg-config  

RUN apt-get install -y openjdk-8-jdk && \
    apt-get install -y junit4 && \
    wget https://www.bouncycastle.org/download/bcprov-jdk15on-159.jar

RUN git clone https://github.com/hyunokoh/CRV/ \
  && cd CRV/libsnark \
  && git submodule init && git submodule update \
  && mkdir build && cd build && cmake .. \
  && make \
	&& DESTDIR=/usr/local make install \
    NO_PROCPS=1 NO_GTEST=1 NO_DOCS=1 CURVE=ALT_BN128 FEATUREFLAGS="-DBINARY_OUTPUT=1 -DMONTGOMERY_OUTPUT=1 -DNO_PT_COMPRESSION=1"

RUN cd /home/crv/CRV/JsnarkCircuitBuilder && \
	mkdir -p bin && \
	javac -encoding utf-8 -d bin -cp /usr/share/java/junit4.jar:bcprov-jdk15on-159.jar  $(find ./src/* | grep ".java$") 


ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/usr/local/lib

CMD ["/bin/bash"]
