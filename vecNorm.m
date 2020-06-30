function [ a ] = vecNorm( a )
%vecNorm normalizes vector "a" to a Euclidean length (i.e., magnitude) of 1

aa = dot(a,a);
if aa ~= 0 % prevent divide by zero
    a = a / sqrt(aa);
end

end