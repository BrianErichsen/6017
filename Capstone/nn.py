import numpy as np
import pandas as pd
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import LSTM, Dense, Dropout
from sklearn.preprocessing import MinMaxScaler

data = pd.read_csv('stock_data.csv')

scaler = MinMaxScaler(feature_range=(0, 1))

scaled_data = scaler.fit_transform(data['Close'].values.reshape(-1, 1))

sequence_length = 60
x_train, y_train = [],[]
for i in range(sequence_length, len(scaled_data)):
    x_train.append(scaled_data[i-sequence_length:i, 0])
    y_train.append(scaled_data[i, 0])
x_train, y_train = np.array(x_train), np.array(y_train)

model = Sequential([
    LSTM(50, return_sequences=True, input_shape=(x_train.shape[1], 1)),
    Dropout(0.2),
    LSTM(50, return_sequences=False),
    Dropout(0.2),
    Dense(25),
    Dense(1)
])

model.compile(optmizer='adam', loss='mean_squared_error')
mode.fit(x_train, y_train, batch_size=1, epochs=1)

model.save('stock_prediction_model.h5')