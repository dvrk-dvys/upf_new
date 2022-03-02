from math import sqrt

# init both variables x (pyhsics scores) and y (history scores)
x = [15, 12, 8, 8, 7, 7, 7, 6, 5, 3]
y = [10, 25, 17, 11, 13, 17, 20, 13, 9, 15]

n = len(x)

sum_x = sum(x)
sum_y = sum(y)

sum_prod_xy = sum([i * j for i, j in zip(x, y)])

sum_sq_x = sum(map(lambda i: i ** 2, x))
sum_sq_y = sum(map(lambda j: j ** 2, y))

sd_x = n * sum_sq_x - (sum_x ** 2)
sd_y = n * sum_sq_y - (sum_y ** 2)

covar_xy = n * sum_prod_xy - (sum_x * sum_y)
corr_coeff = covar_xy / sqrt(sd_x * sd_y)

print("%.3f" % corr_coeff)