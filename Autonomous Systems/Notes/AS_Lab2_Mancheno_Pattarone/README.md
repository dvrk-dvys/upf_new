# Autonomous Systems - Lab 2 SAT Solvers

## Authors: [María Mancheno](mailto:maria.mancheno01@estudiant.upf.edu), [Natalia Pattarone](mailto:natalia.pattarone01@estudiant.upd.efu)

### Prerequisites

* Python 3.6 or above
* Pycosat library
```
pip3 install pycosat
```

## Usage

You can utilise the Sudoku solver in the following way:

```
$ python3 sudoku-solver.py {sudoku configuration} [--all]
```

Where:
- `{sudoku condiguration}` is a Sudoku board representation in string format, containing 81 literals representing the grid cell content ("." is used for empty cells): .......1.4.........2...........5.4.7..8...3....1.9....3..4..2...5.1........8.6... 
- `--all` argument indicates to aditionally look for all number of solutions for the Sudoku configuration provided. For the sake of time that takes to our naive implementation (required by the Assignment at hand) we set a threshold of 60 seconds that can easily be changed in the code, as well as included as an extra argument (not implemented).

```
$ python3 sudoku-solver.py .................1.....2.3......3.2...1.4......5....6..3......4.7..8...962...7... --all

Given Sudoku Grid
[[0, 0, 0, 0, 0, 0, 0, 0, 0],
 [0, 0, 0, 0, 0, 0, 0, 0, 1],
 [0, 0, 0, 0, 0, 2, 0, 3, 0],
 [0, 0, 0, 0, 0, 3, 0, 2, 0],
 [0, 0, 1, 0, 4, 0, 0, 0, 0],
 [0, 0, 5, 0, 0, 0, 0, 6, 0],
 [0, 3, 0, 0, 0, 0, 0, 0, 4],
 [0, 7, 0, 0, 8, 0, 0, 0, 9],
 [6, 2, 0, 0, 0, 7, 0, 0, 0]]
Looking for all possible solutions (up to 1 minute)...
Reached search time threshold!
======================================================================
Solution:  987631542632954871514872936987613425631542897425987163938652714574381629621947538
Number of Solutions:  995
[[9, 8, 7, 6, 3, 1, 5, 4, 2],
 [6, 3, 2, 9, 5, 4, 8, 7, 1],
 [5, 1, 4, 8, 7, 2, 9, 3, 6],
 [9, 8, 7, 6, 1, 3, 4, 2, 5],
 [6, 3, 1, 5, 4, 2, 8, 9, 7],
 [4, 2, 5, 9, 8, 7, 1, 6, 3],
 [9, 3, 8, 6, 5, 2, 7, 1, 4],
 [5, 7, 4, 3, 8, 1, 6, 2, 9],
 [6, 2, 1, 9, 4, 7, 5, 3, 8]]

```