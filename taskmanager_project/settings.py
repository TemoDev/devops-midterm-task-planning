from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent

SECRET_KEY = "django-insecure-taskmanager-dev-key-not-for-production"

DEBUG = True

ALLOWED_HOSTS = ["*"]

INSTALLED_APPS = [
    "tasks",
]

MIDDLEWARE = [
    "django.middleware.common.CommonMiddleware",
]

ROOT_URLCONF = "taskmanager_project.urls"

TEMPLATES = [
    {
        "BACKEND": "django.template.backends.django.DjangoTemplates",
        "DIRS": [],
        "APP_DIRS": True,
        "OPTIONS": {
            "context_processors": [
                "django.template.context_processors.request",
            ],
        },
    },
]

WSGI_APPLICATION = "taskmanager_project.wsgi.application"

DATABASES = {}

DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"
