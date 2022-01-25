# import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import random
from random import randrange
from sklearn.datasets import load_svmlight_file, load_iris
from sklearn.linear_model import LinearRegression, LogisticRegression
from sklearn.model_selection import train_test_split, StratifiedShuffleSplit
from sklearn.metrics import mean_squared_error, r2_score, accuracy_score
from sklearn.utils import shuffle
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

def regress(filename):
    # results_dict = {}
    X, Y = load_svmlight_file("data/Regression Data/" + filename)

    # X = X.todense()
    subsets = np.linspace(10, X.shape[0], 35, dtype=int)
    "Selects susbets of increasing size"
    avg_results_dict = {}
    def avg_regress(X, Y, subset, n):

        avg_results_dict = {}
        for _ in range(n):
            results_dict = {}
            X, Y = shuffle(X, Y)
            # for increment in subset:
            val = 0
            for sub in range(X.shape[0]):
                increment = subset[val]
                sub_X, sub_Y = X[:increment], Y[:increment]

                # Start the stopwatch / counter
                t1_start = process_time()

                # maybe not ################################
                # Splitting the dataset into the Training set and Test set
                X_train, X_test, Y_train, Y_test = train_test_split(sub_X, sub_Y, test_size=1 / 3, random_state=0)

                # Random subset choice to work with as X
                row, col = sub_X.shape
                rowid = np.random.choice(col, replace=False)

                # Fitting Simple Linear Regression to the Training set
                X_orig = sub_X[:, rowid]
                fit_X_train = X_train[:, rowid]
                fit_X_test = X_test[:, rowid]
                # maybe not ################################

                regressor = LinearRegression()
                regressor.fit(fit_X_train, Y_train)

                # Stop the stopwatch / counter
                t1_stop = process_time()
                cpu_time = t1_stop - t1_start
                print("CPU time:", cpu_time)

                # Random choice of the X or subset of Training-set:
                print('Data Set:', filename, 'Training Size:', row, 'Features:', col)
                # Predicting from the original set
                y_pred = regressor.predict(X_orig)

                # Calculation of Mean Squared Error (MSE)
                MSE = mean_squared_error(sub_Y, y_pred)
                print('Approximation Error:', MSE)

                # Calculation of R Squared Error (R2)
                r2 = r2_score(sub_Y, y_pred)
                print('R-square:', r2)
                # R-square range from 0 to 1; 1 means the number of the
                # room perfectly explained the housing price through the model;
                # 0 means the number of room explained nothing of the price

                results_dict[increment] = {}
                results_dict[increment]['mse'] = MSE
                results_dict[increment]['cpu-time'] = [cpu_time]
                results_dict[increment]['R-square'] = [r2]
                results_dict[increment]["coef"] = regressor.coef_
                print('_________________________________________________________________')
                print('\n')
                print()
                val += 1
                if val == subset.size:
                    break
                increment = subset[val]

            for segment in results_dict:
                if segment in avg_results_dict:
                    avg_results_dict[segment]["mse"].append(results_dict[segment]["mse"])
                    avg_results_dict[segment]["cpu-time"].append(results_dict[segment]["cpu-time"][0])
                    avg_results_dict[segment]["R-square"].append(results_dict[segment]["R-square"][0])
                    avg_results_dict[segment]["coef"].append(results_dict[segment]["coef"])
                else:
                    avg_results_dict[segment] = {}
                    avg_results_dict[segment]["mse"] = [results_dict[segment]["mse"]]
                    avg_results_dict[segment]["cpu-time"] = results_dict[segment]["cpu-time"]
                    avg_results_dict[segment]["R-square"] = results_dict[segment]["R-square"]
                    avg_results_dict[segment]["coef"] = [results_dict[segment]["coef"]]

        AVG_MSE = []
        AVG_CPU = []
        AVG_R2 = []
        COEF = []

        for key in avg_results_dict:
            AVG_MSE.append(np.average(avg_results_dict[key]["mse"]))
            AVG_CPU.append(np.average(avg_results_dict[key]["cpu-time"]))
            AVG_R2.append(np.average(avg_results_dict[key]["R-square"]))
            COEF.append(avg_results_dict[key]["coef"])

        return AVG_MSE, AVG_CPU, AVG_R2, COEF, results_dict

    AVG_MSE, AVG_CPU, AVG_R2, COEF, results_dict = avg_regress(X, Y, subsets, 50)

    print('\n')
    print('_________________________________________________________________')
    print('\n')


    print('Training Set Sizes:', subsets)
    # print('Feature:', col)
    # print('AVG MSE Set:', AVG_MSE )
    # print('CPU Time Set:', AVG_CPU)
    # print('R-square Set:', AVG_R2)

    theta = np.polyfit(subsets, AVG_MSE, 2)
    best_fit = theta[2] + theta[1] * pow(subsets, 1) + theta[0] * pow(subsets, 2)\

    viz_MSE = plt
    viz_MSE.scatter(subsets, AVG_MSE, color='red')
    viz_MSE.plot(subsets, AVG_MSE, color='blue')
    # plt.plot(subsets, best_fit, 'r')
    viz_MSE.title('Linear Regression: Approximation Error x N Plot')
    viz_MSE.xlabel('Training Size')
    viz_MSE.ylabel('MSE')
    viz_MSE.show()
    plt.savefig(r'data/graphs/linear_error.png')
    plt.clf()
    plt.cla()
    plt.close()

    viz_CPU = plt
    viz_CPU.scatter(subsets, AVG_CPU, color='red')
    viz_CPU.plot(subsets, AVG_CPU, color='blue')
    viz_CPU.title('Linear Regression: CPU Time x N Plot')
    viz_CPU.xlabel('Training Size')
    viz_CPU.ylabel('CPU Time')
    viz_CPU.show()
    plt.savefig(r'data/graphs/linear_cpu.png')
    plt.clf()
    plt.cla()
    plt.close()

    # subsets = []
    # coefs = []
    # for subset, result in results_dict.items():
    #     subsets.append(subset)
    #     coefs.append(result["coef"])
    #
    # # Plot coefs against N
    # plot = plt.plot(subsets, coefs)
    # labels = ["Sex", "Length", "Diameter", "Height", "Whole weight", "Shucked weight", "Viscera weight", "Shell weight"]
    # plt.legend(plot, labels, loc="upper right")
    # plt.show()
    #
    # print('\n')
    # print('_________________________________________________________________')
    # print('\n')



def classify(filename):
    # results_dict = {}
    X, Y = load_svmlight_file("data/Classification Data/" + filename)

    # X = X.todense()
    subsets = np.linspace(10, X.shape[0], 25, dtype=int)
    "Selects susbets of increasing size"
    avg_results_dict = {}
    def avg_classify(X, Y, subset, n):

        avg_results_dict = {}
        for _ in range(n):
            results_dict = {}
            X, Y = shuffle(X, Y)
            # for increment in subset:
            val = 0
            for sub in range(X.shape[0]):
                increment = subset[val]
                sub_X, sub_Y = X[:increment], Y[:increment]

                # # Start the stopwatch / counter
                t1_start = process_time()
                classifier = LogisticRegression(penalty="none").fit(sub_X, sub_Y)

                end = process_time()
                # # Stop the stopwatch / counter
                t1_stop = process_time()
                cpu_time = t1_stop - t1_start
                print("CPU time:", cpu_time)

                # Random choice of the X or subset of Training-set:
                print('Data Set:', filename)
                # Predicting from the original set
                y_pred = classifier.predict(sub_X)

                # Calculation of Accuracy Score (AS)
                AS = accuracy_score(sub_Y, y_pred)
                print('Approximation Error:', AS)

                results_dict[increment] = {}
                results_dict[increment]['approx'] = AS
                results_dict[increment]['cpu-time'] = [cpu_time]
                print('_________________________________________________________________')
                print('\n')
                print()
                val += 1
                if val == subset.size:
                    break
                increment = subset[val]

            for segment in results_dict:
                if segment in avg_results_dict:
                    avg_results_dict[segment]["approx"].append(results_dict[segment]["approx"])
                    avg_results_dict[segment]["cpu-time"].append(results_dict[segment]["cpu-time"][0])
                else:
                    avg_results_dict[segment] = {}
                    avg_results_dict[segment]["approx"] = [results_dict[segment]["approx"]]
                    avg_results_dict[segment]["cpu-time"] = results_dict[segment]["cpu-time"]

        AVG_AS = []
        AVG_CPU = []

        for key in avg_results_dict:
            AVG_AS.append(np.average(avg_results_dict[key]["approx"]))
            AVG_CPU.append(np.average(avg_results_dict[key]["cpu-time"]))

        return AVG_AS, AVG_CPU, results_dict

    AVG_AS, AVG_CPU, results_dict = avg_classify(X, Y, subsets, 3)

    print('\n')
    print('_________________________________________________________________')
    print('\n')


    print('Training Set Sizes:', subsets)
    print('CPU Time Set:', AVG_AS)
    print('R-square Set:', AVG_CPU)

    viz_AS = plt
    viz_AS.scatter(subsets, AVG_AS, color='red')
    viz_AS.plot(subsets, AVG_AS, color='blue')
    viz_AS.title('Logistic Regression: Mean Accuracy Error x N Plot')
    viz_AS.xlabel('Training Size')
    viz_AS.ylabel('AS')
    viz_MSE.show()
    plt.savefig(r'data/graphs/logistic_error.png')
    plt.clf()
    plt.cla()
    plt.close()

    viz_CPU = plt
    viz_CPU.scatter(subsets, AVG_CPU, color='red')
    viz_CPU.plot(subsets, AVG_CPU, color='blue')
    viz_CPU.title('Logistic Regression: CPU Time x N Plot')
    viz_CPU.xlabel('Training Size')
    viz_CPU.ylabel('CPU Time')
    viz_CPU.show()
    plt.savefig(r'data/graphs/linear_cpu.png')
    plt.clf()
    plt.cla()
    plt.close()

if __name__ == "__main__":

    regress("abolene.txt")
    # classify("glass.txt")
