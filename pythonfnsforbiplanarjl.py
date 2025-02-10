import networkx as nx
import numpy as np
import random
import gcol
#import pysat
#pysat.params['data_dirs'] = 'C:/Users/18479/OneDrive/Desktop/transformers_math_experiments/pysatData'
#from pysat.solvers import Solver  # standard way to import the library
#from pysat.solvers import Minisat22, Glucose3  # more direct way
def maximize_biplanar_components(adj_matrix):
    """
    Split a graph defined by the adjacency matrix into two subgraphs, 
    find their greedy maximal planar subgraphs, and ensure edge independence between components.
    """
    #print("fromjulia")
    n = len(adj_matrix)  # Number of nodes
    G1 = nx.Graph()
    G1.add_nodes_from(range(0,n))
    G2 = nx.Graph()
    G2.add_nodes_from(range(0,n))
    # Parse the adjacency matrix to construct G1 and G2
    for i in range(n):
        for j in range(i + 1, n):
            if adj_matrix[i][j] == 1:
                G1.add_edge(i, j)
            elif adj_matrix[i][j] == 2:
                G2.add_edge(i, j)

    # Get greedy maximal planar subgraphs for G1 and G2
    def greedy_maximal_planar_subgraph(G):
        """
        Greedily construct a maximal planar subgraph from the given graph.
        """
        planar_subgraph = nx.Graph()
        planar_subgraph.add_nodes_from(G.nodes())  # Add all nodes initially

        for u, v in G.edges():
            planar_subgraph.add_edge(u, v)
            is_planar , _ = nx.check_planarity(planar_subgraph)
            if not is_planar:
                planar_subgraph.remove_edge(u, v)  # Remove edge if non-planar

        # Add remaining edges to maximize edge count while maintaining planarity
        candidate_edges = [
            (u, v)
            for u in planar_subgraph.nodes()
            for v in planar_subgraph.nodes()
            if u < v and not planar_subgraph.has_edge(u, v)
        ]
        random.shuffle(candidate_edges)
        for u, v in candidate_edges:
            planar_subgraph.add_edge(u, v)
            is_planar, _ = nx.check_planarity(planar_subgraph)
            if not is_planar:
                planar_subgraph.remove_edge(u, v)

        return planar_subgraph

    is_planar_G1, _ = nx.check_planarity(G1)
    is_planar_G2, _ = nx.check_planarity(G2)
    planar_G1 = G1 if is_planar_G1 else greedy_maximal_planar_subgraph(G1)
    planar_G2 = G2 if is_planar_G2 else greedy_maximal_planar_subgraph(G2)
    # Add edges to maximize planar graphs while avoiding shared edges
    def add_greedy_edges(graph, forbidden_edges):
        max_edges = 3 * graph.number_of_nodes() - 6
        candidate_edges = [
            (u, v)
            for u in graph.nodes()
            for v in graph.nodes()
            if u < v and not graph.has_edge(u, v) and (u, v) not in forbidden_edges
        ]
        random.shuffle(candidate_edges)
        for u, v in candidate_edges:
            if graph.number_of_edges() >= max_edges:
                break
            graph.add_edge(u, v)
            is_planar, _ = nx.check_planarity(graph)
            if not is_planar:
                graph.remove_edge(u, v)

    # Ensure no edge is shared between planar_G1 and planar_G2
    forbidden_edges_G1 = set(planar_G2.edges())

    add_greedy_edges(planar_G1, forbidden_edges_G1)

    forbidden_edges_G2 = set(planar_G1.edges())

    add_greedy_edges(planar_G2, forbidden_edges_G2)

    def find_adj_matrix_from_graphs(G1, G2):
        """
        Create an adjacency matrix with 1s and 2s from graphs G1 and G2.
        """
        n=G1.number_of_nodes()
        adj_matrix = np.zeros((n, n), dtype=int)
        for u, v in G1.edges():
            adj_matrix[u, v] = 1
            adj_matrix[v, u] = 1
        for u, v in G2.edges():
            adj_matrix[u, v] = 2
            adj_matrix[v, u] = 2
        return adj_matrix
    is_planar_G1, _ = nx.check_planarity(planar_G1)
    is_planar_G2, _ = nx.check_planarity(planar_G2)
    if not is_planar_G1:
        print("graph G1 is not planar")
        print(find_adj_matrix_from_graphs(planar_G1,planar_G1))
    if not is_planar_G2:
        print("graph G2 is not planar")
        print(find_adj_matrix_from_graphs(planar_G2,planar_G2))
    return find_adj_matrix_from_graphs(planar_G1, planar_G2)
