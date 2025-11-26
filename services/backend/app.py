import socket

from flask import Flask, jsonify

app = Flask(__name__)


@app.route("/")
def home():
    """Endpoint raíz - verificación de que el servicio funciona"""
    return jsonify(
        {
            "service": "backend",
            "status": "OK",
            "message": "Backend service is running",
            "hostname": socket.gethostname(),
        }
    )


@app.route("/health")
def health():
    """Endpoint de health check"""
    return jsonify({"status": "healthy", "service": "backend"}), 200


@app.route("/api/data")
def get_data():
    """Endpoint simulado con datos sensibles"""
    return jsonify(
        {
            "data": "sensitive information",
            "message": "This endpoint should be protected",
        }
    )


if __name__ == "__main__":
    # Escuchar en todas las interfaces (0.0.0.0)
    # Puerto 5000
    app.run(host="0.0.0.0", port=5000, debug=False)
