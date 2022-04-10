import requests
import pandas as pd
from datetime import datetime
import json
import re


# we use this function to convert responses to dataframes
def df_from_response(res):
    # initialize temp dataframe for batch of data in response
    df = pd.DataFrame()

    # loop through each post pulled from res and append to df
    for post in res.json()['data']['children']:
        df = df.append({
            'subreddit': post['data']['subreddit'],
            'title': post['data']['title'],
            'selftext': post['data']['selftext'],
            'upvote_ratio': post['data']['upvote_ratio'],
            'ups': post['data']['ups'],
            'downs': post['data']['downs'],
            'score': post['data']['score'],
            'link_flair_css_class': post['data']['link_flair_css_class'],
            'created_utc': datetime.fromtimestamp(post['data']['created_utc']).strftime('%Y-%m-%dT%H:%M:%SZ'),
            'id': post['data']['id'],
            'kind': post['kind']
        }, ignore_index=True)

    return df




if __name__ == '__main__':

    # # note that CLIENT_ID refers to 'personal use script' and SECRET_TOKEN to 'token'
    # auth = requests.auth.HTTPBasicAuth('bW2QiOdEYqPD8Qx3lNh1VA', 'BdCoRoS1J5HFwKh6itBro4COSsfYIA')
    # # here we pass our login method (password), username, and password
    # data1 = {'grant_type': 'password',
    #         'username': 'dvrk_dvys',
    #         'password': 'Kelsi123'}
    #
    # # setup our header info, which gives reddit a brief description of our app
    # headers = {'User-Agent': 'MyBot/0.0.1'}
    #
    # # send our request for an OAuth token
    # res = requests.post('https://www.reddit.com/api/v1/access_token',
    #                     auth=auth, data=data1, headers=headers)
    #
    # # convert response to JSON and pull access_token value
    # TOKEN = res.json()['access_token']
    # # print(TOKEN)
    # # TOKEN = '1040596524821-gAPVr5bHOBiNVkCtlmYxAM7ZnFIxiw'
    # # add authorization to our headers dictionary
    # headers = {**headers, **{'Authorization': f"bearer {TOKEN}"}}
    #
    # # while the token is valid (~2 hours) we just add headers=headers to our requests
    # requests.get('https://oauth.reddit.com/api/v1/me', headers=headers)
    #
    # res = requests.get("https://oauth.reddit.com/r/python/hot",
    #                    headers=headers)
    #
    # print(res.json())  # let's see what we get
    # print()
    #
    # data = pd.DataFrame()  # initialize dataframe
    # params = {'limit': 100}
    #
    # # # loop through each post retrieved from GET request
    # # for post in res.json()['data']['children']:
    # #     # append relevant data to dataframe
    # #     df = df.append({
    # #         'subreddit': post['data']['subreddit'],
    # #         'title': post['data']['title'],
    # #         'selftext': post['data']['selftext'],
    # #         'upvote_ratio': post['data']['upvote_ratio'],
    # #         'ups': post['data']['ups'],
    # #         'downs': post['data']['downs'],
    # #         'score': post['data']['score']
    # #     }, ignore_index=True)
    #
    # # params = {'limit': 100}
    # with open('reddit_data_ukraine_test.jsonl', 'a') as f:
    #     # loop through 10 times (returning 1K posts)
    #     for i in range(3):
    #         # make request
    #         res = requests.get("https://oauth.reddit.com/r/ukraine/?q=ucraine%20omicron%20russia%20%20china%20usa%20ukraine%20oil%20subvariant%20sanction%20NATO%20EU%Putin%20Zelensky",
    #                            headers=headers,
    #                            params=params)
    #
    #         pre = json.loads(res.content)
    #         # get dataframe from response
    #         new_df = df_from_response(res)
    #         for line in pre['data']['children']:
    #             f.write(line['data']['selftext'] + "\n")
    #
    #         # take the final row (oldest entry)
    #         row = new_df.iloc[len(new_df) - 1]
    #         # create fullname
    #         fullname = row['kind'] + '_' + row['id']
    #         # add/update fullname in params
    #         params['after'] = fullname
    #
    #         # append new_df to data
    #         data = data.append(new_df, ignore_index=True)
    #


    cleaned_tweets = []
    regex_pattern = re.compile(pattern="["
                                       u"\U0001F600-\U0001F64F"  # emoticons
                                       u"\U0001F300-\U0001F5FF"  # symbols & pictographs
                                       u"\U0001F680-\U0001F6FF"  # transport & map symbols
                                       u"\U0001F1E0-\U0001F1FF"  # flags (iOS)
                                       "]+", flags=re.UNICODE)

    pattern = re.compile(r'(https?://)?(www\.)?(\w+\.)?(\w+)(\.\w+)(/.+)?')
    re_list = ['@[A-Za-z0–9_]+', '#']
    combined_re = re.compile('|'.join(re_list))
    # for clean_prep in twitter_stream.listener.extended_text:
    with open('./data/reddit_data_ukraine_test.jsonl') as f:
        line_prep = f.read().splitlines()
    clean_prep = []
    for line in line_prep:
        if line == '':
           continue
        if len(line) < 15:
            continue
        clean_prep.append(line)
        # try:
        #     if json.loads(line)['is_quote_status'] == True:
        #         clean_prep.append(json.loads(line)['quoted_status']['extended_tweet']['full_text'])
        #     else:
        #         clean_prep.append(json.loads(line)['retweeted_status']['extended_tweet']['full_text'])
        # except:
        #     try:
        #         clean_prep.append(json.loads(line)['text'])
        #     except:
        #         continue
    with open('clean__' + 'reddit_data_ukraine_test.txt', 'a') as f:
        for cp in clean_prep:
            clean = re.sub(regex_pattern, '', cp)
            # replaces pattern with ''
            clean_tweets_1 = re.sub(pattern, '', clean)
            clean_tweets_2 = re.sub(combined_re, '', clean_tweets_1)
            clean_tweets_3 = re.sub('\n', '', clean_tweets_2)
            clean_tweets_4 = re.sub('\'', '', clean_tweets_3)
            cleaned_tweets.append(clean_tweets_4)
            f.write(str(clean_tweets_4) + '\n')

    clean_strings = pd.Series(cleaned_tweets).str.cat(sep=' ')
    print()





    # with open('reddit_data', 'a') as f:  # You can also print your tweets here
    #     try:
    #         # f.write(data)  # This will store the whole JSON data in the file, you can perform some JSON filters
    #         reddit_text = json.loads(data)['retweeted_status']['extended_tweet']['full_text']
    #         f.write(reddit_text + "\n")
    #         # twitter_text = json.loads(data)['text']
    #         # twitter_text = json.loads(data)['retweeted_status']['extended_tweet']['full_text']
    #
    #     except BaseException as e:
    #         print("Error on_data: %s" % str(e))
    #

