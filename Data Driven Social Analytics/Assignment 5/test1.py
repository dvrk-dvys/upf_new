import textblob as textblob
from tweepy import Stream
from tweepy import OAuthHandler
from tweepy.streaming import StreamListener
import json
from textblob import TextBlob

# consumer key, consumer secret, access token, access secret.
consumer_key = 'iG2M79jujJk5qTUVdbzrVTjIf'
consumer_secret = 'T2RFmZkewXdBLqSOJoLQpvf2G7SFkLvTNyJPrq4u61RNO0hFJc'
access_token = '1351603554499387394-SU9nNEsqejhkebtQ1lrDNzIIl0TyyA'
access_token_secret = 'atWRVcwlHYJEb2lcQCNObm1Yau3jlCwq9Cngg7UWvWMnI'


class StdOutlistener(StreamListener):
    def on_data(self, data):
        all_data = json.loads(data)
        tweet = TextBlob(all_data["text"])

        #Add the 'sentiment data to all_data
        all_data['sentiment'] = tweet.sentiment

        print(tweet)
        print(tweet.sentiment)

        # Open json text file to save the tweets
        with open('tweets.json', 'a') as tf:
            # Write a new line
            tf.write('\n')

            # Write the json data directly to the file
            json.dump(all_data, tf)
            # Alternatively: tf.write(json.dumps(all_data))

        return True

    def on_error(self, status):
        print(status)


auth = OAuthHandler(consumer_key, consumer_secret)
auth.set_access_token(access_token, access_token_secret)

twitterStream = Stream(auth, StdOutlistener())
twitterStream.filter(languages=["en"], track=["stimulus"])