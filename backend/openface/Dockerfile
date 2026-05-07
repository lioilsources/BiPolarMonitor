FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential cmake git wget curl \
    libopenblas-dev liblapack-dev \
    libopencv-dev \
    libboost-all-dev \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Build OpenFace from source
WORKDIR /opt
RUN git clone --depth 1 https://github.com/TadasBaltrusaitis/OpenFace.git
WORKDIR /opt/OpenFace
RUN mkdir build && cd build && \
    cmake -D CMAKE_BUILD_TYPE=RELEASE .. && \
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
