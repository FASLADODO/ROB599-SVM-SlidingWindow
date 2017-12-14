acc = []
p = randperm(12451);
train = table2array(X(p(1:10000),:));
train_label = table2array(y(p(1:10000),:));
test = table2array(X(p(10001:end),:));
test_label = table2array(y(p(10001:end),:));

for C = 15:5:20
    SVMModel = fitcsvm(train,train_label,'BoxConstraint',C);
    [label,score] = predict(SVMModel,test);
    acc = [acc,sum(label==test_label)];
end
idx = find(acc==max(acc))
acc2=[]
for C = ((idx-1)*5 +1):((idx+1)*5 -1)
    SVMModel = fitcsvm(train,train_label,'BoxConstraint',C);
    [label,score] = predict(SVMModel,test);
    acc2 = [acc2,sum(label==test_label)];
end
idx2 = find(acc2==max(acc2))
k = (idx-1)*5 + idx2;

acc3 = [];
for C = k-0.9:0.1:k+0.9
    SVMModel = fitcsvm(train,train_label,'BoxConstraint',C);
    [label,score] = predict(SVMModel,test);
    acc3 = [acc3,sum(label==test_label)];
end
idx3 = find(acc3==max(acc3))
holdout_error = acc3(idx3)/2451
C = 3.45
SVMModel = fitcsvm(X,y,'BoxConstraint',C);
[label,score] = predict(SVMModel,X);
acc = sum(label==y)/12451
