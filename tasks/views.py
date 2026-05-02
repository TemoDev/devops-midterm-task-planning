from datetime import datetime, timezone

from django.http import HttpResponse, JsonResponse
from django.shortcuts import redirect, render
from django.views.decorators.http import require_http_methods

from tasks import store


@require_http_methods(["GET"])
def index(request):
    tasks = sorted(store.tasks_store.values(), key=lambda t: t["id"], reverse=True)
    return render(request, "tasks/index.html", {"tasks": tasks})


@require_http_methods(["GET"])
def task_detail(request, id):
    task = store.tasks_store.get(id)
    if task is None:
        return HttpResponse("Task not found", status=404)
    return render(request, "tasks/task_detail.html", {"task": task})


@require_http_methods(["POST"])
def task_create(request):
    title = request.POST.get("title", "").strip()
    description = request.POST.get("description", "").strip()
    if not title:
        return HttpResponse("Title is required", status=400)

    task_id = store.next_id
    store.next_id += 1
    store.tasks_store[task_id] = {
        "id": task_id,
        "title": title,
        "description": description,
        "completed": False,
        "created_at": datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S UTC"),
    }
    return redirect("/")


@require_http_methods(["GET"])
def health(request):
    data = {
        "status": "ok",
        "timestamp": datetime.now(timezone.utc).isoformat(),
    }
    return JsonResponse(data)
