FROM python:latest

WORKDIR /app

COPY . .

RUN apt-get update && apt-get install -y build-essential gcc curl vim \
    && pip install -r app/requirements.txt

EXPOSE 5000

CMD ["python", "app/app.py"]
