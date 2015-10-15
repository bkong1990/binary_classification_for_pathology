% [scores, maxlabel] = classification_demo(im, use_gpu)
%
% Image classification demo using BVLC CaffeNet.
%
% IMPORTANT: before you run this demo, you should download BVLC CaffeNet
% from Model Zoo (http://caffe.berkeleyvision.org/model_zoo.html)
%
% ****************************************************************************
% For detailed documentation and usage on Caffe's Matlab interface, please
% refer to Caffe Interface Tutorial at
% http://caffe.berkeleyvision.org/tutorial/interfaces.html#matlab
% ****************************************************************************
%
% input
%   im       color image as uint8 HxWx3
  %
% output
%   scores   1000-dimensional ILSVRC score vector
%   maxlabel the label of the highest score
%
% You may need to do the following before you start matlab:
%  $ export LD_LIBRARY_PATH=/opt/intel/mkl/lib/intel64:/usr/local/cuda-5.5/lib64
%  $ export LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libstdc++.so.6
% Or the equivalent based on where things are installed on your system
%
% Usage:
%  im = imread('../../examples/images/cat.jpg');
%  scores = classification_demo(im, 1);
%  [score, class] = max(scores);
% Five things to be aware of:
%   caffe uses row-major order
%   matlab uses column-major order
%   caffe uses BGR color channel order
%   matlab uses RGB color channel order
%   images need to have the data mean subtracted

% Data coming in from matlab needs to be in the order
%   [width, height, channels, images]
% where width is the fastest dimension.
% Here is the rough matlab for putting image data into the correct
% format in W x H x C with BGR channels:
%   % permute channels from RGB to BGR
%   im_data = im(:, :, [3, 2, 1]);
%   % flip width and height to make width the fastest dimension
%   im_data = permute(im_data, [2, 1, 3]);
%   % convert from uint8 to single
%   im_data = single(im_data);
%   % reshape to a fixed size (e.g., 227x227).
%   im_data = imresize(im_data, [IMAGE_DIM IMAGE_DIM], 'bilinear');
%   % subtract mean_data (already in W x H x C with BGR channels)
%   im_data = im_data - mean_data;

% If you have multiple images, cat them with cat(4, ...)

% Add caffe/matlab to you Matlab search PATH to use matcaffe
clear
clc

if exist('../+caffe', 'dir')
  addpath('..');
else
  error('Please run this demo from caffe/matlab/demo');
end


caffe.set_mode_cpu();

% Initialize the network using BVLC CaffeNet for image classification
% Weights (parameter) file needs to be downloaded from Model Zoo.
model_dir = '../../examples/1362_962_1/';
net_model = [model_dir 'deploy.prototxt'];
net_weights = [model_dir '1362_962_iter_20000.caffemodel'];
phase = 'test'; % run with phase test (so that dropout isn't applied)
if ~exist(net_weights, 'file')
  error('Please download CaffeNet from Model Zoo before you run this demo');
end

% Initialize a network
net = caffe.Net(net_model, net_weights, phase);


 % For demo purposes we will use the cat image
data_folder = '/media/bkong/bkong_DATA/Data/XF_classification';
D = importdata(fullfile(data_folder,'test.txt'));
img_name = D.textdata;
labels = D.data;

TP = 0;
FP = 0;
TN = 0;
FN = 0;

f = fopen('1.txt','w');

sm_pic_labels = containers.Map;
sm_pic_scores = containers.Map;
for d = 1 : length(img_name)
    fprintf('Processing the %d/%d image\n', d, length(img_name));
    im = imread(fullfile(data_folder,fullfile('test_XF', img_name{d})));
    sm_pic_labels(img_name{d}) = labels(d);
    
    % prepare oversampled input
    % input_data is Height x Width x Channel x Num
   
    input_data = {prepare_image(im)};
    
    % do forward pass to get scores
    % scores are now Channels x Num, where Channels == 1000
   
    % The net forward function. It takes in a cell array of N-D arrays
    % (where N == 4 here) containing data of input blob(s) and outputs a cell
    % array containing data from output blob(s)
    net.forward(input_data);
    
    scores = net.blobs('fc8_flickr').get_data();
    scores = mean(scores, 2);  % take average scores over 10 crops
    
    [~, maxlabel] = max(scores);
    if maxlabel == 1
        if labels(d) == 0
            TN = TN + 1;
        end
        if labels(d) == 1
            FN = FN + 1;
            fprintf(f,'%s\n',img_name{d});
        end
    end
    if maxlabel == 2
        if labels(d) == 1
            TP = TP + 1;
        end
        if labels(d) == 0
            FP = FP + 1;
            fprintf(f,'%s\n',img_name{d});
        end
    end
    
    sm_pic_scores(img_name{d}) = scores;
end
fclose(f);

% call caffe.reset_all() to reset caffe
caffe.reset_all();

fprintf('Accuracy for the small images are %f\n', (TP + TN)/ (TP + TN + FP + FN))
draw_confusion_matrix(TN, FP, FN, TP);

% ------------------------------------------------------------------------
patients={
'S07-9452_ROI',
 'S08-13016_ROI',
 'S08-13180_ROI',
 'S08-15134_ROI',
 'S08-15515_ROI',
 'S08-18213_ROI',
 'S08-18843_ROI',
 'S08-21952_ROI',
 'S08-23269_ROI',
 'S08-23735_ROI',
'S07-1698_ROI',
 'S07-28200_ROI',
 'S07-4393_ROI',
 'S08-16750_ROI',
 'S08-5423_ROI',
 'S08-7609_ROI',
 'SA08-856_ROI',
 'SA09-160_ROI',
 'SM05-9813_ROI',
 'SN06-1753_ROI'};

patient_labels = containers.Map;
patient_scores = containers.Map;
patient_num = containers.Map;
for d = 1 : length(patients)
    patient_labels(patients{d}) = 0;
    patient_scores(patients{d}) = [0;0];
    patient_num(patients{d}) = 0;
end

sm_pic_name = keys(sm_pic_scores);
for d = 1 : length(sm_pic_labels)
    name = sm_pic_name{d};
    for count = 1 : length(patients)
        patient = patients{count};
        if strncmp(patient, name(4:end), length(patient))
            patient_num(patient) = patient_num(patient)+1;
            patient_labels(patient) = sm_pic_labels(name);
            patient_scores(patient) = patient_scores(patient) + sm_pic_scores(name);
            break;
        end
    end
end

TP1 = 0;
FP1 = 0;
TN1 = 0;
FN1 = 0;


for d = 1 : length(patient_labels)
    patient = patients{d};
    [~, maxlabel] = max(patient_scores(patient));
    if maxlabel == 2
        if patient_labels(patient) == 1
            TP1 = TP1 + 1;
        else
            FP1 = FP1 + 1;
            disp(patient);
        end
    else
        if patient_labels(patient) == 1
            FN1 = FN1 + 1;
            disp(patient);
        else
            TN1 = TN1 + 1;
        end
    end
end
fprintf('Accuracy for the big images are %f\n', (TP1 + TN1)/ (TP1 + TN1 + FP1 + FN1))
draw_confusion_matrix(TN1, FP1, FN1, TP1);