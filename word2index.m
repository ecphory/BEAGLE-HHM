function [] = word2index( filename, delim, MAX_LINE, stoplist, printLengths )
%WORD2INDEX Takes a text file filename and replaces all words with indices
%   Writes list of words to filename_WORDS
%   Writes text file with words replaced with indices to filename_INDICES
%   Continued until the line MAX_LINE is reached or end of file

if nargin < 2
    delim = ' ';
end
if nargin < 3
    MAX_LINE = inf; % continue until end of file
end
if nargin < 4
    stoplist = []; % there are no words in the stop list
end
if nargin < 5
    printLengths = false;
end

% Read the corpus line-by-line
corpusFile = fopen(filename,'r');
line = fgetl(corpusFile);
wordList  = cell(30000,1); %30 000 is just a best guess as to how many
wordCount = 0;
sentCount = 0;
% Write indices line-by-line
indexFile = fopen(strcat(filename,'_INDEX.txt'),'w');

% Write word list to file
wordFile = fopen(strcat(filename,'_WORDS.txt'),'w');

% Loop until end of file
while ischar(line) && (sentCount < MAX_LINE)
    if not(isempty(line))        
        words = textscan(line,'%s','delimiter',delim);
        %words = textscan(line,'%s','delimiter',' ');
        words = words{1}; % don't ask
        
        % to lowercase
        for i=1:length(words)
            words{i} = lower(words{i});
        end
        
        % apply stop list
        if not(isempty(stoplist))
            filteredWords = {};
            for i=1:length(words)
                if not(lookup(words{i},stoplist))
                    filteredWords{length(filteredWords)+1} = words{i};
                end
            end
            words = filteredWords;
        end
        
        % omit sentences that are too short or too long
        if (length(words) > 1) && (length(words) < 101)
            sentCount = sentCount + 1;
            indices = zeros(1,length(words));
            % for each word on the line, find its index or create new index
            for i=1:length(words)
                index = 0;
                for j=1:wordCount
                    if strcmp(words{i},wordList{j})
                        index = j; % index found
                        break % stop searching the wordList
                    end
                end
                if not(index) % if no index found, add to wordList
                    wordCount       = wordCount + 1;
                    index           = wordCount;
                    wordList(index) = words(i);
                    % write to file
                    fprintf(wordFile, '%s\n', wordList{index});
                end
                indices(i) = index;
            end
            % for compatibility with FORTRAN and novels corpus
            % we may want to print the sentence length first
            if printLengths
                indices = [length(indices),indices];
            end
            % print a line of indices to file
            fprintf(indexFile,'%s\n',int2str(indices));
        end % > 1 word
    end % not empty
    line = fgetl(corpusFile);
end % end while
fclose(corpusFile);
fclose(indexFile);
fclose(wordFile);


end % end function

