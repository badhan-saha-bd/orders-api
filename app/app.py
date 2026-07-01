import os

from flask import Flask, jsonify

app = Flask(__name__)

app.config["SECRET_KEY"] = os.environ.get("SECRET_KEY", "change-me-for-local-dev")


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
    port = int(os.environ.get("PORT", "5000"))
    debug = os.environ.get("FLASK_DEBUG", "").lower() in {"1", "true", "yes"}
    app.run(host="0.0.0.0", port=port, debug=debug)
