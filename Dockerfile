FROM rocm-docker:latest
MAINTAINER Dmitry Mikushin <dmitry@kernelgen.org>

ENV CMAKE_BUILD_TYPE=Release

ENV DEBIAN_FRONTEND=noninteractive

RUN git clone https://github.com/ROCmSoftwarePlatform/MIOpen.git

WORKDIR /MIOpen

# Make additional user-defined manipulations to the git repository
COPY ./git_checkout.sh .
RUN bash ./git_checkout.sh

RUN apt-get update && apt-get install -y --no-install-recommends ninja-build pkg-config libsqlite3-dev rocblas-dev libbz2-dev half curl wget ssh fish mc

# Download, build and install Boost 1.72 (older versions are not supported)
# to enable MIOpen persistent kernel cache
ENV BOOST_VERSION=1_72_0
ENV BOOST_ROOT=/usr/include/boost
RUN curl -sL -o boost_${BOOST_VERSION}.tar.gz https://boostorg.jfrog.io/artifactory/main/release/1.72.0/source/boost_${BOOST_VERSION}.tar.gz \
	&& tar xfz boost_${BOOST_VERSION}.tar.gz \
	&& rm boost_${BOOST_VERSION}.tar.gz \
	&& cd boost_${BOOST_VERSION} \
	&& ./bootstrap.sh --prefix=/usr/local --with-libraries=filesystem \
	&& ./b2 cxxflags=-fPIC cflags=-fPIC install \
	&& cd .. \
	&& rm -rf boost_${BOOST_VERSION}

RUN mkdir build \
	&& cd build \
	&& CXX=/opt/rocm/llvm/bin/clang++ cmake -DMIOPEN_GPU_SYNC=Off -DBUILD_DEV=On -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -G Ninja .. \
	&& ninja && ninja install

