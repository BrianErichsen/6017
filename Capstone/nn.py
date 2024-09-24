import yfinance as yf
from sklearn.preprocessing import MinMaxScaler
import numpy as np
from keras.models import Sequential
from keras.layers import LSTM, Dense, Dropout, AdditiveAttention, Permute, Reshape, Multiply, Flatten, BatchNormalization
import tensorflow as tf
from keras.callbacks import EarlyStopping, ModelCheckpoint, ReduceLROnPlateau, TensorBoard, CSVLogger
from datetime import datetime

stock_name = 'AAPL'
now = datetime.now()
todays_date = now.strftime("%Y-%m-%d")

def train_and_save_model(stock_name):
    data = yf.download(stock_name, start='2020-01-01', end=todays_date)
    #data = yf.download('AAPL', period='3mo', interval='1d')
    print(data.tail())

    data.isnull().sum() # if number were not 0 then
    data.fillna(method='ffill', inplace=True)
    scaler = MinMaxScaler(feature_range=(0,1))
    data_scaled = scaler.fit_transform(data['Close'].values.reshape(-1, 1))

    sequence_length = 60

    x = []
    y = []

    for i in range (sequence_length, len(data_scaled)):
        x.append(data_scaled[i - sequence_length: i, 0])
        y.append(data_scaled[i, 0])


    x_train, y_train = np.array(x), np.array(y)
    x_train = np.reshape(x_train, (x_train.shape[0], x_train.shape[1], 1))

    model = Sequential()
    # number of units the number of neurons
    model.add(LSTM(units=50, return_sequences=True, input_shape = (x_train.shape[1], 1)))
    model.add(Dropout(0.2))
    model.add(BatchNormalization())
    model.add(LSTM(units=50, return_sequences=True))
    model.add(Dropout(0.2))
    model.add(BatchNormalization())
    attention = AdditiveAttention(name='attention_weight')
    model.add(Permute((2,1)))
    model.add(Reshape((-1, 50)))
    model.add(tf.keras.layers.Flatten())
    model.add(Dense(1))

    model.compile(optimizer='adam', loss='mean_squared_error')

    early_stopping = EarlyStopping(monitor='loss', patience=10)

    model_checkpoint = ModelCheckpoint('best_model.keras', save_best_only=True, monitor='loss')

    reduce_lr = ReduceLROnPlateau(monitor='loss', factor=0.1, patience=5)

    tensorboard = TensorBoard(log_dir='.logs')
    csv_logger = CSVLogger('training_log.csv')

    callbacks_list = [early_stopping, model_checkpoint, reduce_lr, tensorboard, csv_logger]
    history = model.fit(x_train, y_train, epochs=100, batch_size=25, callbacks=callbacks_list)

    model.save(f'models/{stock_name}/{stock_name}.h5')

stock_names = ['TSLA', 'GOOG', 'MSFT', 'AAPL', '^GSPC']

#for stock in stock_names:
#    train_and_save_model(stock)