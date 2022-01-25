import networkx as nx
from networkx.algorithms import community
#
#
#
# def edge_to_remove(g):
#     d1 = nx.edge_betweenness_centrality(g)
#     list_of_tuples = list(d1.items())
#
#     sorted(list_of_tuples, key=lambda x: x[1], reverse=True)
#
#     # Will return in the form (a,b)
#     return list_of_tuples[0][0]
#
#
# def girvan(g):
#     a = nx.connected_components(g)
#     lena = len(list(a))
#     print(' The number of connected components are ', lena)
#     while (lena == 1):
#         # We need (a,b) instead of ((a,b))
#         u, v = edge_to_remove(g)
#         g.remove_edge(u, v)
#
#         a = nx.connected_components(g)
#         lena = len(list(a))
#         print(' The number of connected components are ', lena)
#
#     return a

# Press the green button in the gutter to run the script.
if __name__ == '__main__':
    G = nx.Graph()
    read_file = open(
        "/Users/jordanharris/PycharmProjects/pythonProject/upf/Data Driven Social Analytics/Assignment 7/stimulus_edges.csv", "r")
    Lines = read_file.readlines()

    index = 0
    # Strips the newline character
    for line in Lines:
        x = line.replace('\n', '').split(';')
        Lines[index] = x
        break


    for line in Lines:
        if index == 0:
            index += 1
            continue

        x = line.replace('\n', '').split(',')

        # Overall Edit Wars
        spot = 0
        G.add_edge(x[0], x[1])
    read_file.close()

    read_file = open(
        "/Users/jordanharris/PycharmProjects/pythonProject/upf/Data Driven Social Analytics/Assignment 7/stimulus_nodes.csv", "r")
    Lines = read_file.readlines()
    read_file.close()

#########
    # [0, 1, 2]
    # mapping = {0: "a", 1: "b", 2: "c"}
    # H = nx.relabel_nodes(G, mapping)
#########

    result = community.girvan_newman(G, most_valuable_edge=None)

    a = nx.connected_components(G)
    len_a = len(list(a))
    print(' The number of connected components are ', len_a)
    GV_communities = []
    for i in result:
        for community in i:
            GV_communities.append(community)
            print(community)
        break
    GV_communities = sorted(GV_communities, key=len, reverse=True)

    GN_G = nx.Graph()
    for edge in G.edges:
        if (edge[0] in GV_communities[0]) and (edge[1] in GV_communities[0]):
            GN_G.add_edge(edge[0], edge[1])



    nx.write_gexf(GN_G, "stimulus_GN.gexf")
    read_file.close()
