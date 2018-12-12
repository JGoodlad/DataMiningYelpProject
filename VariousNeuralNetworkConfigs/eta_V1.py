import numpy
import pandas
from keras.models import Sequential
from keras.layers import Dense
from keras.wrappers.scikit_learn import KerasRegressor
from sklearn.model_selection import cross_val_score
from sklearn.model_selection import KFold
from sklearn.preprocessing import StandardScaler
from sklearn.pipeline import Pipeline
from keras import regularizers
from keras import backend as K
from datetime import datetime
from keras import backend
from keras.layers.normalization import BatchNormalization
from sklearn.metrics import fbeta_score, make_scorer


colCount = 0

# def root_mean_squared_error(y_true, y_pred):
#     return backend.sqrt(backend.mean(backend.square(y_pred - y_true), axis=-1))

def root_mean_squared_error(y_true, y_pred):
        return K.sqrt(K.mean(K.square(y_pred - y_true), axis=0))

def larger_model():
    global colCount
    regval = 0.01
	# create model
    model = Sequential()
    model.add(Dense(colCount, input_dim=colCount, kernel_initializer='normal', activation='relu'))
    model.add(Dense(1, kernel_initializer='normal'))
    # Compile model
    # model.compile(loss='root_mean_squared_error', optimizer='adam')
    model.compile(optimizer = "adam", loss = root_mean_squared_error, metrics=[root_mean_squared_error, 'mae'])
    return model




if __name__ == "__main__":
    pass
    
    ds = 'eta'
    timeAsName = str(int((datetime.utcnow() - datetime(1, 1, 1)).total_seconds() * 10000000))
    

    # load dataset
    dataframe = pandas.read_csv(f'1_{ds}.csv')#"1_comp5.csv")
    colCount = dataframe.shape[1] - 1
    dataset = dataframe.values
    # split into input (X) and output (Y) variables
    X = dataset[:,0:colCount]
    Y = dataset[:,colCount]

    testFrame = pandas.read_csv(f'2_{ds}.csv')#"2_comp5.csv")
    testFrame = testFrame.drop(columns=['y'])
    testFrame = testFrame.drop(columns=['TestIndex'])
    testSet = testFrame.values
  


    # fix random seed for reproducibility
    seed = 16
    numpy.random.seed(seed)
    # evaluate model with standardized dataset
    estimators = []
    estimators.append(('standardize', StandardScaler()))
    estimators.append(('mlp', KerasRegressor(build_fn=larger_model, epochs=25, batch_size=32, verbose=1, validation_split=0.05, shuffle=True)))
    pipeline = Pipeline(estimators)

    # estimator = KerasRegressor(build_fn=larger_model, epochs=100, batch_size=32, verbose=1)


    print('start')
    rmse_scorer = make_scorer(root_mean_squared_error, greater_is_better=False)
    kfold = KFold(n_splits=5, random_state=seed)
    results = cross_val_score(pipeline, X, Y, cv=kfold, verbose=2, scoring="mean_squared_error")
    root_res = numpy.sqrt(numpy.array(results) * -1.0)
    ofname = f"out{timeAsName}_{ds}"
    print(results, file=open(f'{ofname}.txt', "a"))
    print(root_res, file=open(f'{ofname}.txt', "a"))
    print("Results: %.4f (%.4f) RMSE" % (numpy.mean(root_res), numpy.std(root_res)), file=open(f'{ofname}.txt', "a"))

    pipeline.fit(X, y=Y)

    print(len(testSet))
    prediction = pipeline.predict(testSet)
    prediction = numpy.clip(prediction.tolist(), 1.0, 5.0)

    res = pandas.DataFrame(list(zip(pandas.read_csv(f'2_{ds}.csv')['TestIndex'].values, prediction)))

    res.to_csv(f"{ofname}.csv", header = ["index", "stars"], index=False)
    print(res)

    # print("Results: %.2f (%.2f) MSE" % (results.mean(), results.std()))
