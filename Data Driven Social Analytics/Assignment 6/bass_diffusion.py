import datetime
import random
import matplotlib.pyplot as plt
import numpy as np
from scipy.optimize import fsolve
from scipy.optimize import leastsq
from numpy import array, empty



# # a
p = 0.03
q = 0.42

# # # # c
# p = 0.3
# q = 0.1

vars = [p, q]
time = [t for t in range(14)]
# time = np.arange(0, 24, 0.25).tolist()
x = [datetime.date.today() + datetime.timedelta(days=i) for i in range(14)]
# F = [(1 - np.exp(-(p+q) * t)) / ((1 + ((p / q) * np.exp(-(p+q) * t)))) for t in range(14)]
# y = [(p + (q * F[t])) * (1 - F[t]) for t in range(14)]
# y = [F[t] for t in range(14)]

def func(t, vars):
    p, q = vars
    return [(1 - np.exp(-(p+q) * t_)) / ((1 + ((p / q) * np.exp(-(p+q) * t_)))) for t_ in t]

# roots = fsolve(func, time, args=(vars))
# test_true = np.isclose(func(roots, vars), [0.0] * len(time))

F = [(1 - np.exp(-(p+q) * t)) / ((1 + ((p / q) * np.exp(-(p+q) * t)))) for t in range(14)]
y = [(p + (q * F[t])) * (1 - F[t]) for t in range(14)]
# y = [(p + (q * .23)) * (1 - .23) for t in range(14)]


# #########################

# Draw the grid line in background.
plt.grid()

# Title & Subtitle
plt.title('simple Bass model')
plt.suptitle('Proportion of Adoption F(t) x Time')

# plot
plt.plot(x, func(time, vars), label='p = ' + str(p) + ' q = ' + str(q))
# beautify the x-labels
plt.gcf().autofmt_xdate()

# # place the legend block in bottom right of the graph
plt.legend(loc='lower right')

# write the Sigmoid formula
plt.text(datetime.date.today() + datetime.timedelta(days=9), 0.2, r'$F(x)=\frac{1-e^{(p+q)t}}{1+\frac{q}{p}e^{(p+q)t}}$', fontsize=13)

# resize the X and Y axes
plt.gca().xaxis.set_major_locator(plt.MultipleLocator(1))
plt.gca().yaxis.set_major_locator(plt.MultipleLocator(0.1))

# plt.plot(x)
plt.xlabel('X Axis')
plt.ylabel('Y Axis')

# create the graph
filename = 'Ft_adoption_portion'
plt.savefig(r'/Users/jordanharris/PycharmProjects/pythonProject/upf/Data Driven Social Analytics/Assignment 6/' + filename + '_' + str(p) + '_' + str(q) + '.png')
plt.show()
plt.clf()
plt.cla()
plt.close()


# #########################

# Draw the grid line in background.
plt.grid()

# Title & Subtitle
plt.title('simple Bass model')
plt.suptitle('New Adoptions x Time')

# plot
plt.plot(x, y, label='p = ' + str(p) + ' q = ' + str(q))
# beautify the x-labels
plt.gcf().autofmt_xdate()

# place the legend block in bottom right of the graph
plt.legend(loc='upper right')

plt.text(datetime.date.today() + datetime.timedelta(days=7), 0.25, r'$\frac{dF(t)}{dt}=(p+qF(t))(1-F(t))$', fontsize=13)

# resize the X and Y axes
plt.gca().xaxis.set_major_locator(plt.MultipleLocator(1))
plt.gca().yaxis.set_major_locator(plt.MultipleLocator(0.1))

# plt.plot(x)
plt.xlabel('X Axis')
plt.ylabel('Y Axis')

# create the graph
filename = 'New_adoptions'
plt.savefig(r'/Users/jordanharris/PycharmProjects/pythonProject/upf/Data Driven Social Analytics/Assignment 6/' + filename + '_' + str(p) + '_' + str(q) + '.png')
plt.show()
plt.clf()
plt.cla()
plt.close()
