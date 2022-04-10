#!/usr/bin/env python3

import argparse
import sys
from sokoban_gen import Sokoban_genDomain, Sokoban_genProblem
# import py2pddl
# from py2pddl import parse as get_domain


def parse_arguments(argv):
    parser = argparse.ArgumentParser(description='Solve Sudoku problems.')
    parser.add_argument("-i", help="Path to the file with the Sokoban instance.")
    return parser.parse_args(argv)


class SokobanGame(object):
    """ A Sokoban Game. """
    def __init__(self, string):
        """ Create a Sokoban game object from a string representation such as the one defined in
            http://sokobano.de/wiki/index.php?title=Level_format
        """
        lines = string.split('\n')
        self.h, self.w = len(lines), max(len(x) for x in lines)
        self.player = None
        self.walls = set()
        self.boxes = set()
        self.goals = set()
        for i, line in enumerate(lines, 0):
            for j, char in enumerate(line, 0):
                if char == '#':  # Wall
                    self.walls.add((i, j))
                elif char == '@':  # Player
                    assert self.player is None
                    self.player = (i, j)
                elif char == '+':  # Player on goal square
                    assert self.player is None
                    self.player = (i, j)
                    self.goals.add((i, j))
                elif char == '$':  # Box
                    self.boxes.add((i, j))
                elif char == '*':  # Box on goal square
                    self.boxes.add((i, j))
                    self.goals.add((i, j))
                elif char == '.':  # Goal square
                    self.goals.add((i, j))
                elif char == ' ':  # Space
                    pass  # No need to do anything
                else:
                    raise ValueError(f'Unknown character "{char}"')

    def is_wall(self, x, y):
        """ Whether the given coordinate is a wall. """
        return (x, y) in self.walls

    def is_box(self, x, y):
        """ Whether the given coordinate has a box. """
        return (x, y) in self.boxes

    def is_goal(self, x, y):
        """ Whether the given coordinate is a goal location. """
        return (x, y) in self.goals


def main(argv):
    args = parse_arguments(argv)
    with open(args.i, 'r') as file:
        board = SokobanGame(file.read().rstrip('\n'))
        soko_prob = Sokoban_genProblem(board)

        soko_prob.init()
        soko_prob.goal()

        x = soko_prob.generate_problem_pddl(filename=args.i.split('/')[-1:][0] + 'problem')
        return x
    # THE MAP ISSS THE PROBLEM FOR THE PDDL TO SOLVE
    # TODO - Some of the things that you need to do:
    #  1. (Previously) Have a domain.pddl file somewhere in disk that represents the Sokoban actions and predicates.
    #  2. Generate an instance.pddl file from the given board, and save it to disk.
    #  3. Invoke some classical planner to solve the generated instance.
    #  3. Check the output and print the plan into the screen in some readable form.

    # soko_prob = Sokoban_genProblem
    # soko_prob.get_board(soko_prob, args=board)
    # soko_prob.init(soko_prob, args=board)


    # p.generate_problem_pddl()

    print()



if __name__ == "__main__":
    main(sys.argv[1:])
