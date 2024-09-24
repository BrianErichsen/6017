import yfinance as yf
from tensorflow.keras.models import load_model
from sklearn.preprocessing import MinMaxScaler
import os
import numpy as np

stock_list = ['AAPL', 'MSFT', 'GOOG', '^GSPC', 'AAPL', 'TSLA']

for stock in stock_list:
    data = yf.download('AAPL', period='1d', interval='1d')

    model = load_model(f'models/{stock}/{stock}.h5')
    scaler = MinMaxScaler(feature_range=(0, 1))

    data_scaled = scaler.fit_transform(data['Close'].values.reshape(-1, 1))
    today_price_scaled = data_scaled[-1]
    x_input = data_scaled.reshape(1, 1, 1)

    model.fit(x_input, np.array([today_price_scaled]), epochs=1, verbose=0)

    model.save('models/{stock}/{stock}.h5')

