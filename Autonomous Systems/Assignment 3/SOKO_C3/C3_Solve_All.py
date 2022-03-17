import os
%pip install --user pandas
from cffi.setuptools_ext import execfile
import subprocess

# from sokoban import main
import sys

# directory = 'files'

# iterate over files in
# that directory
# for filename in os.listdir(directory):
#     f = os.path.join(directory, filename)
#     # checking if it is a file
#     if os.path.isfile(f):
#         print(f)

def docker_plan():
    # directory = '/SOKO_C3/'
    directory = '../../mnt/mydata/'
    for num in range(1, 51):
        filename = 'level' + str(num) + '.sokproblem.pddl'
        f = os.path.join(directory, filename)
        if os.path.isfile(os.getcwd() +  f) == True:
            params = ['../../mnt/mydata/domain.pddl', '../../mnt/mydata/level' + str(num) + '.sokproblem.pddl', './out_soko_m > ./log-fd-fdss']
            # execfile(open(os.getcwd() + directory + 'plan-fd-fdss').name, glob=None)
            # execfile(open(os.getcwd() + directory + "C3_Solve_All.py").name, glob=None)
            s = subprocess.call(["Python", open(os.getcwd() + directory + "C3_Solve_All.py").name] + params)
            print(filename)
            print(s)




if __name__ == '__main__':
    # directory = '/Users/jordanharris/PythonProject/upf_new/Autonomous Systems/Assignment 3/benchmarks/sasquatch'
    # for filename in os.listdir(directory):
    #     f = os.path.join(directory, filename)
    #     if os.path.isfile('/Users/jordanharris/PythonProject/upf_new/Autonomous Systems/Assignment 3/' + filename + 'problem.pddl') == False:
    #     # if os.path.isfile(f):
    #         print(f)
    #         prob_x = main(['-i', f])
    #         print()
    # directory = '/SOKO_C3/'
    # # directory = '../../mnt/mydata/'
    # for num in range(1, 51):
    #     filename = 'level' + str(num) + '.sokproblem.pddl'
    #     f = os.path.join(directory, filename)
    #     if os.path.isfile(os.getcwd() +  f) == True:
    #         sys.argv = ['../../mnt/mydata/domain.pddl', '../../mnt/mydata/level' + str(num) + '.sokproblem.pddl', './out_soko_m > ./log-fd-fdss']
    #         execfile(open(os.getcwd() + directory + 'plan-fd-fdss').name, glob=None)
    #         # execfile(open(os.getcwd() + directory + "C3_Solve_All.py").name, glob=None)
    #         yield 'Hello'
    #         print()
            # ../../ mnt/mydata/SOKO_C3/C3_Solve_All.py
# ./plan-fd-fdss ../../mnt/mydata/domain.pddl ../../mnt/mydata/level1.sokproblem.pddl ./out_soko_m > ./log-fd-fdss



    docker_plan()
