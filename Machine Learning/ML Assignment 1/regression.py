import numpy as np
from sklearn.linear_model import LinearRegression

def main():
 print("hello")


x = np.array([5, 15, 25, 35, 45, 55]).reshape((-1, 1))
y = np.array([5, 20, 14, 32, 22, 38])


#model = LinearRegression()
#model.fit(x, y)
model = LinearRegression().fit(x, y)
r_sq = model.score(x, y)


if __name__ == "__main__":

 print(x)
 print(y)

 ###---------------------------###

 print('coefficient of determination:', r_sq)
 print('intercept:', model.intercept_)
 print('slope:', model.coef_)

 ###---------------------------###

 y_pred = model.predict(x)
 print('predicted response:', y_pred, sep='\n')