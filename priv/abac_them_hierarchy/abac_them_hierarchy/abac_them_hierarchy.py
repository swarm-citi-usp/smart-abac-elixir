from rdflib import Graph


def open_ontology_graph(filename, format):
    print("Creating graph and parsing ontology...")
    g = Graph().parse(filename, format="n3")
    print("Ontology graph parsed.")
    return g


def print_graph(graph):
    for s, p, o in graph:
        print(s, p, o)


def print_list(a_list):
    for row in a_list:
        print(row)


def expand_attributes(graph, attr_name, attr_value):
    return graph.query(
        """
        SELECT DISTINCT ?name ?value
        WHERE {{
            {0} s:in* ?value .
            {0} s:name {1} .
            {0} s:name ?name .
            FILTER(!regex(str(?value), "policy_class")) .
        }}
        """.format(attr_value, attr_name))
