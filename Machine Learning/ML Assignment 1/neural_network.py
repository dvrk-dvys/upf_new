import pandas as pd
import numpy as np
from sklearn.neural_network import MLPClassifier
from sklearn.datasets import load_iris
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import classification_report, confusion_matrix, plot_confusion_matrix
from sklearn.model_selection import validation_curve, train_test_split
from sklearn.datasets import load_svmlight_file, load_iris
import os
import matplotlib.pyplot as plt




def neural_network(filename):
   # X, y = load_svmlight_file("data/Classification Data/" + filename)

# ________________________________________________
    iris = load_iris()
    X = iris.data
    y = iris.target

   # X = pd.DataFrame(iris.data, columns=iris.feature_names)
   # y = iris.target
# ________________________________________________

    X_train, X_test, y_train, y_test = train_test_split(X, y, random_state=1, test_size=0.2)
    #sc_X = StandardScaler()
   # X_train_scaled = sc_X.fit_transform(X_train)
   # X_test_scaled = sc_X.transform(X_test)

    alpha_values = np.array([1e-5, 1e-4, 1e-3, 1e-2, 1e-1, 1e-0, 1e1, 1e2, 1e3, 1e4, 1e5])
    alpha_size = len(alpha_values)

    #clf = MLPClassifier(hidden_layer_sizes=(256, 128, 64, 32), activation="relu", random_state=1).fit(X_train_scaled, y_train)

    clf = MLPClassifier(hidden_layer_sizes=(150), activation='logistic', max_iter=500).fit(X_train, y_train)
    training_error, validation_error = validation_curve(estimator=clf, X=X, y=y, param_name='alpha',
                                                        param_range=alpha_values, cv=5, scoring='accuracy')
    plt.plot(training_error.mean(axis=1), label="training error", color="red")
    plt.plot(validation_error.mean(axis=1), label="validation error", color="pink")
    plt.title("Training and Validation Error")
    plt.xlabel("Alpha Values")
    plt.ylabel("Accuracy")
    plt.legend()
    plt.show()

    y_pred = clf.predict(X_test)
    print(clf.score(X_test, y_test))


if __name__ == "__main__":

    print('')
    #neural_network("diabetes.txt")
    neural_network("iris.txt")
    #neural_network("dna_scale.txt")


    #https://stackoverflow.com/questions/46028914/multilayer-perceptron-convergencewarning-stochastic-optimizer-maximum-iterat