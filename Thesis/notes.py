# Terminologies
#
# First explained below, terminology clarification,
# with different terms referring to the same thing:
#
# Client credentials:
#
# 1. App Key === API Key === Consumer API Key === Consumer Key === Customer Key === oauth_consumer_key
# 2. App Key Secret === API Secret Key === Consumer Secret === Consumer Key === Customer Key === oauth_consumer_secret
# 3. Callback URL === oauth_callback

# Temporary credentials:
# 1. Request Token === oauth_token
# 2. Request Token Secret === oauth_token_secret
# 3. oauth_verifier
#
# Token credentials:
#
# 1. Access token === Token === resulting oauth_token
# 2. Access token secret === Token Secret === resulting oauth_token_secret

# User level (OAuth 1.0a):
# API key:"hgrthgy2374RTYFTY"
# API key secret:"hGDR2Gyr6534tjkht"
# Access token:"HYTHTYH65TYhtfhfgkt34"
# Access token secret: "ged5654tHFG"
#
# auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
# auth.set_access_token(key, secret)
# api = tweepy.API(auth)

# App level (OAuth 2.0):
# Bearer token: "ABDsdfj56nhiugd5tkggred"
# auth = tweepy.Client("Bearer Token here")
# api = tweepy.API(auth)
# Or alternatively:
#
# auth = tweepy.AppAuthHandler(consumer_key, consumer_secret)
# api = tweepy.API(auth)
# [1]
# https: // developer.twitter.com / en / docs / authentication / oauth - 1 - 0
# a / obtaining - user - access - tokens
#
# [2]
# https: // docs.tweepy.org / en / latest / authentication.html  # twitter-api-v2