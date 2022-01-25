from spacy.training import Example
from sklearn.model_selection import train_test_split
import spacy
# spacy.cli.download("en_core_web_sm")
# spacy.load('en_core_web_sm')
from spacy.util import minibatch, compounding
import nltk
from nltk.stem import WordNetLemmatizer
lemmatizer = WordNetLemmatizer()
import random



def load_training_data_choice():
    train_neg_file = "/Users/jordan.harris/PycharmProjects/Adevinta/data/training_data/trunc/train_trunc_negative.txt"
    train_pos_file = "/Users/jordan.harris/PycharmProjects/Adevinta/data/training_data/trunc/train_trunc_positive.txt"
    test_neg_file = "/Users/jordan.harris/PycharmProjects/Adevinta/data/training_data/trunc/test_trunc_negative.txt"
    test_pos_file = "/Users/jordan.harris/PycharmProjects/Adevinta/data/training_data/trunc/test_trunc_positive.txt"

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



def train_model(
        training_data: list,
        test_data: list,
        iterations: int,
        data_directory: str
) -> None:
    # Build pipeline
    spacy.prefer_gpu()
    nlp = spacy.load("en_core_web_sm")
    if "textcat" not in nlp.pipe_names:
        nlp = spacy.blank("en")
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


if __name__ == "__main__":
    # # # Simple Binary Choice
    # train_choice, test_choice = load_training_data_choice()
    # train_model(train_choice, test_choice, 2, "bot_model_artifacts_trunc")
    # columns = ['deviceisbot,screensize,published,published_dt,sessionid,environmentid,type,devicetype,useragent,objecttype,eventname,event_id,timedelta,viewportsize']
    test_trunc_neg = 'false,1125x2436,Close,mobile,iOSSPTTracker1.0.1,Conversation,Conversation Close,0:00:11,1100x650'
    test_trunc_neg1 = 'false,1170x2532,Report,mobile,iOSSPTTracker1.0.1,Account,Report user,0:00:00,Null'
    test_trunc_neg2 = 'false,1080x2186,Close,mobile,Android-Pulse-Tracker/8.0.1,Conversation,Conversation Close,0:00:00,Null'
    test_trunc_pos = 'false,385x854,mobile,Mozilla/5.0 (Linux"; Android 11;" SM-A127F) AppleWebKit/537.36 (KHTML like Gecko) Chrome/87.0.4280.141 Mobile Safari/537.36,Message,User click in send button reply conversation,0:00:14,Null'

    # imprefect would have to add more data to corpus for headerless cases! Not picking up on no browser difference
    test_trunc_pos1 = 'false,1080x2094,Click,mobile,Android-Pulse-Tracker/8.0.1,UIElement,Conversation Close,0:00:40,1080x2094'

    test_model(test_trunc_neg, "bot_model_artifacts_trunc")
    test_model(test_trunc_pos, "bot_model_artifacts_trunc")
    test_model(test_trunc_neg1, "bot_model_artifacts_trunc")
    test_model(test_trunc_pos1, "bot_model_artifacts_trunc")
