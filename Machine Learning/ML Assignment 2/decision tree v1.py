import pandas as pd
import numpy as np
from sklearn.tree import DecisionTreeClassifier # Import Decision Tree Classifier
from sklearn.model_selection import train_test_split # Import train_test_split function
from sklearn import tree, metrics #Import scikit-learn metrics module for accuracy calculation
from sklearn.datasets import load_svmlight_file, load_iris
import os
import matplotlib.pyplot as plt
from sklearn.tree import export_graphviz

def tree_classify(filename):
    X, y = load_svmlight_file("data/Classification Data/" + filename)

    col_names = np.empty(X.shape[1])
    b = np.arange(1, X.shape[1] + 1, 1)
    ind = np.arange(len(col_names))
    np.put(col_names, ind, b)

    uniq = np.unique(y)
    target_values = list(map(str, uniq))

    row, col = X.shape

    # ________________________________________________
    feature_names = ['pregnant', 'glucose', 'bp', 'skin', 'insulin', 'bmi', 'pedigree', 'age', 'label']
    #split dataset in features and target variable
    class_names = ['pregnant', 'insulin', 'bmi', 'age','glucose','bp','pedigree']


    #iris = datasets.load_iris()
    #X1 = iris.data
    #y1 = iris.target
    fn = ['sepal length (cm)', 'sepal width (cm)', 'petal length (cm)', 'petal width (cm)']
    cn = ['setosa', 'versicolor', 'virginica']
# ________________________________________________

    test_partition = 0.30

    # Split dataset into training set and test set
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=test_partition, random_state=1) # 70% training and 30% test

    max_d = 5
    split = 'best'
    clf = DecisionTreeClassifier(criterion="entropy", max_depth=max_d, splitter=split)

    # Train Decision Tree Classifer
    clf = clf.fit(X_train, y_train)

    #Predict the response for test dataset
    y_pred = clf.predict(X_test)

    print('Max Depth:', max_d)
    print('Test Partition:', test_partition)
    print('Data Set:', filename, 'Training Size:', row, 'Features:', col)
    # Model Accuracy, how often is the classifier correct?
    ascore = metrics.accuracy_score(y_test, y_pred)
    print("Accuracy Score:", ascore)

    # plt.figure(nrows=1,ncols=1,figsize=(12, 12))
    fig, axes = plt.subplots(nrows=1,ncols=1, figsize=(4, 4), dpi=200)
    tree.plot_tree(clf,
                   feature_names=fn,
                   class_names=cn,
                   filled=True);
    fig.text(2, 1, 'Accuracy Score:' + str(ascore), fontsize=18, color='g')
    fig.text(2, .75, 'Test Partition:' + str(str(test_partition)), fontsize=18, color='g')
    filename = filename.replace(".txt", "")
    fig.savefig(r'/Users/jordan.harris/Desktop/upf/Machine Learning/data/graphs/decision_trees/' + str(max_d) + '_' + str(test_partition) + '_test_' + split + '_' + filename + '.png', bbox_inches='tight')
    fig.show()
    plt.clf()
    plt.cla()
    plt.close()




if __name__ == "__main__":

    # tree_classify("diabetes.txt")
    tree_classify("iris.txt")
    # tree_classify("dna_scale.txt")

#https://mljar.com/blog/visualize-decision-tree/
#https://www.datacamp.com/community/tutorials/decision-tree-classification-python
#https://chrisalbon.com/machine_learning/trees_and_forests/visualize_a_decision_tree/
#https://datascience.stackexchange.com/questions/37428/graphviz-not-working-when-imported-inside-pydotplus-graphvizs-executables-not
#https://inteligencia-analitica.com/wp-content/uploads/2017/08/Installing-Graphviz-and-pydotplus.pdf
#https://towardsdatascience.com/visualizing-decision-trees-with-python-scikit-learn-graphviz-matplotlib-1c50b4aa68dc






