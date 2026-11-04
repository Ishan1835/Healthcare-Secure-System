FROM python:3.12-alpine

WORKDIR /app

COPY app/requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY app/ .

RUN adduser -D appuser

USER appuser

EXPOSE 5000

CMD ["python", "app.py"]
