FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["sh", "-c", "gunicorn --workers 3 --timeout 120 --access-logfile - --error-logfile - --bind 0.0.0.0:$PORT run:app"]