clear
clc

examples_struct = load('test.mat'); 
features = examples_struct.features_test;
labels = examples_struct.labels_test;
centers = load('codebook.mat');
centers = centers.C;

final_features = cell(length(features),1);

for d = 1 : length(features)
    cur_feature = features{d};
    cur_code = zeros(1,size(centers,1));
    
    for i = 1 : size(cur_feature,1)
        dists = zeros(1,size(centers,1));
        for bin = 1 : size(centers,1)
            diff = double(cur_feature(i,:)) - centers(bin,:);
            dists(bin) = diff * diff' ;
        end
        [~,idx] = max(dists);
        cur_code(idx) = cur_code(idx) + 1;
    end
    final_features{d} = cur_code;
end


save test_code.mat final_features labels

examples_struct = load('train.mat'); 
features = examples_struct.features_train;
labels = examples_struct.labels_train;

final_features = cell(length(features),1);

for d = 1 : length(features)
    cur_feature = features{d};
    cur_code = zeros(1,size(centers,1));
    
    for i = 1 : size(cur_feature,1)
        dists = zeros(1,size(centers,1));
        for bin = 1 : size(centers,1)
            diff = double(cur_feature(i,:)) - centers(bin,:);
            dists(bin) = diff * diff' ;
        end
        [~,idx] = max(dists);
        cur_code(idx) = cur_code(idx) + 1;
    end
    final_features{d} = cur_code;
end

save train_code.mat final_features labels