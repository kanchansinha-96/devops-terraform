FROM on-nexus-proxy:10001/python:3.9
WORKDIR /app
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt 

COPY . .
CMD ["python", "app.py"]
