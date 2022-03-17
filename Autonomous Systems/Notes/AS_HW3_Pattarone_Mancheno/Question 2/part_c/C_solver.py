from sokoban import *
import glob, re, time
import numpy as np

levels = range(1, 51)
levels_solved = []

#Optimality
planner = "seq-opt-lmcut"

#Satisficing
# planner = "lama-first"

cost = []
start_time = time.time()


for level in levels:
    filename = "benchmarks/sasquatch/level%s.sok" % (level)
    print("Information for \t Level %s" % (level))
    print(filename)


    with open(filename, 'r') as file:
        board = SokobanGame(file.read().rstrip('\n'))
        write_instance(board, f"output_{level}.pddl", f"test_{level}")
    file.close()

    planner_path = "/Users/mariafernandamancheno/Desktop/downward/fast-downward.py --overall-time-limit 180 --plan-file sas_plan1 --alias " + planner + " /Users/mariafernandamancheno/Desktop/AS_hw3/sokoban-domain.pddl /Users/mariafernandamancheno/Desktop/AS_hw3/output_" + str(level) + ".pddl"
    print(planner_path)
    os.system(planner_path)


    file_numb = []
    total_files = glob.glob("./sas_plan*")
    print(total_files)
    for single_file in total_files:
        file_numb.append(int(re.findall(r'\d+', single_file)[0]))

    if not file_numb:
        levels_solved.append(0)
        cost.append("inf")
    else:
        f_name = 'sas_plan%s' %(np.max(file_numb))
        with open(f_name, "r") as f:
            lines = f.read().split("\n")
        for line in lines:
            if "cost" in line:
                cost.append(line[2:-12])
        levels_solved.append(1)
        f.close()

end_time = time.time() - start_time

writeup = "Solver: " + planner + "\n\n"
writeup += "Solved %s out of %s\n" %(np.sum(levels_solved), len(levels_solved))
writeup += "Process time: %s s\n\n" %(round(end_time,2))
for level in levels:
    writeup += "Level %s:" %(level)
    if (levels_solved[level-1]):
        writeup += " SOLVED"
        writeup += " - " + cost[level-1] + "\n"


f = open('levelsopt.txt', 'w')
#  = open('levelssatis.txt', 'w')
f.write(writeup)
f.close()
