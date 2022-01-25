import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn import datasets, linear_model
from sklearn.datasets import load_svmlight_file
from sklearn.metrics import mean_squared_error, accuracy_score
import time
from sklearn.model_selection import StratifiedShuffleSplit
data_reg , data_y = load_svmlight_file ("/home/u188702/upf/data/Regression Data/abolene.txt")
data_X = data_reg.todense()
#Regression
#part1
megacof=[]
megaduration=[]
megaloss=[]
for i in range(100):
   sizes=np.linspace(10,data_X.shape[0],20,dtype = int)
   loss=[]
   dur=[]
   cof=[]
   for s in sizes:
       rowid = np.random.choice(data_X.shape[0] , size=s, replace=False)
       data_sub_X = data_X[rowid,:]
       data_sub_y = data_y[rowid]
       # Create linear regression object
       regr = linear_model.LinearRegression()
       #time
       starttime=time.time()
       # Train the model using the training sets
       regr.fit(data_sub_X, data_sub_y)
       duration=time.time()-starttime
       data_sub_y_pred= regr.predict(data_sub_X)
       error = mean_squared_error(data_sub_y, data_sub_y_pred)
       loss.append(error)
       #loss=[loss, error]
       cof.append(regr.coef_)
       dur.append(duration)
   megaloss.append(loss)
   megaduration.append(dur)
   megacof.append(cof)
meanloss=np.array (megaloss) .mean(axis=0)
meanduration=np.array (megaduration) .mean(axis=0)
meancof=np.array (megacof) .mean(axis=0)
plt.plot(sizes , meanloss,'-o',color='blue', linewidth=3)
plt.title("mean loss and sample size")
plt.xlabel("sample size")
plt.ylabel("square loss")
plt.savefig('q1part1.png', dpi=300)
plt.plot(sizes , meanduration,'-o',color='blue', linewidth=3)
plt.title("mean CPU time and sample size")
plt.xlabel("sample size")
plt.ylabel("CPU time")
plt.savefig('q1part2.png', dpi=300)
plt.plot(sizes , meancof, linewidth=3)
plt.title("mean coefficient and sample size")
plt.xlabel("sample size")
plt.ylabel("coefficient")
plt.savefig('q1part4.png', dpi=300)
data_class , data_y = load_svmlight_file ("/home/u188702/upf/data/Classification Data/glass.txt")
data_X = data_class.todense()
#Classification
#part2
megacof=[]
megaduration=[]
megaloss=[]
for i in range(100):
   sizes=np.linspace(10,data_X.shape[0],20,dtype = int)
   loss=[]
   dur=[]
   cof=[]
   for s in sizes:
       sss = StratifiedShuffleSplit(n_splits=1, test_size=10, random_state=0)
       rowid= next(sss.split(data_X, data_y))[0]
       data_sub_X = data_X[rowid,:]
       data_sub_y = data_y[rowid]
       # Create LogisticRegression
       regr = linear_model.LogisticRegression(solver='liblinear')
       #time
       starttime=time.time()
       # Train the model using the training sets
       regr.fit(data_sub_X, data_sub_y)
       duration=time.time()-starttime
       data_sub_y_pred= regr.predict(data_sub_X)
       error = accuracy_score(data_sub_y, data_sub_y_pred)
       loss.append(error)
       #loss=[loss, error]
       cof.append(regr.coef_)
       dur.append(duration)
   megaloss.append(loss)
   megaduration.append(dur)
   megacof.append(cof)
meanloss=np.array (megaloss) .mean(axis=0)
meanduration=np.array (megaduration) .mean(axis=0)
meancof=np.array (megacof) .mean(axis=0)
plt.plot(sizes , meanloss,'-o',color='blue', linewidth=3)
plt.title("mean loss and sample size")
plt.xlabel("sample size")
plt.ylabel("square loss")
plt.savefig('q2part1.png', dpi=300)
plt.plot(sizes , meanduration,'-o' ,color='blue', linewidth=3)
plt.title("mean CPU time and sample size")
plt.xlabel("sample size")
plt.ylabel("CPU time")
plt.savefig('q2part2.png', dpi=300)
meancof= meancof .squeeze()
#plt.plot(sizes , meancof, linewidth=3)
plt.title("mean coefficient and sample size")
plt.xlabel("sample size")
plt.ylabel("coefficient")
plt.savefig('q2part4.png', dpi=300)