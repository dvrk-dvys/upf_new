import pandas as pd
import numpy as np
from sklearn.svm import SVC
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import classification_report, confusion_matrix,  accuracy_score, precision_score, recall_score
from sklearn.model_selection import StratifiedShuffleSplit, train_test_split, GridSearchCV, cross_val_score
from sklearn.datasets import load_svmlight_file, load_iris
import os
import matplotlib.pyplot as plt
from matplotlib.colors import Normalize


# Utility function to move the midpoint of a colormap to be around
# the values of interest.

class MidpointNormalize(Normalize):

    def __init__(self, vmin=None, vmax=None, midpoint=None, clip=False):
        self.midpoint = midpoint
        Normalize.__init__(self, vmin, vmax, clip)

    def __call__(self, value, clip=None):
        x, y = [self.vmin, self.midpoint, self.vmax], [0, 0.5, 1]
        return np.ma.masked_array(np.interp(value, x, y))

# #############################################################################


def kernel_SVM(filename):
    X, y = load_svmlight_file("data/Classification Data/" + filename)

# ________________________________________________
    #iris = load_iris()
    #X = iris.data
    #y = iris.target
# ________________________________________________

    # Dataset for decision function visualization: we only keep the first two
    # features in X and sub-sample the dataset to keep only 2 classes and
    # make it a *binary classification* problem.

    X_2d = X[:, :2]
    X_2d = X_2d[y > 0]
    y_2d = y[y > 0]
    y_2d -= 1

# _____________________?????????IS THIS NECESSARY????????????? ___________________________
    # It is usually a good idea to scale the data for SVM training.
    # We are cheating a bit in this example in scaling all of the data,
    # instead of fitting the transformation on the training set and
    # just applying it on the test set.

    scaler = StandardScaler(with_mean=False)
    X = scaler.fit_transform(X)
    X_2d = scaler.fit_transform(X_2d)

# _____________________?????????IS THIS NECESSARY????????????? ___________________________

    row, col = X.shape
    print('Data Set:', filename, 'Training Size:', row, 'Features:', col)

    C_range = np.logspace(-2, 10, 13)
    gamma_range = np.logspace(-9, 3, 13)
    param_grid = dict(gamma=gamma_range, C=C_range)
    cv = StratifiedShuffleSplit(n_splits=5, test_size=0.2, random_state=42)
    grid = GridSearchCV(SVC(), param_grid=param_grid, cv=cv)
    grid.fit(X, y)

    print("The best parameters are %s with a score of %0.2f"
          % (grid.best_params_, grid.best_score_))

    # Now we need to fit a classifier for all parameters in the 2d version
    # (we use a smaller set of parameters here because it takes a while to train)

    C_2d_range = [1e-2, 1, 1e2]
    gamma_2d_range = [1e-1, 1, 1e1]
    classifiers = []
    for C in C_2d_range:
        for gamma in gamma_2d_range:
            clf = SVC(C=C, gamma=gamma)
            clf.fit(X_2d, y_2d)
            classifiers.append((C, gamma, clf))



# #############################################################################
# Visualization
#
# draw visualization of parameter effects


    scores = grid.cv_results_['mean_test_score'].reshape(len(C_range),
                                                         len(gamma_range))

    # Draw heatmap of the validation accuracy as a function of gamma and C
    #
    # The score are encoded as colors with the hot colormap which varies from dark
    # red to bright yellow. As the most interesting scores are all located in the
    # 0.92 to 0.97 range we use a custom normalizer to set the mid-point to 0.92 so
    # as to make it easier to visualize the small variations of score values in the
    # interesting range while not brutally collapsing all the low score values to
    # the same color.

    plt.figure(figsize=(8, 6))
    plt.subplots_adjust(left=.2, right=0.95, bottom=0.15, top=0.95)
    plt.imshow(scores, interpolation='nearest', cmap=plt.cm.hot,
               norm=MidpointNormalize(vmin=0.2, midpoint=0.92))
    plt.xlabel('gamma')
    plt.ylabel('C')
    plt.colorbar()
    plt.xticks(np.arange(len(gamma_range)), gamma_range, rotation=45)
    plt.yticks(np.arange(len(C_range)), C_range)
    plt.title('Validation accuracy')
    filename = filename.replace(".txt", "")
    plt.savefig(r'/Users/jordan.harris/Desktop/upf/Machine Learning/data/graphs/kernel_svm/' + filename + '_HM.png')
    plt.show()
    plt.clf()
    plt.cla()
    plt.close()
    # #############################################################################

    plt.figure()
    plt.boxplot(C_range)
    plt.xscale('log')
    plt.yscale('log')
    plt.autoscale(True)
    filename = filename.replace(".txt", "")
    plt.savefig(r'/Users/jordan.harris/Desktop/upf/Machine Learning/data/graphs/kernel_svm/' + filename + '_log.png')
    plt.show()
    plt.clf()
    plt.cla()
    plt.close()

    final_clf=SVC(kernel='rbf', C=1.0, gamma=0.1)

    # X_train, X_test, y_train, y_test = train_test_split(X, y, test_size = 0.2, random_state=0)
    X_train, X_test, y_train, y_test = train_test_split(X_2d, y_2d, test_size=0.2, random_state=0)

    final_clf.fit(X_train, y_train)
    y_pred = final_clf.predict(X_test)

    # compute and print accuracy score
    print('Model accuracy score with rbf kernel : ', format(accuracy_score(y_test, y_pred)))


    linear_scores = cross_val_score(final_clf, X, y)
    print('Mean Validation score of : ', linear_scores.mean())
    print('---------------------------------------------------------------')


if __name__ == "__main__":

    print('')
    # kernel_SVM("diabetes.txt")
    kernel_SVM("iris.txt")
    #kernel_SVM("dna_scale.txt")

''



    # https://stackabuse.com/implementing-svm-and-kernel-svm-with-pythons-scikit-learn/
    # https://www.datacamp.com/community/tutorials/svm-classification-scikit-learn-python
    # https://www.learnopencv.com/svm-using-scikit-learn-in-python/
    # https: // www.kaggle.com / prashant111 / svm - classifier - tutorial
    # https://scikit-learn.org/stable/auto_examples/svm/plot_rbf_parameters.html

    # ´Facial reciognition but I think its linear´
    # https://jakevdp.github.io/PythonDataScienceHandbook/05.07-support-vector-machines.html

    #´Visually explore the effects of the two parameters from the support vector classifier´
    # https://chrisalbon.com/machine_learning/support_vector_machines/svc_parameters_using_rbf_kernel/
