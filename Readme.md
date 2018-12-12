## CS145 Yelp Review Prediction Project

## Reproducibility
**_TL:DR: run in Bash, `python3 BestModelwDataAndResults learn_eta.py`_**
**Instructions to reproduce our final results are included in the first bullet of the "Repository Structure" section.**


## Repository Structure
- **/BestModelwDataAndResults/ a folder that contains all parts required to reproduce our results**
  - **The SQL query is included for reference. I would require spinning up a MS SQL Server instance.**
  - **learn_eta.py is produces the cross validation results and makes a prediction which can be used to submitted to Kaggle. This file generates the our selected Kaggle submission.**
  - **1_eta.csv & 2_eta.csv are the files needed by learn_eta.py for training and prediction, respectively.**
  - **out636800673410765696_eta_early.txt & out636800673410765696_eta_early.csv are the results of the 5 K-Fold validation run and the results submitted to Kaggle, respectively. These files can be reproduced by running the learn_eta.py with the required dependencies.**
- /KaggleSubmissions/... Final Kaggle Submissions
- /SQL/... A collection of the all the SQL queries we used
  - Files with name TrainAndPredict_*.sql produce two results, the first is used for training, the second to make predictions for kaggle submissions. The size at the end of the name determines how many features are included.
  - ExpectationTable.sql (ExtendedExpectationTable.sql) produces the (Extended) Expected Value Table for a given User Average and Business Average.
- /VariousTrainingAndPredictionData/ contains the datasets used for training of the various models. 1_* and 2_* represent the data to be used for training and predicting, respectively.
- /VariousSummaries/ contains the results of cross validations runs when training different models. The number represents the number of nanoseconds since the Linux Epoch.
- /VariousPredictionsCsv/ contains .CSV files that can be submitted directly to kaggle.
- /VariousNeuralNetworkCongfigs/ contains various Keras NN models.
- /VariousRecommenderSystems/ contains various Surprise RS models.
- /VariousSVM/ contains various SVM models.
