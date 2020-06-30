function [ models, cosines, group ] = readCorpus( N, L, W, matrix, labels, left, group, placeholder, percepts)
%READCORPUS reads a corpus into a multi-layer HDM
%   N is the dimensionality of the vectors
%   L is the number of layers
%   W is the window size, placeholder ± W, set to zero to use full sentence
%
%   MATRIX is the corpus of indices
%       each row is a sentence
%       each word/cell is an index
%       as generated using the word2index.m function
%       and imported using 'import data...' under the file menu
%
%   LABELS are the word labels generated
%       using the word2index.m function
%       and imported using 'import data...' under the file menu
'reading corpus'
% PARAMETER DEFAULTS
if nargin < 1
    N = 256; % dimensionality
end
if nargin < 2
    L = 4; % layers
end
if nargin < 3
    W = 0; % window size, by default use entire sentence / no window
end

% TEST DATA SET: If no parameters are given, demo with test data set
if nargin < 4
    labels = [{'eagles '},{'birds '},{'airplanes '},{'dishes '},...
              {'squirrels '},{'soar '},{'fly '},{'drive '},{'are '},...
              {'live '},{'over '},{'above '},{'through '},{'on '},{'in '}...
              {'trees '},{'forest '},{'skies '},{'plates '},{'streets '},{'cars'}];

    matrix   = [1,  6, 11, 16; ... % eagles soar over trees
                2,  7, 12, 17; ... % birds fly above forest
                3,  6, 13, 18; ... % airplanes soar through skies
                3,  7, 13, 18; ... % airplanes fly through skies
                4,  9, 11, 19; ... % dishes are over plates
                4,  9, 12, 19; ... % dishes are above plates
                5, 10, 15, 16; ... % squirrels live in trees
                5, 10, 15, 17; ... % squirrels live in forest
               21,  8, 14, 20];    % cars drive on streets
%                3,  8, 13, 18; ... % airplanes glide through skies 
%                4,  9, 14, 19; ... % dishes are atop plates
%                5, 10, 15, 20];    % squirrels live in woods
    
    TEST_MODE = true;
else
    TEST_MODE = false;
    %TEST_MODE = strcmp(labels{1},'eagles ');
end

% HIDDEN PARAMETERS
M = length(labels); % number of items in memory
NORMALIZE = true;  % normalize between layers (RECOMMENDED)
SKIPGRAM  = false; % use skip grams rather than conventional n-grams
NGRAMTEST = false;

[NUM_SENT,MAX_WORDS] = size(matrix);

% CONSTRUCT MODEL

% create permutations
if nargin < 6
    left  = getShuffle(N);
end
if nargin < 7
    group = getShuffle(N);
end
% create placeholder
if nargin < 8
    placeholder = normalVector(N);
end
if nargin < 9
    % first layer uses random vectors as percepts
    % unless otherwise specified
    percepts = zeros(M,N);
    for i=1:M
        percepts(i,:) = normalVector(N);
    end
end

models = cell(1,L);
cosines = zeros(M,M,L);
for h=1:L
    name = ['Layer ',int2str(h)];
    models{h} = HDM(percepts,percepts,labels,name,placeholder,left);
    
    for s=1:NUM_SENT
        % check to see if there's a invalid index:
        %   disallow Inf, NaN, and Zero values
        [invalid,loc] = max(not(isfinite(matrix(s,:))) | matrix(s,:) == 0);
        % if there is an invalid index, end the sentence before it
        if invalid
            sent_len = loc - 1;
        else % otherwise, the sentence is the maximum length
            sent_len = MAX_WORDS;
        end
        for r=1:sent_len
            % set window boundaries
            if W > 0 % read data within a sentence using a window
                first  = max(1,r-W);
                last   = min(r+W,sent_len);
                target = r - first + 1;
            else % don't use a window if W = 0
                first  = 1;
                last   = sent_len;
                target = r;
            end
            % construct window
            window           = percepts(matrix(s,first:last),:);
            window(target,:) = placeholder;
            % construct n-gram or skip-gram and add it to model
            if SKIPGRAM
                experience = hdmUOG(window,target,left);
            else
                experience = hdmNgram(window,target,left);
            end
            if NGRAMTEST
                csvwrite(strcat('experience',int2str(s),'.',int2str(r),'.csv'),experience);
                NGRAMTEST = false;
            end
            models{h} = models{h}.Add(matrix(s,r),experience);
        end
    end
    cosines(:,:,h) = 1 - squareform(pdist(models{h}.concepts,'cosine'));
    % use concepts to construct percepts for next layer
    if h < L
        % permute them to protect the data
        percepts = models{h}.concepts(:,group);
        % normalize if you don't want to bias representations
        % such that they become dominated by the most familiar items
        if NORMALIZE
            for i=1:M
                percepts(i,:) = vecNorm(percepts(i,:));
            end
        end
    end
end

% DISPLAY VISUALS IF IN TEST MODE
if TEST_MODE
    'test_mode_engaged'
    % Colours for scatter plot
    colours = [1 0 1; 1 0 1; 0.5 0.5 0.5; 0.5 0.5 0.5; 0.5 0.5 0.5; ...
               0 0.75 0.75; 0 0.75 0.75; 0 0.75 0.75; 0.5 0.5 0.5; 0.5 0.5 0.5; ...
               1 0 0; 1 0 0; 0.5 0.5 0.5; 1 0 0; 0.5 0.5 0.5; ...
               0 1 0; 0 1 0; 0.5 0.5 0.5; 0.5 0.5 0.5; 0 1 0];
    
    % labels to add to graph
    select = [1,2,6,7,8,11,12,14,16,17,20];

    for h=1:L
        model = models{h};
        reduc = cmdscale(1 - cosines(:,:,h));
        figure(h);
        %scatter(reduc(:,1),reduc(:,2),60,colours,'filled');
        scatter3(reduc(:,1),reduc(:,2),reduc(:,3),60*reduc(:,3)+60,colours,'filled');
        title(model.name,'FontSize',18,'FontName','Times New Roman');
        dx = 0.03;
        dy = 0.03;
        dz = 0.03;
        text(reduc(select,1)+dx,reduc(select,2)+dy,reduc(select,3)+dz,labels(select),'FontSize',16,'FontName','Times New Roman');
        %text(reduc(select,1)+dx,reduc(select,2)+dy,labels(select));
    end
end % END DISPLAY VISUALS

end % END FUNCTION

