% ������������ͼ
clc,clear
close all
VOCopts = VOCinit();
filename = strcat('../VOCdevkit/',VOCopts.dataset,'/labels/');
dirname = dir(filename);
dirname = dirname(3:end);
gtids = {dirname.name};
WIDTH = 6600;
HEIGHT = 4400;
load('output1/classifier_finaldealnumre2.mat');
load('output1/classifier_bbx2.mat');
load('output1/JPEGfile.mat');
fp = fopen('classifier.txt','w+');
classifier_bbx1 = classifier_bbx;
classifier_bbx2 = classifier_bbx;
classifier_bbx3 = classifier_bbx;
classifier_bbx4 = classifier_bbx;
for class = 1:length(classifier_bbx) % �������ҡ����±任��ľ��ο�
    classifier_bbx2{class}(:,[3:6]) = [WIDTH-classifier_bbx{class}(:,5),classifier_bbx{class}(:,4),WIDTH-classifier_bbx{class}(:,3),classifier_bbx{class}(:,6)];
    classifier_bbx3{class}(:,[3:6]) = [classifier_bbx{class}(:,3),HEIGHT-classifier_bbx{class}(:,6),classifier_bbx{class}(:,5),HEIGHT-classifier_bbx{class}(:,4)];
    classifier_bbx4{class}(:,[3:6]) = [WIDTH-classifier_bbx{class}(:,5),HEIGHT-classifier_bbx{class}(:,6),WIDTH-classifier_bbx{class}(:,3),HEIGHT-classifier_bbx{class}(:,4)];
end

load('output1/numlist2.mat');
numsum = length(numlist);
% 
deletname = ['025807103_K1213111_97_3_26.txt'];
%%
% ��ȡtxt������classifier_finaldealnumre
dirname = dir('output4/');
dirname = dirname(3:end);
gtidstxt = {dirname.name};
classifier_finaldealnumre3=cell(length(classifier_finaldealnumre),1);
for ind=1:length(gtidstxt)
    index = find(gtidstxt{ind}=='-');
    i=str2num(gtidstxt{ind}(1:index-1));
    j=str2num(gtidstxt{ind}(index+1:end-4));
    [temp1, temp2] = textread(strcat('output4/',gtidstxt{ind}),'%d%d');
    temp1 = double(temp1);
    temp2 = double(temp2);
    classifier_finaldealnumre3{i,1}{j,1}=[temp1';temp2'];
end
%%
% ��¼ͼƬ��-���-�任��ʽ��classifier.txt
classnum=1;
for i=1:length(classifier_finaldealnumre)
    for j=1:length(classifier_finaldealnumre{i})
        for index=1:length(classifier_finaldealnumre{i}{j}(1,:))
            
            gtidsnum = classifier_finaldealnumre{i}{j}(1,index); %ͬһ����������
            dealnum = classifier_finaldealnumre{i}{j}(2,index);  %ͬһ�����Ķ�Ӧ�任
            fprintf(fp,'%s %d %d\r\n',gtids{gtidsnum}(1:end-4),classnum,dealnum); % name.jpg class dealnum

        end
        classnum=classnum + 1;
    end
end
fclose(fp)

%%
% ���ݷ��� �ֱ𱣴�12����ο� 
roiscell = cell(1,1);
classnum=1;
class4=1;
for i=1:length(classifier_finaldealnumre)
    for j=1:length(classifier_finaldealnumre{i})
        roiscell{classnum,1}=cell(1,length(classifier_bbx));
        for class=1:length(classifier_bbx)
        bbxsum=[];
            for index=1:length(classifier_finaldealnumre{i}{j}(1,:))

                gtidsnum = classifier_finaldealnumre{i}{j}(1,index); %ͬһ����������
                dealnum = classifier_finaldealnumre{i}{j}(2,index);  %ͬһ�����Ķ�Ӧ�任

                % print average rois
                [findex,~]=find(classifier_bbx{class}(:,1)==gtidsnum);
                if dealnum==1
                    indexbbx=classifier_bbx{class}(findex,:);
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
        roiscell{classnum,1}{class}=bbxsum;
        end
        
        classnum=classnum + 1;
    end
end
save('output1/roiscell.mat','roiscell')

% for i=1:length(roiscell)
%     for class=1:length(roiscell{i})
%         if ~isempty(roiscell{i}{class})
%             y=find(strcmp(JPEGfile{1},gtids{roiscell{i}{class}(1,1)}(1:end-4)));
%             filepath = JPEGfile{2}{y};
%             pic = imread(filepath);
%             h=figure,
%             imshow(pic)
%             hold on
%             for j=1:length(roiscell{i}{class})
%                 wh=[roiscell{i}{class}(j,5:6)-roiscell{i}{class}(j,3:4)];
%                 rectangle('Position',[roiscell{i}{class}(j,3:4),wh],'edgecolor','r');
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
% ���ݱ���ÿһ���12����ο� ÿһ�������ɸ���������о��ο�İ�Χ���ο�
lenroiscell=zeros(classnum-1,length(classifier_bbx));
for i=1:length(roiscell)
    for class=1:length(roiscell{i})
        %Ϊ��һ��׼��
        lenroiscell(i,class)=length(roiscell{i}{class});
    end
end
save('output1/lenroiscell.mat','lenroiscell')

lenroiscell(lenroiscell==0)=inf;
minlen = min(lenroiscell,[],2);
annotation_bbx=cell(length(roiscell),1);

for i=1:length(roiscell)
    annotation_temp=[];
    for class=1:length(roiscell{i})
        if isempty(roiscell{i}{class})
            continue
        end
        if length(roiscell{i}{class})==minlen(i)
            minx=min(roiscell{i}{class}(:,3));
            miny=min(roiscell{i}{class}(:,4));
            maxx=max(roiscell{i}{class}(:,5));
            maxy=max(roiscell{i}{class}(:,6));
            annotation_temp = [annotation_temp; [class,minx,miny,maxx,maxy]];
        elseif length(roiscell{i}{class})>minlen(i)
            tempmin=[];
            tempmax=[];
            for j=1:2:length(roiscell{i}{class})
                % ���ͬһͼ�е�ͬһ����������ǩ����Ҫ�������»�����
                if abs(roiscell{i}{class}(j,4)-roiscell{i}{class}(j+1,4))>=50
                    % �����²��ϴ󣬱Ƚ�����������
                    if roiscell{i}{class}(j,4)<roiscell{i}{class}(j+1,4)
                        tempmin=[tempmin;roiscell{i}{class}(j,:)];
                        tempmax=[tempmax;roiscell{i}{class}(j+1,:)];
                    else
                        tempmin=[tempmin;roiscell{i}{class}(j+1,:)];
                        tempmax=[tempmax;roiscell{i}{class}(j,:)];
                    end
                else
                    % �����²���С����Ƚ�����������
                    if roiscell{i}{class}(j,3)<roiscell{i}{class}(j+1,3)
                        tempmin=[tempmin;roiscell{i}{class}(j,:)];
                        tempmax=[tempmax;roiscell{i}{class}(j+1,:)];
                    else
                        tempmin=[tempmin;roiscell{i}{class}(j+1,:)];
                        tempmax=[tempmax;roiscell{i}{class}(j,:)];
                    end
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
save('output1/annotation_bbx','annotation_bbx') % ÿһ���12��index�� �ĸ�����

% print txt
fp = fopen('annotation_bbx.txt','w+');
for i=1:length(annotation_bbx)
    for j=1:length(annotation_bbx{i}(:,1))
        % �Զ������ 12��� �ĸ�����
        fprintf(fp,'%d %d %d %d %d %d\r\n',i,annotation_bbx{i}(j,1),annotation_bbx{i}(j,2),annotation_bbx{i}(j,3),annotation_bbx{i}(j,4),annotation_bbx{i}(j,5));
    end
end
fclose(fp)

%%
% �������ɵİ�Χ���ο�ÿһ��ͼ�����棺output2/
for i=1:length(roiscell)
    flag = 1;
    picj = 1;
    while flag
        try
            y=find(strcmp(JPEGfile{1},gtids{roiscell{i}{picj}(1,1)}(1:end-4)));
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
    for class=1:length(roiscell{i})
        if ~isempty(roiscell{i}{class})

            for j=1:length(roiscell{i}{class})
                wh=[roiscell{i}{class}(j,5:6)-roiscell{i}{class}(j,3:4)];
                rectangle('Position',[roiscell{i}{class}(j,3:4),wh],'edgecolor','y','LineWidth',1);
                
            end
        end
    end
    for j=1:length(annotation_bbx{i}(:,1))
        rectangle('Position',[annotation_bbx{i}(j,2:3),annotation_bbx{i}(j,4:5)-annotation_bbx{i}(j,2:3)],'edgecolor','g','LineWidth',2);
        rectangle('Position',[annotation_bbx{i}(j,2:3),(annotation_bbx{i}(j,4)-annotation_bbx{i}(j,2))*(1.1+0.3*rand(1)),(annotation_bbx{i}(j,5)-annotation_bbx{i}(j,3))*(1+0.2*rand(1))],'edgecolor','r','LineWidth',2);
        text(annotation_bbx{i}(j,2),annotation_bbx{i}(j,3)-30,num2str(annotation_bbx{i}(j,1)),'BackgroundColor','red')
    end
    hold off
    title(strcat(num2str(i),'class-',num2str(class),'subclass'))
    saveas(h,strcat('output2/',num2str(i),'-',num2str(class),'.jpg'))
    close all
end

%%
