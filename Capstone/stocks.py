import pandas as pd
import datetime
import time

## it saves file for now in excel -- convert to csv or download straight csv
# SMA EMA, RSI, MACD can be calculated from price data - help capture market trends and
# momentum

## closing prices is what we looking for - stock prices

## how to tell if stock is overvalued or undervalued P/E ratio, P/B ratio, dividend yield

tickers = ['TSLA', 'TWTR', 'MSFT', 'GOOG', 'AAPL']
interval = '1d'

period1 = int(time.mktime(datetime(2022, 1, 1, 23, 59).timetuple()))
period2 = int(time.mktime(datetime(2024, 8, 19, 23, 59).timetuple()))

xlwriter = pd.ExcelWriter('historical_prices.xlsx', engine='openpyxl')

for ticker in tickers:
    query_string = f''
    df = pd.read_csv(query_string)
    df.to_excel(xlwriter, sheet_name=ticker, index=False)

xlwriter.save()