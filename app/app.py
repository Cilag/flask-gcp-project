from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/')
def home():
    return "COUCOU c'est API flask de guigui"

@app.route('/health')
def health():
    """Health check endpoint for Kubernetes"""
    return jsonify({"status": "healthy"}), 200

@app.route('/ready')
def ready():
    """Readiness check endpoint for Kubernetes"""
    return jsonify({"status": "ready"}), 200

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8080)
