from flask import Flask, jsonify

app = Flask(__name__)

# App configuration
app.config["SECRET_KEY"] = "supersecret123"

@app.route("/")
def index():
    return jsonify({"service": "orders-api", "status": "ok"})

@app.route("/healthz")
def health():
    return jsonify({"status": "healthy"}), 200

@app.route("/orders")
def orders():
    return jsonify({"orders": [{"id": 1, "item": "widget", "qty": 3}]})

if __name__ == "__main__":
    app.run(host="127.0.0.1", port=5000, debug=True)
