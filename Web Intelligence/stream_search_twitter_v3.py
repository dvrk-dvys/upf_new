import re
import tweepy
import json
from tweepy import OAuthHandler
from tweepy import Stream
from tweepy.streaming import Stream
import pandas as pd
from wordcloud import WordCloud, ImageColorGenerator, STOPWORDS
import matplotlib.pyplot as plt


class MyListener(Stream):

    def __init__(self, api=None, max_tweets=10, json_tweets_file=None):
        super(Stream, self).__init__()
        self.num_tweets = 0
        self.max_tweets = max_tweets
        self.json_tweets_file = json_tweets_file
        self.extended_text = []

    def on_data(self, data):
        try:
            with open(self.json_tweets_file, 'a') as f:
                f.write(data)  # This will store the whole JSON data in the file, you can perform some JSON filters
                twitter_text = json.loads(data)['retweeted_status']['extended_tweet']['full_text']
                # twitter_text = json.loads(data)['text']
                # You can also print your tweets here
                print(twitter_text.replace('\n', ' ').replace('\r', ' '))
                self.extended_text.append(twitter_text.replace('\n', ' ').replace('\r', ' '))
                self.num_tweets += 1
                if self.num_tweets < self.max_tweets:
                    return True
                else:
                    return False
        except BaseException as e:
            print("Error on_data: %s" % str(e))
        return True

    def on_error(self, status):
        print('Error :', status)
        return False

if __name__ == '__main__':
    # ________________________Authorize Twitter API________________________________#
    consumer_key = 'iG2M79jujJk5qTUVdbzrVTjIf'
    consumer_secret = 'T2RFmZkewXdBLqSOJoLQpvf2G7SFkLvTNyJPrq4u61RNO0hFJc'
    access_token = '1351603554499387394-SU9nNEsqejhkebtQ1lrDNzIIl0TyyA'
    access_token_secret = 'atWRVcwlHYJEb2lcQCNObm1Yau3jlCwq9Cngg7UWvWMnI'

    auth = OAuthHandler(consumer_key, consumer_secret)
    auth.set_access_token(access_token, access_token_secret)
    api = tweepy.API(auth)

    user = api.get_user('twitter')
    # print('Auth Screen Name:', api.verify_credentials().screen_name)
    # print('User Screen Name:', user.screen_name)
    # print('User Follower Count:', user.followers_count)
    # for friend in user.friends():
    #     print('Friend:', friend.screen_name)


    # ________________________Geo Location________________________________#
    city = 'New York, NY'
    city_geodata = api.geo_search(
        query='{}'.format(city),
        wait_on_rate_limit=True,
        granularity='city'
    )

    for _ in city_geodata:
        if city_geodata[city_geodata.index(_)].full_name == city:
            geo_prep = city_geodata[city_geodata.index(_)].bounding_box.coordinates[0]
            city_coords = [geo_prep[0][0], geo_prep[0][1], geo_prep[2][0], geo_prep[2][1]]

    places = api.geo_search(query="New York", granularity="city")
    place_id = places[0].id

    # # ________________________Query: Stream______________________________________#
    # keywords = ["coronavirus", "covid", "omicorn", "ukraine", "russia", "poland"]
    # json_tweets_file = '_'.join(keywords)+'.jsonl'
    # # You can increase this value to retrieve more tweets but remember the rate limiting
    # max_tweets = 200
    # twitter_stream = Stream(auth, MyListener(json_tweets_file=json_tweets_file, max_tweets=max_tweets), tweet_mode="extended")
    # # Add your keywords and other filters
    # twitter_stream.filter(track=keywords, locations=city_coords, languages=["en"])
    # print('_______ End _______')
    #
    # # __________________________Get Results: Stream______________________________#
    # with open(json_tweets_file) as f:
    #     lines = f.read().splitlines()
    #
    # df_inter = pd.DataFrame(lines)
    # df_inter.columns = ['json_element']
    # df_inter['json_element'].apply(json.loads)
    # df = pd.json_normalize(df_inter['json_element'].apply(json.loads))
    # print(len(df), 'tweets')
    # df.head()

    # __________________________Query: Search______________________________#
    query = 'Womens History Month'
    max_tweets = 15

    # __________________________Get Results: Stream______________________________#
    #!PAGINATION!
    # API.search_geo(*, lat, long, query, ip, granularity, max_results)
    # Only iterate through the first 200 statuses
    for status in tweepy.Cursor(api.search, q='{} place:{}'.format(query, place_id),
                                            geo=city_coords,
                                            lang="en",
                                            result_type="mixed",
                                            count=max_tweets,
                                            tweet_mode="extended").items(200):
        print(status._json["full_text"])
        print('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~')

    # # Only iterate through the first 3 pages
    for page in tweepy.Cursor(api.search, q='{} place:{}'.format(query, place_id),
                                          geo=city_coords,
                                          lang="en",
                                          result_type="mixed",
                                          count=max_tweets,
                                          tweet_mode="extended").pages(3):
        for tweet in page:
            print(tweet._json["full_text"])
            print('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~')

    # __________________________Clean Results______________________________#
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
    #
    # for clean_prep in twitter_stream.listener.extended_text:
    #     clean = re.sub(regex_pattern, '', clean_prep)
    #     # replaces pattern with ''
    #     clean_tweets_1 = re.sub(pattern, '', clean)
    #     clean_tweets_2 = re.sub(combined_re, '', clean_tweets_1)
    #     cleaned_tweets.append(clean_tweets_2)
    # clean_strings = pd.Series(cleaned_tweets).str.cat(sep=' ')

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



