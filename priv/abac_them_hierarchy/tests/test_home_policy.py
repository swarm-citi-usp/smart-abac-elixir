# -*- coding: utf-8 -*-

import pytest
from abac_them_hierarchy import *
from rdflib import Graph

@pytest.fixture
def graph():
    return open_ontology_graph("tests/example_home_policy.n3", "n3")

def test_attribute_expansion(graph):
    expanded_attributes = expand_attributes(graph, "swarm:Role", "swarm:Father")
    print_list(expanded_attributes)
