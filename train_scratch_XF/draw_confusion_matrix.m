function draw_confusion_matrix(TN, FP, FN, TP)

matrix = [TN, FP; FN, TP];
matrix(1,:) = matrix(1,:)/sum(matrix(1,:));
matrix(2,:) = matrix(2,:) / sum(matrix(2,:));

img = imresize(matrix, [255,255], 'nearest');
figure
imshow(img);
colormap(jet)
colorbar

row_parts = size(img, 1) / 2 /2;
col_parts = size(img, 2) / 2 /2;

for i = 1 : 2
    for j = 1 : 2
        text(col_parts * (2*j-1), row_parts * (2*i-1), num2str(matrix(i,j),'%2.2f'));
    end
end

end