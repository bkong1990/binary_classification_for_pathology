% Generate features from a bunch of images in a directory that contains two
% subfolders: C1, C2
% also make sure to indicate the txt file that show the class labels

clear
clc

% include vlfeat
run('toolbox/vlfeat-0.9.20/toolbox/vl_setup');

% training and validation image folders
data_folder='/media/bkong/bkong_DATA/Data';
train_images_folder='/media/bkong/bkong_DATA/Data/Data_GroundTruth';

test_images_folder='/media/bkong/bkong_DATA/Data/Data_GroundTruth';

[features_train, labels_train] = extract_SIFT_features(fullfile(data_folder,'train.txt'), train_images_folder);
[features_test, labels_test] = extract_SIFT_features(fullfile(data_folder,'test.txt'), test_images_folder);

save train.mat features_train labels_train
save test.mat features_test labels_test