from django.urls import path

from tasks import views

urlpatterns = [
    path("", views.index, name="index"),
    path("task/<int:id>/", views.task_detail, name="task_detail"),
    path("task/create/", views.task_create, name="task_create"),
    path("health/", views.health, name="health"),
]
