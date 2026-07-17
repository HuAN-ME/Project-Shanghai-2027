from flask import Flask
import os
import psycopg2


app = Flask(__name__)


@app.route("/")
def index():

    return {
        "project": "Shanghai 2027",
        "day": "29",
        "database": os.getenv("DB_HOST")
    }


if __name__ == "__main__":
    app.run(
        host="0.0.0.0",
        port=5000
    )
