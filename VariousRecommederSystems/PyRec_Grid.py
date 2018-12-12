from __future__ import (absolute_import, division, print_function,
                        unicode_literals)
import pandas as pd
from surprise import SVDpp
from surprise import SVD
from surprise import Dataset
from surprise import accuracy
from surprise import BaselineOnly
from surprise import Dataset
from surprise import Reader
from surprise.model_selection import train_test_split
from surprise.model_selection import GridSearchCV
from surprise.model_selection import cross_validate

# Use movielens-100K
# data = Dataset.load_builtin('ml-100k')


df = pd.read_csv("tr_mini_1.csv")
reader = Reader(rating_scale=(1, 5))
data = Dataset.load_from_df(df[['user_id', 'business_id', 'rating']], reader)
trainset, testset = train_test_split(data, test_size=.15)

pred = Dataset.load_from_df(pd.read_csv("tr_mini_2.csv")[['user_id', 'business_id']], reader)

# reader = Reader(line_format='user item rating', sep=',', rating_scale=(0, 5), skip_lines=1)
# data = Dataset.load_from_file('tr_mini_2.csv', reader=reader)

trainset, testset = train_test_split(data, test_size=.15)

print("About to start")
# ----- SVD ----- #

param_grid = {'n_factors' : [160, 200, 250], 'n_epochs' : [70, 90, 110], 'lr_all': [0.003, 0.005],
              'reg_all': [0.2]}
gs = GridSearchCV(SVD, param_grid, measures=['rmse', 'mae'], cv=3, joblib_verbose = 2, n_jobs=7)
gs.fit(data)
algo = gs.best_estimator['rmse']
print(gs.best_score['rmse'])
print(gs.best_params['rmse'])
cross_validate(algo, data, measures=['RMSE', 'MAE'], cv=5, verbose=True, n_jobs=6)

# # Use the new parameters with the train data
# algo = SVD(n_factors=120, n_epochs=70, lr_all=0.03, reg_all=0.2, verbose = 1)
# algo.fit(trainset)
# test_pred = algo.test(testset)
# print("SVD : Test Set")
# accuracy.rmse(test_pred, verbose=True)