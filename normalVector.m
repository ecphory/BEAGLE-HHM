function [ vector ] = normalVector( n )
%normalVector
% Generate a vector of n random values
% selected from an normal distribution
% with a mean of 0 and a variance of 1/n
% (i.e. a standard deviation of sqrt(1/n)).
% The vector is then normalized to have a mean of zero
% and Euclidean length (i.e magnitude) of one.

% mean and standard deviation of the normal distribution 
sd = sqrt(1/n);
mn = 0;

% sample n random values from the normal distribution to create a vector
vector = mn + sd*randn(1,n);

% The vector's mean and magnitude should be respectively close to
% 0 and 1 given the properties of the distribution from which the
% values of the vector have been sampled. Nonetheless, here we
% ensure that the mean is exactly 0 and magnitude is exactly 1.
vector = vector - mean(vector);
vector = vector / sqrt(dot(vector,vector));

end