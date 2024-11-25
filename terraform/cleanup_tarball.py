import os

# Define the path to the tarball
tarball_path = os.path.join(os.path.dirname(__file__), "flask-app.tar.gz")

# Delete the tarball
try:
    if os.path.exists(tarball_path):
        os.remove(tarball_path)
        print(f"Deleted tarball: {tarball_path}")
    else:
        print(f"Tarball not found: {tarball_path}")
except Exception as e:
    print(f"Error deleting tarball: {e}")
    exit(1)
