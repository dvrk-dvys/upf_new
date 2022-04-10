import sys
import tweepy
import json
import csv
import datetime
import requests
from tweepy import OAuthHandler
import configparser
import pandas as pd
from wordcloud import WordCloud, ImageColorGenerator
import matplotlib.pyplot as plt




# API Key:
#
# iG2M79jujJk5qTUVdbzrVTjIf
#
# API Secret Key:
#
# T2RFmZkewXdBLqSOJoLQpvf2G7SFkLvTNyJPrq4u61RNO0hFJc
#
# Access Token:
#
# 1351603554499387394-SU9nNEsqejhkebtQ1lrDNzIIl0TyyA
#
# copy-light
# Access Token Secret:
#
# atWRVcwlHYJEb2lcQCNObm1Yau3jlCwq9Cngg7UWvWMnI
#


consumer_key = 'iG2M79jujJk5qTUVdbzrVTjIf'
consumer_secret = 'T2RFmZkewXdBLqSOJoLQpvf2G7SFkLvTNyJPrq4u61RNO0hFJc'
access_token = '1351603554499387394-SU9nNEsqejhkebtQ1lrDNzIIl0TyyA'
access_token_secret = 'atWRVcwlHYJEb2lcQCNObm1Yau3jlCwq9Cngg7UWvWMnI'

# auth = OAuthHandler(consumer_key, consumer_secret)
# auth.set_access_token(access_token, access_token_secret)


class MyListener(tweepy.Stream):

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
        with open(self.json_tweets_file, 'wb') as f: # You can also print your tweets here
            try:
                f.write(data)  # This will store the whole JSON data in the file, you can perform some JSON filters
                twitter_text = json.loads(data)['text']
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



if __name__ == '__main__':
    # read config
    config = configparser.ConfigParser()
    config.read('config.ini')

    consumer_key = 'iG2M79jujJk5qTUVdbzrVTjIf'
    consumer_secret = 'T2RFmZkewXdBLqSOJoLQpvf2G7SFkLvTNyJPrq4u61RNO0hFJc'
    access_token = '1351603554499387394-SU9nNEsqejhkebtQ1lrDNzIIl0TyyA'
    access_token_secret = 'atWRVcwlHYJEb2lcQCNObm1Yau3jlCwq9Cngg7UWvWMnI'

    auth = OAuthHandler(consumer_key, consumer_secret)
    auth.set_access_token(access_token, access_token_secret)

    api = tweepy.API(auth)
    print(api.verify_credentials().screen_name)


    #
    keywords = ["ukraine", "russia", "war"]
    json_tweets_file = '_'.join(keywords) + '.jsonl'

    # You can increase this value to retrieve more tweets but remember the rate limiting
    max_tweets = 100
    twitter_stream = MyListener(consumer_key, consumer_secret, access_token, access_token_secret, api, max_tweets, json_tweets_file)



    # Add your keywords and other filters
    twitter_stream.filter(track=keywords, languages="en")

    print('_______ End _______')



    with open(json_tweets_file) as f:
        lines = f.read().splitlines()
    #
    df_inter = pd.DataFrame(lines)
    df_inter.columns = ['json_element']
    df_inter['json_element'].apply(json.loads)
    df = pd.json_normalize(df_inter['json_element'].apply(json.loads))
    print(len(df), 'tweets')
    df.head()


    # # Start with one review:
    # text = df.description[0]
    #
    # # Create and generate a word cloud image:
    # wordcloud = WordCloud().generate(text)
    #
    # # Display the generated image:
    # plt.imshow(wordcloud, interpolation='bilinear')
    # plt.axis("off")
    # plt.show()
    # wordcloud.to_file("img/first_tweet.png")
    #
    # text = " ".join(tweets for tweets in df.description)
    #
    # # Generate a word cloud image
    # wordcloud = WordCloud(stopwords=None, background_color="white").generate(text)
    #
    # # Display the generated image:
    # # the matplotlib way:
    # plt.imshow(wordcloud, interpolation='bilinear')
    # plt.axis("off")
    # plt.show()
    #
