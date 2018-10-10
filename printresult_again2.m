%执行完again_optimizer2.m后打印输出结果
clc,clear
close all
load('output1/final_classifeir_finaldealnum.mat');
load('output1/again_classifier_finaldealnum2.mat');
classifier_finaldealnumre = {again_classifier_finaldealnum};
VOCopts = VOCinit();
filename = strcat('../VOCdevkit/',VOCopts.dataset,'/labels/');
dirname = dir(filename);
dirname = dirname(3:end);
gtids = {dirname.name};
WIDTH = 6600;
HEIGHT = 4400;

load('output1/JPEGfile.mat');
load('output1/classifier_bbx2.mat');
load('output1/annotation_bbx.mat');

annotation_bbx_new = cell(1,length(classifier_bbx));
annotation_bbx1=annotation_bbx;
for i=1:length(annotation_bbx)
    for j=1:length(annotation_bbx{i}(:,1))
        index = annotation_bbx{i}(j,1);
        annotation_bbx_new{index}=[annotation_bbx_new{index};[i,annotation_bbx{i}(j,:)]];
    end
end

classifier_bbx1 = annotation_bbx_new;
classifier_bbx2 = annotation_bbx_new;
classifier_bbx3 = annotation_bbx_new;
classifier_bbx4 = annotation_bbx_new;
for class = 1:length(annotation_bbx_new) % 生成左右、上下变换后的矩形框
    classifier_bbx2{class}(:,[3:6]) = [WIDTH-annotation_bbx_new{class}(:,5),annotation_bbx_new{class}(:,4),WIDTH-annotation_bbx_new{class}(:,3),annotation_bbx_new{class}(:,6)];
    classifier_bbx3{class}(:,[3:6]) = [annotation_bbx_new{class}(:,3),HEIGHT-annotation_bbx_new{class}(:,6),annotation_bbx_new{class}(:,5),HEIGHT-annotation_bbx_new{class}(:,4)];
    classifier_bbx4{class}(:,[3:6]) = [WIDTH-annotation_bbx_new{class}(:,5),HEIGHT-annotation_bbx_new{class}(:,6),WIDTH-annotation_bbx_new{class}(:,3),HEIGHT-annotation_bbx_new{class}(:,4)];
end

numsum = length(classifier_finaldealnumre{1});
% 
deletname = ['025807103_K1213111_97_3_26.txt'];

%%
% 记录图片名-类别-变换方式到classifier.txt
fp = fopen('classifier_again.txt','w+');
classnum=1;
for i=1:length(final_classifier_finaldealnum)
        for index=1:length(final_classifier_finaldealnum{i}(1,:))
            
            gtidsnum = final_classifier_finaldealnum{i}(1,index); %同一个类别的索引
            dealnum = final_classifier_finaldealnum{i}(2,index);  %同一个类别的对应变换
            fprintf(fp,'%s %d %d\r\n',gtids{gtidsnum}(1:end-4),classnum,dealnum); % name.jpg class dealnum

        end
        classnum=classnum + 1;
end
fclose(fp);

%%
% 根据分类 分别保存12类矩形框 
roiscell_again = cell(numsum,1);
classnum=1;
class4=1;
for i=1:length(classifier_finaldealnumre)
    for j=1:length(classifier_finaldealnumre{i})
        roiscell_again{classnum}=cell(1,length(classifier_bbx1));
        for class=1:length(classifier_bbx1)
        bbxsum=[];
            for index=1:length(classifier_finaldealnumre{i}{j}(1,:))

                gtidsnum = classifier_finaldealnumre{i}{j}(1,index); %同一个类别的索引
                dealnum = classifier_finaldealnumre{i}{j}(2,index);  %同一个类别的对应变换

                % print average rois
                [findex,~]=find(classifier_bbx1{class}(:,1)==gtidsnum);
                if dealnum==1
                    indexbbx=classifier_bbx1{class}(findex,:);
                elseif dealnum==2
                    indexbbx=classifier_bbx2{class}(findex,:);
                elseif dealnum==3
                    indexbbx=classifier_bbx3{class}(findex,:);
                elseif dealnum==4
                    indexbbx=classifier_bbx4{class}(findex,:);
                    class4=class4+1;
                end
                bbxsum=[bbxsum;indexbbx];

            end
        roiscell_again{classnum}{class}=bbxsum;
        end
        
        classnum=classnum + 1;
    end
end
save('output5/roiscell_again_again.mat','roiscell_again')

% for i=1:length(roiscell_again)
%     for class=1:length(roiscell_again{i})
%         if ~isempty(roiscell_again{i}{class})
%             y=find(strcmp(JPEGfile{1},gtids{roiscell_again{i}{class}(1,1)}(1:end-4)));
%             filepath = JPEGfile{2}{y};
%             pic = imread(filepath);
%             h=figure,
%             imshow(pic)
%             hold on
%             for j=1:length(roiscell_again{i}{class})
%                 wh=[roiscell_again{i}{class}(j,5:6)-roiscell_again{i}{class}(j,3:4)];
%                 rectangle('Position',[roiscell_again{i}{class}(j,3:4),wh],'edgecolor','r');
%             end
%             hold off
%             title(strcat(num2str(i),'class-',num2str(class),'subclass'))
%             saveas(h,strcat('output2/',num2str(i),'-',num2str(class),'.jpg'))
%             close all
%         end
% 
%     end
% end

%%
% 根据保存每一类的12类矩形框 每一类中生成各类包含所有矩形框的包围矩形框
lenroiscell_again=zeros(classnum-1,length(classifier_bbx));
for i=1:length(roiscell_again)
    for class=1:length(roiscell_again{i})
        %为下一段准备
        lenroiscell_again(i,class)=length(roiscell_again{i}{class}(:,1));
    end
end
save('output5/lenroiscell_again_again.mat','lenroiscell_again')

lenroiscell_again(lenroiscell_again==0)=inf;
minlen = min(lenroiscell_again,[],2);
annotation_bbx=cell(length(roiscell_again),1);

for i=1:length(roiscell_again)
    annotation_temp=[];
    for class=1:length(roiscell_again{i})
        if isempty(roiscell_again{i}{class})
            continue
        end
        tempmin=[];
        tempmax=[];
        if length(roiscell_again{i}{class}(:,1))==1
            % 所有长度为1
            minx=min(roiscell_again{i}{class}(:,3));
            miny=min(roiscell_again{i}{class}(:,4));
            maxx=max(roiscell_again{i}{class}(:,5));
            maxy=max(roiscell_again{i}{class}(:,6));
            annotation_temp = [annotation_temp; [class,minx,miny,maxx,maxy]];
        elseif length(roiscell_again{i}{class})>1
            %如果groundtruth长度大于1
            result = cell(length(again_classifier_finaldealnum{i}(1,:)),1);
            result_len = zeros(length(again_classifier_finaldealnum{i}(1,:)),1);
            for index=1:length(again_classifier_finaldealnum{i}(1,:))
                result{index} = find(roiscell_again{i}{class}(:,1)==again_classifier_finaldealnum{i}(1,index));
                result_len(index) = length(result{index});
            end
            
            % 处理来自相同标签的class
            index2result_len = find(result_len==2);
            % 如果没有2个同类的标签，则统一处理
            if isempty(index2result_len)
                minx=min(roiscell_again{i}{class}(:,3));
                miny=min(roiscell_again{i}{class}(:,4));
                maxx=max(roiscell_again{i}{class}(:,5));
                maxy=max(roiscell_again{i}{class}(:,6));
                annotation_temp = [annotation_temp; [class,minx,miny,maxx,maxy]];
                continue
            end
            for index2 = 1:length(index2result_len) 
                index22 = index2result_len(index2);
                result_index = result{index22};
                % 如果同一图中的同一类有两个标签，需要区分上下或左右
                if abs(roiscell_again{i}{class}(result_index(1),4)-roiscell_again{i}{class}(result_index(2),4))>=50
                    % 若上下差距较大，比较上下来区分
                    if roiscell_again{i}{class}(result_index(1),4)<roiscell_again{i}{class}(result_index(2),4)
                        tempmin=[tempmin;roiscell_again{i}{class}(result_index(1),:)];
                        tempmax=[tempmax;roiscell_again{i}{class}(result_index(2),:)];
                    else
                        tempmin=[tempmin;roiscell_again{i}{class}(result_index(2),:)];
                        tempmax=[tempmax;roiscell_again{i}{class}(result_index(1),:)];
                    end
                else
                    % 若上下差距较小，则比较左右来区分
                    if roiscell_again{i}{class}(result_index(1),3)<roiscell_again{i}{class}(result_index(2),3)
                        tempmin=[tempmin;roiscell_again{i}{class}(result_index(1),:)];
                        tempmax=[tempmax;roiscell_again{i}{class}(result_index(2),:)];
                    else
                        tempmin=[tempmin;roiscell_again{i}{class}(result_index(2),:)];
                        tempmax=[tempmax;roiscell_again{i}{class}(result_index(1),:)];
                    end
                end
            end
            
            % 处理来自单一标签的class
            index1result_len = find(result_len==1);
            for index1 = 1:length(index1result_len)
                index11 = index1result_len(index1);
                result_index = result{index11};
                % 区分该标签是哪一类
                bb = roiscell_again{i}{class}(result_index,3:6);
                bbgtmin = tempmin(1,3:6);
                bbgtmax = tempmax(1,3:6);
                ovmax = 0.3;
                ovmaxsingle = 0.5;
                flagmin = IOU(bb,bbgtmin,ovmax,ovmaxsingle)
                flagmax = IOU(bb,bbgtmax,ovmax,ovmaxsingle)
                if flagmin || ~flagmax
                    tempmin=[tempmin;roiscell_again{i}{class}(result_index,:)];
                elseif ~flagmin || flagmax    
                    tempmax=[tempmax;roiscell_again{i}{class}(result_index,:)];
                elseif flagmin && flagmax
                    error('flagmin/max wrong')
                elseif ~flagmin && ~flagmax
                    error('flagmin/max ~wrong')
                end
            end
            minx1=min(tempmin(:,3));
            miny1=min(tempmin(:,4));
            maxx1=max(tempmin(:,5));
            maxy1=max(tempmin(:,6));
            minx2=min(tempmax(:,3));
            miny2=min(tempmax(:,4));
            maxx2=max(tempmax(:,5));
            maxy2=max(tempmax(:,6));
            annotation_temp = [annotation_temp; [class,minx1,miny1,maxx1,maxy1]];
            annotation_temp = [annotation_temp; [class,minx2,miny2,maxx2,maxy2]];
        end
    end
    annotation_bbx{i}=annotation_temp;
end
save('output5/annotation_bbx_again.mat','annotation_bbx') % 每一类的12类index， 四个坐标

% print txt
fp = fopen('annotation_bbx_again.txt','w+');
for i=1:length(annotation_bbx)
    for j=1:length(annotation_bbx{i}(:,1))
        % 自定义类别， 12类别， 四个坐标
        fprintf(fp,'%d %d %d %d %d %d\r\n',i,annotation_bbx{i}(j,1),annotation_bbx{i}(j,2),annotation_bbx{i}(j,3),annotation_bbx{i}(j,4),annotation_bbx{i}(j,5));
    end
end
fclose(fp)

%%
% 根据生成的包围矩形框画每一类图并保存：output3/
load('output1/roiscell.mat')
for i=1:length(roiscell_again)
    flag = 1;
    picj = 1;
    while flag
        try
            y=find(strcmp(JPEGfile{1},gtids{roiscell{again_classifier_finaldealnum{i}(1,1)}{1,picj}(1,1)}(1:end-4)));
            filepath = JPEGfile{2}{y};
            pic = imread(filepath);
            pic = imresize(pic, [HEIGHT,WIDTH]);
            flag=0;
        catch
            pic=zeros(HEIGHT,WIDTH);
            flag=1;
            picj=picj+1
        end
    end
    h=figure,
    imshow(pic)
    hold on
    for class=1:length(roiscell_again{i})
        if ~isempty(roiscell_again{i}{class})
            for j=1:length(roiscell_again{i}{class}(:,1))
                wh=[roiscell_again{i}{class}(j,5:6)-roiscell_again{i}{class}(j,3:4)];
                rectangle('Position',[roiscell_again{i}{class}(j,3:4),wh],'edgecolor','r');
            end
        end
    end
    for j=1:length(annotation_bbx{i}(:,1))
        
        rectangle('Position',[annotation_bbx{i}(j,2:3),annotation_bbx{i}(j,4:5)-annotation_bbx{i}(j,2:3)],'edgecolor','b');
        text(annotation_bbx{i}(j,2),annotation_bbx{i}(j,3)-30,num2str(annotation_bbx{i}(j,1)),'BackgroundColor','yellow')
    end
    hold off
    title(strcat(num2str(i),'class-',num2str(class),'subclass'))
    saveas(h,strcat('output5/',num2str(i),'.jpg'))
    close all
end


%%
%手动修改
% group1 = roiscell_again{29,1}{1,11}([1,5],:);
% minx1=min(group1(:,3))
% miny1=min(group1(:,4))
% maxx1=max(group1(:,5))
% maxy1=max(group1(:,6))
% group2 = roiscell_again{29,1}{1,11}([2,3,4],:);
% minx2=min(group2(:,3))
% miny2=min(group2(:,4))
% maxx2=max(group2(:,5))
% maxy2=max(group2(:,6))

%%
%读取annotation_bbx_again.txt
[temp1, temp2, temp3, temp4, temp5, temp6] = textread('annotatioin_bbx_again.txt','%d %d %d %d %d %d');
final_classifier_finaldealnum_changed=cell(max(temp1),1);
for index = 1:max(temp1)
    indexi = find(temp1==index);
    final_classifier_finaldealnum_changed{index} = [temp2(indexi),temp3(indexi),temp4(indexi),temp5(indexi),temp6(indexi)];
end
save('output5/final_classifier_finaldealnum_changed.mat','final_classifier_finaldealnum_changed')
% 根据生成的包围矩形框画每一类图并保存：output3/
load('output1/roiscell.mat')
for i=1:length(roiscell_again)
    flag = 1;
    picj = 1;
    while flag
        try
            y=find(strcmp(JPEGfile{1},gtids{roiscell{again_classifier_finaldealnum{i}(1,1)}{1,picj}(1,1)}(1:end-4)));
            filepath = JPEGfile{2}{y};
            pic = imread(filepath);
            pic = imresize(pic, [HEIGHT,WIDTH]);
            flag=0;
        catch
            pic=zeros(HEIGHT,WIDTH);
            flag=1;
            picj=picj+1
        end
    end
    h=figure,
    imshow(pic)
    hold on
    for class=1:length(roiscell_again{i})
        if ~isempty(roiscell_again{i}{class})
            for j=1:length(roiscell_again{i}{class}(:,1))
                wh=[roiscell_again{i}{class}(j,5:6)-roiscell_again{i}{class}(j,3:4)];
                rectangle('Position',[roiscell_again{i}{class}(j,3:4),wh],'edgecolor','r');
            end
        end
    end
    for j=1:length(final_classifier_finaldealnum_changed{i}(:,1))
        
        rectangle('Position',[final_classifier_finaldealnum_changed{i}(j,2:3),final_classifier_finaldealnum_changed{i}(j,4:5)-final_classifier_finaldealnum_changed{i}(j,2:3)],'edgecolor','b');
        text(final_classifier_finaldealnum_changed{i}(j,2),final_classifier_finaldealnum_changed{i}(j,3)-30,num2str(final_classifier_finaldealnum_changed{i}(j,1)),'BackgroundColor','yellow')
    end
    hold off
    title(strcat(num2str(i),'class-',num2str(class),'subclass'))
    saveas(h,strcat('output5/changed_by_txt_',num2str(i),'.jpg'))
    close all
end