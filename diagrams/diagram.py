"""Cloud architecture diagrams (as code)."""
from diagrams import Cluster, Diagram
from diagrams.gcp.compute import ComputeEngine, Run
from diagrams.gcp.network import FirewallRules, LoadBalancing
from diagrams.saas.cdn import Cloudflare

FULL_NODE_COUNT = 2
SENTRY_COUNT = 3
VALIDATOR_COUNT = 2

graph_attr = {
    "margin": "-2, -2",
}


def list_to_list(l1: list, l2: list) -> None:
    for nd in l1:
        nd >> l2


with Diagram("full nodes", graph_attr=graph_attr, show=False):
    with Cluster("nodes"):
        nginx_group = [Run(f"nginx{i+1}") for i in range(FULL_NODE_COUNT)]
        nginx_full_node = [
            nginx_group[i] >> ComputeEngine(f"node{i+1}")
            for i in range(FULL_NODE_COUNT)
        ]
    Cloudflare("Cloudflare") >> LoadBalancing("lb") >> nginx_group


with Diagram("validators", graph_attr=graph_attr, show=False):
    sentries = [ComputeEngine(f"sentry{i+1}") for i in range(SENTRY_COUNT)]
    validators = [ComputeEngine(f"validator{i+1}") for i in range(VALIDATOR_COUNT)]
    firewalls = [FirewallRules(f"fw{i+1}") for i in range(FULL_NODE_COUNT)]
    [firewalls[i] >> validators[i] for i in range(FULL_NODE_COUNT)]
    list_to_list(sentries, firewalls)
