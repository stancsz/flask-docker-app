#!/bin/bash
exec > >(tee -a /var/log/startup-script.log) 2>&1

echo "Starting startup script..."

# Install dependencies
sudo apt-get update
sudo apt-get install -y docker.io google-cloud-sdk

# Variables
APP_BUCKET="gs://${var.gcs_bucket_name}"
APP_ARCHIVE="${var.app_archive_name}"
LOCAL_ARCHIVE="/opt/${var.app_archive_name}"
APP_DIR="/opt/app"

# Download the archive
for i in {1..5}; do
    echo "Downloading app archive from GCS (attempt ${i}/5)..."
    sudo gsutil cp ${APP_BUCKET}/${APP_ARCHIVE} ${LOCAL_ARCHIVE} && break
    sleep 5
done

if [ ! -f "${LOCAL_ARCHIVE}" ]; then
    echo "App archive not found at ${LOCAL_ARCHIVE}. Exiting."
    exit 1
fi

# Cleanup and extract the archive
echo "Cleaning up and setting up app directory..."
sudo rm -rf ${APP_DIR}
sudo mkdir -p ${APP_DIR}

echo "Extracting app archive to ${APP_DIR}..."
sudo tar -xzf ${LOCAL_ARCHIVE} -C ${APP_DIR}
if [ $? -ne 0 ]; then
    echo "Failed to extract archive. Exiting."
    exit 1
fi
echo "Archive extracted successfully."

# Build and run the Docker container
cat <<EOF | sudo tee ${APP_DIR}/Dockerfile
FROM python:3.9-slim
WORKDIR /app
COPY . /app
RUN pip install -r requirements.txt
CMD ["python", "app.py"]
EOF

echo "Building Docker image..."
sudo docker build -t flask-app ${APP_DIR}
if [ $? -ne 0 ]; then
    echo "Failed to build Docker image. Exiting."
    exit 1
fi

echo "Running Docker container..."
sudo docker run -d --restart always --name flask-app -p 8080:8080 flask-app
if [ $? -ne 0 ]; then
    echo "Failed to run Docker container. Exiting."
    exit 1
fi

echo "Startup script completed successfully."
