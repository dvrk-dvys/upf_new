# search.py
# ---------
# Licensing Information:  You are free to use or extend these projects for
# educational purposes provided that (1) you do not distribute or publish
# solutions, (2) you retain this notice, and (3) you provide clear
# attribution to UC Berkeley, including a link to http://ai.berkeley.edu.
# 
# Attribution Information: The Pacman AI projects were developed at UC Berkeley.
# The core projects and autograders were primarily created by John DeNero
# (denero@cs.berkeley.edu) and Dan Klein (klein@cs.berkeley.edu).
# Student side autograding was added by Brad Miller, Nick Hay, and
# Pieter Abbeel (pabbeel@cs.berkeley.edu).

from game import Directions
from queue import PriorityQueue
import sys


"""
In search.py, you will implement generic search algorithms which are called by
Pacman agents (in searchAgents.py).
"""

import util

class SearchProblem:
    """
    This class outlines the structure of a search problem, but doesn't implement
    any of the methods (in object-oriented terminology: an abstract class).

    You do not need to change anything in this class, ever.
    """

    def getStartState(self):
        """
        Returns the start state for the search problem.
        """
        util.raiseNotDefined()

    def isGoalState(self, state):
        """
          state: Search state

        Returns True if and only if the state is a valid goal state.
        """
        util.raiseNotDefined()

    def getSuccessors(self, state):
        """
          state: Search state

        For a given state, this should return a list of triples, (successor,
        action, stepCost), where 'successor' is a successor to the current
        state, 'action' is the action required to get there, and 'stepCost' is
        the incremental cost of expanding to that successor.
        """
        util.raiseNotDefined()

    def getCostOfActions(self, actions):
        """
         actions: A list of actions to take

        This method returns the total cost of a particular sequence of actions.
        The sequence must be composed of legal moves.
        """
        util.raiseNotDefined()


def tinyMazeSearch(problem):
    """
    Returns a sequence of moves that solves tinyMaze.  For any other maze, the
    sequence of moves will be incorrect, so only use this for tinyMaze.
    """
    from game import Directions
    s = Directions.SOUTH
    w = Directions.WEST
    return  [s, s, w, s, w, w, s, w]

def depthFirstSearch(problem):
    """
    Search the deepest nodes in the search tree first.

    Your search algorithm needs to return a list of actions that reaches the
    goal. Make sure to implement a graph search algorithm.

    To get started, you might want to try some of these simple commands to
    understand the search problem that is being passed in:

    print("Start:", problem.getStartState())
    print("Is the start a goal?", problem.isGoalState(problem.getStartState()))
    print("Start's successors:", problem.getSuccessors(problem.getStartState()))
    """
    "*** YOUR CODE HERE ***"

    print("Start:", problem.getStartState())
    print("Is the start a goal?", problem.isGoalState(problem.getStartState()))
    print("Start's successors:", problem.getSuccessors(problem.getStartState()))

    # def my_function(a: int, b: Tuple[int, int], c: List[List], d: Any, e: float = 1.0):
    # my_function(1, (2, 3), [['a', 'b'], [None, my_class], [[]]], ('h', 1))


    def DFSPath(graph, start, goal):
        visited = []
        path = []
        fringe = PriorityQueue()
        fringe.put((0, start, path, visited))

        while not fringe.empty():
            depth, current_node, path, visited = fringe.get()

            if current_node == goal:
                return path + [current_node]

            visited = visited + [current_node]

            child_nodes = graph[current_node]
            for node in child_nodes:
                if node not in visited:
                    if node == goal:
                        finalpath = [start] + path + [node]
                        return finalpath
                    depth_of_node = len(path)
                    fringe.put((-depth_of_node, node, path + [node], visited))

        return path

    nodes = set((x, y) for x in range(0, (problem.walls.width-1)) for y in range(0, (problem.walls.height-1)))
    nodes = sorted(nodes, key=lambda tup: tup[0])
    for each in list(nodes):
        if problem.walls.data[each[0]][each[1]] == True:
            nodes.remove(each)

    if problem.walls.width == problem.walls.height:
        graph = {k: [] for k in nodes}

        for each in nodes:
            for every in problem.getSuccessors(each):
                graph[each].append(every[0])

    print(sys.argv)
    path = DFSPath(graph, problem.startState, problem.goal)
    print(path)


    output = []

    for each in path:
        if path[path.index(each) + 1] == problem.goal:
            for next in problem.getSuccessors(each):
                if (problem.goal == next[0]):
                    output.append(next[1])

            break
        for next in problem.getSuccessors(each):
            if (path[path.index(each) + 1] in next) and (path[path.index(each) + 1] == next[0]):
                output.append(next[1])

    print(output)

    return output

    util.raiseNotDefined()

def breadthFirstSearch(problem):
    """Search the shallowest nodes in the search tree first."""
    def shortestBFSPath(graph, start, goal):
        visited = []

        # Queue for traversing the
        # graph in the BFS
        queue = [[start]]

        # Loop to traverse the graph
        # with the help of the queue
        while queue:
            path = queue.pop(0)
            node = path[-1]

            # Condition to check if the
            # current node is not visited
            if node not in visited:
                neighbours = graph[node]

                # Loop to iterate over the
                # neighbours of the node
                for neighbour in neighbours:
                    new_path = list(path)
                    new_path.append(neighbour)
                    queue.append(new_path)

                    # Condition to check if the
                    # neighbour node is the goal
                    if neighbour == goal or (neighbour in goal):
                        print("Shortest path = ", *new_path)
                        return new_path
                visited.append(node)

        return


    for check in sys.argv:
        if 'Corners' in check:
            prob = 'Corners'
            break
        else:
            prob = None

    nodes = set((x, y) for x in range(0, (problem.walls.width-1)) for y in range(0, (problem.walls.height-1)))
    nodes = sorted(nodes, key=lambda tup: tup[0])
    for each in list(nodes):
        if problem.walls.data[each[0]][each[1]] == True:
            nodes.remove(each)
        print()

    if problem.walls.width == problem.walls.height:
        graph = {k: [] for k in nodes}

        for each in nodes:
            for every in problem.getSuccessors(each):
                if 'Corners' == prob:
                    graph[each].append(every[0][0])
                else:
                    graph[each].append(every[0])


    output = []

    if prob == 'Corners':
        goals = list(problem.goal)
        while goals != []:
            if len(goals) == len(problem.goal):
                path = shortestBFSPath(graph, problem.startingPosition, goals[0])
                new_start = goals.pop(0)

            else:
                path = shortestBFSPath(graph, new_start, goals[0])
                new_start = goals.pop(0)

            for each in path:
                if path[path.index(each) + 1] in problem.goal:
                    for next in problem.getSuccessors(each):
                        if (next[0][0] in problem.goal):
                            output.append(next[1])

                    break

                for next in problem.getSuccessors(each):
                    if (path[path.index(each) + 1] == next[0][0]):
                        output.append(next[1])

    else:
        path = shortestBFSPath(graph, problem.startState, problem.goal)

        for each in path:
            if path[path.index(each) + 1] == problem.goal or (path[path.index(each) + 1] in problem.goal):
                for next in problem.getSuccessors(each):
                    if (problem.goal == next[0]) or (next[0] in problem.goal):
                        output.append(next[1])

                break

            for next in problem.getSuccessors(each):
                if (path[path.index(each) + 1] in next) and (path[path.index(each) + 1] == next[0]):
                    output.append(next[1])

    print(output)

    return output

def uniformCostSearch(problem):
    """Search the node of least total cost first."""
    nodes = set((x, y) for x in range(0, (problem.walls.width - 1)) for y in range(0, (problem.walls.height - 1)))
    nodes = sorted(nodes, key=lambda tup: tup[0])
    for each in list(nodes):
        if problem.walls.data[each[0]][each[1]] == True:
            nodes.remove(each)

    if problem.walls.width == problem.walls.height:
        graph = {k: [] for k in nodes}

        for each in nodes:
            for every in problem.getSuccessors(each):
                graph[each].append(every[0])

    visited = set()
    path = []
    queue = PriorityQueue()
    queue.put((0, [problem.startState]))

    while queue:
        # if no path is present beteween two nodes

        cost, path = queue.get()
        node = path[len(path) - 1]
        if node not in visited:
            visited.add(node)
            if node == problem.goal or (node in problem.goal):
                path.append(cost)

                output = []

                for each in path:
                    if path[path.index(each) + 1] == problem.goal or (path[path.index(each) + 1] in problem.goal):
                        for next in problem.getSuccessors(each):
                            if (problem.goal == next[0]) or (next[0] in problem.goal):
                                output.append(next[1])

                        break
                    for next in problem.getSuccessors(each):
                        if (path[path.index(each) + 1] in next) and (path[path.index(each) + 1] == next[0]):
                            output.append(next[1])

                print(output)

                return output


            for n in problem.getSuccessors(node):
                if n[0] not in visited:
                    t_cost = cost + n[2]

                    temp = path[:]
                    temp.append(n[0])
                    queue.put((t_cost, temp))

def nullHeuristic(state, problem=None):
    """
    A heuristic function estimates the cost from the current state to the nearest
    goal in the provided SearchProblem.  This heuristic is trivial.
    """
    return 0


def aStarSearch(problem, heuristic=nullHeuristic):
    """Search the node that has the lowest combined cost and heuristic first."""
    for check in sys.argv:
        if 'Corners' in check:
            prob = 'Corners'
            break
        else:
            prob = None


    open = util.PriorityQueue()
    closed = []
    actionList = []
    startState = problem.getStartState()
    open.push((startState, actionList), heuristic(startState, problem))

    while not open.isEmpty():
        currentNode, actionPath = open.pop()
        if problem.isGoalState(currentNode):
            return actionPath
        if currentNode not in closed:
            closed.append(currentNode)
            succ = problem.getSuccessors(currentNode)

            if 'Corners' == prob:
                for child in succ:
                    coordinate, direction, cost = child
                    # print('cost:', cost)
                    nextActions = actionPath + [direction]
                    nextCost = problem.getCostOfActions(actionPath) + child[2] + heuristic(child[0], problem)
                    open.push((coordinate, nextActions), nextCost)

            else:
                for child in succ:
                    open.push((child[0], actionPath + [child[1]]),
                                  problem.getCostOfActions(actionPath) + child[2] + heuristic(child[0], problem))
    return []


# Abbreviations
bfs = breadthFirstSearch
dfs = depthFirstSearch
astar = aStarSearch
ucs = uniformCostSearch


# !!!! medium doesnt work for dfs: UnboundLocalError: local variable 'graph' referenced before assignment


