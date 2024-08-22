import pandas as pd
import yfinance as yf

## it saves file for now in excel -- convert to csv or download straight csv
# SMA EMA, RSI, MACD can be calculated from price data - help capture market trends and
# momentum

## how to tell if stock is overvalued or undervalued P/E ratio, P/B ratio, dividend yield
# states which stocks data to download
tickers = ['TSLA', 'MSFT', 'GOOG', 'AAPL']
start_date = '2022-01-01'
end_date = '2024-08-19'

xlwriter = pd.ExcelWriter('historical_prices.xlsx', engine='openpyxl')

for ticker in tickers:
    df = yf.download(ticker, start=start_date, end=end_date, interval='1d')
    df.to_excel(xlwriter, sheet_name=ticker) #index=False

xlwriter.close()