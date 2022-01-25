from datetime import datetime, date, time, timedelta
import os
import json

# the most frequent time spent on any event transistion is between 4-7 seconds


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

bot_user_agents = [
"Mozilla/5.0 (Linux; Android 7.0; Moto G (4)) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4590.2 Mobile Safari/537.36 Chrome-Lighthouse",
"Mozilla/5.0 (Windows NT 6.1; WOW64; rv:63.0.247) Gecko/20100101 Firefox/63.0.247 Site24x7",
"Mozilla/5.0 (compatible; Cincraw/1.0; +http://cincrawdata.net/bot/)",
"Mozilla/5.0 (compatible; AhrefsBot/7.0; +http://ahrefs.com/robot/)",
"Mozilla/5.0 (Linux; Android 8.1.0; XBot_Senior) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.92 Mobile Safari/537.36",
"Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/93.0.4577.0 Safari/537.36 WordPress.com mShots",
"facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)",
"Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/534+ (KHTML, like Gecko) BingPreview/1.0b",
"Mozilla/5.0 (Linux; Android 6.0.1; Nexus 5X Build/MMB29P) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.93 Mobile Safari/537.36 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)",
"Mozilla/5.0 (Linux; Android 6.0.1; Nexus 5X Build/MMB29P) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.45 Mobile Safari/537.36 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)",
"AdsBot-Google (+http://www.google.com/adsbot.html)",
"Mozilla/5.0 (Linux; Android 7.0; Moto G (4)) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/98.0.4695.0 Mobile Safari/537.36 Chrome-Lighthouse",
"Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.110 Safari/537.36/VbOt0EJa-05",
"Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; Googlebot/2.1; +http://www.google.com/bot.html) Chrome/96.0.4664.93 Safari/537.36"
]


def get_sample(path):
    # raw_bot_data[(environment_id, sessionid)] = [event_id, published, eventname, useragent, isBot, confidence]
    # human_confirmed[(environment_id, sessionid)] = [eventname, published]
    my_file = "/Users/jordan.harris/PycharmProjects/Adevinta/data/Clean_isBot_False.csv"
    a_file = open(path, "r")
    list_of_lines = a_file.readlines()
    a_file.close()

    raw_bot_data = {}
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
            splits.append(clean)

        if (splits[5], splits[4]) not in raw_bot_data.keys():
            try:
                dt = datetime.fromisoformat (splits [2])
            except:
                print()
            dt = datetime.fromisoformat(splits[2])
            raw_bot_data[(splits[5], splits[4])] = [[splits[11], dt, splits[10], splits[8], json.loads(splits[0].lower()), None]]
            continue
        else:
            dt = datetime.fromisoformat(splits[2])
            raw_bot_data[(splits[5], splits[4])].append([splits[11], dt, splits[10], splits[8], json.loads(splits[0].lower()), None])
            continue

    # # RECORD SESSIONS W/ HUMAN CONFIRMED EVENTS
    human_confirmed = {}
    for human in raw_bot_data:
        for x in raw_bot_data[human]:
            if (x[2].lower() in human_events) and (x[4] == False):
                # if [(human, x[0])] in human_confirmed.keys():
                #     human_confirmed[(human, x[0])].append(x[2], x[1])
                # else:
                human_confirmed[(human, x[0])] = (x[2], x[1], x[3])

    # # REMOVE SESSIONS W/ HUMAN CONFIRMED EVENTS
    # for clean in raw_bot_data.copy():
    #     for x in raw_bot_data[clean]:
    #         if x[2].lower() in human_events:
    #             raw_bot_data.pop(clean, None)

    return raw_bot_data, human_confirmed

def get_sample_isbot():
    # currently, no session data for isBot=True. Therefore:
    #raw_bot_data[(environment_id)] = ['@id' *(event_id)* , published, eventname, useragent]
    my_file = "/Users/jordan.harris/PycharmProjects/Adevinta/data/sample_bot.csv"
    a_file = open(my_file, "r")
    list_of_lines = a_file.readlines()
    a_file.close()

    splits = None
    raw_bot_data = {}
    columns = []
    count = 0
    for each in list_of_lines:
        splits = each.split(',')
        if count == 0:
            count += 1
            for each in splits:
                clean = each.strip ('"').strip ('\n').strip ('"')
                columns.append(clean)
            continue
        clean = []
        for each in splits:
            pre = each.strip('"').strip('\n').strip('"')
            clean.append(pre)
        if splits[1] not in raw_bot_data.keys():
            dt = datetime.fromisoformat(splits[3])
            raw_bot_data[splits[1]] = [[splits[4], dt, splits[7], splits[11]]]
            continue
        else:
            dt = datetime.fromisoformat(splits[3])
            raw_bot_data[splits[1]].append([splits[4], dt, splits[7], splits[11]])
            continue
    return raw_bot_data

def get_sample_viewport():
    #raw_vp_data[(environment_id, event_id)] = [screenSize, viwportSize, device_type]

    my_file = "data/viewports.csv"
    # string_list = my_file.readlines()
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
    print()
    return raw_vp_data, time



def average(data):
    new_data = {}
    avg_prep = {}
    # avg_prep[(environment_id, sessionid)] = [event_id_start, event_id_end, diff]
    avg = {}
    t1 = timedelta(minutes=15)
    for each in data:
        for every in data[each]:
            if (data[each].index(every) + 1) == len(data[each]):
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


def invalid_session(data):
    t = timedelta(seconds=1)
    too_fast = {}
    hum = False
    for each in data:
        count = 0
        for every in data[each]:
            if every[2].lower() in human_events:
                hum = True
            elif (every[6] <= t) and hum == False:
                count += 1

        if count > 0:
            if each in too_fast.keys():
                too_fast[each] += count
            else:
                too_fast[each] = count

    return too_fast


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

def detect_bot_user_agent(raw_data, inval, headless):
    bot_agents = {}
    for r in raw_data:
        if r in inval.keys():
            if raw_data[r][0][3] not in bot_agents.keys():
                bot_agents[raw_data[r][0][3]] = 1
            else:
                bot_agents[raw_data[r][0][3]] += 1

        if r[0] in headless:
            if raw_data[r][0][3] not in bot_agents.keys():
                bot_agents[raw_data[r][0][3]] = 1
            else:
                bot_agents[raw_data[r][0][3]] += 1

    return bot_agents


def serialized_detection():
    print()



if __name__ == '__main__':
    # __________________________________________________________________
    #   Load & Process Data
    # __________________________________________________________________

    headless_path = "/Users/jordan.harris/PycharmProjects/Adevinta/data/headless_confirmed.csv"
    not_bot_path = "/Users/jordan.harris/PycharmProjects/Adevinta/data/Clean_isBot_False.csv"
    isbot_path = "/Users/jordan.harris/PycharmProjects/Adevinta/data/sample_bot.csv"

    notBot = open(not_bot_path, "r")
    raw_notBot = notBot.readlines()
    notBot.close()

    headless = open(headless_path, "r")
    orig_headless = headless.readlines()
    headless.close()

    isBot = open(isbot_path, "r")
    raw_isBot = isBot.readlines()
    isBot.close()

    headless_data, human_headless = get_sample(headless_path)
    raw_data, human_not_bot = get_sample(not_bot_path)
    raw_data_isbot, human_isbot = get_sample(isbot_path)
    raw_viewports, times_vp = get_sample_viewport()

    avgs_headless, headless_data_new = average(headless_data)
    avgs_notbot, notbot_data_new = average(raw_data)
    avgs_isbot, isbot_data_new = average(raw_data_isbot)

    # __________________________________________________________________
    #   Detect Headless , Invalid Session & Bot User Agents
    # __________________________________________________________________

    inval = invalid_session(notbot_data_new)
    inval_isbot = invalid_session(isbot_data_new)
    headless, perc_headless, mode_headless = detect_headless(raw_viewports)
    bot_agents = detect_bot_user_agent(notbot_data_new, inval, headless)

    human_agents = []
    for r in human_not_bot:
        for x in human_not_bot[r]:
            if human_not_bot[r][2] not in human_agents:
                human_agents.append(human_not_bot[r][2])

    # __________________________________________________________________
    #   Report
    # __________________________________________________________________

    # not_bot = len(data_new)
    total_count = len(raw_notBot) + len(raw_isBot)
    total_count_head = len(headless_data_new) + len(isbot_data_new)

    raw_viewports_keys = [raw_viewports.keys()]
    raw_viewports_env_id = []
    for key in raw_viewports:
        # (environment_id, event_id)
        raw_viewports_env_id.append(key[0])
    raw_viewports_env_id = set(raw_viewports_env_id)
    # #
    headless_keys = [headless.keys()]
    headless_env_id = []
    for key in headless:
        # (environment_id, event_id)
        headless_env_id.append(key[0])
    headless_env_id = set(headless_env_id)
    #
    not_bot_keys = [notbot_data_new.keys()]
    not_bot_env_id = []
    for key in notbot_data_new:
        # (environment_id, session_id)
        not_bot_env_id.append(key[0])
    not_bot_env_id = set(not_bot_env_id)
    #
    inval_keys = [inval.keys()]
    inval_env_id = []
    for key in inval:
        # (environment_id, session_id)
        inval_env_id.append(key[0])
    inval_env_id = set(inval_env_id)


    bot_intersection = raw_viewports_env_id & headless_env_id

    print("Percent of isBot=False events with headless characteristics", perc_headless)

    percent_inval = (len(inval)/len(notbot_data_new)) * 100
    #
    print("Percent of isBot=False events with irregular time frames", percent_inval)
    print("isBot=True", avgs_isbot)

    # __________________________________________________________________
    #   Notes
    # __________________________________________________________________


    # # https://sciencing.com/calculate-confidence-levels-2844.html
    # # https://www.genesys.com/article/set-bot-confidence-thresholds-with-confidence

    # headless_events = []
    # for key in avgs_headless:
    #     headless_events.append(key[0])
    #     headless_events.append(key[1])
    # headless_events = set(sorted(headless_events, key=str.lower))
    #
    # head_or_human = headless_events & set(human_events)
    # # # NONE!!!!

    # not_bot_events = []
    # for key in raw_data:
    #     not_bot_events.append(key[0])
    #     not_bot_events.append(key[1])
    # not_bot_events = set(sorted(not_bot_events, key=str.lower))

    # x = []
    # y = []
    # for each in headless:
    #     # x.append(each)
    #     x.append(each[0])
    #
    # times_not_bot = []
    # for every in data_new:
    #     for event in data_new[every]:
    #         # event_id = raw_data[every][raw_data[every].index(event)][0]
    #         # y.append((every[0], event_id))
    #
    #         for _ in data_new[every]:
    #             times_not_bot.append([_][0][1].hour)
    #             if [_][0][1].hour >= 17:
    #                 y.append(every[0])
    #         y.append(every[0])
    # times_not_bot = sorted(set(times_not_bot))
    # print()


    # # Would an environment_id from today be the associated with the same visitor tomorrow?
    # head_not_bot = set(x) & set(y)
    # if os.path.exists('/Users/jordan.harris/PycharmProjects/Adevinta/data/force_intersect.txt'):
    #     os.remove('/Users/jordan.harris/PycharmProjects/Adevinta/data/force_intersect.txt')
    # else:
    #     print("The file does not exist")
    # new_file = open('/Users/jordan.harris/PycharmProjects/Adevinta/data/force_intersect.txt', 'w')
    # for envi_id in head_not_bot:
    #     new_file.writelines("'" + envi_id + "',\n")
    # new_file.close()
    # print()



    # if os.path.exists('/Users/jordan.harris/PycharmProjects/Adevinta/data/isbot_intersect.txt'):
    #     os.remove('/Users/jordan.harris/PycharmProjects/Adevinta/data/isbot_intersect.txt')
    # else:
    #     print("The file does not exist")
    # new_file = open('/Users/jordan.harris/PycharmProjects/Adevinta/data/isbot_intersect.txt', 'w')
    #
    # for envi_id in isbot_data_new:
    #     new_file.writelines("'" + envi_id[0] + "',\n")
    # new_file.close()
    # print()

    #
