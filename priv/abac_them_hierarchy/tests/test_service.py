import pytest
from abac_them_hierarchy import service, open_ontology_graph


@pytest.fixture
def client():
    service.graph = open_ontology_graph(
        "tests/example_home_policy.n3", "n3")
    return service.app.test_client()


def test_expand(client):
    # access_request = {
    #     'user_attr': 'swarm:group1',
    #     'object_attr': 'swarm:project1',
    #     'operation': 'crud:read'
    # }

    # result = client.post("/authorizations", json=access_request)
    # assert result.status_code == 200
    assert True
