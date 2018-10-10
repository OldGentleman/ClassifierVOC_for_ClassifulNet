% 评价非监督聚类算法
clc,clear
close all
load('output1/roiscell.mat')
load('Evalution/copy_roiscell3.mat')
% roiscell = copy_roiscell;
c=colormap(jet(length(roiscell)));

for mainclass = 1:12
    h=figure,
    
    
    flag = 1;
        ilist = [];
        num = 1;
    for i=1:length(roiscell)
        
%         for class=1:length(roiscell{i})
            if ~isempty(roiscell{i}{mainclass})
%                 for j=1:length(roiscell{i}{mainclass})
                wh=[roiscell{i}{mainclass}(:,5:6)-roiscell{i}{mainclass}(:,3:4)];
                p = plot(roiscell{i}{mainclass}(:,3)+wh(1)/2,roiscell{i}{mainclass}(:,4)+wh(2)/2,'.','color',c(i,:));
                hold on
%                 end
                mylgd{num} = ['Class:' num2str(i)];
                ilist(num) = i;
                num = num + 1;
            end
%         end

        
    end
    axis([0 6600 0 4400]) 
    legend(mylgd,'location','bestoutside')
    title(strcat(num2str(i),'class-',num2str(mainclass),'subclass'))
    saveas(h,strcat('Evalution/kmeans2',num2str(mainclass),'.jpg'))

end
%%
% 每张图的每个类别求一个重心
% for mainclass = 1:12
weightx = zeros(length(roiscell), 12);
weighty = weightx;
CP=weighty;
    for i = 1: length(roiscell)
        for class=1:length(roiscell{i})
            if ~isempty(roiscell{i}{class})
                % qiuzhong xin
                wh=[roiscell{i}{class}(:,5:6)-roiscell{i}{class}(:,3:4)];
                x=roiscell{i}{class}(:,3)+wh(1)/2;
                y=roiscell{i}{class}(:,4)+wh(2)/2;
                weightx(i,class) = sum(x.^2)/sum(x);
                weighty(i,class) = sum(y.^2)/sum(y);
                % 求紧密性 cp
                xi_xw = 0;
                for index = 1:length(y)
                    xi_xw = xi_xw + norm([x(index), y(index)] - [weightx(i,class), weighty(i,class)]);
                end
                CP(i,class) = xi_xw/length(y);
                
            end
        end
    end
% 求间隔性 SP

for class = 1 : 12
    xw_xk = 0;
    num=0;
    for i = 1 : length(weightx(:,class))
        
        for j = i+1:length(weightx(:,class))
            if weightx(i,class)==0 || weightx(j,class)==0
                i,j
                continue
            end
            xw_xk = xw_xk + norm([weightx(i,class), weighty(i,class)] - [weightx(j,class), weighty(j,class)]);
            num = num+1;
        end
    end
    SP(class) = xw_xk* 2/(num);
                
end

%求Davies-Bouldin Index(戴维森堡丁指数)(分类适确性指标)(DB)(DBI)
%求43类之间的距离，互不存在的用0代替
distance = zeros(length(weightx),length(weightx));
for i =1:length(weightx)
    for j =i+1:length(weightx)
        num=0;
        for class = 1:12
            if weightx(i,class)==0 || weightx(j,class)==0
                continue
            end
            distance(i,j) = distance(i,j) + norm([weightx(i,class)+weighty(i,class)] - [weightx(j,class)+weighty(j,class)]);
            num=num+1;
            
        end
        distance(i,j) = distance(i,j)/num;
        
    end
end
distance = distance + distance';
%求43类内的距离
zeroslist = sum(CP'==0);
CP2 = sum(CP,2);
CP2 = CP2./(12-zeroslist)';
%%求Davies-Bouldin Index(戴维森堡丁指数)(分类适确性指标)(DB)(DBI)
DBIhouxuan = zeros(length(weightx),length(weightx));    
for i =1:length(weightx)
    for j =1:length(weightx)
        if j==i || isnan(distance(i,j))
            continue
        end
        DBIhouxuan(i,j) = (CP2(i)+CP2(j))/distance(i,j);
    end
end
for i=1:length(DBIhouxuan)
    DIB = sum(max(DBIhouxuan))/length(DBIhouxuan);
end
% close all