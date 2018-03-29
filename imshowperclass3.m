function imshowperclass3(classifier_finaldealnumre)
% 有变换显示

VOCopts = VOCinit();
filename = strcat('../VOCdevkit/',VOCopts.dataset,'/labels/');
dirname = dir(filename);
dirname = dirname(3:end);
gtids = {dirname.name};
% function imshowperclass(classifier_result)
%读取子文件路径及图片名称
% load('output1/classifier_bboxnum.mat')
% load('output1/classifier_absnum.mat')
% load('output1/classifier_absnumdeal.mat')
% load('output1/classifier_finaldealnum.mat')
load('output1/classifier_finaldealnumre2.mat')

maindir = strcat('../VOCdevkit/VOC2007/JPEGImages/');
subdir  = dir( maindir );
JPEGfile=cell(1,2);
% 预读所有jpg
for i = 1 : length( subdir )
    if( isequal( subdir( i ).name, '.' )||isequal( subdir( i ).name, '..')||~subdir( i ).isdir)               % 如果不是目录则跳过
        continue;
    end
    subdirpath = fullfile( maindir, subdir( i ).name, '*.jpg' );
    dat = dir( subdirpath );               % 子文件夹下找后缀为dat的文件

    for j = 1 : length( dat )
        datpath = fullfile( maindir, subdir( i ).name, dat( j ).name);
%         fid = fopen( datpath );
        JPEGfile{1}=[JPEGfile{1};{dat( j ).name(1:end-4)}];
        JPEGfile{2}=[JPEGfile{2};{datpath}];
    end
    i
end
save('output1/JPEGfile.mat','JPEGfile');
% 拼接展示同一类样本
sumplot=[];
sumsumplot=[];
num=1;
for i=1:length(classifier_finaldealnumre)
    for j=1:length(classifier_finaldealnumre{i})
        sumsumplot=[];
        sumplot=[];
        for jj=1:length(classifier_finaldealnumre{i}{j})
            % read picture
            y=find(strcmp(JPEGfile{1},gtids{classifier_finaldealnumre{i}{j}(1,jj)}(1:end-4)));
            filepath = JPEGfile{2}{y};
            pic = imread(filepath);
            
            % deal and resize picture
            pic = imresize(pic,[100,100]);
            if classifier_finaldealnumre{i}{j}(2,jj)==1
                pic = pic;
            elseif classifier_finaldealnumre{i}{j}(2,jj)==2
                pic = pic(:,end:-1:1);
            elseif classifier_finaldealnumre{i}{j}(2,jj)==3
                pic = pic(end:-1:1,:);
            elseif classifier_finaldealnumre{i}{j}(2,jj)==4
                pic = pic(end:-1:1,end:-1:1);
            end
            
            % adding
            if mod(jj,11)==0
                num=num+1
                sumsumplot=[sumsumplot;sumplot];
                sumplot=[];
            else
                sumplot=[sumplot,pic];
            end
            % plotting
            if num==11
                11111111111111
                h=figure,imshow(sumsumplot)
                title(strcat(num2str(i),'numclass-',num2str(j),'subclass'))
                saveas(h,strcat('output1/',num2str(i),'-',num2str(j),'-',num2str(jj),'.jpg'))
                sumsumplot=[];
                num=1;
            elseif jj==length(classifier_finaldealnumre{i}{j})
                22222222222222
                [h,l]=size(sumplot);
                sumplot = [sumplot,zeros(100,100*(10-l/100))];
                sumsumplot=[sumsumplot;sumplot];
                h=figure,imshow(sumsumplot)
                title(strcat(num2str(i),'numclass-',num2str(j),'subclass'))
                saveas(h,strcat('output1/',num2str(i),'-',num2str(j),'-',num2str(jj),'.jpg'))
                sumsumplot=[];
                num=1;
            end
            close all
        end
    end
end
% end