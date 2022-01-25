import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import random
from sklearn.datasets import load_svmlight_file, load_iris
from sklearn.linear_model import LinearRegression, LogisticRegression
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error, r2_score, accuracy_score
from sklearn.feature_extraction.text import TfidfVectorizer
from collections import OrderedDict
from time import process_time
from statistics import mean

import os

# Importing the dataset

# example: ABOLENE
# y:#Rings / integer / -- / +1.5 gives the age in years    <<< To be predicted!!

# 1: Sex / nominal / -- / M, F, and I (infant)
# 2: Length / continuous / mm / Longest shell measurement
# 3: Diameter / continuous / mm / perpendicular to length
# 4: Height / continuous / mm / with meat in shell
# 5: Whole weight / continuous / grams / whole abalone
# 6: Shucked weight / continuous / grams / weight of meat
# 7: Viscera weight / continuous / grams / gut weight (after bleeding)
# 8: Shell weight / continuous / grams / after being dried

# dataset = pd.read_csv('data/abolene.txt')
# Small
# X, Y = load_svmlight_file('data/triazines.txt')
# X, Y = load_svmlight_file('data/bodyfat.txt')
# X, Y = load_svmlight_file('data/mpg.txt')
# X, Y = load_svmlight_file('data/boston_housing.txt')

# Medium
# X, Y = load_svmlight_file('data/space_ga.txt')
# X, Y = load_svmlight_file('data/abolene.txt')
# X, Y = load_svmlight_file('data/cadata.txt')

# Large


data_files_regression = os.listdir(r"/home/u188702/upf/data/Regression Data")
data_files_classification = os.listdir(r"/home/u188702/upf/data/Classification Data")

# data_files_regression = os.listdir(r"C:\Users\karlv\jordan-python\data\Regression Data")
# data_files_classification = os.listdir(r"C:\Users\karlv\jordan-python\data\Classification Data")

# data_files = os.listdir(r"C:\Users\karlv\jordan-python\data\Regression Data Scale")



def iterate_files(data_files, root):
    training_size_set = []
    feature_size_set = []
    training_dict = {}

    for filename in data_files:
        X, Y = load_svmlight_file("data/" + root + "/" + filename)
        #X, Y = load_svmlight_file("data/" + root + "/splice.txt")

        # X, Y = load_svmlight_file("data/Regression Data Scale/" + filename)

        # Start the stopwatch / counter
        t1_start = process_time()
        row, col = X.shape

        # Random subset choice to work with as X
        rowid = np.random.choice(col, replace=False)
        # ?? rowid = np.random.choice(data_X.shape[0], size=s, replace=False#
        # ?? What is S??

        # Splitting the dataset into the Training set and Test set
        X_train, X_test, Y_train, Y_test = train_test_split(X, Y, test_size=1 / 3, random_state=0)

        # Fitting Simple Linear Regression to the Training set
        X_orig = X[:, rowid].toarray()
        fit_X_train = X_train[:, rowid].toarray()
        fit_X_test = X_test[:, rowid].toarray()

        if root == 'Regression Data':

            regressor = LinearRegression()
            regressor.fit(fit_X_train, Y_train)

            # Visualizing the Training set results
            # viz_train = plt
            # viz_train.scatter(fit_X_train, Y_train, color='red')
            # viz_train.plot(fit_X_train, regressor.predict(fit_X_train), color='blue')
            # viz_train.show()

            # Visualizing the Test set results
            # viz_test = plt
            # viz_test.scatter(fit_X_test, Y_test, color='red')
            # viz_test.plot(fit_X_test, regressor.predict(fit_X_test), color='blue')
            # viz_test.show()

            # Random choice of the X or subset of Training-set:
            print('Data Set:', filename, 'Training Size:', row, 'Features:', col)
            print('Random subset of Training set Choice:', rowid)

            # Predicting something based on the randomly chosen X (feature)
            ran_x = random.choice(X[:, rowid].toarray())
            ran_y_pred = regressor.predict(ran_x.reshape(1, 1))
            print('Prediction from Random Choice:', ran_y_pred)

            # Predicting the Test set results
            # y_pred = regressor.predict(fit_X_test)
            # print(test_y_pred)

            # Predicting from the original set
            y_pred = regressor.predict(X_orig)
            # print('Prediction from Original Set:', y_pred)

            # Stop the stopwatch / counter
            t1_stop = process_time()
            cpu_time = t1_stop - t1_start
            print("CPU time:", cpu_time)

            # Calculation of Mean Squared Error (MSE)
            MSE = mean_squared_error(Y, y_pred)
            # MSE = mean_squared_error(Y_test, y_pred)
            print('Approximation Error:', MSE)

            # Calculation of R Squared Error (R2)
            r2 = r2_score(Y, y_pred)
            print('R-square:', r2)
            # R-square range from 0 to 1; 1 means the number of the
            # room perfectly explained the housing price through the model;
            # 0 means the number of room explained nothing of the price
        else:
            MSE = 0
            r2 = 0

        if root == 'Classification Data':

            # all parameters not specified are set to their defaults
            logisticRegr = LogisticRegression()
            logisticRegr.fit(X_train, Y_train)

            # Visualizing the Training set results
            # viz_train = plt
            # viz_train.scatter(fit_X_train, Y_train, color='red')
            # viz_train.plot(fit_X_train, logisticRegr.predict(fit_X_train), color='blue')
            # viz_train.show()

            # Visualizing the Test set results
            # viz_test = plt
            # viz_test.scatter(fit_X_test, Y_test, color='red')
            # viz_test.plot(fit_X_test, logisticRegr.predict(fit_X_train), color='blue')
            # viz_test.show()

            # Random choice of the X or subset of Training-set:
            print('Data Set:', filename, 'Training Size:', row, 'Features:', col)
            print('Random subset of Training set Choice:', rowid)


            # Predicting something based on the randomly chosen X (feature)
            # Returns a NumPy Array
            logisticRegr.predict(X_test[0].reshape(1, -1))


            # Predicting the Test set results
            #y_pred = logisticRegr.predict(fit_X_test)

            # Predicting from the original set
            y_pred = logisticRegr.predict(X)

            # Use score method to get accuracy of model
            score = logisticRegr.score(X_test, Y_test)
            print(score)

            # Stop the stopwatch / counter
            t1_stop = process_time()
            cpu_time = t1_stop - t1_start
            print("CPU time:", cpu_time)

            # Calculation of Accuracy Score (AS)
            AS = accuracy_score(Y, y_pred, normalize=False)
            print('Approximation Error:', AS)


        else:
            AS = 0

        # ___________________________________________________________________________



        # Stop the stopwatch / counter
        t1_stop = process_time()
        cpu_time = t1_stop - t1_start
        print("CPU time:", cpu_time)

        print('\n')
        print('_________________________________________________________________')
        print('\n')
        training_size_set.append(row)
        feature_size_set.append(col)
        training_dict[row, col] = [MSE], [cpu_time], [r2], [AS]

    return training_size_set, feature_size_set, training_dict

def regress(data_files):
    avg_training_dict = {}

    for _ in range(50):
        training_size_set, feature_size_set, training_dict = iterate_files(data_files, 'Regression Data')

        if avg_training_dict == {}:
            avg_training_dict = training_dict
        else:
            for k, v in training_dict.keys():
                avg_training_dict[k, v][0].append(training_dict[k, v][0][0])
                avg_training_dict[k, v][1].append(training_dict[k, v][1][0])
                avg_training_dict[k, v][1].append(training_dict[k, v][2][0])
                avg_training_dict[k, v][1].append(training_dict[k, v][3][0])


    result = OrderedDict(sorted(avg_training_dict.items(), key=lambda x: x[0][0]))

    print('Reordered Training Dict:', result)
    print('\n')

    # Plot the approximation error (square loss) on the training set as a function
    # of the number of samples N (i.e. data points in the training set).
    print('Approximation Error x N Plot')
    processMSE = []
    processCPU = []
    processR2 = []
    processTS = []

    for k, v in result:
        processMSE.append(np.average(result[k, v][0]))
        processCPU.append(np.average(result[k, v][1]))
        processR2.append(np.average(result[k, v][2]))
        processTS.append([k])  # y-axis

    # processMSE = processMSE.reshape([30, 1])

    print('Training Size Set:', processTS)
    print('Feature:', feature_size_set)
    print('AVG MSE Set:', processMSE)
    print('CPU Time Set:', processCPU)
    print('R-square Set:', processR2)

    viz_MSE = plt
    viz_MSE.scatter(processTS, processMSE, color='red')
    viz_MSE.plot(processTS, processMSE, color='blue')
    viz_MSE.title('Linear Regression: Approximation Error x N Plot')
    viz_MSE.xlabel('Training Size')
    viz_MSE.ylabel('MSE')
    viz_MSE.show()

    # ???The regression loses its ability to successfully predict the label when the
    # training set is not proportionally large enough to sole the complexity of
    # the problem???

    viz_CPU = plt
    viz_CPU.scatter(processTS, processCPU, color='red')
    viz_CPU.plot(processTS, processCPU, color='blue')
    viz_CPU.title('Linear Regression: CPU Time x N Plot')
    viz_CPU.xlabel('Training Size')
    viz_CPU.ylabel('CPU Time')
    viz_CPU.show()

    print('\n')
    print('_________________________________________________________________')
    print('\n')

def classify(data_files):
    avg_training_dict = {}

    for _ in range(1):
        training_size_set, feature_size_set, training_dict = iterate_files(data_files, 'Classification Data')

        if avg_training_dict == {}:
            avg_training_dict = training_dict
        else:
            for k, v in training_dict.keys():
                avg_training_dict[k, v][0].append(training_dict[k, v][0][0])
                avg_training_dict[k, v][1].append(training_dict[k, v][1][0])
                avg_training_dict[k, v][1].append(training_dict[k, v][2][0])
                avg_training_dict[k, v][1].append(training_dict[k, v][3][0])


    print('\n')
    print('_________________________________________________________________')
    print('\n')

    result = OrderedDict(sorted(avg_training_dict.items(), key=lambda x: x[0][0]))

    print('Reordered Training Dict:', result)
    print('\n')

    # Plot the approximation error (square loss) on the training set as a function
    # of the number of samples N (i.e. data points in the training set).
    print('Approximation Error x N Plot')
    processAS = []
    processCPU = []
    processR2 = []
    processTS = []

    for k, v in result:
        processAS.append(np.average(result[k, v][3]))
        processCPU.append(np.average(result[k, v][1]))
        processR2.append(np.average(result[k, v][2]))
        processTS.append([k])  # y-axis


    print('Training Size Set:', processTS)
    print('Feature:', feature_size_set)
    print('AVG AS Set:', processAS)
    print('CPU Time Set:', processCPU)

    viz_AS = plt
    viz_AS.scatter(processTS, processAS, color='red')
    viz_AS.plot(processTS, processAS, color='blue')
    viz_AS.title('Logistic Regression: Mean Accuracy x N Plot')
    viz_AS.xlabel('Training Size')
    viz_AS.ylabel('AS')
    viz_AS.show()

    # ???The regression loses its ability to successfully predict the label when the
    # training set is not proportionally large enough to sole the complexity of
    # the problem???

    viz_CPU = plt
    viz_CPU.scatter(processTS, processCPU, color='red')
    viz_CPU.plot(processTS, processCPU, color='blue')
    viz_CPU.title('Logistic Regression: CPU Time x N Plot')
    viz_CPU.xlabel('Training Size')
    viz_CPU.ylabel('CPU Time')
    viz_CPU.show()

    print('\n')
    print('_________________________________________________________________')
    print('\n')


if __name__ == "__main__":

    regress(data_files_regression)
    classify(data_files_classification)