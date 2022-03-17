import argparse
import sys
import os
import time
import subprocess


def parse_arguments(argv):
    parser = argparse.ArgumentParser(description='Solve Sudoku problems.')
    parser.add_argument(
        "-i", help="Path to the file with the Sokoban instance.")
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


def write_instance(board, filename, problem_name):

    with open(filename, 'w') as file:
        actions = ['up', 'down', 'right', 'left', 'teleport']

        file.write("(define (problem " + problem_name + ") \n")
        file.write('\n')
        file.write("(:domain sokoban) \n")
        file.write('\n')
        # OBJECTS START -------------------------------------------
        file.write('(:objects \n')

        # Adding the possible actions
        for action in actions:
            file.write("\tact_" + action + " - action \n")

        # Adding the player
        file.write("\tplayer_01 - player \n")

        # Adding all locations of the board
        for row in range(board.h):
            for col in range(board.w):
                file.write("\tpos_" + str(row) + "_" +
                           str(col) + " - location \n")

        # Adding all boxes
        for box in enumerate(board.boxes):
            file.write(f"\tbox_{box[0]} - box \n")

        file.write(")\n")

        # INIT START -------------------------------------------
        file.write("(:init \n")

        # Add initial goal state
        for box, coord in enumerate(board.goals):
            file.write(f"\t(IS-GOAL pos_{coord[0]}_{coord[1]}) \n")

        # Adding initial non-goal states
        for row in range(board.h):
            for col in range(board.w):
                if (row, col) not in board.goals:
                    file.write(f"\t(IS-NONGOAL pos_{row}_{col})\n")

        # Add initial player state
        file.write(
            f"\t(at player_01 pos_{board.player[0]}_{board.player[1]}) \n")

        # Add initial boxes state
        for box, coord in enumerate(board.boxes):
            file.write(f"\t(at box_{box} pos_{coord[0]}_{coord[1]}) \n")

        # Adding initial clear positions
        clear = [board.player]
        for row in range(board.h):
            for col in range(board.w):
                if (row, col) not in board.walls and (row, col) != board.player:
                    clear.append((row, col))
                    file.write(f"\t(clear pos_{row}_{col})\n")
        
        # Adding initial possible teleportation movements
        for i, from_clear in enumerate(clear):
            for j, to_clear in enumerate(clear):
                if (from_clear != to_clear and to_clear[0] < board.h and 
                    to_clear[1] < board.w and to_clear not in board.boxes):
                    file.write(f"\t(MOVE-DIR pos_{from_clear[0]}_{from_clear[1]} pos_{to_clear[0]}_{to_clear[1]} act_teleport)\n")

        # Adding initial possible action movements
        for i, pos_clear in enumerate(clear):
            pos_up = (pos_clear[0] + 1, pos_clear[1])
            pos_down = (pos_clear[0] - 1, pos_clear[1])
            pos_left = (pos_clear[0], pos_clear[1]-1)
            pos_right = (pos_clear[0], pos_clear[1] + 1)
            
            if (pos_up not in board.walls and 
                pos_up[0] >= 0 and pos_up[1] >= 0 and
                pos_up[0] < board.h and pos_up[1] < board.w):
                file.write(f"\t(MOVE-DIR pos_{pos_clear[0]}_{pos_clear[1]} pos_{pos_up[0]}_{pos_up[1]} act_up)\n")
            if (pos_down not in board.walls and 
                pos_down[0] >= 0 and pos_down[1] >= 0 and
                pos_down[0] < board.h and pos_down[1] < board.w):
                file.write(f"\t(MOVE-DIR pos_{pos_clear[0]}_{pos_clear[1]} pos_{pos_down[0]}_{pos_down[1]} act_down)\n")
            if (pos_left not in board.walls and 
                pos_left[0] >= 0 and pos_left[1] >= 0 and
                pos_left[0] < board.h and pos_left[1] < board.w):
                file.write(f"\t(MOVE-DIR pos_{pos_clear[0]}_{pos_clear[1]} pos_{pos_left[0]}_{pos_left[1]} act_left)\n")
            if (pos_right not in board.walls and 
                pos_right[0] >= 0 and pos_right[1] >= 0 and
                pos_right[0] < board.h and pos_right[1] < board.w):
                file.write(f"\t(MOVE-DIR pos_{pos_clear[0]}_{pos_clear[1]} pos_{pos_right[0]}_{pos_right[1]} act_right)\n")
        
        file.write(")\n(:goal (and\n")

        # Add goals
        for box in enumerate(board.boxes):
            file.write(f"\t(at_goal box_{box[0]})\n")
        file.write(")))")

    file.close()


def main(argv):
    args = parse_arguments(argv)
    with open(args.i, 'r') as file:
        board = SokobanGame(file.read().rstrip('\n'))
        write_instance(board, 'test_instance.pddl', 'test')


if __name__ == "__main__":
    main(sys.argv[1:])
