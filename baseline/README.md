# Notes for running this baseline:

1 run generate_features.m, this will generate train.mat and test.mat files which contains the training features extracted from training example images and testing images used to get the testing error.

2 run generate_codebook.m, which will utilise train.mat to generate codebook for encoding SIFT features.

3 run encodeFeature.m to encode the SIFT features extracted from both training and testing images, this file will need train.mat, test.mat and codebook.mat files.

4. run dic_demo.m, this file will train a SVM machine and to test it on the testing examples to get the accuracy.
