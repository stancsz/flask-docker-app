# README
## Build and Run the Docker Container
#### **Step 1: Build the Docker Image**
From the `flask-docker-app/` directory, run:

```bash
docker build -t flask-docker-app .
```

#### **Step 2: Run the Container**
Start the container and map it to your local port 8080:

```bash
docker run -d -p 8080:8080 --name flask_app flask-docker-app
```

- `-d`: Runs the container in detached mode (background).
- `-p 8080:8080`: Maps container's port 8080 to your local port 8080.

#### **Step 3: Test the App**
Open your browser or use `curl` to test the app:
```bash
curl -H "Authorization: Bearer YOUR_SECRET_BEARER_TOKEN" http://localhost:8080
```

You should see:
```json
{"message": "Hello, World!"}
```


### **6. Stop and Clean Up**

Stop the container:
```bash
docker stop flask_app
```

Remove the container:
```bash
docker rm flask_app
```

Remove the Docker image:
```bash
docker rmi flask-docker-app
```
