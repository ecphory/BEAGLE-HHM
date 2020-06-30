MATLAB code for BEAGLE / HHM models.

Cite Kelly, Reitter & West (2017) for HHM (see BibTex file).

readCorpus.m constructs the BEAGLE/HHM model from the corpus represented as a matrix.

readCorpusFile.m reads an indexed corpus file and puts it into a matrix

word2index.m takes a text document a produces a lexicon and indexed corpus file

HDM.m is a BEAGLE model.

hdmNgram.m creates a vector representing all n-grams up to window size within a given window

hdmUOG.m creates a vector representing all unconstrained open grams up to window size within a given window

normalVector.m creates a random vector of normal / Gaussian distributed values

vecNorm.m normalizes a vector to a Euclidean length of one

vectorCosine.m measures the cosine similarity between vectors

lookup.m looks up the vector for a word given the word, uses an inefficient linear search

getShuffle.m creates a permutation of the numbers 1 to N.