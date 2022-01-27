# import pyaudio
import numpy as np
import speech_recognition as sr
import time
from statistics import mode
import pyttsx3
import os
from spacy.training.example import Example
from sklearn.model_selection import train_test_split
import spacy
# spacy.cli.download("en_core_web_sm")
# spacy.load('en_core_web_sm')
from spacy.util import minibatch, compounding
import nltk
# nltk.download('punkt')
# nltk.download('wordnet')
# nltk.download('omw-1.4')
from nltk.stem import WordNetLemmatizer
lemmatizer = WordNetLemmatizer()
import json
import pickle
from keras.models import Sequential
from keras.layers import Dense, Activation, Dropout
from tensorflow.keras.optimizers import SGD
import random
from keras.models import load_model
chat_model = load_model('chatbot_model.h5')




# use conda base env
# https://caffeinedev.medium.com/how-to-install-tensorflow-on-m1-mac-8e9b91d93706
# https://github.com/conda-forge/miniforge/releases/tag/4.11.0-0
# spacy
# # spacy model
# https://github.com/explosion/spacy-models/releases/download/en_core_web_sm-2.2.5/en_core_web_sm-2.2.5.tar.gz

# "model_artifacts"
# "choice_model_artifacts"
# "both_model_artifacts_new"
# 'chatbot_model.h5'
# TO DO:
# ADD:
# -WASSUP
# -sure im ready!
# intensity detector?

TEST_REVIEW = """
Transcendently beautiful in moments outside the office, it seems almost
sitcom-like in those scenes. When Toni Colette walks out and ponders
life silently, it's gorgeous.<br /><br />The movie doesn't seem to decide
whether it's slapstick, farce, magical realism, or drama, but the best of it
doesn't matter. (The worst is sort of tedious - like Office Space with less humor.)
"""

TEST_ART_OPINION = """
I am not really a fan of paintings and photos. Because they dont move and are boring.
"""

Exhibitons = {
    0:['Nicholas Tesla The Genius of Modern Electricity', 'Lab Math'],
    1:['Sabers and Mastodonts', 'Micrarium'],
    2:['The geological wall', 'Flooded Forest']
}

question_set = {0: ['How do bright lights and loud booms make you feel?',
                    'Does building things with your hands seem fun?',
                    'Do you enjoy riddles, puzzles, and mazes?'],
                1: ['Would you want to see what life was like long ago?',
                    'How does the idea of an invisible microscopic world make you feel?',
                    'Do you think life could survive on other planets?'],
                2: ['Do you like visiting rivers and lakes?',
                    'Do you like being scared?',
                    'Have you ever wondered how the surface of our earth was formed?'],
                3: ['Are you feeling like a mad scientist?',
                    'How do horns, tucks and fangs make you feel?',
                    'Are you in a relaxed mood?']
                }


words = []
classes = []
documents = []

classes = ['goodbye', 'greeting', 'help', 'map', 'no_answer', 'options', 'schedule', 'thanks', 'tickets']
words = ['a', 'again', 'all', 'am', 'and', 'any', 'anyone', 'are', 'art', 'awesome', 'bathroom', 'be', 'begin', 'bye', 'ca', 'can', 'card', 'chatting', 'check', 'close', 'coat', 'contact', 'cool', 'could', 'day', 'decide', 'detail', 'discount', 'do', 'done', 'elderly', 'exhibit', 'exhibition', 'exit', 'find', 'food', 'for', 'get', 'good', 'goodbye', 'have', 'hello', 'help', 'helpful', 'helping', 'here', 'hey', 'hi', 'hola', 'how', 'i', 'interactive', 'is', 'jacket', 'kid', 'know', 'later', 'layout', 'like', 'lost', 'main', 'me', 'membership', 'most', 'museum', 'my', 'need', 'next', 'nice', 'not', 'offered', 'on', 'painting', 'popular', 'pricing', 'provide', 'purchase', 'renew', 'schedule', 'sculpture', 'see', 'show', 'sign', 'something', 'sound', 'space', 'start', 'statue', 'student', 'support', 'sure', 'thank', 'thanks', 'that', 'thats', 'the', 'there', 'this', 'three', 'ticket', 'ticketing', 'till', 'time', 'to', 'today', 'trying', 'up', 'upcoming', 'very', 'visit', 'want', 'week', 'what', 'whats', 'where', 'which', 'will', 'work', 'would', 'you']




# Function to convert text to speech
def SpeakText(command):
    # Initialize the engine
    engine = pyttsx3.init()
    engine.say(command)
    engine.runAndWait()


def done(speech):
    if 'done' in speech.lower():
        # SpeakText('Thank You for Coming to CosmoCaixa Barcelona!')
        return True
    else:
        return False


def question_asker(model):
    question_dict = {0: [0, 1, 2], 1: [0, 1, 2], 2: [0, 1, 2]}
    exibs = [0, 1, 2]
    choices = []
    counter = 0
    recent_yes = None
    while (1):
        if len(choices) == 3 or counter == 4:
            break
        if exibs == []:
            break
        if recent_yes != None:
            x = recent_yes
            y = random.choice(question_dict[x])
        else:
            x = random.choice(exibs)
            y = random.choice(question_dict[x])
        # SpeakText(question_set[x][y])
        if counter == 0:
            print('OK! Here we go...')
            for i in range(3, 0, -1):
                time.sleep(1)
                print('...' + str(i))

        MyText = input(question_set[x][y])

        GGO = test_model_ggo(MyText, "ggo_artifacts_new")[0]
        sentiment = test_model(MyText, model)[0]

        if GGO == 'gratitude':
            res, tag = getResponse([{'intent': 'thanks', 'probability': '1.0'}])
            print(res)
        elif GGO == 'greeting':
            res, tag = getResponse([{'intent': 'greeting', 'probability': '1.0'}])
            print(res)
        if done(MyText) == True:
            return 'Thank you for coming to CosmoCaixa!'

        if sentiment == 'Positive':
            recent_yes = x
            question_dict[x].remove(y)
            choices.append(x)
            print(question_dict)
            print(choices)
            counter += 1
            if recent_yes == None:
                recent_yes = x
        elif sentiment == 'Negative':
            exibs.remove(x)
            question_dict[x].remove(y)
            print(question_dict)
            print(choices)
            counter += 1
            recent_yes = None

    tie_break = mode(choices)
    final = input(question_set[3][tie_break])
    sentiment = test_model(final, model)[0]

    if sentiment == 'Positive':
        choice = Exhibitons[tie_break][0]
        print('We think you may enjoy this exhibition!:' + Exhibitons[tie_break][0])
    else:
        choice = Exhibitons[tie_break][1]
        print('We think you may enjoy this exhibition!:' + Exhibitons[tie_break][1])

    # SpeakText('We think you may enjoy this exhibition!:' + Exhibitons[mode(choices)])
    # MyText = input('We think you may enjoy this exhibition!:' + Exhibitons[mode(choices)])
    MyText = input('What do you think of this recommendation?')
    GGO = test_model_ggo(MyText, "ggo_artifacts_new")[0]
    sentiment = test_model(MyText, model)[0]

    if GGO == 'gratitude':
        print('You are very welcome! You can purchase tickets at the kiosk. We hope you have an amazing time with us here at CosmoCaixa Barcelona!')
        return False, choice
    elif GGO == 'greeting':
        MyText = input('Hi There! Would you like to try again?')
        sentiment = test_model(MyText, model)[0]
        if sentiment == 'positive':
            return True, choice
        else:
            return False, choice
    elif GGO == 'other' and sentiment == 'Negative':
        print('If you need further assistance you will see the Help Desk <location>!')
        return False, choice
    elif GGO == 'other' and sentiment == 'Positive':
        MyText = input('Was there anything else I could help you with?')
        sentiment = test_model(MyText, model)[0]
        if sentiment == 'positive':
            return True, choice
        else:
            return False, choice


def listener(model, cont=False):
    # Initialize the recognizer
    # r = sr.Recognizer()  #

    mode = input("Speech or Text: ")
    print("You entered: " + mode)
    mode = mode.lower()
    if mode == 'text':
        time_out = 0
        while (1):
            # SpeakText("You chose text.")
            # SpeakText("Welcome to CosmoCaixa Barcelona!")
            if cont == True:
                Hello = input('How can I help you?')
            else:
                Hello = input("Hello! Welcome to CosmoCaixa Barcelona!")
            while (1):
                GGO = test_model_ggo(Hello, "ggo_artifacts_new")[0]
                response, tag = chatbot_response(Hello)
                print("Chat Model tag: " + tag)
                sentiment = test_model(Hello, model)[0]
                prep = Hello.lower()
                exit = [prep.split()]
                if len(exit) >= 1:
                    stop = set(exit[0]).isdisjoint(words)
                else:
                    stop = set(exit).isdisjoint(words)

                if sentiment == 'Negative' and stop == True:
                    print('Thank you for coming to CosmoCaixa!')
                    return 'Thank you for coming to CosmoCaixa!'
                elif GGO == 'greeting':
                    time_out += 1
                    response, tag = chatbot_response(Hello)
                    print("Chat Model tag: " + tag)
                    if mode == 'speech':
                        SpeakText(response)
                        SpeakText("I'm here to help you find an exhibition you may like! Would you like to try?")
                    print(response)
                    Hello = input("I'm here to help you find an exhibition you may like! Would you like to try?\n")
                    sentiment = test_model(Hello, model)[0]
                    GGO = test_model_ggo(Hello, "ggo_artifacts_new")[0]
                    response, tag = chatbot_response(Hello)

                    if sentiment == 'Positive' and GGO == 'other' and tag == "no_answer":
                        break
                    else:
                        if mode == 'speech':
                            SpeakText(response)
                            SpeakText('Was there something else I could help you with?')
                        print(response)
                        Hello = input('Was there something else I could help you with?')
                elif tag == 'thanks':
                    response, tag = chatbot_response(Hello)
                    print("Chat Model tag: " + tag)
                    if mode == 'speech':
                        SpeakText(response)
                        SpeakText("Was there anything else I could you with?")
                    print(response)
                    Hello = input("Was there anything else I could help you with?")
                elif tag == 'noanswer':
                    response, tag = chatbot_response(Hello)
                    print("Chat Model tag: " + tag)
                    if mode == 'speech':
                        SpeakText(response)
                        SpeakText("Was there anything else I could you with?")
                    print(response)
                    Hello = input("Was there anything else I could help you with?")
                elif tag == 'options':
                    response, tag = chatbot_response(Hello)
                    print("Chat Model tag: " + tag)
                    if mode == 'speech':
                        SpeakText(response)
                        SpeakText("I'm here to help you find an exhibition you may like! Would you like to try?\n")
                    print(response)
                    break
                elif tag == 'help':
                    response, tag = chatbot_response(Hello)
                    print("Chat Model tag: " + tag)
                    if mode == 'speech':
                        SpeakText(response)
                        SpeakText("Was there anything else I could help you with?")
                    print(response)
                    Hello = input("Was there anything else I could help you with?")
                elif tag == 'map':
                    response, tag = chatbot_response(Hello)
                    print("Chat Model tag: " + tag)
                    if mode == 'speech':
                        SpeakText(response)
                        SpeakText("Was there anything else I could help you with?")
                    print(response)
                    Hello = input("Was there anything else I could help you with?")
                elif tag == 'tickets':
                    response, tag = chatbot_response(Hello)
                    print("Chat Model tag: " + tag)
                    if mode == 'speech':
                        SpeakText(response)
                        SpeakText("Was there anything else I could help you with?")
                    print(response)
                    Hello = input("Was there anything else I could help you with?")
                elif tag == 'goodbye':
                    response, tag = chatbot_response(Hello)
                    print("Chat Model tag: " + tag)
                    if mode == 'speech':
                        SpeakText(response)
                    print(response)
                    return cont, None

            if mode == 'speech':
                SpeakText("Ready to begin?\n")
            Text = input("Ready to begin?")
            Text = Text.lower()
            sentiment = test_model(Text, model)[0]
            if sentiment == 'Positive':
                if mode == 'speech':
                    SpeakText("Great! You can say DONE at anytime to exit.")
                print("Great! You can say DONE at anytime to exit.")
                cont, choice = question_asker('both_model_artifacts_new')
                return cont, choice
            else:
                if mode == 'speech':
                    print('If you need further assistance you will see the Help Desk <location>!')
                return cont, None
#### Training Data ####

# A good ratio to start with is 80 percent
# of the data for training data and
# 20 percent for test data. #

def load_training_data_imdb(
        data_directory: str = "data/aclImdb/train",
        split: float = 0.8,
        limit: int = 0
) -> tuple:
    # Load from files
    reviews = []
    for label in ["pos", "neg"]:
        labeled_directory = f"{data_directory}/{label}"
        for review in os.listdir(labeled_directory):
            if review.endswith(".txt"):
                with open(f"{labeled_directory}/{review}") as f:
                    text = f.read()
                    text = text.replace("<br />", "\n\n")
                    if text.strip():
                        spacy_label = {
                            "cats": {
                                "pos": "pos" == label,
                                "neg": "neg" == label
                            }
                        }
                        reviews.append((text, spacy_label))
    random.shuffle(reviews)

    if limit:
        reviews = reviews[:limit]
    split = int(len(reviews) * split)
    return reviews[:split], reviews[split:]


def load_training_data_choice():
    train_neg_file = "/Users/jordanharris/upf_new/Natural Language Processing/data/archive/train/negative_words_en.txt"
    train_pos_file = "/Users/jordanharris/upf_new/Natural Language Processing/data/archive/train/positive_words_en.txt"
    test_neg_file = "/Users/jordanharris/upf_new/Natural Language Processing/data/archive/test/negative_words_en.txt"
    test_pos_file = "/Users/jordanharris/upf_new/Natural Language Processing/data/archive/test/positive_words_en.txt"

    train_neg = open(train_neg_file, "r")
    train_pos = open(train_pos_file, "r")
    test_neg = open(test_neg_file, "r")
    test_pos = open(test_pos_file, "r")

    train_neg_lines = train_neg.readlines()
    train_pos_lines = train_pos.readlines()
    test_neg_lines = test_neg.readlines()
    test_pos_lines = test_pos.readlines()

    train_choice = []
    test_choice = []
    for each in train_neg_lines:
        x = (each, {'cats': {'pos': False, 'neg': True}})
        train_choice.append(x)
    for each in test_neg_lines:
        x = (each, {'cats': {'pos': False, 'neg': True}})
        test_choice.append(x)
    for each in train_pos_lines:
        x = (each, {'cats': {'pos': True, 'neg': False}})
        train_choice.append(x)
    for each in test_pos_lines:
        x = (each, {'cats': {'pos': True, 'neg': False}})
        test_choice.append(x)

    return train_choice, test_choice


def load_training_data_ggo():
    gratitude_file = "/Users/jordan.harris/PycharmProjects/pythonProject/upf/Natural Language Processing/data/Greetings_and_justification/gratitude_corpus.txt"
    greeting_file = "/Users/jordan.harris/PycharmProjects/pythonProject/upf/Natural Language Processing/data/Greetings_and_justification/greeting_corpus.txt"
    other_file = "/Users/jordan.harris/PycharmProjects/pythonProject/upf/Natural Language Processing/data/Greetings_and_justification/other_corpus.txt"

    train_grat = open(gratitude_file, "r")
    train_greet = open(greeting_file, "r")
    test_oth = open(other_file, "r")

    train_grat_lines = train_grat.readlines()
    train_greet_lines = train_greet.readlines()
    test_oth_lines = test_oth.readlines()

    y_grat = ['gratitude'] * len(train_grat_lines)
    y_greet = ['greeting'] * len(train_greet_lines)
    y_oth = ['other'] * len(test_oth_lines)

    x = train_grat_lines + train_greet_lines + test_oth_lines
    y = y_grat + y_greet + y_oth
    x_train, x_test, y_train, y_test = train_test_split(x, y, test_size=0.20)

    train_ggo = []
    test_ggo = []

    for index in range(len(x_train)):
        if y_train[index] == 'gratitude':
            x = (x_train[index], {'cats': {'gratitude': True, 'greeting': False, 'other': False}})
            train_ggo.append(x)
        elif y_train[index] == 'greeting':
            x = (x_train[index], {'cats': {'gratitude': False, 'greeting': True, 'other': False}})
            train_ggo.append(x)
        elif y_train[index] == 'other':
            x = (x_train[index], {'cats': {'gratitude': False, 'greeting': False, 'other': True}})
            train_ggo.append(x)
    for index in range(len(x_test)):
        if y_train[index] == 'gratitude':
            x = (x_train[index], {'cats': {'gratitude': True, 'greeting': False, 'other': False}})
            test_ggo.append(x)
        elif y_train[index] == 'greeting':
            x = (x_train[index], {'cats': {'gratitude': False, 'greeting': True, 'other': False}})
            test_ggo.append(x)
        elif y_train[index] == 'other':
            x = (x_train[index], {'cats': {'gratitude': False, 'greeting': False, 'other': True}})
            test_ggo.append(x)

    return train_ggo, test_ggo


def train_model(
        training_data: list,
        test_data: list,
        iterations: int,
        data_directory: str
) -> None:
    # Build pipeline
    spacy.prefer_gpu()
    # config = spacy.util.load_config('./spacy.cfg')
    # nlp = spacy.load("en_core_web_sm", config=config)
    nlp = spacy.load("en_core_web_sm")
    if "textcat" not in nlp.pipe_names:
        nlp = spacy.blank("en")
        # nlp = spacy.blank("en", config=config)
        # textcat = nlp.create_pipe("textcat",
        #                           config={"architechture": "simple_cnn"}
        #                           )
        nlp.add_pipe("textcat", last=True)
    textcat = nlp.get_pipe("textcat")


    textcat.add_label("pos")
    textcat.add_label("neg")

    # Train only textcat
    training_excluded_pipes = [
        pipe for pipe in nlp.pipe_names if pipe != "textcat"
    ]
    with nlp.disable_pipes(training_excluded_pipes):
        optimizer = nlp.begin_training()
        # Training loop
        print("Beginning training")
        print("Loss\tPrecision\tRecall\tF-score")
        batch_sizes = compounding(
            4.0, 32.0, 1.001
        )  # A generator that yields infinite series of input numbers
        for i in range(iterations):
            random.shuffle(training_data)

            losses = {}
            for batch in minibatch(training_data, size=batch_sizes):
                for text, annotations in batch:
                    doc = nlp.make_doc(text)
                    example = Example.from_dict(doc, annotations)
                    nlp.update([example], drop=0.2, sgd=optimizer, losses=losses)

            # batches = minibatch(training_data, size=batch_sizes)
            # for batch in batches:
            #     text, labels = zip(*batch)
            #     nlp.update(
            #         text,
            #         labels,
            #         drop=0.2,
            #         sgd=optimizer,
            #         losses=loss
            #     )
            # with textcat.model.use_params(optimizer.averages):
            evaluation_results = evaluate_model(
                tokenizer=nlp.tokenizer,
                textcat=textcat,
                test_data=test_data
            )
            print(
                f"{losses['textcat']}\t{evaluation_results['precision']}"
                f"\t{evaluation_results['recall']}"
                f"\t{evaluation_results['f-score']}"
            )
    # Save model
    with nlp.use_params(optimizer.averages):
        nlp.to_disk(data_directory)

# TEST WITH TEXTCAT multilabel
# https://github.com/explosion/spaCy/discussions/8035#discussioncomment-710721
def train_model_ggo(
        training_data: list,
        test_data: list,
        iterations: int,
        data_directory: str
) -> None:
    # Build pipeline
    spacy.prefer_gpu()
    # config = spacy.util.load_config('./spacy.cfg')
    # nlp = spacy.load("en_core_web_sm", config=config)
    nlp = spacy.load("en_core_web_sm")
    # , config = {"architechture": "simple_cnn", last = True}
    if "textcat" not in nlp.pipe_names:
        nlp = spacy.blank("en")
        nlp.add_pipe("textcat", last=True)
    textcat = nlp.get_pipe("textcat")

    textcat.add_label("gratitude")
    textcat.add_label("greeting")
    textcat.add_label("other")

    # Train only textcat
    training_excluded_pipes = [
        pipe for pipe in nlp.pipe_names if pipe != "textcat"
    ]
    with nlp.disable_pipes(training_excluded_pipes):
        optimizer = nlp.begin_training()
        # Training loop
        print("Beginning training")
        print("Loss\tPrecision\tRecall\tF-score")
        batch_sizes = compounding(
            4.0, 32.0, 1.001
        )  # A generator that yields infinite series of input numbers
        for i in range(iterations):
            random.shuffle(training_data)
            losses = {}
            for batch in minibatch(training_data, size=batch_sizes):
                for text, annotations in batch:
                    doc = nlp.make_doc(text)
                    example = Example.from_dict(doc, annotations)
                    nlp.update([example], drop=0.2, sgd=optimizer, losses=losses)


            # batches = minibatch(training_data, size=batch_sizes)
            # for batch in batches:
            #     text, labels = zip(*batch)
            #     nlp.update(
            #         text,
            #         labels,
            #         drop=0.2,
            #         sgd=optimizer,
            #         losses=loss
            #     )
            # with textcat.model.use_params(optimizer.averages):
            evaluation_results = evaluate_model_ggo(
                tokenizer=nlp.tokenizer,
                textcat=textcat,
                test_data=test_data
            )
            print(
                f"{losses['textcat']}\t{evaluation_results['precision']}"
                f"\t{evaluation_results['recall']}"
                f"\t{evaluation_results['f-score']}"
            )
    # Save model
    # with nlp.use_params(optimizer.averages):
    nlp.to_disk(data_directory)


def test_model(input_data, load):
    #  Load saved trained model
    loaded_model = spacy.load(load)
    # Generate prediction
    parsed_text = loaded_model(input_data)
    # Determine prediction to return
    if parsed_text.cats["pos"] > parsed_text.cats["neg"]:
        prediction = "Positive"
        score = parsed_text.cats["pos"]
    else:
        prediction = "Negative"
        score = parsed_text.cats["neg"]

    print(
        "_______________________________________________________________\n"
        f"Review text: {input_data}\nPredicted sentiment: {prediction}"
        f"\tScore: {score}\n"
        "_______________________________________________________________\n"
    )
    return (prediction, score)


def test_model_ggo(input_data, load):
    #  Load saved trained model
    loaded_model = spacy.load(load)
    # Generate prediction
    parsed_text = loaded_model(input_data)
    # Determine prediction to return
    if (parsed_text.cats["gratitude"] > parsed_text.cats["greeting"]) and (
            parsed_text.cats["gratitude"] > parsed_text.cats["other"]):
        prediction = "gratitude"
        score = parsed_text.cats["gratitude"]
    elif (parsed_text.cats["greeting"] > parsed_text.cats["gratitude"]) and (
            parsed_text.cats["greeting"] > parsed_text.cats["other"]):
        prediction = "greeting"
        score = parsed_text.cats["greeting"]
    elif (parsed_text.cats["other"] > parsed_text.cats["gratitude"]) and (
            parsed_text.cats["other"] > parsed_text.cats["greeting"]):
        prediction = "other"
        score = parsed_text.cats["other"]
    print(
        "_______________________________________________________________\n"
        f"Review text: {input_data}\nPredicted GGO: {prediction}"
        f"\tScore: {score}\n"
        f"_______________________________________________________________\n"
    )
    return (prediction, score)


def evaluate_model(
        tokenizer, textcat, test_data: list
) -> dict:
    reviews, labels = zip(*test_data)
    reviews = (tokenizer(review) for review in reviews)
    true_positives = 0
    false_positives = 1e-8  # Can't be 0 because of presence in denominator
    true_negatives = 0
    false_negatives = 1e-8
    for i, review in enumerate(textcat.pipe(reviews)):
        true_label = labels[i]
        for predicted_label, score in review.cats.items():
            # Every cats dictionary includes both labels. You can get all
            # the info you need with just the pos label.
            if (
                    predicted_label == "neg"
            ):
                continue
            if score >= 0.5 and true_label["cats"]["pos"]:
                true_positives += 1
            elif score >= 0.5 and true_label["cats"]["neg"]:
                false_positives += 1
            elif score < 0.5 and true_label["cats"]["neg"]:
                true_negatives += 1
            elif score < 0.5 and true_label["cats"]["pos"]:
                false_negatives += 1
    precision = true_positives / (true_positives + false_positives)
    recall = true_positives / (true_positives + false_negatives)

    if precision + recall == 0:
        f_score = 0
    else:
        f_score = 2 * (precision * recall) / (precision + recall)
    return {"precision": precision, "recall": recall, "f-score": f_score}


def evaluate_model_ggo(
        tokenizer, textcat, test_data: list
) -> dict:
    reviews, labels = zip(*test_data)
    reviews = (tokenizer(review) for review in reviews)
    true_positives = 0
    false_positives = 1e-8  # Can't be 0 because of presence in denominator
    true_negatives = 0
    false_negatives = 1e-8
    for i, review in enumerate(textcat.pipe(reviews)):
        true_label = labels[i]
        for predicted_label, score in review.cats.items():
            if score >= 0.5 and true_label["cats"]["gratitude"]:
                true_positives += 1
            elif score >= 0.5 and true_label["cats"]["greeting"]:
                false_positives += 1
            elif score >= 0.5 and true_label["cats"]["other"]:
                false_positives += 1


            elif score >= 0.5 and true_label["cats"]["gratitude"]:
                false_positives += 1
            elif score >= 0.5 and true_label["cats"]["greeting"]:
                true_positives += 1
            elif score >= 0.5 and true_label["cats"]["other"]:
                false_positives += 1


            elif score >= 0.5 and true_label["cats"]["gratitude"]:
                false_positives += 1
            elif score >= 0.5 and true_label["cats"]["greeting"]:
                false_positives += 1
            elif score >= 0.5 and true_label["cats"]["other"]:
                true_positives += 1


            elif score < 0.5 and true_label["cats"]["gratitude"]:
                true_negatives += 1
            elif score < 0.5 and true_label["cats"]["greeting"]:
                false_negatives += 1
            elif score < 0.5 and true_label["cats"]["other"]:
                false_negatives += 1

            elif score < 0.5 and true_label["cats"]["gratitude"]:
                false_negatives += 1
            elif score < 0.5 and true_label["cats"]["greeting"]:
                true_negatives += 1
            elif score < 0.5 and true_label["cats"]["other"]:
                false_negatives += 1


            elif score < 0.5 and true_label["cats"]["gratitude"]:
                false_negatives += 1
            elif score < 0.5 and true_label["cats"]["greeting"]:
                false_negatives += 1
            elif score < 0.5 and true_label["cats"]["other"]:
                true_negatives += 1

    precision = true_positives / (true_positives + false_positives)
    recall = true_positives / (true_positives + false_negatives)

    if precision + recall == 0:
        f_score = 0
    else:
        f_score = 2 * (precision * recall) / (precision + recall)
    return {"precision": precision, "recall": recall, "f-score": f_score}


def nlg():
    words = []
    classes = []
    documents = []
    ignore_words = ['?', '!']
    data_file = open('data/intents.json').read()
    intents = json.loads(data_file)

    for intent in intents['intents']:
        for pattern in intent['patterns']:

            # take each word and tokenize it
            w = nltk.word_tokenize(pattern)
            words.extend(w)
            # adding documents
            documents.append((w, intent['tag']))

            # adding classes to our class list
            if intent['tag'] not in classes:
                classes.append(intent['tag'])

    words = [lemmatizer.lemmatize(w.lower()) for w in words if w not in ignore_words]
    words = sorted(list(set(words)))

    for clean in words[:]:
        if clean.isalpha() == False:
            words.remove(clean)

    classes = sorted(list(set(classes)))

    print (len(documents), "documents")

    print (len(classes), "classes", classes)

    print (len(words), "unique lemmatized words", words)


    pickle.dump(words,open('words.pkl','wb'))
    pickle.dump(classes,open('classes.pkl','wb'))

    # initializing training data
    training = []
    output_empty = [0] * len(classes)
    for doc in documents:
        # initializing bag of words
        bag = []
        # list of tokenized words for the pattern
        pattern_words = doc[0]
        # lemmatize each word - create base word, in attempt to represent related words
        pattern_words = [lemmatizer.lemmatize(word.lower()) for word in pattern_words]
        # create our bag of words array with 1, if word match found in current pattern
        for w in words:
            bag.append(1) if w in pattern_words else bag.append(0)

        # output is a '0' for each tag and '1' for current tag (for each pattern)
        output_row = list(output_empty)
        output_row[classes.index(doc[1])] = 1

        training.append([bag, output_row])
    # shuffle our features and turn into np.array
    random.shuffle(training)
    training = np.array(training)
    # create train and test lists. X - patterns, Y - intents
    train_x = list(training[:, 0])
    train_y = list(training[:, 1])
    print("Training data created")

    # Create model - 3 layers. First layer 128 neurons, second layer 64 neurons and 3rd output layer contains number of neurons
    # equal to number of intents to predict output intent with softmax
    model = Sequential()

    model.add(Dense(128, input_shape=(len(train_x[0]),), activation='relu'))
    model.add(Dropout(0.5))
    model.add(Dense(64, activation='relu'))
    model.add(Dropout(0.5))
    model.add(Dense(len(train_y[0]), activation='softmax'))


    # Compile model. Stochastic gradient descent with Nesterov accelerated gradient gives good results for this model
    sgd = SGD(lr=0.01, decay=1e-6, momentum=0.9, nesterov=True)
    model.compile(loss='categorical_crossentropy', optimizer=sgd, metrics=['accuracy'])

    # fitting and saving the model
    hist = model.fit(np.array(train_x), np.array(train_y), epochs=200, batch_size=5, verbose=1)
    model.save('chatbot_model.h5', hist)
    print(classes)
    print(words)
    print("model created")

def clean_up_sentence(sentence):
    sentence_words = nltk.word_tokenize(sentence)
    sentence_words = [lemmatizer.lemmatize(word.lower()) for word in sentence_words]
    return sentence_words

# return bag of words array: 0 or 1 for each word in the bag that exists in the sentence

def bow(sentence, words, show_details=True):
    # tokenize the pattern
    sentence_words = clean_up_sentence(sentence)
    # bag of words - matrix of N words, vocabulary matrix
    bag = [0] * len(words)
    for s in sentence_words:
        for i, w in enumerate(words):
            if w == s:
                # assign 1 if current word is in the vocabulary position
                bag[i] = 1
                if show_details:
                    print("found in bag: %s" % w)
    return (np.array(bag))

def predict_class(sentence, model):
    # filter out predictions below a threshold
    p = bow(sentence, words, show_details=False)
    res = model.predict(np.array([p]))[0]
    ERROR_THRESHOLD = 0.25
    results = [[i, r] for i, r in enumerate(res) if r > ERROR_THRESHOLD]
    # sort by strength of probability
    results.sort(key=lambda x: x[1], reverse=True)
    return_list = []
    for r in results:
        return_list.append({"intent": classes[r[0]], "probability": str(r[1])})
    return return_list

def getResponse(ints):
    data_file = open('data/intents.json').read()
    intents_json = json.loads(data_file)

    tag = ints[0]['intent']
    list_of_intents = intents_json['intents']
    for i in list_of_intents:
        if (i['tag'] == tag):
            result = random.choice(i['responses'])
            break
    return result, tag

def chatbot_response(msg):
    ints = predict_class(msg, chat_model)
    res, tag = getResponse(ints)
    return res, tag

if __name__ == "__main__":
    # IMDB
    # train_imdb, test_imdb = load_training_data_imdb(limit=2500)
    # # train_model(train_both, test_both, 20, "model_artifacts")
    #
    # # # Simple Binary Choice
    # train_choice, test_choice = load_training_data_choice()
    # train_model(train_choice, test_choice , 20, "choice_model_artifacts_new")
    # test_model('Where is the bathroom', 'choice_model_artifacts_new')

    # # IMDB + Simple Binary Choice
    # train_both = train_choice + train_imdb
    # test_both = test_choice + test_imdb
    # train_model(train_both, test_both, 20, "both_model_artifacts_new")

    # Greeting, Gratitude, Other
    # train_ggo, test_ggo = load_training_data_ggo()
    # train_model_ggo(train_ggo, test_ggo, 20, "ggo_artifacts_new")
    # test_model_ggo('yes', "ggo_artifacts_new")
    # test_model_ggo("no i want help with discounts", "ggo_artifacts_new")


    # Assistance
    # train_assist, test_assist = load_training_data_assist()
    # train_model_assist(train_assist, test_assist, 20, "assist_artifacts")
    # test_model_assist('I just want to get some tickets.', "assist_artifacts")

    # ________________________________________________________________________________________________________#

    # print("________________Present______________________")
    # MyText = "yes, lets try it"
    # response, tag = chatbot_response(MyText)
    # print(response, tag)
    # test_model(MyText, 'both_model_artifacts_new')
    # test_model_ggo(MyText, "ggo_artifacts_new")
    #
    # MyText = "no i want help with discounts"
    # response, tag = chatbot_response(MyText)
    # print(response, tag)
    # test_model(MyText, 'both_model_artifacts_new')
    # test_model_ggo(MyText, "ggo_artifacts_new")
    #
    # MyText = "this is so cool, thank you so much!"
    # response, tag = chatbot_response(MyText)
    # print(response, tag)
    # test_model(MyText, 'both_model_artifacts_new')
    # test_model_ggo(MyText, "ggo_artifacts_new")
    #
    # MyText = "gross and uncomfortable"
    # response, tag = chatbot_response(MyText)
    # print(response, tag)
    # test_model(MyText, 'both_model_artifacts_new')
    # test_model_ggo(MyText, "ggo_artifacts_new")

    # test_model(TEST_ART_OPINION, 'both_model_artifacts_new')
    # test_model(TEST_REVIEW, 'both_model_artifacts_new')

    # print("______________________________________")

    # ________________________________________________________________________________________________________#
    # nlg()
    # MyText = "yes, lets try it"
    # response, tag = chatbot_response(MyText)
    # print(response)

    # ________________________________________________________________________________________________________#

    print('§!Begin!§')
    cont, recc = listener('both_model_artifacts_new')
    while (1):
        if cont == True:
            cont, recc = listener('both_model_artifacts_new', cont)
        else:
            break
    print('~end~')


