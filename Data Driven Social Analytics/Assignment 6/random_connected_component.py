from itertools import combinations, groupby
import numpy as np
import networkx as nx
import matplotlib.pyplot as plt

# Generate the graph
# 0.33, 0.61, 0.71, 0.75, 0.82
n = 5
p = 0.82
G_erdos = nx.erdos_renyi_graph(n,p, seed =100)

pos = nx.circular_layout(G_erdos)
# Plot the graph
plt.figure(figsize=(8,5))
nx.draw(G_erdos, pos, node_color='lightblue',
        with_labels=True,
        node_size=500)
filename = 'Small_network'
plt.savefig(r'/Users/jordanharris/PycharmProjects/pythonProject/upf/Data Driven Social Analytics/Assignment 6/' + filename + '_' + str(n) + '_' + str(p) + '.png')
plt.show()
plt.clf()
plt.cla()
plt.close()

for _, node_edges in groupby(G_erdos.edges, key=lambda x: x[0]):
    print(list(node_edges))


# Get the list of the degrees
degree_sequence_erdos = list(G_erdos.degree())

nb_nodes = n
nb_arr = len(G_erdos.edges())

avg_degree = np.mean(np.array(degree_sequence_erdos)[:,1])
med_degree = np.median(np.array(degree_sequence_erdos)[:,1])

max_degree = max(np.array(degree_sequence_erdos)[:,1])
min_degree = np.min(np.array(degree_sequence_erdos)[:,1])

esp_degree = (n-1)*p

print("Number of nodes : " + str(nb_nodes))
print("Number of edges : " + str(nb_arr))

print("Maximum degree : " + str(max_degree))
print("Minimum degree : " + str(min_degree))

print("Average degree : " + str(avg_degree))
print("Expected degree : " + str(esp_degree))
print("Median degree : " + str(med_degree))


def kPresentProbability(a, n, d):
    count = a.count(d)
    return str(round(count / n, 2))     # <-- max sum of row is len(ar) == 3


probs = []
for each in degree_sequence_erdos:
    probs.append(each[1])

prob = []
for every in set(probs):
    prob.append((every, kPresentProbability(probs, len(probs), every)))

degree_freq = np.array(nx.degree_histogram(G_erdos)).astype('float')

prob_adj_degree = []
degrees = []
for d in prob:
    prob_adj_degree.append((d[0]/(2 * len(G_erdos.edges()))) * degree_freq[d[0]])
    degrees.append(d[0])


degree_freq = np.array(nx.degree_histogram(G_erdos)).astype('float')
plt.figure(figsize=(12, 8))
plt.ylabel("Frequency")
plt.xlabel("Degree")
plt.stem(degree_freq, label='p = ' + str(p))

# Function add a legend
plt.legend(bbox_to_anchor=(0.90, 1.05), ncol=2)

prob_y_axis = [0.0, .10, .20, .30, .40, .50, .60, .70, .80, .90, 1]
plt.twinx()
plt.plot(degrees, prob_adj_degree, 'o-', color='red')
plt.ylabel('Probability of Neighbors Degree')
plt.yticks(prob_y_axis)

plt2 = plt.twiny()

_ = []
annotation = []
for iter in prob:
    _.append(iter[0])
    annotation.append(str(iter[1]) + "% of Nodes")
plt2.xaxis.tick_bottom()  # x axis on top
plt2.xaxis.set_label_position('bottom')
plt.xticks(list(range(0, max_degree + 1)))
plt2.set_xticks(_)
plt2.set_xticklabels(annotation, rotation=45, color='blue')

# Title & Subtitle
plt.title('Prob Distribution of Degrees VS Prob of Degree of Neighbor')
filename = 'Probability_Degrees'
plt.savefig(r'/Users/jordanharris/PycharmProjects/pythonProject/upf/Data Driven Social Analytics/Assignment 6/' + filename + '_' + str(n) + '_' + str(p) + '.png')
plt.show()
plt.clf()
plt.cla()
plt.close()
