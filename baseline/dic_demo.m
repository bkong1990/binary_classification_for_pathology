clear
clc
examples = load('train_code.mat');
test_image_code = load('test_code.mat');

train_labels = examples.labels;
train_labels(train_labels==0)=-1;
test_labels = test_image_code.labels;
test_labels(test_labels == 0) = -1;
examples = sparse(cell2mat(examples.final_features));
test_features = sparse(cell2mat(test_image_code.final_features));

addpath('./toolbox/liblinear-2.01/matlab');
model = train(train_labels,examples, '-s 2');
%model = train(train_labels,examples);

[predict_label, accuracy, dec_values] = predict(test_labels, test_features, model);

TP = 0 ;
FP = 0;
FN = 0;
TN = 0;
for d = 1 : length(test_labels)
    if predict_label(d) == 1
        if test_labels(d) ==1
            TP = TP + 1;
        end
        if test_labels(d) ==-1
            FP = FP + 1;
        end
    end
    
    if predict_label(d) == -1
        if test_labels(d) ==1
            FN = FN + 1;
        end
        if test_labels(d) ==-1
            TN = TN + 1;
        end
    end
end

data_folder='/media/bkong/bkong_DATA/Data/test.txt';

D = importdata(data_folder);
labels = D.data();
images = D.textdata();

draw_confusion_matrix(TN, FP, FN, TP);

C1={
'S07-9452_ROI',
 'S08-13016_ROI',
 'S08-13180_ROI',
 'S08-15134_ROI',
 'S08-15515_ROI',
 'S08-18213_ROI',
 'S08-18843_ROI',
 'S08-21952_ROI',
 'S08-23269_ROI',
 'S08-23735_ROI'};

C2={
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

patient_values = containers.Map;
patients_label = containers.Map;
for d = 1 : length(C1)
    patient_values(C1{d}) = 0;
    patients_label(C1{d}) = 1;
end

for d = 1 : length(C1)
    patient_values(C2{d}) = 0;
    patients_label(C2{d}) = 0;
end

patients = keys(patient_values);
for d = 1 : length(dec_values)
    image_name = images{d};
    for count = 1 : length(patients)
        if strncmp(patients{count}, image_name(4:end),length(patients{count}))
             patient_values(patients{count}) = patient_values(patients{count}) + dec_values(d);
        end
    end
end

TP = 0;
TN = 0;
FP = 0;
FN = 0;
for count = 1 : length(patients)
    if patient_values(patients{count}) > 0
        if patients_label(patients{count}) > 0
            TP = TP + 1;
        end
        if patients_label(patients{count}) == 0
            FP = FP + 1;
        end
    end
    
    if patient_values(patients{count}) < 0
        if patients_label(patients{count}) == 0
            TN = TN + 1;
        end
        if patients_label(patients{count}) > 0
            FN = FN + 1;
        end
    end
    if patient_values(patients{count}) == 0
        error('cannot be zero');
    end
    
end

draw_confusion_matrix(TN, FP, FN, TP);

