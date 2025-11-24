import socket

from flask import Flask, jsonify

app = Flask(__name__)


@app.route("/")
def home():
    """Endpoint raíz - verificación de que el servicio funciona"""
    return jsonify(
        {
            "service": "frontend",
            "status": "OK",
            "message": "Frontend service is running",
            "hostname": socket.gethostname(),
        }
    )


@app.route("/health")
def health():
    """Endpoint de health check"""
    return jsonify({"status": "healthy", "service": "frontend"}), 200


if __name__ == "__main__":
    # Escuchar en todas las interfaces (0.0.0.0) para que Docker pueda acceder
    # Puerto 8080
    app.run(host="0.0.0.0", port=8080, debug=False)