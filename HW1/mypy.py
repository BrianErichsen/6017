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