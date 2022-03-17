import sys
import tweepy
import json
from tweepy import OAuthHandler
from tweepy import Stream
import pandas as pd
from wordcloud import WordCloud, ImageColorGenerator
import matplotlib.pyplot as plt

# from tweepy.streaming import StreamListener


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

auth = OAuthHandler(consumer_key, consumer_secret)
auth.set_access_token(access_token, access_token_secret)


# class StdOutListener(tweepy.StreamListener):
#
# 	def on_status(self, status):
# 		try:
# 			tweet_json = json.loads(json.dumps(status._json))
# 			#print tweet_json
# 			print(json.dumps(status._json))
# 		except:
# 			print("Unexpected error:", sys.exc_info()[0])
# 		return True
#
# 	def on_error(self, status_code):
# 		print('Got an error with status code: ' + str(status_code))
# 		return False # To continue listening
#
# 	def on_timeout(self):
# 		print('Timeout...')
# 		return False # To continue listening


class MyListener(tweepy.Stream):

    def __init__(self, api=None, max_tweets=10, json_tweets_file=None):
        super(tweepy.Stream, self).__init__()
        self.num_tweets = 0
        self.max_tweets = max_tweets
        self.json_tweets_file = json_tweets_file

    def on_data(self, data):
        try:
            with open(self.json_tweets_file, 'a') as f:
                f.write(data)  # This will store the whole JSON data in the file, you can perform some JSON filters
                twitter_text = json.loads(data)['text']  # You can also print your tweets here
                print(twitter_text.replace('\n', ' ').replace('\r', ' '))
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
    # # listener = StdOutListener()
    # auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
    # auth.set_access_token(access_token, access_token_secret)
    # stream = tweepy.Stream(auth, listener)
    # #stream.filter(locations=[-6.38,49.87,1.77,55.81]) # coordinates of barcelona
    # stream.filter(track=['stimulus'])

    keywords = ["coronavirus", "covid19"]
    json_tweets_file = '_'.join(keywords) + '.jsonl'

    # You can increase this value to retrieve more tweets but remember the rate limiting
    max_tweets = 100

    twitter_stream = Stream(auth, MyListener(json_tweets_file=json_tweets_file, max_tweets=max_tweets))

    # Add your keywords and other filters
    twitter_stream.filter(track=keywords)

    print('_______ End _______')

    with open(json_tweets_file) as f:
        lines = f.read().splitlines()

    df_inter = pd.DataFrame(lines)
    df_inter.columns = ['json_element']
    df_inter['json_element'].apply(json.loads)
    df = pd.json_normalize(df_inter['json_element'].apply(json.loads))
    print (len(df),'tweets')
    df.head()