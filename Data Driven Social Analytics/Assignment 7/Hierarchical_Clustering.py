# https://stackabuse.com/hierarchical-clustering-with-python-and-scikit-learn/
from scipy.cluster.hierarchy import dendrogram, linkage
from matplotlib import pyplot as plt
import matplotlib.pyplot as plt
import numpy as np
import networkx as nx

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

sources = []
target = []
for line in Lines:
    if index == 0:
        index += 1
        continue

    x = line.replace('\n', '').split(',')

    # Overall Edit Wars
    spot = 0
    G.add_edge(x[0], x[1])
    sources.append(x[0])
    target.append(x[1])

read_file.close()

labels = range(0, len(G.nodes()))
plt.figure(figsize=(10, 7))
plt.subplots_adjust(bottom=0.1)
plt.scatter(sources, target, label='True Position')

for label, x, y in zip(labels, sources, target):
    plt.annotate(
        label,
        xy=(x, y), xytext=(-3, 3),
        textcoords='offset points', ha='right', va='bottom')
filename = 'scatter'
plt.savefig(r'/Users/jordanharris/PycharmProjects/pythonProject/upf/Data Driven Social Analytics/Assignment 7/stimulus_' + filename + '.png')
plt.show()
plt.clf()
plt.cla()
plt.close()

linked = linkage(G.edges(), 'single')

labelList = range(0, len(G.edges()))

plt.figure()
dendrogram(linked,
            orientation='top',
            labels=labelList,
            distance_sort='descending',
            show_leaf_counts=True)
# create the graph
filename = 'dendogram'
plt.savefig(r'/Users/jordanharris/PycharmProjects/pythonProject/upf/Data Driven Social Analytics/Assignment 7/stimulus_' + filename + '.png')
plt.show()
plt.clf()
plt.cla()
plt.close()
