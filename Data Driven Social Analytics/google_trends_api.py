import pandas as pd
from pytrends.request import TrendReq
import operator
import matplotlib.pyplot as plt



if __name__ == '__main__':



    pytrend = TrendReq()

    keywords = ["nato, omicorn, ukraine, russia, poland"]
                # "war", "weapons", "support", "refugees", "usa", "Volodymyr Zelenskyy",
                # "Vladimir Putin", "Joe Biden", "Joe Byron", "China", "Xi Jinping",
                # "Andrzej Duda", "EU", "NATO", "Oil", "Gas", "Sanction", "Subvariant"]


    pytrend.build_payload(kw_list=keywords)
    df = pytrend.trending_searches()[0]
    # Interest by Region
    # df = pytrend.interest_by_region()
    interest_regions = []

    for each in df.T:
       if df.T[each].values != 0:
            interest_regions.append((each, df.T[each].values[0]))


    interest_regions.sort(key = operator.itemgetter(1), reverse = True)
    # print('\n')
    # print('----------------------------------------')
    # # print('Piers Morgan:')
    # print('\n')
    # print(*interest_regions, sep='\n')
    #
    # print('----------------------------------------')
    # print('\n')
    #
    #
    #
    # df.reset_index().plot(x='geoName', y='Piers Morgan', figsize=(120, 10), kind='bar')
    # # plt.show()
    # plt.clf()
    # plt.cla()
    # plt.close()



    # Get Google Hot Trends data
    df = pytrend.trending_searches(pn='united_states')
    df.head()

    trending = []
    for each in df.values:
        trending.append(each[0])

    print('\n')
    print('----------------------------------------')
    print('Trending {United States}:')
    print('\n')
    print(*trending, sep='\n')
    print('----------------------------------------')
    print('\n')


    # Get Google Top Charts
    df = pytrend.top_charts(2022, hl='en-US', tz=300, geo='GLOBAL')
    df.head()

    global_chart = []
    for each in df.values:
        global_chart.append(each[0])

    print('\n')
    print('----------------------------------------')
    print('Global Chart:')
    print('\n')
    print(*global_chart, sep='\n')
    print('----------------------------------------')
    print('\n')