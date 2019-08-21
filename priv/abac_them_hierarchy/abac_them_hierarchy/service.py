import flask
from flask import request, jsonify
import argparse
from abac_them_hierarchy import open_ontology_graph, expand_attributes

app = flask.Flask(__name__)
global graph


@app.route("/expansions", methods=["POST"])
def expand():
    attribute = request.get_json()
    print(attribute)

    expanded_attributes = expand_attributes(
        graph, attribute["name"], attribute["value"].replace("http://iotswarm.info/ontology#", "swarm:"))

    if len(expanded_attributes) > 0:
        expanded_attributes = list(map(
            lambda expanded:
                expanded.asdict()['value'].toPython().replace("http://iotswarm.info/ontology#", "swarm:"),
            expanded_attributes))
    else:
        expanded_attributes = [attribute["value"]]

    return jsonify(expanded_attributes), 200, {'Content-Type': 'application/json'}


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("-g", "--policy-graph", required=False,
                        help="policy graph in 'n3' format")

    policy_graph = vars(parser.parse_args())['policy_graph']
    if not policy_graph:
        policy_graph = "tests/example_home_policy.n3"

    graph = open_ontology_graph(policy_graph, "n3")

    app.run(host="0.0.0.0", port=4010, threaded=True, debug=1)
