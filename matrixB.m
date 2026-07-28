clear;

A_data = readmatrix("C:\Users\A.txt");
A = A_data(:, 2:end);
ray_ids = A_data(:, 1);

x_data = readmatrix("C:\Users\iri_0.4_8.45.txt");
x = x_data(:, 4);

[m, n] = size(A);
[n_x, num_columns] = size(x);

assert(n == n_x, 'The number of columns in A (%d) does not match the number of rows in x (%d).', n, n_x);

stec_pred = A * x;
output = [ray_ids, stec_pred];

writematrix(output, "C:\Users\b.txt");
