M = 1052;N = 1914;
files = dir('trainval/*/*_image.jpg');
Num = numel(files);
tic;
for i = 1:Num
    if rem(i,100)==0
        disp(i)
        toc
        tic;
    end
    file = files(i);
    snapshot = [file.folder, '/', file.name];
    img = imread(snapshot);
    fullFileName = sprintf('data_for_yolo/test%d.jpg',i); 
    imwrite(img, fullFileName);

    proj = read_bin(strrep(snapshot, '_image.jpg', '_proj.bin'));
    proj = reshape(proj, [4, 3])';
    bbox = read_bin(strrep(snapshot, '_image.jpg', '_bbox.bin'));
    bbox = reshape(bbox, [11, numel(bbox) / 11])';
    ignore_in_eval = bbox(:,11);
    bbox = bbox(~ignore_in_eval,:);
    
    fullFileName = sprintf('data_for_yolo/test%d.txt',i);
    fileID = fopen(fullFileName,'w');
    if ~isempty(bbox)
        for k = 1:size(bbox,1);
            b = bbox(k, :);
            n = b(1:3);
            theta = norm(n, 2);
            n = n / theta;
            R = rot(n, theta);
            t = reshape(b(4:6), [3, 1]);

            sz = b(7:9);
            [vert_3D, edges] = get_bbox(-sz / 2, sz / 2);
            vert_3D = R * vert_3D + t;

            vert_2D = proj * [vert_3D; ones(1, 8)];
            vert_2D_car = vert_2D(1:2,:) ./ vert_2D(3, :);
            car_min = min(vert_2D_car,[],2);
            car_max = max(vert_2D_car,[],2);
            car_min = max(min(car_min,[N;M]),1);
            car_max = max(min(car_max,[N;M]),1);
            c = (car_min+car_max)/2;
            h = (car_max-car_min)/2;
            A = [0 c(1)/N c(2)/M h(1)/N h(2)/M];
            fprintf(fileID,'%d %12.8f %12.8f %12.8f %12.8f\r\n',A);%accuracy of input
        end
    end 
    fclose(fileID);
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