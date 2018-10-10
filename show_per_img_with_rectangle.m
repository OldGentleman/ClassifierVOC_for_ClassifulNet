clc,clear
close all
CLASS = {'Insulator','Rotary_double_ear','Binaural_sleeve','Brace_sleeve',
    'Steady_arm_base','Bracing_wire_hook','Double_sleeve_connector','Messenger_wire_base',
    'Windproof_wire_ring','Insulator_base','Isoelectric_line','Brace_sleeve_screw'};

%��ȡannotation_bbx.txt
txtname = 'annotation_bbx.txt';
[class,subclass,xmin,ymin,xmax,ymax]=textread(txtname,'%n%n%n%n%n%n');

% ��ʾÿ��ͼƬ�Ƿ���ϵ�ǰ���
filename = strcat('sample_img');
dirname = dir(filename);
dirname = dirname(3:end);
gtids = {dirname.name};
for subfile_ind = 1:length(gtids)
    subfile = gtids{subfile_ind};
    subfilename = strcat(filename,'/',subfile)
    subdirname = dir(subfilename);
    subdirname = subdirname(3:end);
    subgtids = {subdirname.name};
    for img_ind=1:length(subgtids)
        img_path = strcat(subfilename,'/',subgtids{img_ind})
        img = imread(img_path);
        img = imresize(img,[4400,6600]);
        figure(1),imshow(img);hold on,
        ind = find(class==str2num(subfile))
        for jind = 1:length(ind)
            rectangle('Position',[xmin(ind(jind)),ymin(ind(jind)),xmax(ind(jind))-xmin(ind(jind)),ymax(ind(jind))-ymin(ind(jind))],'edgecolor','r');
            text(xmin(ind(jind)),ymin(ind(jind)),CLASS{ind(jind)},'color','w')
        end
        hold off
        A = input('Input a number:')
        if A==1
            %��ȷ/����/��һ��
        elseif A==2
            %��˳��ת����
        elseif A==3
            %����/��һ��
        end
    end
end