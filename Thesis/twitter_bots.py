# Main Tokens
# consumer_key = '7cXG565ehcH9TO4XtgtjWiAF2'
# consumer_secret = 'J9qWmKfdiuTJxKwGvwDLASqSCMEwE1O85ta0QP8ARScnMAiTrR'
# access_token = '1351603554499387394-g2gyZg8hryr3QiqmRD1lnj5i16wAVV'
# access_token_secret = 'rZNyp3xngCUBK9rHlHmnD7Gu4OXRWRBUSHDPasBho8icL'
# bearer_token = 'AAAAAAAAAAAAAAAAAAAAAELZawEAAAAA6ItGxjfWQfyI3gSlZJtgfmBXQAo%3DkqWpeCvfK7q3OU6w6Rd0zEGpnKrDLUqS2dxJu2d2NjmMkifnWs'
# client_id = 'WlFtUXZhQnNrdkdDdzZVNDB2OFk6MTpjaQ'
# client_secret = 'arVmpRlANwEZUST55FcJsD8ZO0OhEOaM1Ng1VAku7-AgNcsQFY'

# email: rochelle_tunti@outlook.com
# password: S7ixKqK5Eg
# fullname: Rochelle Tunti
# username: RochelleTunti
# dob: 8/8/98


import re
import requests
import tweepy
import json
from tweepy import OAuthHandler
import twurl
from tweepy.streaming import Stream
import urllib.request, urllib.parse, urllib.error
import ssl

import pandas as pd
from wordcloud import WordCloud, ImageColorGenerator, STOPWORDS
import matplotlib.pyplot as plt

class MyListener(Stream):

    def __init__(self, consumer_key, consumer_secret, access_token, access_token_secret, api, max_tweets, json_tweets_file):
        super(tweepy.Stream, self).__init__()
        self.num_tweets = 0
        self.max_tweets = max_tweets
        self.api = api
        self.json_tweets_file = json_tweets_file
        self.consumer_key = consumer_key
        self.consumer_secret = consumer_secret
        self.access_token = access_token
        self.access_token_secret = access_token_secret


    def on_data(self, data):
        with open(self.json_tweets_file, 'a') as f: # You can also print your tweets here
            try:
                # f.write(data)  # This will store the whole JSON data in the file, you can perform some JSON filters
                twitter_text = json.loads(data)['retweeted_status']['extended_tweet']['full_text']
                f.write(twitter_text + "\n")
                # twitter_text = json.loads(data)['text']
                # twitter_text = json.loads(data)['retweeted_status']['extended_tweet']['full_text']

            except BaseException as e:
                print("Error on_data: %s" % str(e))
                return


            self.num_tweets += 1
            print(twitter_text.replace('\n', ' ').replace('\r', ' '))
            if self.num_tweets >= self.max_tweets:
                raise Exception("Limit Reached")
                    # return

    def on_error(self, status):
        print('Error :', status)
        return False

def user_timeline(user_name, user_id):
    TWITTER_URL = 'https://api.twitter.com/1.1/statuses/user_timeline.json'
    # TWITTER_URL = 'https://api.twitter.com/2/users/' + user_id + 'tweets.json'
    # TWITTER_URL = 'https://api.twitter.com/2/users/:id/mentions'

    # Ignore SSL certificate errors
    ctx = ssl.create_default_context()
    ctx.check_hostname = False
    ctx.verify_mode = ssl.CERT_NONE

    url = twurl.augment(TWITTER_URL,
                        {'screen_name': user_name, 'count': '2'})

    # url = twurl.augment(TWITTER_URL,
    #                     {"tweet.field": "attachments,author_id,created_at,entities,geo,id,in_reply_to_user_id,lang,possibly_sensitive,public_metrics,referenced_tweets,source,withheld",
    #                     "user.fields": "created_at,description,entities,id,location,name,profile_image_url,protected,public_metrics,url,username,verified,withheld",
    #                     "expansions": "author_id,referenced_tweets.id,referenced_tweets.id.author_id,entities.mentions.username,attachments.media_keys",
    #                     "media.fields": "duration_ms,height,preview_image_url,public_metrics,url,width",
    #                     "max_results": "100"})

    print('Retrieving', url)
    connection = urllib.request.urlopen(url, context=ctx)
    data = json.loads(connection.read().decode())
    print(data[:250])

    return data

def get_client(CONSUMER_KEY,CONSUMER_SECRET,BEARER_TOKEN,ACCESS_TOKEN,ACCESS_TOKEN_SECRET):
    client = tweepy.Client(bearer_token=BEARER_TOKEN,
                           consumer_key=CONSUMER_KEY,
                           consumer_secret=CONSUMER_SECRET,
                           access_token=ACCESS_TOKEN,
                           access_token_secret=ACCESS_TOKEN_SECRET, wait_on_rate_limit=True)
    return client

def pagination(client, user_id):
    responses = tweepy.Paginator(client.get_users_tweets, user_id,
                                 exclude='replies,retweets',
                                 max_results=100,
                                 expansions='referenced_tweets.id',
                                 tweet_fields=['created_at', 'public_metrics', 'entities'])
    return responses

def get_original_tweets(client, user_id):
    tweet_list = []
    responses = pagination(client, user_id)
    for response in responses:
        if response.data ==None:
            continue
        else:
            for tweets in response.data:
                tweet_list.append([tweets.text,
                                tweets['public_metrics']['like_count'],
                                tweets['public_metrics']['retweet_count'],
                                tweets['created_at'].date()])

    return tweet_list



if __name__ == '__main__':

    # ________________________Authorize Twitter API________________________________#
    consumer_key = '7cXG565ehcH9TO4XtgtjWiAF2'
    consumer_secret = 'J9qWmKfdiuTJxKwGvwDLASqSCMEwE1O85ta0QP8ARScnMAiTrR'
    access_token = '1351603554499387394-g2gyZg8hryr3QiqmRD1lnj5i16wAVV'
    access_token_secret = 'rZNyp3xngCUBK9rHlHmnD7Gu4OXRWRBUSHDPasBho8icL'
    bearer_token = 'AAAAAAAAAAAAAAAAAAAAAELZawEAAAAA6ItGxjfWQfyI3gSlZJtgfmBXQAo%3DkqWpeCvfK7q3OU6w6Rd0zEGpnKrDLUqS2dxJu2d2NjmMkifnWs'
    client_id = 'WlFtUXZhQnNrdkdDdzZVNDB2OFk6MTpjaQ'
    client_secret = 'arVmpRlANwEZUST55FcJsD8ZO0OhEOaM1Ng1VAku7-AgNcsQFY'

    auth = OAuthHandler(consumer_key, consumer_secret, callback="oob")
    print(auth.get_authorization_url())
    # Enter that PIN to continue
    verifier = input("PIN (oauth_verifier= parameter): ")
    # Complete authenthication
    bot_token, bot_secret = auth.get_access_token(verifier)
    auth.set_access_token(bot_token, bot_secret)
    api = tweepy.API(auth, wait_on_rate_limit=True)
    print(api.verify_credentials())


    # ________________________Tweet and Follow and Timeline________________________________#

    # response = api.update_status("Its been 47 years.....")
    # print(response)
    bot_name = 'RochelleTunti'
    user = api.get_user(screen_name=bot_name)
    new_friend = api.get_user(screen_name="DvrkdvysD")

    bot_timeline = user_timeline(user_name=user.screen_name, user_id=user.id_str)

    print('Auth Screen Name:', api.verify_credentials().screen_name)
    print('User Screen Name:', user.screen_name)
    print('User ID:', user.id)
    print("The location is : " + str(user.location))
    print("The description is : " + user.description)
    print('User Follower Count:', user.followers_count)
    for friend in user.friends():
        print('Friend:', friend.screen_name)


    scopes = ['tweet.read', 'tweet.write', 'users.read']
    oauth2_user_handler = tweepy.OAuth2UserHandler(client_id=client_id, redirect_uri="oob", scope=scopes)


    client = tweepy.Client(bearer_token=bearer_token,
                           consumer_key=consumer_key,
                           consumer_secret=consumer_secret,
                           access_token=access_token,
                           access_token_secret=access_token_secret,
                           return_type=requests.Response,
                           wait_on_rate_limit=True)
    client.get_user(username=user.screen_name)
    client.get_users_tweets(id=user.id)

    print('_______ End _______')


    # api.create_friendship(screen_name=new_friend.screen_name, follow=True)
    # new_friend.follow()


    # ________________________Geo Location________________________________#
    # city = 'New York, NY'
    # city_geodata = api.search_geo(
    #     query='{}'.format(city),
    #     wait_on_rate_limit=True,
    #     granularity='city'
    # )

    # for _ in city_geodata:
    #     if city_geodata[city_geodata.index(_)].full_name == city:
    #         geo_prep = city_geodata[city_geodata.index(_)].bounding_box.coordinates[0]
    #         city_coords = [geo_prep[0][0], geo_prep[0][1], geo_prep[2][0], geo_prep[2][1]]

    # places = api.search_geo(query="New York", granularity="city")
    # place_id = places[0].id
    #
    # # # ________________________Query: Stream______________________________________#
    # keywords = ["coronavirus", "covid", "omicorn", "ukraine", "russia", "poland", 'russian', 'ukranian', 'german', 'nazi'
    #             "war", "weapons", "refugee", "detainee", "support", "refugees", "usa", "Volodymyr Zelenskyy",
    #             "Vladimir Putin", "Joe Biden", "Joe Byron", "China", "Xi Jinping", 'putin',
    #             "Andrzej Duda", "EU", "NATO", "Oil", "Gas", "Sanction", "Subvariant"]
    #
    # json_tweets_file = '_'.join(keywords)+'.jsonl'
    # json_tweets_file = 'ukraine_war_omicron_world_crisis.jsonl'
    # # You can increase this value to retrieve more tweets but remember the rate limiting
    # max_tweets = 200
    # twitter_stream = MyListener(consumer_key, consumer_secret, access_token, access_token_secret, api, max_tweets, json_tweets_file)
    # # # Add your keywords and other filters
    # twitter_stream.filter(track=keywords, locations=city_coords, languages=["en"])
    print('_______ End _______')

    # # __________________________Get Results: Stream______________________________#
    # with open(json_tweets_file) as f:
    #     lines = f.read().splitlines()

    # df_inter = pd.DataFrame(lines)
    # df_inter.columns = ['json_element']
    # df_inter['json_element'].apply(json.loads)
    # df = pd.json_normalize(df_inter['json_element'].apply(json.loads))
    # print(len(df), 'tweets')
    # df.head()

    # __________________________Query: Search______________________________#
    # query = 'Womens History Month'
    # max_tweets = 15

    # __________________________Get Results: Stream______________________________#
    #!PAGINATION!
    # API.search_geo(*, lat, long, query, ip, granularity, max_results)
    # Only iterate through the first 200 statuses
    # for status in tweepy.Cursor(api.search_tweets, q='{} place:{}'.format(keywords, place_id),
    #                                         # geo=city_coords,
    #                                         lang="en",
    #                                         result_type="mixed",
    #                                         count=max_tweets,
    #                                         tweet_mode="extended").items(200):
    #     print(status._json["full_text"])
    #     print('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~')

    # # # Only iterate through the first 3 pages
    # for page in tweepy.Cursor(api.search, q='{} place:{}'.format(query, place_id),
    #                                       geo=city_coords,
    #                                       lang="en",
    #                                       result_type="mixed",
    #                                       count=max_tweets,
    #                                       tweet_mode="extended").pages(3):
    #     for tweet in page:
    #         print(tweet._json["full_text"])
    #         print('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~')

    # __________________________Clean Results______________________________#

    # with open('reddit_data', 'a') as f:  # You can also print your tweets here

    # cleaned_tweets = []
    # regex_pattern = re.compile(pattern="["
    #                                    u"\U0001F600-\U0001F64F"  # emoticons
    #                                    u"\U0001F300-\U0001F5FF"  # symbols & pictographs
    #                                    u"\U0001F680-\U0001F6FF"  # transport & map symbols
    #                                    u"\U0001F1E0-\U0001F1FF"  # flags (iOS)
    #                                    "]+", flags=re.UNICODE)
    #
    # pattern = re.compile(r'(https?://)?(www\.)?(\w+\.)?(\w+)(\.\w+)(/.+)?')
    # re_list = ['@[A-Za-z0–9_]+', '#']
    # combined_re = re.compile( '|'.join( re_list) )
    # # for clean_prep in twitter_stream.listener.extended_text:
    # with open('./data/coronavirus_covid_omicorn_ukraine_russia_poland.jsonl') as f:
    #     line_prep = f.read().splitlines()
    # clean_prep = []
    # for line in line_prep:
    #     try:
    #         if json.loads(line)['is_quote_status'] ==True:
    #             clean_prep.append(json.loads(line)['quoted_status']['extended_tweet']['full_text'])
    #         else:
    #             clean_prep.append(json.loads(line)['retweeted_status']['extended_tweet']['full_text'])
    #     except:
    #         try:
    #             clean_prep.append(json.loads(line)['text'])
    #         except:
    #             continue
    # with open('clean__' + json_tweets_file, 'a') as f:
    #     for cp in clean_prep:
    #         clean = re.sub(regex_pattern, '', cp)
    #         # replaces pattern with ''
    #         clean_tweets_1 = re.sub(pattern, '', clean)
    #         clean_tweets_2 = re.sub(combined_re, '', clean_tweets_1)
    #         clean_tweets_3 = re.sub('\n', '', clean_tweets_2)
    #         clean_tweets_4 = re.sub('\'', '', clean_tweets_3)
    #         cleaned_tweets.append(clean_tweets_4)
    #         f.write(str(clean_tweets_4) + '\n')
    #
    # clean_strings = pd.Series(cleaned_tweets).str.cat(sep=' ')
    # print()

    # __________________________Word Cloud______________________________#
    # stopwords = set(STOPWORDS)
    # wordcloud = WordCloud(width=1600, stopwords=stopwords, height=800, max_font_size=200, max_words=50,
    #                       collocations=False, background_color='black').generate(clean_strings)
    # plt.figure(figsize=(40, 30))
    # plt.imshow(wordcloud, interpolation="bilinear")
    # plt.axis("off")
    # plt.show()
    # plt.savefig(r'word_map' + keywords + '.png')
    # plt.clf()
    # plt.cla()
    # plt.close()



