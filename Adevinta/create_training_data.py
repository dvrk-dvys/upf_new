from datetime import datetime, date, time, timedelta
import os
import json
import random




human_events = [
'ad insertion confirmed',
'ad phone number called',
'ad saved',
'ad unsaved',
'listing saved',
'listing unsaved',
'delivery requested',
'delivery accepted',
'delivery rejected',
# 'bulk conversation delete',
'report user',
# 'block user',
# 'unblock user',
'send rating',
'send message',
'report user'
]


def get_sample(path):
    # raw_bot_data[(environment_id, sessionid)] = [event_id, published, eventname, useragent, isBot, confidence]
    # human_confirmed[(environment_id, sessionid)] = [eventname, published]
    a_file = open(path, "r")
    list_of_lines = a_file.readlines()
    a_file.close()

    bot_data = {}
    orig_data = []
    columns = []
    count = 0
    for each in list_of_lines:
        splits = each.split(',')
        if count == 0:
            count += 1
            columns = columns + splits
            break
    index = 0
    for every in list_of_lines:
        if index == 0 or every == '\n':
            index += 1
            continue
        splits_prep = every.split(',')
        splits = []
        for each in splits_prep:
            clean = each.strip('"').strip('\n').strip('"')
            try:
                clean = clean(splits)
            except:
                print('Cleaning error')
            splits.append(clean)
        orig_data.append(splits)

        if (splits[5], splits[4]) not in bot_data.keys():
            try:
                dt = datetime.fromisoformat(splits[2])
            except:
                print('Datetime format error')
            dt = datetime.fromisoformat(splits[2])
            bot_data[(splits[5], splits[4])] = [[splits[11], dt, splits[10], splits[8], json.loads(splits[0].lower()), 'Null']]
            continue
        else:
            dt = datetime.fromisoformat(splits[2])
            bot_data[(splits[5], splits[4])].append([splits[11], dt, splits[10], splits[8], json.loads(splits[0].lower()), 'Null'])
            continue

    # # RECORD SESSIONS W/ HUMAN CONFIRMED EVENTS
    human_confirmed = {}
    for human in bot_data:
        for x in bot_data[human]:
            if (x[2].lower() in human_events) and (x[4] == False):
                if (human) in human_confirmed.keys():
                    human_confirmed[(human)].append(x)
                else:
                    human_confirmed[(human)] = x

    # # REMOVE SESSIONS W/ HUMAN CONFIRMED EVENTS
    # for clean in raw_bot_data.copy():
    #     for x in raw_bot_data[clean]:
    #         if x[2].lower() in human_events:
    #             raw_bot_data.pop(clean, None)

    return bot_data, human_confirmed, orig_data

def get_sample_viewport():
    #raw_vp_data[(environment_id, event_id)] = [screenSize, viwportSize, device_type]

    my_file = "data/viewports.csv"
    a_file = open(my_file, "r")
    list_of_lines = a_file.readlines()
    a_file.close()

    splits = None
    raw_vp_data = {}
    columns = []
    count = 0
    time = []
    for each in list_of_lines:
        splits = each.split(',')
        if count == 0:
            count += 1
            for each in splits:
                columns.append (each.strip ('"').strip ('\n').strip ('"'))
            break
    index = 0
    for every in list_of_lines:
        if index == 0 or every == '\n':
            index += 1
            continue

        splits_prep = every.split(',')
        splits = []

        for each in splits_prep:
            splits.append(each.strip('"').strip('\n').strip('"'))
        if len(splits) < 10:
            continue
        if (splits[0], splits[1]) not in raw_vp_data.keys():
            time.append(datetime.fromisoformat (splits [10]).hour)
            raw_vp_data[(splits[0], splits[1].lower())] = [(splits[8], splits[9], splits[7])]
            continue
        else:
            time.append(datetime.fromisoformat (splits [10]).hour)
            raw_vp_data[(splits[0], splits[1].lower())].append((splits[8], splits[9], splits[7]))
            continue
    time = sorted(set(time))
    return raw_vp_data, time


def average(data):
    # Below avg yellow, below mode light red, below 1 red
    new_data = {}
    avg_prep = {}
    # avg_prep[(environment_id, sessionid)] = [event_id_start, event_id_end, diff]
    avg = {}
    t1 = timedelta(minutes=15)
    for each in data:
        for every in data[each]:
            if (data[each].index(every) + 1) == len(data[each]):
                end = every + [datetime.fromisoformat ('2021-12-20 00:00:00+00:00') - datetime.fromisoformat ('2021-12-20 00:00:00+00:00')]
                if each not in new_data.keys():
                    new_data[each] = [end]
                else:
                    new_data[each].append(end)
                continue
            diff = data[each][data[each].index(every) + 1][1] - every[1]
            if each not in avg_prep.keys():
                avg_prep[every[2], data[each][data[each].index(every) + 1][2]] = [diff]
            else:
                avg_prep[each].append(diff)

            add_diff = every + [diff]
            if each not in new_data.keys():
                new_data[each] = [add_diff]
            else:
                new_data[each].append(add_diff)

    for each in avg_prep:
        avg_prep[each] = list(filter(lambda a: a < t1, avg_prep[each]))
        if len(avg_prep[each]) > 0:
            average_timedelta = sum(avg_prep[each], timedelta()) / len(avg_prep[each])
            # (avg, mode)
            avg[each] = [average_timedelta, (max(set(avg_prep[each]), key=avg_prep[each].count))]
    return avg, new_data


def average_bot(data):
    # Below avg yellow, below mode light red, below 1 red
    new_data = {}
    avg_prep = {}
    # avg_prep[(environment_id, sessionid)] = [event_id_start, event_id_end, diff]
    avg = {}
    t1 = timedelta(minutes=15)
    for each in data.copy():
        for every in data[each].copy():
            if (data[each].index(every) + 1) == len(data[each]):
                end = every + [datetime.fromisoformat ('2021-12-20 00:00:00+00:00') - datetime.fromisoformat ('2021-12-20 00:00:00+00:00')]
                if each not in new_data.keys():
                    new_data[each] = [end]
                else:
                    new_data[each].append(end)
                continue
            diff = data[each][data[each].index(every) + 1][1] - every[1]
            if each not in avg_prep.keys():
                avg_prep[every[2], data[each][data[each].index(every) + 1][2]] = [diff]
            else:
                avg_prep[each].append(diff)
            add_diff = every + [diff]
            if each not in new_data.keys():
                new_data[each] = [add_diff]
            else:
                new_data[each].append(add_diff)

    for each in avg_prep:
        # filter time deltas above 15 mins and ???????less than 1 sec
        avg_prep[each] = list(filter(lambda a: a < t1, avg_prep[each]))
        if len(avg_prep[each]) > 0:
            average_timedelta = sum(avg_prep[each], timedelta()) / len(avg_prep[each])
            # (avg, mode)
            avg[each] = [average_timedelta, (max(set(avg_prep[each]), key=avg_prep[each].count))]
    return avg, new_data



def invalid_session(data):
    # below 1 RED???
    t = timedelta(seconds=1)
    too_fast = {}
    tf_data = {}
    hum = False
    for each in data:
        count = 0
        for every in data[each]:
            tf_data[(each[0], each[1], every[0])] = every[6]
            if every[2].lower() in human_events:
                hum = True
            elif (every[6] <= t) and hum == False:
                count += 1

        if count > 0:
            if each in too_fast.keys():
                too_fast[each] += count
            else:
                too_fast[each] = count


    return too_fast, tf_data


def detect_headless(data):
    #data = raw_vp_data[(environment_id, event_id)] = [(screenSize, viwportSize, device_type), diff]
    no_diff = 0
    mode_calc = []
    headless_confirm = {}
    # screenSize, viewportSize
    for each in data.copy():
        screensize = data[each][0][0].split('x')
        viewportsize = data[each][0][1].split('x')
        # diff of height
        diff = int(screensize[1]) - int(viewportsize[1])
        data[each].append(diff)
        mode_calc.append(diff)

        if diff == 0:
            headless_confirm[each] = data[each]
            no_diff += 1

    mode = (max(set(mode_calc), key=mode_calc.count))
    return headless_confirm, (no_diff/len(data)) * 100, mode

def clean(arr):
    clean_arr = []
    clean_arr_pre = []
    for x in arr:
        if '\n' in x:
            spc1 = x.strip('"')
            spc2 = spc1.strip('\n')
            spc3 = spc2.strip(';')
            clean_arr_pre.append(spc3)
        elif '"' in x:
            spc1 = x.strip('"')
            spc2 = spc1.strip('\n')
            spc3 = spc2.strip(';')
            clean_arr_pre.append(spc3)
        elif ';' in x:
            spc1 = x.strip('"')
            spc2 = spc1.strip('\n')
            spc3 = spc2.strip(';')
            clean_arr_pre.append(spc3)
        else:
            clean_arr_pre.append(x)

    for y in clean_arr_pre:
        spc1 = y.strip('"')
        spc2 = spc1.strip('\n')
        spc3 = spc2.strip(';')
        clean_arr.append(spc3)
    return clean_arr


def add_timedelta_viewport(raw_data,  diff, vp):
    new_lines = []
    diff_lines = []
    # for each_data in [lol_corpus]:
    for splits in raw_data:
        columns = []
        # splits = clean(splits)
        if splits[0] == 'deviceisbot':
            columns.append(splits)
            continue
        elif (splits[5], splits[4], splits[11]) in diff.keys():
            splits.append(str(diff[(splits[5], splits[4], splits[11])]))
            diff_lines.append(splits)
        elif (splits[5], splits[4]) in diff.keys():
            splits.append(str(diff[(splits[5], splits[4], splits[11])]))
            diff_lines.append(splits)

        if (splits [5], splits [11]) in vp.keys ():
            splits.append(vp[splits [5], splits [11]][0][1])
        else:
            splits.append('Null')


    return diff_lines



if __name__ == '__main__':
    # _________________________________________
    #   Load & Process Data
    # _________________________________________
    # path_viewports = "data/viewports.csv"
    path_notBot = '/Users/jordan.harris/PycharmProjects/Adevinta/data/Clean_isBot_False.csv'
    path_headless = "/Users/jordan.harris/PycharmProjects/Adevinta/data/headless_confirmed.csv"
    path_isBot = "/Users/jordan.harris/PycharmProjects/Adevinta/data/sample_bot.csv"

    prep_notBot, human_not_bot, orig_notBot = get_sample(path_notBot)
    avgs_notBot, notBot_diff = average(prep_notBot)

    prep_headless, human_headless, orig_headless = get_sample(path_headless)
    avgs_headless, headless_diff = average(prep_headless)

    prep_isBot, human_isBot, orig_isBot = get_sample(path_isBot)
    avgs_isBot, isBot_diff = average(prep_isBot)

    raw_vp_data, time = get_sample_viewport()

    # __________________________________________________________________
    #   Detect Headless , Invalid Session & Bot User Agents
    # __________________________________________________________________

    notBot_inval, diff_data_nb = invalid_session(notBot_diff)
    ALL_notBot = add_timedelta_viewport(orig_notBot, diff_data_nb, raw_vp_data)
    TRUE_notBot = []
    FALSE_notBot = []
    for each in ALL_notBot:


        if ((each[5], each[4])) in human_not_bot.keys():
             if 'gecko' not in each[8].lower():
                FALSE_notBot.append(each)
        elif (each [5], each [4]) in notBot_inval.keys ():
            TRUE_notBot.append (each)
        else:
            if 'gecko' not in each [8].lower ():
                FALSE_notBot.append (each)

    isBot_inval, diff_data_isb = invalid_session(isBot_diff)
    TRUE_isBot = add_timedelta_viewport(orig_isBot, diff_data_isb, raw_vp_data)

    TRUE_headless = []
    headless_inval, diff_data_h = invalid_session(headless_diff)
    headless_1 = add_timedelta_viewport(orig_headless, diff_data_h, raw_vp_data)
    for every in headless_1:
        if every[13] != 'Null':
            TRUE_headless.append(every)


    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    bot_positive_data = TRUE_notBot + TRUE_isBot + TRUE_headless
    bot_negative_data = FALSE_notBot
    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    print()



    # # ______Orig____________________________________________________________
    #
    # columns = ['deviceisbot,screensize,published,published_dt,sessionid,environmentid,type,devicetype,useragent,objecttype,eventname,event_id,timedelta,viewportsize\n']
    #
    # if os.path.exists('/Users/jordan.harris/PycharmProjects/Adevinta/data/training_data/bot_negative.csv'):
    #     # os.remove('/Users/jordan.harris/PycharmProjects/Adevinta/data/not_bot.csv')
    #     print()
    # else:
    #     print("The file does not exist")
    # train_file = open('data/training_data_balance/train_bot_negative.csv', 'w')
    # train_file.writelines(columns)
    # test_file = open ('data/training_data_balance/test_bot_negative.csv', 'w')
    # test_file.writelines(columns)
    #
    #
    # # random.shuffle(l)
    #
    # test_neg = random.sample(bot_negative_data, 392)
    # train_neg = []
    # for line in bot_negative_data:
    #     if line not in test_neg:
    #         train_neg.append(line)
    #
    #
    # for x in test_neg:
    #     csv = ",".join(x)
    #     test_file.writelines(csv + '\n')
    # test_file.close()
    #
    # for y in train_neg:
    #     csv = ",".join(y)
    #     train_file.writelines(csv + '\n')
    # train_file.close()
    # __________________________________________________________________

    # ______Truc____________________________________________________________

    # trunc_columns = ['deviceisbot,screensize,published,type,devicetype,useragent,objecttype,eventname,timedelta,viewportsize\n']

    # if os.path.exists('/Users/jordan.harris/PycharmProjects/Adevinta/data/training_data/bot_negative.csv'):
    #     # os.remove('/Users/jordan.harris/PycharmProjects/Adevinta/data/not_bot.csv')
    #     print()
    # else:
    #     print("The file does not exist")
    # train_file_neg = open('data/training_data/trunc/train_trunc_negative.txt', 'w')
    # train_file_neg.writelines(trunc_columns)
    # test_file_neg = open ('data/training_data/trunc/test_trunc_negative.txt', 'w')
    # test_file_neg.writelines(trunc_columns)
    # train_file_pos = open('data/training_data/trunc/train_trunc_positive.txt', 'w')
    # train_file_pos.writelines(trunc_columns)
    # test_file_pos = open ('data/training_data/trunc/test_trunc_positive.txt', 'w')
    # test_file_pos.writelines(trunc_columns)
    #
    # # negative 29495 > 80% 23596 : 5899
    # # positive 21151 > 80% 21151 : 4231
    # test_neg_prep = random.sample(bot_negative_data, 5899)
    # test_neg = []
    # for line in test_neg_prep:
    #         line.pop(2)
    #         line.pop(2)
    #         line.pop(2)
    #         line.pop(2)
    #         line.pop(7)
    #         test_neg.append(line)
    #
    # train_neg = []
    # lim = 0
    # for line in bot_negative_data:
    #     if line not in test_neg_prep:
    #         # if lim != 5899:
    #         #     lim += 1
    #         line.pop(2)
    #         line.pop(2)
    #         line.pop(2)
    #         line.pop(2)
    #         line.pop(7)
    #         train_neg.append(line)
    #
    # test_pos_prep = random.sample(bot_positive_data, 4231)
    # test_pos = []
    # for line in test_pos_prep:
    #     line.pop (2)
    #     line.pop (2)
    #     line.pop (2)
    #     line.pop (2)
    #     line.pop (7)
    #     test_pos.append(line)
    #
    # train_pos = []
    # lim = 0
    # for line in bot_positive_data:
    #     if line not in test_pos_prep:
    #         # if lim != 4231:
    #         #     lim += 1
    #         line.pop(2)
    #         line.pop(2)
    #         line.pop(2)
    #         line.pop(2)
    #         line.pop(7)
    #         train_pos.append(line)
    #
    #
    #
    # for x in test_neg:
    #     csv = ",".join(x)
    #     # test_file_neg.writelines(csv + '\n')
    # test_file_neg.close()
    #
    # for x in test_pos:
    #     csv = ",".join(x)
    #     # test_file_pos.writelines(csv + '\n')
    # test_file_pos.close()
    #
    # for y in train_neg:
    #     csv = ",".join(y)
    #     # train_file_neg.writelines(csv + '\n')
    # train_file_neg.close()
    #
    # for y in train_pos:
    #     csv = ",".join(y)
    #     # train_file_pos.writelines(csv + '\n')
    # train_file_pos.close()
    # print()
    # __________________________________________________________________


    # __________________________________________________________________
    # train_file = open('data/training_data/train_bot_positive.csv', 'w')
    # train_file.writelines(columns)
    # test_file = open ('data/training_data/test_bot_positive.csv', 'w')
    # test_file.writelines(columns)
     # __________________________________________________________________
    # test_pos = random.sample(bot_negative_data, 392)
    # train_pos = []
    # for line in bot_negative_data:
    #     if line not in test_pos:
    #         train_pos.append(line)
    #
    # # __________________________________________________________________
    # train_file = open('data/training_data/train_trunc_positive.csv', 'w')
    # train_file.writelines(columns)
    # test_file = open ('data/training_data/test_trunc_positive.csv', 'w')
    # test_file.writelines(columns)
     # __________________________________________________________________



    # for x in test_pos:
    #     csv = ",".join(x)
    #     test_file.writelines(csv + '\n')
    # test_file.close()
    #
    # for y in train_pos:
    #     csv = ",".join(y)
    #     train_file.writelines(csv + '\n')
    # train_file.close()




