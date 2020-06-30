function [ matrix ] = readCorpusFile( filename, delim, MAX_LINE )
%Reads a corpus file, e.g., the novels corpus, into a matrix

if nargin < 2
    delim = ' ';
end
if nargin < 3
    MAX_LINE = inf; % continue until end of file
end

if MAX_LINE < inf
    matrix = zeros(MAX_LINE,100);
else
    matrix = zeros(100000,100);
end

% Read the corpus line-by-line
corpusFile = fopen(filename,'r');
line = fgetl(corpusFile);
max_sent = 2; % longest sentence found so far
s = 1; % sentence count
% Loop until end of file
while ischar(line) && (s < MAX_LINE)
    if not(isempty(line))
        words = textscan(line,'%s','delimiter',delim);
        words = words{1}; % don't ask
        numbers = [];
        j = 0;
        % find all of the numbers in the array words
        for i=1:length(words)
            if not(isempty(words{i}))
                j = j + 1;
                numbers(j) = str2num(words{i});
            end
        end
        % omit sentences that are too short
        if (j > 1)
            matrix(s,1:j) = numbers;
            s = s+1;
        end % > 1 word
        if j > max_sent
            max_sent = j;
        end
    end % not empty
    line = fgetl(corpusFile);
end % end while
fclose(corpusFile);

matrix = matrix(1:s,1:max_sent);

end % end function
