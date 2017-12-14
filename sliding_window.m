% fileID = fopen('sub1.txt','w');

N=[];
% files = dir('rob599_dataset_deploy/test/*/*_image.jpg');
tic;
for i = 1:numel(files)
    if rem(i,100)==0
        disp(i)
        toc;
        tic;
    end
    file = files(i);
    snapshot = [file.folder, '/', file.name];
    img = imread(snapshot);
    %window size 64 by 64, stride 32
%     map = []
    feature = [];
    for j = 64:64:960
        for k = 64:64:1856
            I = img(j-32:j+31,k-32:k+31,:);
            feature = [feature;extractHOGFeatures(I)];
        end
    end
    feature = feature(:,1:end-1);
    
    
%      map(j,k) = reshape(score(:,1),)
n = size(find(score(:,2)>40),1);
    %window size 32 by 32, stride 16
    
    %window size 128 by 128, stride 64
    
    %window size 

    
    
    N = [N,n]
%     x = snapshot(63:end);
%     x = x(1:end-10);
% %     fprintf(fileID,'%s,%d\n',x,'n');
% csvwrite('',x)
end
save('N.mat','N')
save('files.mat','files')
% fclose(fileID);