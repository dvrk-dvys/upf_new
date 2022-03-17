import datetime
import sys
import time
from collections import defaultdict
from queue import PriorityQueue
from problem import *



class PriorityQueueing(object):
    def __init__(self):
        self.queue = []

    def __str__(self):
        return ' '.join([str(i) for i in self.queue])

        # for checking if the queue is empty

    def isEmpty(self):
        return len(self.queue) == []

        # for inserting an element in the queue

    def insert(self, data):
        self.queue.append(data)

        # for popping an element based on Priority

    # min_fScore = defaultdict(list)
    # for each in openSet:
    #     min_fScore[tuple(each)] = fScore[tuple(each)]
    # current = min(min_fScore, key=min_fScore.get)


    def get(self):
        try:
            minimum = 0
            for i in range(len(self.queue)):
                # keep = i
                # test = defaultdict(list)
                # test[tuple(self.queue[i][1])] = self.queue[i][0]
                # test[tuple(self.queue[minimum][1])] = self.queue[minimum][0]
                # testing = test[min(test, key=test.get)]
                # if testing == i:
                #     minimum = i
                # minimum = list(test.keys())[list(.values()).index(minimum)]

                if self.queue[i] < self.queue[minimum]:

                    minimum = i
            item = self.queue[minimum]
            del self.queue[minimum]
            return item
        except IndexError:
            print()
            exit()


class Astar:
    def __init__(self, parent=None, position=None):
        self.optimal_cost = 0
        self.hmax = 0
        # Index of chosen operators names
        self.output = []
        self.p = None
        # new node : (cost of op, index of op)
        self.states = defaultdict(list)
        self.f_score = defaultdict(list)
        self.g_score = defaultdict(list)

        self.h_map = defaultdict(list)
        self.i = 0

    #   g value of goal state equalz

    # set hmax to zero  and upload?

    def functionA_Star(self, fn_strips):
        p = Strips(fn_strips)
        self.p = p
        start = sorted(p.init)
        goal = sorted(p.goal)

        self.states[tuple(sorted(start))] = [(0, 0)]

        # // The set of nodes already evaluated
        closedSet = []

        # // The set of currently discovered nodes that are not evaluated yet.
        # // Initially, only the start node is known.
        # openSet = []
        # openSet.append(tuple(sorted(start)))

        # openSetQ = PriorityQueue()
        # openSetQ.put(tuple(sorted(start)), 0)

        openSetQ = PriorityQueueing()
        openSetQ.insert((0, tuple(sorted(start))))

        # // For each node, which node it can most efficiently be reached from.
        # // If a node can be reached from many nodes, cameFrom will eventually contain the
        # // most efficient previous step.
        cameFrom = defaultdict(list)


        # // For each node, the cost of getting from the start node to that node.
        gScore = defaultdict(list)

        # // The cost of going from start to start is zero.
        gScore[tuple(sorted(start))] = 0
        self.g_score[tuple(sorted(start))] = 0
        # // For each node, the total cost of getting from the start node to the goal
        # // by passing by that node. That value is partly known, partly heuristic.
        #         HMAX!! F = G+HMAX
        fScore = defaultdict(list)

        # // For the first node, that value is completely heuristic.
        if Astar.Hmax(fn_strips, start) == float("inf"):
            fScore[tuple(sorted(start))] = 0
            self.f_score[tuple(sorted(start))] = 0
        else:
            fScore[tuple(sorted(start))] = Astar.Hmax(fn_strips, start)
            self.f_score[tuple(sorted(start))] = Astar.Hmax(fn_strips, start)

        # while openSet != []:
        # while not openSetQ.empty():
        while not openSetQ.isEmpty():

            # min_fScore = defaultdict(list)
            # for each in openSet:
            #     min_fScore[tuple(each)] = fScore[tuple(each)]
            # current = min(min_fScore, key=min_fScore.get)

            current = openSetQ.get()
            current = current[1]
            self.i += 1
            if self.i % 1000 == 0:
                st = datetime.datetime.fromtimestamp(time.time()).strftime('%Y-%m-%d %H:%M:%S')
                sys.stderr.write(str(current) + ' ' + str(st) + '\n')


        # for each in min_fScore:
        #         print((each, min_fScore[each]))
        #     print('===============')
        #     print(current)
        #     print(currentQ)

            if set(goal).issubset(current):
                return Astar.resconstruct_path(cameFrom, current)

            #
            # openSet.remove(current)
            closedSet.append(current)

            neighbors = Astar.findNeighbors(current, p.operators)

            for neighbor in neighbors:
                if neighbor in closedSet:
                    continue  # // Ignore the neighbor which is already evaluated.

                temp_gScore = gScore[current] + neighbors[neighbor][0]


                # if tuple(neighbor) not in openSet:
                #     openSet.append(neighbor) # Discover a new node
                # elif temp_gScore >= gScore[neighbor]:
                #     continue

                if neighbor not in self.h_map:
                    testing_h = Astar.Hmax(fn_strips, neighbor)
                    self.h_map[neighbor] = testing_h
                else:
                    testing_h = self.h_map[neighbor]



                if tuple(neighbor) not in gScore:
                    # openSetQ.put(neighbor, (temp_gScore + testing_h))
                    openSetQ.insert((temp_gScore + testing_h, neighbor))
                elif temp_gScore >= gScore[neighbor]:
                    continue



                cameFrom[neighbor] = (current, neighbors[neighbor][1])

                gScore[neighbor] = temp_gScore
                self.g_score[neighbor] = temp_gScore
                fScore[neighbor] = gScore[neighbor] + testing_h
                self.f_score[neighbor] = gScore[neighbor] + testing_h
                # print(self.f_score[neighbor])


    def findNeighbors(self, node, ops):
        neighbors = defaultdict(list)

        for pre in ops:
            if set(pre.pre).issubset(node) == True:
                nextnode = list(node)
                for del_eff in pre.del_eff:
                    if del_eff in nextnode:
                        nextnode.remove(del_eff)

                nextnode = list(set(list(nextnode) + list(pre.add_eff)))


                if tuple(sorted(nextnode)) in self.states:
                    if tuple(sorted(nextnode)) not in self.h_map:
                        hm = Astar.Hmax(self.p, tuple(sorted(nextnode)))
                        self.h_map[tuple(sorted(nextnode))] = hm
                        gscore = hm + self.states[tuple(sorted(nextnode))][0][0]

                    else:
                        gscore = self.h_map[tuple(sorted(nextnode))] + self.states[tuple(sorted(nextnode))][0][0]
                    if self.g_score[tuple(sorted(nextnode))] != []:
                        if self.g_score[tuple(sorted(nextnode))] > gscore:
                            # if set(self.p.operators[self.states[tuple(sorted(nextnode))][0][1]].pre).issubset(node):
                            if set(self.p.operators[self.states[tuple(sorted(nextnode))][0][1]].pre).issubset(node) == True:
                                neighbors[tuple(sorted(nextnode))] = (self.states[tuple(sorted(nextnode))][0][0], self.states[tuple(sorted(nextnode))][0][1])
                                continue


                neighbors[tuple(sorted(nextnode))] = (pre.cost, ops.index(pre))
                self.states[tuple(sorted(nextnode))] = [(pre.cost, ops.index(pre))]

        return neighbors

    def resconstruct_path(self, cameFrom, current):
        total_path = [(current, cameFrom[current][1])]
        self.optimal_cost += self.g_score[current]
        while current in cameFrom.keys():
            if cameFrom[current][0] not in cameFrom:
                # self.optimal_cost += self.p.operators[cameFrom[current][1]].cost
                break
            current = cameFrom[current][0]

            total_path.append((current, cameFrom[current][1]))

            # self.optimal_cost += self.p.operators[cameFrom[current][1]].cost
        return total_path

    def Hmax(self, fn_strips, currentState=[]):
        if type(fn_strips) == str:
            p = Strips(fn_strips)
        else:
            p = fn_strips


        delta = {}
        deltaQ = PriorityQueue()
        U = {}

        if currentState == []:
            for ifact in p.init:
                delta[ifact] = 0
                deltaQ.put(ifact, 0)
            for ofact in range(len(p.facts)):
                if ofact not in p.init:
                    delta[ofact] = float("inf")
                    deltaQ.put(ifact, float("inf"))

        else:
            for ifact in currentState:
                delta[ifact] = 0
                deltaQ.put(ifact, 0)
            for ofact in range(len(p.facts)):
                if ofact not in currentState:
                    delta[ofact] = float("inf")
                    deltaQ.put(ifact, float("inf"))


        # for op in p.operators:
        #     for pre in op.pre:
        #         if delta[pre] == set():
        #             for add in op.add_eff:
        #                 # delta[add] = op.cost
        #                 delta.put(add, op.cost)

        for op in p.operators:
            U[p.operators.index(op)] = len(op.pre)

        C = set()

        while not set(p.goal).issubset(C):
            test = delta.copy()

            for remove in C:
              del test[remove]

            k = min(test, key=test.get)

            # k = deltaQ.get()
            # while k in C:
            #     k = deltaQ.get()

            C.add(k)
            for op in p.operators:
                if k in op.pre:
                    U[p.operators.index(op)] = U[p.operators.index(op)] - 1
                    if U[p.operators.index(op)] == 0:
                        for fact in op.add_eff:
                            delta[fact] = min(delta[fact], op.cost + delta[k])
                            deltaQ.put(fact, op.cost + delta[k])
        # HMAX
        final = []
        for each in delta:
            if each in p.goal:
                final.append(delta[each])
        return max(final)


if __name__ == '__main__':
    # # if len(sys.argv) != 3:
    # for each in sys.argv:
    #     print('Usage: {0} problem.strips problem.fdr'.format(sys.argv[0]))
    #     # sys.exit(-1)

    Astar = Astar()

    Astar.hmax = Astar.Hmax(sys.argv[1])
    path = Astar.functionA_Star(sys.argv[1])
    print(';; Cost: ' + str(Astar.optimal_cost))
    print(';; Init: ' + str(Astar.hmax))
    print('')

    for printing in reversed(path):
        print(Astar.p.operators[printing[1]].name)


# python ./max.py ./pui-test-set/depot/pfile1.strips ./pui-test-set/depot/pfile1.fdr