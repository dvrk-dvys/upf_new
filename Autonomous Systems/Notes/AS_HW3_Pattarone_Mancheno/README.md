# Autonomous Systems - Lab 3 Planning

## Authors: [María Mancheno](mailto:maria.mancheno01@estudiant.upf.edu), [Natalia Pattarone](mailto:natalia.pattarone01@estudiant.upd.efu)


## Question C2.b

### Generating Instance Files
You can utilise the Sokoban `sokoban.py` file to automatically generate the instance files in the following way:

```
$./sokoban.py -i benchmarks/sasquatch/(level).sok
```

## Minisat Solver
### Prerequisites

* Python 3.6 or above
* Linux OS
* Provide execution permissions for the minisat SAT Solver
```
chmod +x sokoban/solver/minisat/minisat
```

## Usage

You can utilize the Sokoban `instance.pddl` generation in the following way. Make sure you are position inside sokoban folder:

====== TO BE COMPLETED ======

You can utilize the Sokoban SAT solver in the following way. Make sure you are position inside sokoban/solver folder:

```
$ python3 solver.py {map file}
```

Where:
- `{map file}` is a Sokoban map representation in string format like the following:

``` 
######
#   .#
#@$  #
#    #
######
``` 

```
$ python3 solver.py level0

Creating CNF file ...
Creating DIMACS file ...
Solving ...
DONE!

Solution found, the actions are:
push(box1,2_1,2_2,2_3,1)
push(box1,2_2,2_3,2_4,2)
move(2_3,3_3,3)
move(3_3,3_4,4)
push_t(box1,3_4,2_4,1_4,5)

```
## Question C2.c

### Using Fast Downward to solve all the levels
You can utilize the file `C_solver.py` file to solve all the levels using C_solver.py. The planner path contains the path for the local installation of the fast downward, two input files are needed (domain and instance files) and it can be used with the following command:

```
./fast-downward.py --overall-time-limit 60 \
--alias seq-sat-lama-2011 \
--plan-file myplan.txt \
sokoban-domain.pddl output_(level).pddl
```
