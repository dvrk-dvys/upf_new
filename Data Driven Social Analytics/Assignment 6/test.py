from scipy.optimize import leastsq
from scipy.optimize import curve_fit
import matplotlib.pyplot as plt
import numpy as np

# time intervals
t = np.linspace(1.0, 10.0, num=10)
# sales vector
sales = np.array([840, 1470, 2110, 4000, 7590, 10950, 10530, 9470, 7790, 5890])
# cumulatice sales
c_sales = np.cumsum(sales)
# initial variables(M, P & Q)
vars = [60630, 0.03, 0.38]


# residual (error) function
def residual(vars, t, sales):
    M = vars[0]
    P = vars[1]
    Q = vars[2]
    Bass = M * (((P + Q) ** 2 / P) * np.exp(-(P + Q) * t)) / (1 + (Q / P) * np.exp(-(P + Q) * t)) ** 2
    return (Bass - (sales))


def func(vars, t):
    M = vars[0]
    P = vars[1]
    Q = vars[2]
    Bass = (((P + Q) ** 2 / P) * np.exp(-(P + Q) * t)) / (1 + (Q / P) * np.exp(-(P + Q) * t)) ** 2
    return (Bass)


# non linear least square fitting
varfinal1, success1 = leastsq(residual, vars, args=(t, sales))
varfinal2, success2 = leastsq(func, vars, args=(t))


# estimated coefficients
m = varfinal1[0]
p = varfinal1[1]
q = varfinal1[2]


m = varfinal2[0]
p = varfinal2[1]
q = varfinal2[2]

print(varfinal1)

# Draw the grid line in background.
plt.grid()

# Title & Subtitle
plt.title('simple Bass model')
plt.suptitle('Proportion of Adoption F(t) x Time')

tp = (np.linspace(1.0, 100.0, num=100)) / 10
cofactor = np.exp(-(p + q) * tp)
test_pdf = (((p + q) ** 2 / p) * cofactor) / (1 + (q / p) * cofactor) ** 2



# plot
plt.plot(tp, test_pdf)
# beautify the x-labels
plt.gcf().autofmt_xdate()

# resize the X and Y axes
plt.gca().xaxis.set_major_locator(plt.MultipleLocator(1))
plt.gca().yaxis.set_major_locator(plt.MultipleLocator(0.1))

# plt.plot(x)
plt.xlabel('X Axis')
plt.ylabel('Y Axis')
plt.show()
plt.clf()
plt.cla()
plt.close()

#
#
#
# # sales plot (pdf)
# # time interpolation
tp = (np.linspace(1.0, 100.0, num=100)) / 10
cofactor = np.exp(-(p + q) * tp)
sales_pdf = m * (((p + q) ** 2 / p) * cofactor) / (1 + (q / p) * cofactor) ** 2
# plt.plot(tp, sales_pdf, t, sales)
# # plt.plot(t, sales)
#
# plt.title('Sales pdf')
# plt.legend(['Fit', 'True'])
# plt.show()
#
# # Cumulative sales (cdf)
# sales_cdf = m * (1 - cofactor) / (1 + (q / p) * cofactor)
# plt.plot(tp, sales_cdf, t, c_sales)
# plt.title('Sales cdf')
# plt.legend(['Fit', 'True'])
# plt.show()
