from flask import Flask, request, render_template, jsonify
import numpy as np
import pandas as pd
from tensorflow.keras.models import load_model
from sklearn.preprocessing import MinMaxScaler
from datetime import datetime
import yfinance as yf
from nn import train_and_save_model
import os

# flask runs on localhost/5000

app = Flask(__name__)

now = datetime.now()
todays_date = now.strftime("%Y-%m-%d")

# loads the home page route
@app.route('/')
def index():
    return render_template('index.html')

@app.route('/predict', methods=['POST'])
def predict():
    # Get form data
    try:
        data = request.json
        stock = data.get('stock')
        prediction_type = data.get('prediction_type')
        print(f"Received request for stock: {stock}, predicting {prediction_type}.")

        # lets check for stock path and if not existing then we create a new model
        model_path = f'models/{stock}/{stock}.h5' #stock path

        # fetches data from yahoo finance
        stock_data = yf.download(stock, period='3mo', interval='1d')

        # if data retrieved is empty then user input is not correct - non existing stock
        if stock_data is None or stock_data.empty:
            return jsonify({'Error': f'Stock not available from Yahoo Finance database for {stock}!!'})

        # if no model for given stock then we create a new model
        if not os.path.exists(model_path):
            print(f'AI Model will be attepted to be for {stock}')
            train_and_save_model(stock)
            print(f'Finished training new Model for {stock}')

        stock_data = stock_data[-60:]
        stock_data.isnull().sum() # if number were not 0 then
        stock_data.fillna(method='ffill', inplace=True)

        scaler = MinMaxScaler(feature_range=(0,1))
        data_scaled = scaler.fit_transform(stock_data['Close'].values.reshape(-1, 1))
        model = load_model(model_path)

        if prediction_type == 'next-day':
            # Prepare input for next day prediction

            x_input = np.array([data_scaled[-60:].reshape(60)])
            x_input = np.reshape(x_input, (x_input.shape[0], x_input.shape[1], 1))

            # Predict next day price
            predicted_stock_price = model.predict(x_input)
            predicted_price = scaler.inverse_transform(
                np.array([predicted_stock_price[0], [0]])
            )[0][0]

            return jsonify([f'Predicted Closing Price for {stock}: {predicted_price:.2f}'])
        
        elif prediction_type == 'multi-day':
            n_future = int(data.get('n_future'))
            predicted_prices = []
            current_batch = data_scaled[-60:].reshape(1, 60, 1)
            for i in range(n_future):
                next_prediction = model.predict(current_batch)
                next_prediction_reshaped = next_prediction.reshape(1, 1, 1)
                current_batch = np.append(current_batch[:, 1:, :], next_prediction_reshaped, axis=1)
                predicted_price = float(scaler.inverse_transform(next_prediction)[0, 0])
                predicted_prices.append(predicted_price)

            predicted_prices_formatted = ['%.2f' % elem for elem in predicted_prices]
    
        
            return jsonify(predicted_prices_formatted)

    except Exception as e:
        print(f'{e}')
        return jsonify({"Error": str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True)