# tests/test_app.py

import pytest
from src.app import app


@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client


def test_home(client):
    response = client.get('/')
    assert response.status_code == 200


def test_services(client):
    response = client.get('/services')
    assert response.status_code == 200


def test_contact(client):
    response = client.get('/contact')
    assert response.status_code == 200
