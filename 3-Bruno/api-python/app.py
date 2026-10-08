from flask import Flask, jsonify, request
app = Flask(__name__)

@app.route("/api/ping", methods=["GET"])
def ping():
    return jsonify({"pong":"ok"}), 200

@app.route("/api/status", methods=["GET"])
def status():
    return jsonify({"status":"ok"}), 200

@app.route("/api/orders", methods=["POST"])
def orders():
    data = request.json or {}
    if not data.get("product"):
        return jsonify({"error":"product required"}), 400
    # Simula criação
    return jsonify({"id":"ORD-123","product":data.get("product")}), 201

@app.route("/api/process", methods=["POST"])
def process():
    data = request.json or {}
    # simular processamento
    return jsonify({"status":"processed","input":data}), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)