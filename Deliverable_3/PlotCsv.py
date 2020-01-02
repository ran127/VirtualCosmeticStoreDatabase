#!/usr/bin/env python
import matplotlib.pyplot as plt
import csv

x = []
y = []

with open('orderByDay.csv','r') as csvfile:
    plots = csv.reader(csvfile, delimiter=',')
    for row in plots:
        x.append(row[0])
        y.append(int(row[1]))

plt.plot(x,y)
plt.xlabel('Weekdays')
plt.ylabel('Number of orders')
plt.title('Order By Weekdays')
plt.show()
