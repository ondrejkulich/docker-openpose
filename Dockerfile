FROM ubuntu:18.04

ARG DEBIAN_FRONTEND=noninteractive
ARG CUDA_PIN_LINK=https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-ubuntu1804.pin
ARG CUDA_LINK=http://developer.download.nvidia.com/compute/cuda/10.2/Prod/local_installers/cuda-repo-ubuntu1804-10-2-local-10.2.89-440.33.01_1.0-1_amd64.deb
ARG cudnn_version=8.2.4.*
ARG cuda_version=cuda10.2

#get deps
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
                        python3-dev \
                        python3-pip \
                        git \
                        g++ \
                        wget \
                        make \
                        libprotobuf-dev \
                        protobuf-compiler \
                        libopencv-dev \
                        libgoogle-glog-dev \
                        libboost-all-dev \
                        libcaffe-cuda-dev \
                        libhdf5-dev \
                        libatlas-base-dev \
                        gnupg \
                        software-properties-common

#for python api
RUN pip3 install --upgrade pip
RUN pip3 install numpy opencv-python 

#replace cmake as old version has CUDA variable bugs
RUN wget https://github.com/Kitware/CMake/releases/download/v3.16.0/cmake-3.16.0-Linux-x86_64.tar.gz && \
    tar xzf cmake-3.16.0-Linux-x86_64.tar.gz -C /opt && \
    rm cmake-3.16.0-Linux-x86_64.tar.gz
ENV PATH="/opt/cmake-3.16.0-Linux-x86_64/bin:${PATH}"

#Intsall CUDA
RUN wget -c "$CUDA_PIN_LINK" && \
    mv cuda-ubuntu1804.pin /etc/apt/preferences.d/cuda-repository-pin-600 && \
    wget "$CUDA_LINK" && \
    dpkg -i cuda-repo-ubuntu1804-10-2-local-10.2.89-440.33.01_1.0-1_amd64.deb && \
    apt-key add /var/cuda-repo-10-2-local-10.2.89-440.33.01/7fa2af80.pub && \
    apt-get update && \
    apt-get install -y --no-install-recommends cuda

#Install cudNN
RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub && \
    add-apt-repository "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/ /" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
                        libcudnn8=${cudnn_version}-1+${cuda_version} \
                        libcudnn8-dev=${cudnn_version}-1+${cuda_version}


#get openpose
WORKDIR /openpose
RUN git clone https://github.com/CMU-Perceptual-Computing-Lab/openpose.git .

#build it
WORKDIR /openpose/build
RUN cmake -DBUILD_PYTHON=ON \
	      -DDOWNLOAD_BODY_25_MODEL=ON \
          -DDOWNLOAD_BODY_MPI_MODEL=OFF \
          -DDOWNLOAD_HAND_MODEL=OFF \
          -DDOWNLOAD_FACE_MODEL=OFF \
	      .. 
RUN sed -ie 's/set(AMPERE "80 86")/#&/g'  ../cmake/Cuda.cmake && \
    sed -ie 's/set(AMPERE "80 86")/#&/g'  ../3rdparty/caffe/cmake/Cuda.cmake
RUN make -j `nproc`
WORKDIR /home/root/project/
