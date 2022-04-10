import sys
import tweepy
import json

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

class StdOutListener(tweepy.Stream):

	def on_status(self, status):
		try:
			tweet_json = json.loads(json.dumps(status._json))
			#print tweet_json
			print(json.dumps(status._json))
		except:
			print("Unexpected error:", sys.exc_info()[0])
		return True

	def on_error(self, status_code):
		print('Got an error with status code: ' + str(status_code))
		return False # To continue listening

	def on_timeout(self):
		print('Timeout...')
		return False # To continue listening

if __name__ == '__main__':

	listener = StdOutListener()
	auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
	auth.set_access_token(access_token, access_token_secret)
	stream = tweepy.Stream(auth, listener)
	#stream.filter(locations=[-6.38,49.87,1.77,55.81]) # coordinates of barcelona
	stream.filter(track=['stimulus'])
