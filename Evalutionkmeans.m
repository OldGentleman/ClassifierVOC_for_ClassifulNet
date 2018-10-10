%kmeans
%随机获取150个点
clc,clear
load ('output/classifier_bbx2.mat')
% x=zeros(5000,12);
% for i=1:5000
%     i
% %     if mod(i,500)==1
% %         i
% %     end
% for j=1:12
%     tempmat = cell2mat(classifier_bbx{j});
%     index = find(tempmat(:,1)==i);
%     if isempty(index)
%         continue
%     end
%     temp = [tempmat(index(1),3)+tempmat(index(1),5),tempmat(index(1),4)+tempmat(index(1),6)]/2;
%     x(i,(j*2-1):2*j)=temp;
% end
% end
% save('Evalution/x.mat','x');
% return
%%
load('output1/roiscell.mat')
x1list = [];
for i=1:length(roiscell)
    for j=1:length(roiscell{i})
        if isempty(roiscell{i}{j})
            continue
        end
        temp = roiscell{i}{j};
        x1list = union(x1list, temp(:,1));
    end
end
x1=zeros(length(x1list),12);
for i=1:length(x1list)
    i
%     if mod(i,500)==1
%         i
%     end
for j=1:12
%     tempmat = cell2mat(classifier_bbx{j});
    tempmat = classifier_bbx{j};
    index = find(tempmat(:,1)==x1list(i));
    if isempty(index)
        continue
    end
    temp = [tempmat(index(1),3)+tempmat(index(1),5),tempmat(index(1),4)+tempmat(index(1),6)]/2;
    x1(i,(j*2-1):2*j)=temp;
end
end
save('Evalution/x1.mat','x1');
%%
load('output1/roiscell.mat')
x1list = [];
for i=1:length(roiscell)
    for j=1:length(roiscell{i})
        if isempty(roiscell{i}{j})
            continue
        end
        temp = roiscell{i}{j};
        x1list = union(x1list, temp(:,1));
    end
end
x2=zeros(length(x1list),12);

for j=1:12

    i
    temp4classifier = []
    for i=1:length(x1list)
        for jj=1:length(roiscell)
            tempmat = roiscell{jj}{j};
            index = find(tempmat(:,1)==x1list(i));
            if isempty(index)
                continue
            end
    temp = [tempmat(index(1),3)+tempmat(index(1),5),tempmat(index(1),4)+tempmat(index(1),6)]/2;
    x2(i,(j*2-1):2*j)=temp;
    temp4classifier = [temp4classifier; tempmat(index(1),:)];
    
        end
    end
    classifier_bbx4x2{j}=temp4classifier;
    
end
save('Evalution/x2.mat','x2');
save('Evalution/classifier_bbx4x2.mat','classifier_bbx4x2')
%%

load('Evalution/x2.mat')
opts = statset('Display','final');
% c = randperm(length(x));
% x = x(c(1:3000),:);
%调用Kmeans函数
%X N*P的数据矩阵
%Idx N*1的向量,存储的是每个点的聚类标号
%Ctrs K*P的矩阵,存储的是K个聚类质心位置
%SumD 1*K的和向量,存储的是类间所有点与该类质心点距离之和
%D N*K的矩阵，存储的是每个点与所有质心的距离;
 
[Idx,Ctrs,SumD,D] = kmeans(x2,43,'Replicates',2,'Options',opts);
 
% %画出聚类为1的点。X(Idx==1,1),为第一类的样本的第一个坐标；X(Idx==1,2)为第二类的样本的第二个坐标
% plot(X(Idx==1,1),X(Idx==1,2),'r.','MarkerSize',14)
% hold on
% plot(X(Idx==2,1),X(Idx==2,2),'b.','MarkerSize',14)
% hold on
% plot(X(Idx==3,1),X(Idx==3,2),'g.','MarkerSize',14)
%  
% %绘出聚类中心点,kx表示是圆形
% plot(Ctrs(:,1),Ctrs(:,2),'kx','MarkerSize',14,'LineWidth',4)
% plot(Ctrs(:,1),Ctrs(:,2),'kx','MarkerSize',14,'LineWidth',4)
% plot(Ctrs(:,1),Ctrs(:,2),'kx','MarkerSize',14,'LineWidth',4)
%  
% legend('Cluster 1','Cluster 2','Cluster 3','Centroids','Location','NW')
%  
% Ctrs
%%
copy_roiscell=cell(43,1);
for i =1:12
%      temp = cell2mat(classifier_bbx{i});
    temp = classifier_bbx4x2{i};
%     temp1 = temp;
%     temp = temp1;
%     temp(:,4) = temp1(:,5);
%     temp(:,5) = temp1(:,4);
    i
    for j=1:43
        index = find(Idx==j);
        sumtemp = [];
        for ii = 1:length(index)
            indexj = find(temp(:,1)==x1list(index(ii)));
            sumtemp = [sumtemp; temp(indexj,:)] ;
        end
        copy_roiscell{j}{i} = sumtemp;
    end
end
save('Evalution/copy_roiscell3.mat','copy_roiscell')

%%
