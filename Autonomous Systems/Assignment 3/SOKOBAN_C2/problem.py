import json
import pandas as pd


class PDDLOperator(object):
    def __init__(self, name, pre, add_eff, del_eff, cost):
        self.name = '(' + name + ')'
        self.pre = set(pre)
        self.add_eff = set(add_eff)
        self.del_eff = set(del_eff)
        self.cost = cost

class PDDL(object):
    def __init__(self, dom_path, prob_path):
        self.types = []
        self.preds = []
        self.acts = []
        self.objs = []
        self.inits = []
        self.goals = []
        self.facts = []

        with open(dom_path, 'r') as dp:
            self.dom_load(dp)
        with open(prob_path, 'r') as pp:
            self.prob_load(pp)

    def dom_load(self, fin):
        # pd.DataFrame([x.split(';') for x in data.split('\n')])
        # df = pd.read_csv(fin, sep=":")
        df = {}
        concat = 0
        act = ''
        # data = fin.read().strip().split('\n')
        for line in fin.read().strip().split('\n'):
            if len(line.strip()) < 2:
                print()
                continue
            for x in line.split('\n'):
                if '-' in line and '?' not in line and 'action' not in line:
                    keys = x.strip().split('-')
                    if concat != 0:
                        new_df = {}
                        new_df[keys[-1].strip()] = keys[:-1][0].strip().split(' ')
                        df[concat].append(new_df)
                    else:
                        df[keys[-1].strip()] = keys[:-1][0].strip().split(' ')
                elif '?' in line:
                    keys = x.strip().replace('(', '').replace(')', '')
                    if act != '':
                        df[concat][-1][act].append(keys)
                        # act = 0
                    elif concat != 0:
                        new_df = {}
                        keys.split()
                        keys.split('?')[0]
                        new_df[keys.split('?')[0].strip()] = keys.split('?')[1:]
                        df[concat].append(new_df)
                    else:
                        df[keys[0].strip('(').strip()] = keys[1:]
                elif 'action' in line:
                    concat = line.strip().replace('(', '')
                    act = ''
                    if act == '':
                        df[concat] = []
                        break
                    else:
                        print()

                else:
                    if type(concat) == str and len(line.strip()) > 1:
                        if 'action' in concat:
                            if 'airplane' in concat:
                                print()
                            act = line.strip()
                            new_df = {}
                            new_df[act] = []
                            if ':' in line:
                                df[concat].append(new_df)
                            else:
                                df[concat] = new_df
                            break
                    keys = x.strip().split(' ')
                    if keys[1:] == []:
                        concat = keys[0].replace('(', '')
                        if len(concat) < 2:
                            concat = 0
                            continue
                    if ':predicates' == concat:
                        df[keys[0].replace('(', '')] = []
                        continue
                    df[keys[0].replace('(', '')] = keys[1:]


        print()
        # for line in data:
        #     if ':types' in line:
        #         for t in data[3:]:
        #             if ' )' in t:
        #                 end_t = data.index(t)
        #                 self.types = data[3:end_t]
        #     if ':predicates' in line:
        #         for p in data[end_t+1:]:
        #             if ' )' in p:
        #                 strt_t = end_t+2
        #                 end_p = data[strt_t:].index(p) + strt_t
        #                 self.preds = data[strt_t:end_p]
        #     if ':action' in line:
        #         for a in data[end_p + 1:]:
        #             # if 'action' in a:
        #             #     start_test =
        #             #     print()
        #             if ' )' in a:
        #                 test = data[end_p + 1:].index(a)
        #                 self.acts.append(data[end_p + 1:][:test].pop)
        #                 end_p += test
        #                 # break
        #             # self.acts.append(data[strt_a:end_a])
        # print()

    def prob_load(self, fin):
        # data = fin.read().strip().split('\n')
        for line in fin.read().strip().split('\n'):
            print()



        # for line in data:
        #     if ':objects' in line:
        #         strt_o = data.index(line)
        #         for o in data[strt_o:]:
        #             if ' )' in o:
        #                 end_o = data[strt_o:].index(o) + strt_o
        #                 self.objs = data[strt_o+1:end_o]
        #                 break
        #     elif ':init' in line:
        #         strt_i = data.index(line)
        #         for i in data[strt_i+1:]:
        #             if ' )' in i:
        #                 end_i = data[strt_i:].index(i) + strt_i
        #                 self.inits.append(data[strt_i+1:end_i])
        #     elif ':goal' in line:
        #         strt_g = data.index(line)
        #         self.goals = data[strt_g:]
        #
        #
        # for _ in self.acts:
        #     for pre in _:
        #         if 'precondition' in pre:
        #             for each in _[_.index(pre)+1:]:
        #                 if 'effect' in each :
        #                     break
        #                 concat = {}
        #                 x = each.split('(')[-1]
        #                 y = [a.replace(')', '') for a in x.split(' ')]
        #                 for find_param in y[1:]:
        #                     for every in self.objs:
        #                         for _p in _:
        #                             if (find_param + ' - ') in _p:
        #                                 param = _p.split(' ')[-1].replace(')', '')
        #                                 if param in every.lower():
        #                                     if len(y) == y.index(find_param) + 1:
        #                                         try:
        #                                             concat[find_param].append(every.split(' - ')[0].replace(' ', ''))
        #                                         except:
        #                                             concat[find_param] = [every.split(' - ')[0].replace(' ', '')]
        #                                         break
        #                                     else:
        #                                         concat['pred'] = y[0]
        #                                         try:
        #                                             concat[find_param].append(every.split(' - ')[0].replace(' ', ''))
        #                                         except:
        #                                             concat[find_param] = [every.split(' - ')[0].replace(' ', '')]
        #                                         break
        #                 cat = '(' + y[0] + ' '
        #                 permu = []
        #                 for key in y[1:]:
        #                     # k = key.replace('?', '')
        #                     for val in concat[key]:
        #                         if y.index(key)+1 != len(y):
        #                             permu.append(cat + val + ' ')
        #                         else:
        #                             for prefix in permu:
        #                                 self.facts.append(prefix + val + ')')
        #                         # self.facts.append(cat[:-1] + ")")
        #
        # print()

class StripsOperator(object):
    def __init__(self, name, pre, add_eff, del_eff, cost):
        self.name = '(' + name + ')'
        self.pre = set(pre)
        self.add_eff = set(add_eff)
        self.del_eff = set(del_eff)
        self.cost = cost


class Strips(object):
    def __init__(self, path):
        with open(path, 'r') as fin:
            self._load(fin)

    def _load(self, fin):
        data = fin.read().strip().split('\n')

        num_facts = int(data[0])
        self.facts = data[1:num_facts+1]

        data = data[num_facts+1:]
        init = [int(x) for x in data[0].split()]
        self.init = init[1:]

        data = data[1:]
        goal = [int(x) for x in data[0].split()]
        self.goal = goal[1:]

        data = data[1:]
        num_ops = int(data[0])

        self.operators = []
        ops = [data[x:x+5] for x in range(1, len(data), 5)]
        for name, pre, add_eff, del_eff, cost in ops:
            pre = [int(x) for x in pre.split()][1:]
            add_eff = [int(x) for x in add_eff.split()][1:]
            del_eff = [int(x) for x in del_eff.split()][1:]
            op = StripsOperator(name, pre, add_eff, del_eff, int(cost))
            self.operators += [op]
        print()


class FDRVar(object):
    def __init__(self, names):
        self.range = len(names)
        self.names = names


class FDRPartState(object):
    def __init__(self, pairs):
        self.facts = []
        for i in range(0, len(pairs), 2):
            self.facts += [(pairs[i], pairs[i+1])]


class FDROperator(object):
    def __init__(self, name, pre, eff, cost):
        self.name = name
        self.pre = pre
        self.eff = eff
        self.cost = cost


class FDR(object):
    def __init__(self, path):
        with open(path, 'r') as fin:
            self._load(fin)

    def _load(self, fin):
        data = fin.read().strip().split('\n')

        self.vars = []
        num_vars = int(data[0])
        data = data[1:]
        for i in range(num_vars):
            num_values = int(data[0])
            names = data[1:num_values+1]
            self.vars += [FDRVar(names)]
            data = data[num_values+1:]

        self.init = [int(x) for x in data[0].split()]
        self.goal = FDRPartState([int(x) for x in data[1].split()[1:]])

        num_ops = int(data[2])
        data = data[3:]

        self.operators = []
        ops = [data[x:x+4] for x in range(0, len(data), 4)]
        for name, pre, eff, cost in ops:
            pre = FDRPartState([int(x) for x in pre.split()[1:]])
            eff = FDRPartState([int(x) for x in eff.split()[1:]])
            cost = int(cost)
            self.operators += [FDROperator(name, pre, eff, cost)]
