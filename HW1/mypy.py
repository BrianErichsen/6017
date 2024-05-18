#Author:Brian Erichsen Fagundes
#MSD CS 6017 - Summer - 2024

import numpy as np
import scipy.stats as stats
import matplotlib.pyplot as plt
import pandas as pd

def compute_mean(data):
    return sum(data) / len(data)

def compute_std(data):
    mean = compute_mean(data)
    variance = sum((x - mean) ** 2 for x in data) / len(data)
    return np.sqrt(variance)

#normal distribution is 0; standard deviation is 1 and 1000 random samples
samples = stats.norm.rvs(loc=0, scale=1, size=1000)

# compute mean and std by using my own methods
custom_mean = compute_mean(samples)
custom_std = compute_std(samples)

# compute mean and std by using in built methods
numpy_mean = np.mean(samples)
numpy_std = np.std(samples)

# asserts that both results are nearly identical
assert np.isclose(custom_mean, numpy_mean, atol=0.01)
assert np.isclose(custom_std, numpy_std, atol=0.01)

# plotting histogram values
plt.hist(samples, bins=30, edgecolor='k', alpha=0.7)
plt.title('Histogram of Normal Distribution Samples')
plt.xlabel('Value')
plt.ylabel('Frequency')
plt.show()

#------------------------------
# Load data
df = pd.read_csv('2020-PM2.5.csv', header=2, parse_dates=['Date'], index_col='Date')
print(df.head())
print(df.columns)
station_name = 'Unnamed: 22'
station_data = df[[station_name]]

# Plotting yearly data for a specific station
plt.figure(figsize=(12, 6))
plt.plot(station_data.index, station_data[station_name], label='PM2.5')
plt.title(f'PM2.5 Levels over a Year at {station_name}')
plt.xlabel('Date')
plt.ylabel('PM2.5 Level')
plt.legend()
plt.show()
# -----------------------
#Plotting monthly means PM2.5 levels
monthly_mean = station_data.resample('M').mean()

plt.figure(figsize=(10, 6))
monthly_mean.plot(kind='bar')
plt.title(f'Monthly Mean PM2.5 Levels at {station_name}')
plt.xlabel('Month')
plt.ylabel('Mean PM2.5 Level')
plt.show()

# Insights from visualization
# Higher pollution levels in winter months due to temperature inversions
#-------------------------
#Plotting hourly mean data
hourly_mean = station_data.groupby(station_data.index.hour).mean()

plt.figure(figsize=(10, 6))
hourly_mean.plot(kind='bar')
plt.title(f'Hourly Mean PM2.5 Levels at {station_name}')
plt.xlabel('Hour of the day')
plt.ylabel('Mean PM2.5 Level')
plt.show()

# Insights from visualization
# Higher pollution levels during mornings and evening rush hours

#  More complete view of the data -- monthly
station_data['Month'] = station_data.index.month
plt.figure(figsize=(10, 6))
station_data.boxplot(column=station_name, by='Month', layout=(1, 1))
plt.title(f'Monthly PM2.5 Levels at {station_name}')
plt.xlabel('Month')
plt.ylabel('PM2.5 Level')
plt.suptitle('')
plt.show()

# More complex view of the data -- hourly
station_data['Hour'] = station_data.index.hour
plt.figure(figsize=(10, 6))
station_data.boxplot(column=station_name, by='Hour', layout=(1, 1))
plt.title(f'Hourly PM2.5 Levels at {station_name}')
plt.xlabel('Hour of Day')
plt.ylabel('PM2.5 Level')
plt.suptitle('')
plt.show()