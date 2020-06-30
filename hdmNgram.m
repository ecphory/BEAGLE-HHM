function [ sum ] = hdmNgram( percepts, p, left )
%hdmNgram produces all the convolutional n-grams of row vectors in percepts
%   that contain vector p
%   n-grams vary in size from 1 to numOfItems   
%   Contrast with hdmUOG, which gets all skip-grams / unconstrained open
%   grams of row vectors in percepts that contain vector p.
%
%   percepts: matrix of environmental vectors of dimensions [numOfItems,N]
%             where: numOfItems is the number of vectors
%                    N is the dimensionality of each vector
%
%   chunk: sum of all n-grams of the environmental vectors in percepts
%          
%   p: the index of the placeholder vector, i.e., the item that must be
%      included in all n-grams
%          
%   left: permutation for indicating that a vector is the left operand of
%         a non-commutative circular convolution. By default, the function
%         uses no permutation (i.e., the numbers 1 to N in ascending order)

[numOfItems,N] = size(percepts);

if nargin < 3
    left = 1:N;
end

gram = percepts(1,:);
sum  = zeros(1,N);

for i=2:numOfItems
    if i < p % build up grams
        gram = percepts(i,:) + cconv(gram(left),percepts(i,:),N);
    elseif i == p % begin add grams to the sum now that we've hit p
        gram = cconv(gram(left),percepts(i,:),N);
        sum  = gram;
        gram = gram + percepts(i,:);
    else % i > p
        gram = cconv(gram(left),percepts(i,:),N);
        sum  = sum + gram;
    end
end

end