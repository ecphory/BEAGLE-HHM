function [ index ] = lookup( word, dictionary )
%LOOKUP finds an exact match to string WORD in cell array DICTIONARY
% index defaults to zero if not found
index = 0;
for i=1:length(dictionary)
    if strcmp(strtrim(dictionary{i}),word)
        index=i;
    end
end

end