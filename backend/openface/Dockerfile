FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential cmake git wget curl \
    libopenblas-dev liblapack-dev \
    libopencv-dev \
    libboost-all-dev \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Build dlib from source (apt has 19.10, OpenFace requires 19.13+)
RUN git clone --depth 1 --branch v19.24 https://github.com/davisking/dlib.git /opt/dlib && \
    mkdir /opt/dlib/build && cd /opt/dlib/build && \
    cmake .. -DDLIB_NO_GUI_SUPPORT=ON -DCMAKE_BUILD_TYPE=RELEASE && \
    cmake --build . --config Release -- -j$(nproc) && \
    make install && \
    ldconfig

# Build OpenFace from source
WORKDIR /opt
RUN git clone --depth 1 https://github.com/TadasBaltrusaitis/OpenFace.git
WORKDIR /opt/OpenFace
# Strip x86-only SSE flags — this image may run on ARM (aarch64)
RUN sed -i 's/-msse[^ "]*//g' CMakeLists.txt
RUN MULTIARCH=$(gcc -print-multiarch) && \
    mkdir build && cd build && \
    cmake -D CMAKE_BUILD_TYPE=RELEASE \
          -D OpenBLAS_INCLUDE_DIR=/usr/include \
          -D OpenBLAS_LIB=/usr/lib/${MULTIARCH}/libopenblas.so \
          .. && \
    make -j$(nproc) FeatureExtraction

# Download models
RUN bash /opt/OpenFace/download_models.sh

# FastAPI wrapper
WORKDIR /app
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

COPY main.py .

EXPOSE 8002
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8002"]
