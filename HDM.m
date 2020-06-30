classdef HDM
    %HDM memory model (Kelly, Kwok, & West, 2015)
    
    properties
        % actual values of these properties are set in the constructor
        percepts = 0;
        concepts = 0;
        labels = 0;
        placeholder = 0;
        left = 0;
        group = 0;
        % n: the dimensionality of a percept or concept
        n = 0;
        % m: the number of percepts / concepts
        m = 0;
        % activation threshold: if max similarity is below this,
        %                       retrieval failure occurs
        ACTIVATION_THRESHOLD = 0;
        % name of the model
        name = 'HDM';
    end
    
    methods
        % construct HDM model
        % concepts, percepts, and labels are required
        % all other arguments have defaults
        function obj = HDM(concepts,percepts,labels,name,placeholder,left,group)
            [obj.m,obj.n] = size(concepts);

            % create the model
            obj.concepts = concepts;
            obj.percepts = percepts;
            obj.labels   = labels;
            
            if nargin > 3
                obj.name = name;
            end
            
            % the placeholder vector - acts as a question mark
            if nargin > 4
                obj.placeholder = placeholder;
            else
                obj.placeholder = normalVector(obj.n);
            end
            % left - a permutation indicating order
            if nargin > 5
                obj.left = left;
            else
                obj.left = getShuffle(obj.n);
            end
            % group - a permutation for creating composite units (groups)
            if nargin > 6
                obj.group = group;
            else
                obj.group = getShuffle(obj.n);
            end
        end
        
        % given probe, find memory vector most similar to probe
        % retrieve:
        %   maxSim: similarity of that memory vector
        %   index: index of that memory vector
        %   percept: environment vector corresponding to that memory vector
        function [maxSim,index,label,percept] = Retrieve(obj,probe)
            
            % find concept most similar to the probe
            similarities = obj.Resonance(probe);
            [maxSim,index] = max(similarities);
            
            % here's the label and percept if you want it
            if maxSim > obj.ACTIVATION_THRESHOLD
                label = obj.labels(index);
                percept = obj.percepts(index);
            else
                % if nothing in memory has greater similarity than zero
                % the following default values are returned
                index = 0;
                maxSim = obj.ACTIVATION_THRESHOLD;
                label = 'retrieval failure';
                percept = zeros(1,obj.n);
            end
        end
                
        % calculate all similarities between probe and memory vectors
        function similarities = Resonance(obj,probe)
            similarities = zeros(1,obj.m);
            for i=1:obj.m
                similarities(i) = obj.GetSimilarity(i,probe);
            end
        end

        % get the similarity between the probe and indexed memory vector
        function similarity = GetSimilarity(obj,index,probe)
            item = obj.concepts(index,:);
            if all(item==0)
                similarity = 0;
            else
                similarity = vectorCosine(item,probe);
            end
        end
        
        % add an experience (represented by a vector) of indexed concept
        function obj = Add(obj,index,experience)
            obj.concepts(index,:) = obj.concepts(index,:) + experience;
        end
        
        % read in a set of sentences commit those associations to memory
        % indices is a matrix of percept/concept indices
        %   each row of indices is a 'sentence' of co-occurring terms
        %   each column of indices is a sentence position
        function obj = Read(obj,indices)
            [num_sentences, num_words] = size(indices);
            for i=1:num_sentences
                % check to see if there's a invalid index:
                %   disallow Inf, NaN, and Zero values
                [invalid,loc] = max(not(isfinite(indices(i,:))) | indices(i,:) == 0);
                % if there is an invalid index, end the sentence before it
                if invalid
                    sent_len = loc - 1;
                else % otherwise, the sentence is the maximum length
                    sent_len = num_words;
                end
                % construct the sentence
                sentence  = zeros(sent_len,obj.n);
                for w=1:sent_len
                    sentence(w,:) = obj.percepts(indices(i,w),:);
                end
                % for each word in the sentence, construct a query
                % and convert the query into a vector using hdmUOG
                % then add that vector to memory
                for w=1:sent_len
                    query = sentence;
                    query(w,:) = obj.placeholder;
                    obj = obj.Add(indices(i,w),hdmUOG(query,w,obj.left));
                end
            end
        end
        
        % retrieve from HDM the memory vector identified by label
        function concept = GetConcept(obj,label)
            index = lookup(label,obj.labels);
            concept = obj.concepts(index,:);
        end
        
        % retrieve from HDM the environment vector identified by label
        function percept = GetPercept(obj,label)
            index = lookup(label,obj.labels);
            percept = obj.percepts(index,:);
        end
        
    end % end methods
    
end % end classdef

