function [ perm, invPerm ] = getShuffle( N )
%GETSHUFFLE provides a permutation and inverse permutation 
%           of the numbers 1:N.
%   perm: for shuffling a thing, shuffledThing = thing(perm)
%   invPerm: for unshuffling, thing = shuffledThing(invPerm)

[~,perm] = sort(rand([1,N]));

[~,invPerm] = sort(perm);

end