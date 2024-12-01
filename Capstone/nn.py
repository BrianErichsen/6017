import yfinance as yf
from sklearn.preprocessing import MinMaxScaler
import numpy as np
from keras.models import Sequential
from keras.layers import LSTM, Dense, Dropout, AdditiveAttention, Permute, Reshape, Multiply, Flatten, BatchNormalization
import tensorflow as tf
from keras.callbacks import EarlyStopping, ModelCheckpoint, ReduceLROnPlateau, TensorBoard, CSVLogger
from datetime import datetime

now = datetime.now()
todays_date = now.strftime("%Y-%m-%d")

def train_and_save_model(stock_name):
    data = yf.download(stock_name, start='2020-01-01', end=todays_date)
    print(data.tail())

    data.isnull().sum() # if number were not 0 then
    data.fillna(method='ffill', inplace=True)
    scaler = MinMaxScaler(feature_range=(0,1)) # scale data to range of 0 to 1
    data_scaled = scaler.fit_transform(data['Close'].values.reshape(-1, 1))

    sequence_length = 60 # using 60 days worth of data to predict next day's price

    x = [] # input sequences
    y = [] # target values

    # creates sequences of 60 time steps from scaled data
    for i in range (sequence_length, len(data_scaled)):
        x.append(data_scaled[i - sequence_length: i, 0])
        y.append(data_scaled[i, 0])

    # converts to numpy arrays
    x_train, y_train = np.array(x), np.array(y)
    # converts to 3 dimensional -- samples, time steps, features
    x_train = np.reshape(x_train, (x_train.shape[0], x_train.shape[1], 1))

    model = Sequential()
    # number of units the number of neurons
    # return sequences for stacking
    model.add(LSTM(units=50, return_sequences=True, input_shape = (x_train.shape[1], 1)))
    model.add(Dropout(0.2)) # dropout prevents overfitting
    model.add(BatchNormalization()) # normalizes output of previous layer
    model.add(LSTM(units=50, return_sequences=True)) # second LSTM layer
    model.add(Dropout(0.2)) # another dropout to prevent overfitting
    model.add(BatchNormalization()) # normalizes output of previous layer
    attention = AdditiveAttention(name='attention_weight') # additive attention layer for temporal dependencies
    # attention layer needs -- samples - features - time steps -- hence why permuting
    # attention layer also needs data to be in 2D
    model.add(Permute((2,1))) # permute the dimensions to apply attention
    model.add(Reshape((-1, 50))) # prepares data for attention mechanism / Flattens time steps and LSTM outputs to 2D
    model.add(tf.keras.layers.Flatten()) # flatten final output from attention layer
    model.add(Dense(1)) # denser layer to output the predicted price

    # compiles model with adam optimizer and mean squared error for regression
    model.compile(optimizer='adam', loss='mean_squared_error')

    # stops training if no improvement for 10 epochs
    early_stopping = EarlyStopping(monitor='loss', patience=10)

    # saves only best performing model
    model_checkpoint = ModelCheckpoint('best_model.keras', save_best_only=True, monitor='loss')
    
    # reduces learning rate when plateauing
    reduce_lr = ReduceLROnPlateau(monitor='loss', factor=0.1, patience=5)
    tensorboard = TensorBoard(log_dir='.logs') # logs metrics for visialization in TensorBoard
    csv_logger = CSVLogger('training_log.csv') # log training details in csv file
    # combine callbacks into a list
    callbacks_list = [early_stopping, model_checkpoint, reduce_lr, tensorboard, csv_logger]
    history = model.fit(x_train, y_train, epochs=100, batch_size=25, callbacks=callbacks_list)
    # save trained model into stock name directory
    model.save(f'models/{stock_name}/{stock_name}.h5')