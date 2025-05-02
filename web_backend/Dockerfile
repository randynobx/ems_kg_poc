FROM python:3.12-slim

# Set environment variables for Python
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Install Poetry
RUN pip install --no-cache-dir poetry

# Copy only dependency files first for efficient Docker caching
COPY pyproject.toml poetry.lock ./

# Install dependencies (no virtualenv, system-wide)
RUN poetry config virtualenvs.create false \
    && poetry install --no-interaction --no-ansi

# Copy the rest of the application code
COPY ./app ./app

# Expose port (FastAPI/Flask default is 8000)
EXPOSE 8000

# Command to run the web server (adjust for Flask if needed)
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
