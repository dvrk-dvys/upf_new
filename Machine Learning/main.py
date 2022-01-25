import numpy as np
from sklearn.neural_network import MLPClassifier
from sklearn.neural_network import MLPRegressor
from sklearn.datasets import make_regression
from sklearn.model_selection import train_test_split
import matplotlib.pyplot as plt
from sklearn.model_selection import validation_curve
alpha_values = np.array([1e-5,1e-4,1e-3,1e-2,1e-1,1e-0,1e1,1e2,1e3,1e4,1e5])
alpha_size = len(alpha_values)
clf = MLPClassifier(hidden_layer_sizes=(150,), activation='logistic', max_iter=500)
training_error, validation_error = validation_curve(estimator=clf, X=X, y=y, param_name = 'alpha', param_range = alpha_values, cv=5, scoring='accuracy')
plt.plot(training_error.mean(axis=1), label="training error", color="red")
plt.plot(validation_error.mean(axis=1), label="validation error", color="pink")
plt.title("Training and Validation Error")
plt.xlabel("Alpha Values")
plt.ylabel("Accuracy")
plt.legend()
plt.show()