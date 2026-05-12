FROM nvcr.io/nvidia/pytorch:25.08-py3

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg libsm6 libxext6 git && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
# openai-whisper 20240930 setup.py imports pkg_resources; setuptools 81+ dropped it.
# Pin build-time setuptools below 81 via PIP_CONSTRAINT so PEP-517 build isolation
# uses a setuptools that still ships pkg_resources.
RUN echo "setuptools<81" > /tmp/pip-constraints.txt
ENV PIP_CONSTRAINT=/tmp/pip-constraints.txt
RUN pip install --no-cache-dir -r requirements.txt

# Pre-download models to cache during build (optional — can be done at first run)
# RUN python -c "import whisper; whisper.load_model('large-v3')"

COPY . .

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8001", "--workers", "1"]
