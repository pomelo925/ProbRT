# Generated Dockerfile
FROM python:3.10

WORKDIR /app

# Copy application files
COPY . .

# Install dependencies
RUN if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
RUN if [ -f package.json ]; then npm install; fi

# Expose port
EXPOSE 8000

# Default command
CMD ["app"]
