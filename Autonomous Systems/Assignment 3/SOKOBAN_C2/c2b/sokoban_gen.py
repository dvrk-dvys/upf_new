from py2pddl import Domain, create_type
from py2pddl import predicate, action, goal, init


class Sokoban_genDomain(Domain):
    def __init__(self, board):
        self.board = board

    Object = create_type("Object")
    Thing = create_type("Thing", Object)
    Location = create_type("Location", Object)
    Direction = create_type("Direction", Object)
    Player = create_type("Player", Thing)
    Box = create_type("Box", Thing)

    @predicate(Thing, Location)
    def at(self, t, l):
        """Complete the method signature and specify
        the respective types in the decorator"""
        pass

    @predicate(Box)
    def at_goal(self, b):
        """Complete the method signature and specify
        the respective types in the decorator"""
        pass


    @predicate(Location)
    def is_goal(self, l):
        """Complete the method signature and specify
        the respective types in the decorator"""
        pass

    @predicate(Location)
    def is_nongoal(self, l):
        """Complete the method signature and specify
        the respective types in the decorator"""
        pass


    @predicate(Location, Location, Direction)
    def move_dir(self, frm, to, dir):
        """Complete the method signature and specify
        the respective types in the decorator"""
        pass


    @predicate(Location)
    def clear(self, l):
        """Complete the method signature and specify
        the respective types in the decorator"""
        pass


    @predicate(Thing, Location)
    def teleported(self, t, l):
        """Complete the method signature and specify
        the respective types in the decorator"""
        pass

    @action(Player, Location, Location, Direction)
    def move(self, p, frm, to, dir):
        precond: list = [self.at(p, frm), self.clear(to), self.move_dir(frm, to, dir)]
        effect: list = [~self.at(p, frm), ~self.clear(to), self.at(p, to), self.clear(frm)]
        return precond, effect

    @action(Player, Location, Location, Direction)
    def teleport(self, p, frm, to, dir):
        precond: list = [self.at(p, frm), self.clear(to), self.move_dir(frm, to, dir),  ~self.teleported(p, to)]
        effect: list = [~self.at(p, frm), ~self.clear(to), self.at(p, to), self.clear(frm),  self.teleported(p, to)]
        return precond, effect

    @action(Player, Box, Location, Location, Location, Direction)
    def push_to_nongoal(self, p, b, ppos, frm, to, dir):
        precond: list = [self.at(p, ppos), self.at(b, frm), self.clear(to), self.move_dir(ppos, frm, dir), self.move_dir(frm, to, dir), self.is_nongoal(to)]
        effect: list = [~self.at(p, ppos), ~self.at(b, frm), ~self.clear(to), self.at(p, frm), self.at(b, to), self.clear(ppos), ~self.at_goal(b)]
        return precond, effect

    @action(Player, Box, Location, Location, Location, Direction)
    def push_to_goal(self, p, b, ppos, frm, to, dir):
        precond: list = [self.at(p, ppos), self.at(b, frm), self.clear(to), self.move_dir(ppos, frm, dir), self.move_dir(frm, to, dir), self.is_goal(to)]
        effect: list = [~self.at(p, ppos), ~self.at(b, frm), ~self.clear(to), self.at(p, frm), self.at(b, to), self.clear(ppos), self.at_goal(b)]
        return precond, effect


class Sokoban_genProblem(Sokoban_genDomain):
    def __init__(self,  board):
        super().__init__(board=board)
        prep = []
        for b in board.boxes:
            prep.append("box-" + str(b[0]) + str(b[1]))
        self.Box = Sokoban_genDomain.Box.create_objs(prep)

        compass = ['up', 'down', 'left', 'right', 'teleport']
        self.Direction = Sokoban_genDomain.Direction.create_objs(compass)

        prep = []
        for row in range(board.h):
            for col in range(board.w):
                prep.append("pos-" + str(row) + "-" + str(col))
        self.Location = Sokoban_genDomain.Location.create_objs(prep)
        self.Player = Sokoban_genDomain.Player.create_objs(["player-01"])


    @init
    def init(self) -> list:
        is_goal = []
        for g in self.board.goals:
            is_goal.append(self.is_goal(self.Location["pos-" + str(g[0]) + "-" + str(g[1])]))

        is_nongoal = []
        for row in range(self.board.h):
            for col in range(self.board.w):
                if (row, col) not in self.board.goals:
                    is_nongoal.append(self.is_nongoal(self.Location["pos-" + str(row) + "-" + str(col)]))

        at = []
        for b in self.board.boxes:
            at.append(
                self.at(self.Box["box-" + str(b[0]) + str(b[1])],
                              self.Location["pos-" + str(b[0]) + "-" + str(b[1])]))
        at.append(self.at(self.Player["player-01"], self.Location["pos-" + str(self.board.player[0]) + "-" + str(self.board.player[1])]))

        clear = []
        clear = []
        for rowc in range(self.board.h):
            for colc in range(self.board.w):
                if (rowc, colc) not in self.board.walls: #and (rowc, colc) != self.board.player:
                    clear.append(self.clear(self.Location["pos-" + str(rowc) + "-" + str(colc)]))

        move_dir = []
        for from_ in clear:
            for to_ in clear:
                # if from_ != to_:
                from_coord = from_.data.split("|")[-1:][0].split(' ')[-1:][0][:-1]
                to_coord = to_.data.split("|")[-1:][0].split(' ')[-1:][0][:-1]
                if (self.move_dir(self.Location[from_coord], self.Location[to_coord], self.Direction['teleport']) not in move_dir):
                    if str(from_coord) != str(to_coord):
                        move_dir.append(self.move_dir(self.Location[from_coord], self.Location[to_coord], self.Direction['teleport']))

        for dir in clear:
            coord = dir.data.split("|")[-1:][0].split(' ')[-1:][0][:-1].split("-")
            from_coord = dir.data.split("|")[-1:][0].split(' ')[-1:][0][:-1]

            pos_up = (int(coord[1]) + 1, int(coord[2]))
            pos_down = (int(coord[1]) - 1, int(coord[2]))
            pos_left = (int(coord[1]), int(coord[2]) - 1)
            pos_right = (int(coord[1]), int(coord[2]) + 1)

            if pos_up not in self.board.walls and pos_up[0] >= 0 and pos_up[1] >= 0 and pos_up[0] < self.board.h and pos_up[1] < self.board.w:
                if from_coord != pos_up:
                    up_coord = "pos-" + str(pos_up[0]) + "-" + str(pos_up[1])
                    move_dir.append(self.move_dir(self.Location[from_coord], self.Location[up_coord], self.Direction['up']))
            if pos_down not in self.board.walls and pos_down[0] >= 0 and pos_down[1] >= 0 and pos_down[0] < self.board.h and pos_down[1] < self.board.w:
                if from_coord != pos_down:
                    down_coord = "pos-" + str(pos_down[0]) + "-" + str(pos_down[1])
                    move_dir.append(self.move_dir(self.Location[from_coord], self.Location[down_coord], self.Direction['down']))
            if pos_left not in self.board.walls and pos_left[0] >= 0 and pos_left[1] >= 0 and pos_left[0] < self.board.h and pos_left[1] < self.board.w:
                if from_coord != pos_left:
                    left_coord = "pos-" + str(pos_left[0]) + "-" + str(pos_left[1])
                    move_dir.append(self.move_dir(self.Location[from_coord], self.Location[left_coord], self.Direction['left']))
            if pos_right not in self.board.walls and pos_right[0] >= 0 and pos_right[1] >= 0 and pos_right[0] < self.board.h and pos_right[1] < self.board.w:
                if from_coord != pos_right:
                    right_coord = "pos-" + str(pos_right[0]) + "-" + str(pos_right[1])
                    move_dir.append(self.move_dir(self.Location[from_coord], self.Location[right_coord], self.Direction['right']))
        return is_goal + is_nongoal + at + clear + move_dir

    @goal
    def goal(self) -> list:
        at_goal = []
        for b in self.Box:
            at_goal.append(self.at_goal(self.Box[b]))
        # self.Box = '\t'.join(self.Box)
        return at_goal


if __name__ == "__main__":
    # / Users / jordanharris / Library / Python / 3.8 / lib / python / site - packages / py2pddl / py2pddl.py

    # d = Sokoban_genDomain()
    # d.generate_domain_pddl()
    s = Sokoban_genProblem(Sokoban_genDomain)
    # print()
    # p.generate_problem_pddl()

    # print(p)


