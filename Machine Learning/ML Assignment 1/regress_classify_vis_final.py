# import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import random
from random import randrange
from sklearn.datasets import load_svmlight_file, load_iris
from sklearn.linear_model import LinearRegression, LogisticRegression
from sklearn.model_selection import train_test_split, StratifiedShuffleSplit
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

#data_files_regression = os.listdir(r"/home/u188702/upf/data/Regression Data")
#data_files_classification = os.listdir(r"/home/u188702/upf/data/Classification Data")
#data_files_regression = os.listdir(r"C:\Users\karlv\jordan-python\data\Regression Data")
#data_files_classification = os.listdir(r"C:\Users\karlv\jordan-python\data\Classification Data")
# /Users/jordan.harris/Desktop/upf/Machine Learning/data/Regression Data/abolene.txt

def regress(filename):
    training_dict = {}

    avg_training_dict = {}

    X, Y = load_svmlight_file("/Users/jordan.harris/Desktop/upf/Machine Learning/data/Regression Data/" + filename)

    X = X.todense()

    for _ in range(100):
        cuts = np.linspace(10, X.shape[0], 25, dtype=int)

        for s in cuts:
            rowid = np.random.choice(X.shape[0], size=s, replace=False)
            rand_sub_X = X[rowid, :]
            rand_sub_Y = Y[rowid]


            # Start the stopwatch / counter
            t1_start = process_time()
            row, col = rand_sub_X.shape
            print('New Shape', row, col)

            # Random subset choice to work with as X
            rowid = np.random.choice(col, replace=False)

            # Splitting the dataset into the Training set and Test set
            X_train, X_test, Y_train, Y_test = train_test_split(rand_sub_X, rand_sub_Y, test_size=1 / 3, random_state=0)

            # Fitting Simple Linear Regression to the Training set
            X_orig = rand_sub_X[:, rowid]
            fit_X_train = X_train[:, rowid]
            fit_X_test = X_test[:, rowid]


            regressor = LinearRegression()
            regressor.fit(fit_X_train, Y_train)

            # Random choice of the X or subset of Training-set:
            print('Data Set:', filename, 'Training Size:', row, 'Features:', col)
            print('Random subset of Training set Choice:', rowid)

            # Predicting something based on the randomly chosen X (feature)
            ran_x = random.choice(rand_sub_X[:, rowid])
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
            MSE = mean_squared_error(rand_sub_Y, y_pred)
            # MSE = mean_squared_error(Y_test, y_pred)
            print('Approximation Error:', MSE)

            # Calculation of R Squared Error (R2)
            r2 = r2_score(rand_sub_Y, y_pred)
            print('R-square:', r2)
            # R-square range from 0 to 1; 1 means the number of the
            # room perfectly explained the housing price through the model;
            # 0 means the number of room explained nothing of the price

            training_dict[row, col] = [MSE], [cpu_time], [r2]
            print('_________________________________________________________________')
            print('\n')

        if avg_training_dict == {}:
            avg_training_dict = training_dict.copy()
        else:
            for k, v in training_dict.keys():
                avg_training_dict[k, v][0].append(training_dict[k, v][0][0])
                avg_training_dict[k, v][1].append(training_dict[k, v][1][0])
                avg_training_dict[k, v][2].append(training_dict[k, v][2][0])


    result = OrderedDict(sorted(avg_training_dict.items(), key=lambda x: x[0][0]))

    print('Reordered Training Dict:', result)
    print('\n')

    # Plot the approximation error (square loss) on the training set as a function
    # of the number of samples N (i.e. data points in the training set).
    print('Approximation Error x N Plot')

    processMSE = [None] * 100
    processCPU = [None] * 100
    processR2 = [None] * 100

    for _ in range(100):
        for k, v in result:

            if processMSE[_] == None:
                processMSE[_] = [result[k, v][0][_]]
                processCPU[_] = [result[k, v][1][_]]
                processR2[_] = [result[k, v][2][_]]
            else:
                processMSE[_].append(result[k, v][0][_])
                processCPU[_].append(result[k, v][1][_])
                processR2[_].append(result[k, v][2][_])

    AVG_MSE = np.average(processMSE, axis=0)
    AVG_CPU = np.average(processCPU, axis=0)
    AVG_R2 = np.average(processR2, axis=0)

    print('\n')
    print('_________________________________________________________________')
    print('\n')


    print('Training Set Sizes:', cuts)
    print('Feature:', col)
    print('AVG MSE Set:', AVG_MSE )
    print('CPU Time Set:', AVG_CPU)
    print('R-square Set:', AVG_R2)

    viz_MSE = plt
    viz_MSE.scatter(cuts, AVG_MSE, color='red')
    viz_MSE.plot(cuts, AVG_MSE, color='blue')
    viz_MSE.title('Linear Regression: Approximation Error x N Plot')
    viz_MSE.xlabel('Training Size')
    viz_MSE.ylabel('MSE')
    #viz_MSE.show()
    plt.savefig(r'data/graphs/linear_error.png')
    plt.clf()
    plt.cla()
    plt.close()

    viz_CPU = plt
    viz_CPU.scatter(cuts, AVG_CPU, color='red')
    viz_CPU.plot(cuts, AVG_CPU, color='blue')
    viz_CPU.title('Linear Regression: CPU Time x N Plot')
    viz_CPU.xlabel('Training Size')
    viz_CPU.ylabel('CPU Time')
    #viz_CPU.show()
    plt.savefig(r'data/graphs/linear_cpu.png')
    plt.clf()
    plt.cla()
    plt.close()

    print('\n')
    print('_________________________________________________________________')
    print('\n')

def classify(filename):
    training_dict = {}
    avg_training_dict = {}

    X, Y = load_svmlight_file("data/Classification Data/" + filename)
    X = X.todense()

    for _ in range(100):
        cuts = np.linspace(10, X.shape[0], 25, dtype=int)

        for s in cuts:
            rowid = np.random.choice(X.shape[0], size=s, replace=False)
            rand_sub_X = X[rowid, :]
            rand_sub_Y = Y[rowid]

            # Start the stopwatch / counter
            t1_start = process_time()

            row, col = rand_sub_X.shape
            print('New Shape', row, col)

            # Random subset choice to work with as X
            rowid = np.random.choice(col, replace=False)


            # Splitting the dataset into the Training set and Test set
            X_train, X_test, Y_train, Y_test = train_test_split(rand_sub_X, rand_sub_Y, test_size=1 / 3,
                                                                random_state=0)

            # Fitting Simple Linear Regression to the Training set
            X_orig = rand_sub_X[:, rowid]
            fit_X_train = X_train[:, rowid]
            fit_X_test = X_test[:, rowid]

            logisticRegr = LogisticRegression(solver='liblinear')
            logisticRegr.fit(fit_X_train, Y_train)

            # Random choice of the X or subset of Training-set:
            print('Data Set:', filename, 'Training Size:', row, 'Features:', col)
            print('Random subset of Training set Choice:', rowid)

            print('_________________________________________________________________')
            print('\n')
            # Predicting from the original set
            y_pred = logisticRegr.predict(X_orig)

            # Use score method to get accuracy of model
            score = logisticRegr.score(fit_X_test, Y_test)
            print(score)

            # Stop the stopwatch / counter
            t1_stop = process_time()
            cpu_time = t1_stop - t1_start
            print("CPU time:", cpu_time)

            # Calculation of Accuracy Score (AS)
            AS = accuracy_score(rand_sub_Y, y_pred)
            print('Approximation Error:', AS)

            training_dict[row, col] = [AS], [cpu_time], [score]


        if avg_training_dict == {}:
            avg_training_dict = training_dict.copy()
        else:
            for k, v in training_dict.keys():
                avg_training_dict[k, v][0].append(training_dict[k, v][0][0])
                avg_training_dict[k, v][1].append(training_dict[k, v][1][0])
                avg_training_dict[k, v][2].append(training_dict[k, v][2][0])

    result = OrderedDict(sorted(avg_training_dict.items(), key=lambda x: x[0][0]))

    #  print('Reordered Training Dict:', result)
    # print('\n')

    processAS = [None] * 100
    processCPU = [None] * 100
    processSCORE = [None] * 100

    for _ in range(100):
        for k, v in result:

            if processAS[_] == None:
                processAS[_] = [result[k, v][0][_]]
                processCPU[_] = [result[k, v][1][_]]
                processSCORE[_] = [result[k, v][2][_]]
            else:
                processAS[_].append(result[k, v][0][_])
                processCPU[_].append(result[k, v][1][_])
                processSCORE[_].append(result[k, v][2][_])

    AVG_AS = np.average(processAS, axis=0)
    AVG_CPU = np.average(processCPU, axis=0)
    AVG_SCORE = np.average(processSCORE, axis=0)

    print('\n')
    print('_________________________________________________________________')
    print('\n')


    print('Training Set Sizes:', cuts)
    print('Feature:', col)
    print('AVG AS:', AVG_AS)
    print('CPU Time:', AVG_CPU)
    print('score method to get accuracy of model:', AVG_SCORE)

    viz_AS = plt
    viz_AS.scatter(cuts, AVG_AS, color='red')
    viz_AS.plot(cuts, AVG_AS, color='blue')
    viz_AS.title('Logistic Regression: Mean Accuracy Error x N Plot')
    viz_AS.xlabel('Training Size')
    viz_AS.ylabel('AS')
    # viz_MSE.show()
    plt.savefig(r'data/graphs/logistic_error.png')
    plt.clf()
    plt.cla()
    plt.close()

    viz_CPU = plt
    viz_CPU.scatter(cuts, AVG_CPU, color='red')
    viz_CPU.plot(cuts, AVG_CPU, color='blue')
    viz_CPU.title('Logistic Regression: CPU Time x N Plot')
    viz_CPU.xlabel('Training Size')
    viz_CPU.ylabel('CPU Time')
    # viz_CPU.show()
    plt.savefig(r'data/graphs/logistic_cpu.png')
    plt.clf()
    plt.cla()
    plt.close()



if __name__ == "__main__":
    print()

    regress("abolene.txt")
    # classify("glass.txt")
