import numpy as np
import pandas as pd
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import LSTM, Dense, Dropout
from sklearn.preprocessing import MinMaxScaler

#data = pd.read_csv('stock_data.csv')
# fetches data from excel file
excel_data = pd.read_excel('historical_prices.xlsx', sheet_name=None)
combined_data = pd.DataFrame() # initiate empty data that will be combined

# per each sheet in excell file set stock to specific stock and concatenate data
for sheet_name, df in excel_data.items():
    df['Stock'] = sheet_name
    combined_data = pd.concat([combined_data, df], ignore_index=True)

#print(combined_data.info())
#print(combined_data.columns)
#print(combined_data.head())
#print(combined_data.tail())

# this step is crucial for NN LSTM training
scaler = MinMaxScaler(feature_range=(0, 1))

scaled_data = scaler.fit_transform(combined_data[['Close', 'Volume']])

sequence_length = 60
x_train, y_train = [],[]
# splits x_t and y_t -- 3d Array (len of data, 60, 1)
# Len of data number of training examples, sequence len is number of steps, 1 feature
# I think currently only 1D array for y_train
for i in range(sequence_length, len(scaled_data)):
    x_train.append(scaled_data[i-sequence_length:i, 0])
    y_train.append(scaled_data[i, 0])

x_train, y_train = np.array(x_train), np.array(y_train)
## cant reshape 154560 into 60, 1
x_train = np.reshape(x_train, (x_train.shape[0], x_train.shape[1], 1))

model = Sequential([
    LSTM(50, return_sequences=True, input_shape=(x_train.shape[1], 1)),
    Dropout(0.2),
    LSTM(50, return_sequences=False),
    Dropout(0.2),
    Dense(25),
    Dense(1)
])

## from ln 35
model.compile(optimizer='adam', loss='mean_squared_error')
model.fit(x_train, y_train, batch_size=1, epochs=1)

model.save('stock_prediction_model.h5')