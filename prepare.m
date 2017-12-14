numrows = 64;numcols = 64;
M = 1052;N = 1914;
Num = numel(files);
stride = randi([1 3],1,Num);
x = randi([1 M-200],1,Num);
x_end = x + stride*63;
y = randi([1 N-200],1,Num);
y_end = y + stride*63;
files = dir('rob599_dataset_deploy/trainval/*/*_image.jpg');
car = zeros(numrows,numrows,3,2);
k_car = 0;
not_valid = zeros(numrows,numrows,3,2);
k_not_valid = 0;
scene = zeros(numrows,numrows,3,2);
tic;
for i = 298:Num%101:numel(files)
    if rem(i,100)==0
        disp(i)
        toc
        tic;
    end
    file = files(i);
    snapshot = [file.folder, '/', file.name];
    img = imread(snapshot);
    proj = read_bin(strrep(snapshot, '_image.jpg', '_proj.bin'));
    proj = reshape(proj, [4, 3])';
    bbox = read_bin(strrep(snapshot, '_image.jpg', '_bbox.bin'));
    bbox = reshape(bbox, [11, numel(bbox) / 11])';
    ignore_in_eval = bbox(:,11);
    idx_car = find(ignore_in_eval~=0,1,'first');
    idx_non_car = find(ignore_in_eval==0,1,'first');
    if ~isempty(idx_car)
        k_car = k_car+1;
        b = bbox(idx_car, :);
        n = b(1:3);
        theta = norm(n, 2);
        n = n / theta;
        R = rot(n, theta);
        t = reshape(b(4:6), [3, 1]);

        sz = b(7:9);
        [vert_3D, edges] = get_bbox(-sz / 2, sz / 2);
        vert_3D = R * vert_3D + t;

        vert_2D = proj * [vert_3D; ones(1, 8)];
        vert_2D_car = round(vert_2D(1:2,:) ./ vert_2D(3, :));
        car_min = min(vert_2D_car,[],2);
        car_max = max(vert_2D_car,[],2);
        car_min = max(min(car_min,[N;M]),1);
        car_max = max(min(car_max,[N;M]),1);
        image1 = imresize(img(car_min(2):car_max(2),car_min(1):car_max(1),:),[numrows,numcols]);
%         fullFileName = strrep(snapshot, '_image.jpg', '_car.jpg'); 
%         imwrite(image1, fullFileName);
        car(:,:,:,k_car) = image1;
    end  
        %%%%%%%%%%%%%5
    if ~isempty(idx_non_car)
        k_not_valid = k_not_valid + 1;
        b = bbox(idx_non_car, :);

        n = b(1:3);
        theta = norm(n, 2);
        n = n / theta;
        R = rot(n, theta);
        t = reshape(b(4:6), [3, 1]);

        sz = b(7:9);
        [vert_3D, edges] = get_bbox(-sz / 2, sz / 2);
        vert_3D = R * vert_3D + t;

        vert_2D = proj * [vert_3D; ones(1, 8)];
        vert_2D__non_car = round(vert_2D(1:2,:) ./ vert_2D(3, :));
        non_car_min = min(vert_2D_car,[],2);
        non_car_max = max(vert_2D_car,[],2);
        non_car_min = max(min(non_car_min,[N;M]),1);
        non_car_max = max(min(non_car_max,[N;M]),1);
        image2 = imresize(img(non_car_min(2):non_car_max(2),non_car_min(1):non_car_max(1),:),[numrows,numcols]);
%         fullFileName = strrep(snapshot, '_image.jpg', '_non_car.jpg'); 
%         imwrite(image2, fullFileName);
        not_valid(:,:,:,k_not_valid) = image2;
    end
    image3 = img(x(i):stride(i):x_end(i),y(i):stride(i):y_end(i),:);
%     fullFileName = strrep(snapshot, '_image.jpg', '_scene.jpg'); 
%     fullFileName = strrep(fullFileName, 'rob599_dataset_deploy', 'dataset');
%     imwrite(image3, fullFileName);
    scene(:,:,:,i) = image3;
end
save('car.mat','car')
save('not_valid.mat','not_valid')
save('scene.mat','scene')



function [v, e] = get_bbox(p1, p2)
v = [p1(1), p1(1), p1(1), p1(1), p2(1), p2(1), p2(1), p2(1)
    p1(2), p1(2), p2(2), p2(2), p1(2), p1(2), p2(2), p2(2)
    p1(3), p2(3), p1(3), p2(3), p1(3), p2(3), p1(3), p2(3)];
e = [3, 4, 1, 1, 4, 4, 1, 2, 3, 4, 5, 5, 8, 8
    8, 7, 2, 3, 2, 3, 5, 6, 7, 8, 6, 7, 6, 7];
end