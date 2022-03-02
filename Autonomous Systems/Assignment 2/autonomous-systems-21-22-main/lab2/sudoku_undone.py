#!/usr/bin/env python3
import itertools

import numpy as np
import copy
import argparse
from itertools import permutations, combinations, product, combinations_with_replacement
import math
import sys

from utils import save_dimacs_cnf, solve



# objective is to to fill a 9 × 9 grid with integer digits from
# N = {1, 2, . . . , 9}, so that the resulting grid satisfies two basic constraints:
# ◦ Each digit in N appears exactly once in every row and column of the grid.
# ◦ Each digit in N appears exactly once in every one of the nine 3 × 3 subgrids that partition
# the main grid.

# A “.” denotes an empty cell, and a digit denotes a cell with that value. See the
# figure for an example of such encoding.
# n conjunctive normal form (CNF).

def parse_arguments(argv):
    parser = argparse.ArgumentParser(description='Solve Sudoku problems.')
    parser.add_argument("board", help="A string encoding the Sudoku board, with all rows concatenated,"
                                      " and 0s where no number has been placed yet.")
    parser.add_argument('-q', '--quiet', action='store_true',
                        help='Do not print any output.')
    parser.add_argument('-c', '--count', action='store_true',
                        help='Count the number of solutions.')
    return parser.parse_args(argv)


def print_solution(solution):
    """ Print a (hopefully solved) Sudoku board represented as a list of 81 integers in visual form. """
    print(f'Solution: {"".join(map(str, solution))}')
    print('Solution in board form:')
    Board(solution).print()

def var(row, col, n):
    # convert possible input number to a var with Base 9
    return (9 * 9) * (row - 1) + 9 * (col - 1) + n


def restrict(coord, clauses):
    for row in range(len(coord)):
        for col in range(len(coord)):
            if row < col:
                for n in range(1, 10):
                    clauses.append([-var(coord[row][0], coord[row][1], n), -var(coord[col][0], coord[col][1], n)])
    return clauses

def compute_solution(sat_assignment, variables, size, matrix):
    solution = []
    # TODO: Map the SAT assignment back into a Sudoku solution
    for row, col in product(range(1, 10), repeat=2):
        for n in range(1, 10):
            if sat_assignment[var(row, col, n)] == True:
                matrix[row - 1][col - 1] = n
                break

    solution_str = ""
    for row, col in product(range(9), repeat=2):
        cell = '.' if matrix[row][col] == 0 else str(matrix[row][col])
        solution_str += cell

    return solution_str

def generate_theory(board, verbose):
    """ Generate the propositional theory that corresponds to the given board. """
    size = board.size()
    clauses = []
    variables = []

    # TODO
    matrix = [[0] * size for i in range(size)]

    for row, col in product(range(size), repeat=2):
        matrix[row][col] = board.data.pop(0)
    print(matrix)
    # grid_for_work = copy.deepcopy(matrix)

    # Clauses for known values :: clause with one literal
    for row, col in product(range(0, size), repeat=2):
        if matrix[row][col] != 0:
            clauses.append([var(row+1, col+1, matrix[row][col])])

    # Clauses for valid numbers in individual cells
    prep = []
    # for row in range(1, size + 1):
    #     for col in range(1, size + 1):
    for row, col in product(range(1, size + 1), repeat=2):
        for val in range(1, size + 1):
            prep.append(var(row, col, val))
        clauses.append(prep)
        prep = []

    #-A cell cannot take two diff (n) values-#
    # Clauses for column constraints
    # for col in range(1, size + 1):
    #     for val in range(1, size + 1):
    for col, val in product(range(1, size + 1), repeat=2):
        for row in range(1, size):
            for i in range(row + 1, size + 1):
                clauses.append([-var(row, col, val), -var(i, col, val)])

    # Clauses for column constraints
    # for row in range(1, size + 1):
    #     for val in range(1, size + 1):
    for row, val in product(range(1, size + 1), repeat=2):
        for col in range(1, size):
            for i in range(col + 1, size + 1):
                clauses.append([-var(row, col, val), -var(row, i, val)])

    # # Clauses for 3x3 constraints for box grid
    # for val in range(1, size + 1):
    #     for x_axis in range(0, 3):
    #         for y_axis in range(0, 3):
    #             for row in range(1, 4):
    #                 for col in range(1, 4):
    #                     #Base Clauses
    #                     for i in range(col + 1, 4):
    #                         a = x_axis * 3 + row
    #                         b = y_axis * 3 + col
    #                         c = y_axis * 3 + i
    #                         clauses.append([-var(a, b, val), -var(a, c, val)])
    #                     for i in range(row + 1, 4):
    #                         for j in range(1, 4):
    #                             a = x_axis * 3 + row
    #                             b = y_axis * 3 + col
    #                             c = x_axis * 3 + i
    #                             d = y_axis * 3 + j
    #                             clauses.append([-var(a, b, val), -var(c, d, val)])

    # Every 3x3 box contains every number:
    for row, col in product([1, 4, 7], repeat=2):
        clauses = restrict([(row + x % 3, col + x // 3) for x in range(9)], clauses)


    return clauses, variables, size, matrix
    # return clauses, variables, size


def count_number_solutions(board, verbose=False):
    count = 0

    # TODO

    print(f'Number of solutions: {count}')


def find_one_solution(board, verbose=False):
    clauses, variables, size, matrix = generate_theory(board, verbose)
    return solve_sat_problem(clauses, "theory.cnf", size, variables, verbose, matrix)


def solve_sat_problem(clauses, filename, size, variables, verbose, matrix):
    save_dimacs_cnf(variables, clauses, filename, verbose)
    result, sat_assignment = solve(filename, verbose)
    if result != "SAT":
        if verbose:
            print("The given board is not solvable")
        return None
    solution = compute_solution(sat_assignment, variables, size, matrix)
    if verbose:
        print_solution(solution)
    return sat_assignment


class Board(object):
    """ A Sudoku board of size 9x9, possibly with some pre-filled values. """
    def __init__(self, string):
        """ Create a Board object from a single-string representation with 81 chars in the .[1-9]
         range, where a char '.' means that the position is empty, and a digit in [1-9] means that
         the position is pre-filled with that value. """
        size = math.sqrt(len(string))
        if not size.is_integer():
            raise RuntimeError(f'The specified board has length {len(string)} and does not seem to be square')
        self.data = [0 if x == '.' else int(x) for x in string]
        self.size_ = int(size)

    def size(self):
        """ Return the size of the board, e.g. 9 if the board is a 9x9 board. """
        return self.size_

    def value(self, x, y):
        """ Return the number at row x and column y, or a zero if no number is initially assigned to
         that position. """
        return self.data[x*self.size_ + y]

    def all_coordinates(self):
        """ Return all possible coordinates in the board. """
        return ((x, y) for x, y in itertools.product(range(self.size_), repeat=2))

    def print(self):
        """ Print the board in "matrix" form. """
        assert self.size_ == 9
        for i in range(self.size_):
            base = i * self.size_
            row = self.data[base:base + 3] + ['|'] + self.data[base + 3:base + 6] + ['|'] + self.data[base + 6:base + 9]
            print(" ".join(map(str, row)))
            if (i + 1) % 3 == 0:
                print("")  # Just an empty line


def main(argv):
    args = parse_arguments(argv)
    board = Board(args.board)

    if args.count:
        count_number_solutions(board, verbose=False)
    else:
        find_one_solution(board, verbose=not args.quiet)


if __name__ == "__main__":
    main(sys.argv[1:])
