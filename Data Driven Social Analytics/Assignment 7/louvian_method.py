from community import community_louvain
import networkx as nx
import snap
import matplotlib.pyplot as plt
import matplotlib.cm as cm

if __name__ == '__main__':


    G = nx.Graph()
    read_file = open(
        "/Users/jordanharris/PycharmProjects/pythonProject/upf/Data Driven Social Analytics/Assignment 7/stimulus_edges.csv",
        "r")
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

    # retrun partition as a dict
    partition = community_louvain.best_partition(G)
    # visualization
    pos = nx.spring_layout(G)
    cmap = cm.get_cmap('viridis', max(partition.values()) + 1)
    nx.draw_networkx_nodes(G, pos, partition.keys(), node_size=50, cmap=cmap, node_color=list(partition.values()))
    nx.draw_networkx_edges(G, pos, alpha=0.5)
    plt.show()
    plt.clf()
    plt.cla()
    plt.close()

    nx.write_gexf(G, "stimulus_lm.gexf")

    # UGraph = snap.GenRndGnm(s   nap.TUNGraph, 100, 1000)
    # modularity, CmtyV = UGraph.CommunityGirvanNewman()
    # for Cmty in CmtyV:
    #     print("Community: ")
    #     for NI in Cmty:
    #         print(NI)
    # print("The modularity of the network is %f" % modularity)