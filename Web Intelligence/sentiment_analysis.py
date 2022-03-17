import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import json
import nltk
from nltk.tokenize import RegexpTokenizer
from nltk.corpus import stopwords
nltk.download('stopwords')
from collections import Counter
import liwc
import urllib


if __name__ == '__main__':


    # Load the JSON lines file as a dataframe
    with open('coronavirus.jsonl') as f:
        lines = f.read().splitlines()
    df_inter = pd.DataFrame(lines)
    df_inter.columns = ['json_element']
    df_inter['json_element'].apply(json.loads)
    df = pd.json_normalize(df_inter['json_element'].apply(json.loads))

    # Keep only the tweets in English
    df = df[df.lang=='en']

    # Create URL field for tweets
    df['url'] = 'https://twitter.com/_/status/'+df['id_str']

    print(df.head(5))

    # Extract tokens, generate count vectors and remove stopwords
    tokenizer = RegexpTokenizer(r'[a-zA-Z]+')
    word_vec = df['text'].apply(str.lower).apply(tokenizer.tokenize).apply(pd.value_counts).fillna(0)
    word_vec = word_vec.drop(stopwords.words('english') + ['https', 'co'], axis=1, errors='ignore').fillna(0)
    word_vec

    # Compute term frequencies
    tf = word_vec.divide(np.sum(word_vec, axis=1), axis=0)

    tf_dict = {}
    for column in tf:  tf_dict[column] = tf[column].sum()
    tf_words = sorted(tf_dict.items(), key=lambda item: item[1], reverse=True)[:10]

    labels = [w[0] for w in tf_words]
    values = [w[1] for w in tf_words]
    indexes = np.arange(len(labels))

    f, ax = plt.subplots(figsize=(20, 5))
    cmap = plt.cm.tab10
    plt.bar(indexes, values, color=cmap(np.arange(len(df)) % cmap.N))
    plt.xticks(indexes, labels)
    plt.title('Coronavirus/COVID19 Tweets: Words by TF', fontsize=20)
    plt.show()
    plt.savefig(r'tweet_words_by_TF.png')
    plt.clf()
    plt.cla()
    plt.close()

# Term Frequency - Inverse Document Frequency (TF-IDF)
    # Compute inverse document frequencies
    idf = np.log10(len(tf) / word_vec[word_vec > 0].count())

    # Compute TF-IDF vectors
    tfidf = np.multiply(tf, idf.to_frame().T)

    tfidf_dict = {}
    for column in tfidf:  tfidf_dict[column] = tfidf[column].sum()
    tfidf_words = sorted(tfidf_dict.items(), key=lambda item: item[1], reverse=True)[:10]

    labels = [w[0] for w in tfidf_words]
    values = [w[1] for w in tfidf_words]
    indexes = np.arange(len(labels))

    f, ax = plt.subplots(figsize=(20, 5))
    cmap = plt.cm.tab10
    plt.bar(indexes, values, color=cmap(np.arange(len(df)) % cmap.N))
    plt.xticks(indexes, labels)
    plt.title('Coronavirus/COVID19 Tweets: Words by TF-IDF', fontsize=20)
    plt.show()
    plt.savefig(r'tweet_words_by_TF-IDF.png')
    plt.clf()
    plt.cla()
    plt.close()

    # Home-made dictionary (tweets about German issues)
    german_dictionary = ['germany', 'merkel']
    df[df.text.str.lower().str.contains('|'.join(german_dictionary))].text

    # Sentiment nanalysis with VADER(Valence Aware Dictionary and sEntiment Reasoner)

    # Initialize the VADER sentiment analyzer
    nltk.download('vader_lexicon')
    from nltk.sentiment.vader import SentimentIntensityAnalyzer

    sid = SentimentIntensityAnalyzer()
    counter = Counter(sid.lexicon)

    # Finding 20 highest values
    print('\nMost positive words')
    highest = counter.most_common()[0:10]
    for entry in highest:
        print(entry[0], " :", entry[1], " ")

        # Finding 20 lowest values
    print('\nMost negative words')
    lowest = counter.most_common()[-10:-1]
    for entry in lowest[:10]: print(entry[0], " :", entry[1], " ")

    # Compute VADER scores
    df['scores'] = df['text'].apply(lambda text: sid.polarity_scores(text))
    df['compound'] = df['scores'].apply(lambda score_dict: score_dict['compound'])
    df['comp_score'] = df['compound'].apply(lambda c: 'pos' if c > 0 else 'neg' if c < 0 else 'neu')
    df[['url', 'text', 'scores', 'compound', 'comp_score']].head(100)

    # Sentiment analysis with LIWC(Linguistic Inquiry and Word Count)

    # Load available copy
    url = "https://raw.githubusercontent.com/usc-sail/mica-text-characternetworks/master/LIWC/LIWC2007_English131104.dic"
    infile = urllib.request.urlopen(url)

    # Remove badly formatted entries
    outfile = open('liwc.dic', 'w')
    outfile.writelines([line.decode("utf-8") for line in infile if not '/' in str(line)])
    outfile.close()

    # Load dictionary
    parse, category_names = liwc.load_token_parser('liwc.dic')

    # Compute LIWC categories
    sample_text = "Today's coronavirus stats in Alabama: 5,498 new COVID-19 cases, more than 3,000 hospitalizations. https://t.co/lAWmpt8xwj"
    words = tokenizer.tokenize(sample_text)
    for word in words:
        for category in parse(word):
            print(word, category)



#!! identify the most positive and negative documents
#
#!! Detect the most frequent words between positive and negative and show them with a word cloud with two colors to distinguish them
#
#!! Detect categories of emotions beyond polar sentiments using LIWC and/or ANEW
#
# ... (be creative!)