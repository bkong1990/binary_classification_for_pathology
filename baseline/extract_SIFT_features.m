function [features, labels] = extract_SIFT_features(data_dir, images_folder)

D = importdata(data_dir);
images_name = D.textdata();
labels = D.data();
features = cell(size(labels));

for d = 1 : length(images_name)
    img_name = fullfile(images_folder, images_name{d});
    img = imread(img_name);
    
    [~,feature] = vl_sift(single(rgb2gray(img)));
    features{d} = feature';
end

labels(labels==0) = -1;

end