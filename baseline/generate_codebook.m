% load SIFT featues, labels from mat files
clear;clc
load train.mat

num_of_images = length(features_train);
features_selected = cell(num_of_images,1);

for d = 1 : num_of_images
    cur_img_feature = features_train{d};  % currect image 
    cur_img_feature_num = size(cur_img_feature,1); % how many features in that image?
    num_selected = floor(0.1 * cur_img_feature_num+1);  % select 10% features
    rand_nums = randperm(cur_img_feature_num);
    selected_index = rand_nums(1:num_selected);
    cur_features_selected = zeros(num_selected,size(cur_img_feature,2));
    
    for ptr = 1 : num_selected
        cur_features_selected(ptr,:) = cur_img_feature(selected_index(ptr),:);
    end
    
    features_selected{d} = cur_features_selected;
end

% % any recommend?
codebook_size = 200;
features_selected = cell2mat(features_selected);
% %save features_selected.mat features_selected
% 
% features_selected = features_selected';
pool = parpool; 
stream = RandStream('mlfg6331_64');
options = statset('UseParallel',1,'UseSubstreams',1,'Streams',stream);
% 
tic;
[idx, C, sumd, D] = kmeans(features_selected, codebook_size, 'Options', options, 'MaxIter', 2000, 'Display', 'final', 'Replicates', 5);
toc;

save codebook.mat C

