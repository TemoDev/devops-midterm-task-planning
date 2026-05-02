import json

import pytest

from tasks import store


@pytest.fixture(autouse=True)
def reset_store():
    store.tasks_store.clear()
    store.next_id = 1
    yield
    store.tasks_store.clear()
    store.next_id = 1


def test_index_returns_200(client):
    response = client.get("/")
    assert response.status_code == 200


def test_health_returns_200_and_ok(client):
    response = client.get("/health/")
    assert response.status_code == 200
    data = json.loads(response.content)
    assert data["status"] == "ok"


def test_create_task_redirects(client):
    response = client.post("/task/create/", {"title": "Test Task", "description": "A description"})
    assert response.status_code == 302
    assert response["Location"] == "/"


def test_task_detail_returns_200(client):
    client.post("/task/create/", {"title": "Detail Task", "description": "Detail desc"})
    response = client.get("/task/1/")
    assert response.status_code == 200
