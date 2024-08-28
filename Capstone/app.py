from flask import Flask, request, render_template, jsonify
import numpy as np
import pandas as pd
from tensorflow.keras.models import load_model
from sklearn.preprocessing import MinMaxScaler

# flask runs on localhost/5000

app = Flask(__name__)

model_next_day = load_model('stock_prediction_model.h5')
model_multi_day = load_model('stock_prediction_model2.h5')

# Load and scale data
excel_data = pd.read_excel('historical_prices.xlsx', sheet_name=None)
combined_data = pd.DataFrame()

for sheet_name, df in excel_data.items():
    df['Stock'] = sheet_name
    combined_data = pd.concat([combined_data, df], ignore_index=True)

print(combined_data.info())
print(combined_data.columns)
print(combined_data.head())
print(combined_data.tail())

scaler = MinMaxScaler(feature_range=(0, 1))
scaled_data = scaler.fit_transform(combined_data[['Close', 'Volume']])

# loads the home page route
@app.route('/')
def index():
    return render_template('index.html')

@app.route('/predict', methods=['POST'])
def predict():
    # Get form data
    try:
        print("Test")
        data = request.json
        print(f"{data}")
        stock = data.get('stock')
        prediction_type = data.get('prediction_type')
        print(f"Received request for stock: {stock}, predicting {prediction_type}.")

        if prediction_type == 'next-day':
            # Prepare input for next day prediction
            new_data = scaler.fit_transform(combined_data[['Close']])

            x_input = np.array([scaled_data[:, 0]])
            x_input = np.reshape(x_input, (x_input.shape[0], x_input.shape[1], 1))

            # Predict next day price
            predicted_stock_price = model_next_day.predict(x_input)
            predicted_price = scaler.inverse_transform(
                np.array([predicted_stock_price[0], [0]])
            )[0][0]

            return jsonify([f'Predicted Closing Price: {predicted_price:.2f}'])
        
        elif prediction_type == 'multi-day':
            n_future = int(data.get('n_future'))
            last_60_days = combined_data[combined_data['Stock'] == stock].tail(60)
            last_60_days_scaled = scaler.transform(last_60_days[['Close', 'Volume']])
    
            x_input = np.array([last_60_days_scaled])
            x_input = np.reshape(x_input, (x_input.shape[0], x_input.shape[1], x_input.shape[2]))

        # Predict
            predictions_scaled = model_multi_day.predict(x_input)
            predictions = scaler.inverse_transform(
                np.concatenate([predictions_scaled, np.zeros((n_future, 1))], axis=1)
            )[:, 0]
            return jsonify(predictions.toList())

    except Exception as e:
        print(f'{e}')
        return jsonify({"Error": str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True)