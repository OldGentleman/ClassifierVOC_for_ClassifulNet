% function imshowperclass(classifier_result)
%��ȡ���ļ�·����ͼƬ����
load('output/classifier_bboxnum.mat')
load('output/classifier_absnum.mat')
load('output/classifier_absnumdeal.mat')
maindir = strcat('../VOCdevkit/VOC2007/JPEGImages/');
subdir  = dir( maindir );
JPEGfile=cell(1,2);
for i = 1 : length( subdir )
    if( isequal( subdir( i ).name, '.' )||isequal( subdir( i ).name, '..')||~subdir( i ).isdir)               % �������Ŀ¼������
        continue;
    end
    subdirpath = fullfile( maindir, subdir( i ).name, '*.jpg' );
    dat = dir( subdirpath );               % ���ļ������Һ�׺Ϊdat���ļ�

    for j = 1 : length( dat )
        datpath = fullfile( maindir, subdir( i ).name, dat( j ).name);
%         fid = fopen( datpath );
        JPEGfile{1}=[JPEGfile{1};{dat( j ).name(1:end-4)}];
        JPEGfile{2}=[JPEGfile{2};{datpath}];
    end
    i
end
save('output/JPEGfile.mat','JPEGfile');
% ƴ��չʾͬһ������
sumplot=[];
sumsumplot=[];
num=1;
for i=1:length(classifier_absnumdeal)
    for j=1:length(classifier_absnumdeal{i})
        y=find(strcmp(JPEGfile{1},gtids{classifier_absnumdeal{i}(j)}(1:end-4)));
        filepath = JPEGfile{2}{y};
        pic = imread(filepath);
        pic = imresize(pic,[200,200]);
        if mod(j,10)==0
            num=num+1
            sumsumplot=[sumsumplot;sumplot];
            sumplot=[];
        else
            sumplot=[sumplot,pic];
        end
        if num==10
            figure,imshow(sumsumplot)
            sumsumplot=[];
            num=1;
        end
    end
end
% end