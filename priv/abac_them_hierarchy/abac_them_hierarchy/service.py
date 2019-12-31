import flask
from flask import request, jsonify
import argparse
import datetime
from abac_them_hierarchy import open_ontology_graph, expand_attributes

import logging
log = logging.getLogger('werkzeug')
log.setLevel(logging.ERROR)

app = flask.Flask(__name__)
global graph

summa = 0
i = 0

@app.route("/expansions", methods=["POST"])
def expand():
    global summa, i

    attribute = request.get_json()
    # print(attribute)

    attribute_name = attribute["name"].replace("http://iotswarm.info/ontology#", "swarm:")
    attribute_value = attribute["value"].replace("http://iotswarm.info/ontology#", "swarm:")

    start_us = datetime.datetime.now()
    expanded_attributes = expand_attributes(graph, attribute_name, attribute_value)
    ms = (datetime.datetime.now() - start_us).total_seconds() * 1000
    summa += ms
    i += 1
    # print("Finished in %s ms" % ms)

    if len(expanded_attributes) > 0:
        expanded_attributes = list(map(
            lambda expanded:
                expanded.asdict()['value'].toPython().replace("http://iotswarm.info/ontology#", "swarm:"),
            expanded_attributes))
    else:
        expanded_attributes = [attribute["value"]]

    return jsonify(expanded_attributes), 200, {'Content-Type': 'application/json'}

@app.route("/avg", methods=["GET"])
def avg():
    return jsonify({"avg": summa / i})

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("-g", "--policy-graph", required=False,
                        help="policy graph in 'n3' format")

    policy_graph = vars(parser.parse_args())['policy_graph']
    if not policy_graph:
        policy_graph = "tests/example_home_policy.n3"

    graph = open_ontology_graph(policy_graph, "n3")

    app.run(host="0.0.0.0", port=4010, threaded=True, debug=1)
