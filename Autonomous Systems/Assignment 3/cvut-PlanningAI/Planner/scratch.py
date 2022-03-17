import os, sys
from problem import *
import operator
from collections import defaultdict



def functionA_Star(start, goal):
    # // The set of nodes already evaluated
    closedSet = defaultdict(list)

    # // The set of currently discovered nodes that are not evaluated yet.
    # // Initially, only the start node is known.
    openSet = defaultdict(list)

    # // For each node, which node it can most efficiently be reached from.
    # // If a node can be reached from many nodes, cameFrom will eventually contain the
    # // most efficient previous step.

    # _____________________________
    # o1 = [['a'], ['c', 'd'], ['a']]
    # o2 = [['a', 'b'], ['e'], []]
    # o3 = [['b', 'e'], ['d', 'f'], ['a', 'e']]
    # o4 = [['b'], ['a'], []]
    # o5 = [['d', 'e'], ['g'], ['e']]

    # Initial state/ start nodes
    # init = ['a', 'b']

    # goal node
    # goal = ['f', 'g']
    # test = Astar()
    # test.add_nodes(o2)
    # test.add_nodes(o4)
    #
    # test.add_nodes(o1)
    # test.add_nodes(o3)
    # test.add_nodes(o5)
    # ______________________________
    # [pre, add, del, cost]
    # USE ON LY THE FULL OPERATOR OBJECT? EASIER FASTER? RATHER THAN REFORMAT?
    # test = Astar()
    # fn_strips = sys.argv[1]
    # p = Strips(fn_strips)
    # init_queue = []
    # for format in p.operators:
    #     if set(format.pre).issubset(p.init):
    #         init_queue.append([format.pre, format.add_eff, format.del_eff, format.cost])
    #
    # next_queue = []
    # test.add_nodes(init_queue[0])
    # for add_next in test.nodes:
    #     if test.nodes[add_next] == []:
    #         next_queue.append(list(add_next))
    #
    # for _ in next_queue:
    #     for find in p.operators:
    #         test.add_nodes(_[0])
    #
    #
    # for n in test.nodes:
    #     print(str(n) + ' : ' + str(test.nodes[n]))
