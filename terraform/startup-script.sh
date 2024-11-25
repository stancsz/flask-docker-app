#! /bin/bash
sudo apt-get update
sudo apt-get install -y docker.io

# Pull the app from GCS
sudo gsutil cp gs://${var.gcs_bucket_name}/${var.app_archive_name} /opt/
sudo mkdir -p /opt/app
sudo tar -xzf /opt/${var.app_archive_name} -C /opt/app

# Create a Dockerfile dynamically
cat <<EOF | sudo tee /opt/app/Dockerfile
FROM python:3.9-slim
WORKDIR /app
COPY . /app
RUN pip install -r requirements.txt
CMD ["python", "app.py"]
EOF

# Build and run the Docker container
sudo docker build -t flask-app /opt/app
sudo docker run -d --restart always -p 8080:8080 flask-app
