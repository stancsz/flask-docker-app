from flask import Flask, request, jsonify

app = Flask(__name__)

BEARER_TOKEN = "YOUR_SECRET_BEARER_TOKEN"

@app.route("/", methods=["GET"])
def hello_world():
    auth_header = request.headers.get("Authorization")
    # if auth_header and auth_header == f"Bearer {BEARER_TOKEN}":
    #     return jsonify({"message": "Hello, World!"}), 200
    return jsonify({"message": "Hello, World!"}), 200
    # return jsonify({"error": "Unauthorized"}), 401

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080) #new
