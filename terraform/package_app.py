import os
import tarfile
import time

# Set paths
app_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "../app"))
output_tarball = os.path.abspath(os.path.join(os.path.dirname(__file__), "flask-app.tar.gz"))

def create_tarball(source_dir, output_file):
    if not os.path.exists(source_dir):
        raise FileNotFoundError(f"Source directory '{source_dir}' does not exist.")
    
    with tarfile.open(output_file, "w:gz") as tar:
        tar.add(source_dir, arcname=os.path.basename(source_dir))
    print(f"Tarball created successfully: {output_file}")

def wait_for_file(file_path, timeout=10):
    start_time = time.time()
    while not os.path.exists(file_path):
        if time.time() - start_time > timeout:
            raise TimeoutError(f"File '{file_path}' not created within {timeout} seconds.")
        print("Waiting for tarball to be created...")
        time.sleep(1)

try:
    print("Creating tarball...")
    create_tarball(app_dir, output_tarball)
    wait_for_file(output_tarball)
    print("Tarball creation completed successfully.")
except Exception as e:
    print(f"Error: {e}")
    exit(1)
