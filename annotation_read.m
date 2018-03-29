function [classifier_bbx, WIDTH, HEIGHT, gtids]=annotation_read()
clss = {'Insulator';
'Rotary_double_ear';
'Binaural_sleeve';
'Brace_sleeve';
'Steady_arm_base';
'Bracing_wire_hook';
'Double_sleeve_connector';
'Messenger_wire_base';
'Windproof_wire_ring';
'Insulator_base';
'Isoelectric_line';
'Brace_sleeve_screw'};
VOCopts = VOCinit();
filename = strcat('../VOCdevkit/VOC2007/Annotations/');
dirname = dir(filename);
dirname = dirname(3:end);
gtids = {dirname.name};
width=6600;
height=4400;
classifier_bbx = cell(1,length(clss));
WIDTH=cell(1,length(clss));
HEIGHT=cell(1,length(clss));
for i=1:length(gtids)
    if mod(i,100)==0
        disp(strcat(num2str(i),'/',num2str(length(gtids))))
    end 
    xmlpath = strcat(filename,gtids{i});
    xmlcontent = VOCreadxml(xmlpath);
    xmlfolder = xmlcontent.annotation.folder;
    xmlfilename = xmlcontent.annotation.filename;
    xmlpath = xmlcontent.annotation.path;
    xmlsizewidth = str2num(xmlcontent.annotation.size.width);
    xmlsizeheight = str2num(xmlcontent.annotation.size.height);
    xmlobject = xmlcontent.annotation.object; % 需要
    if isempty(xmlsizewidth)|isempty(xmlsizeheight)|isempty(xmlobject)
        error('empty:width\height\xmlobject')
    end
    
    a={};
    flag=0;
    for ii=1:length(xmlobject)
        a = [a; xmlobject(ii).name];
    end
    for jj=1:length(clss)
        b = find(strcmp(a,clss{jj}));
        if length(b)>2
%             error('stop')
%             disp(strcat('delet multi classes tag b:',num2str(length(b))))
            flag = 1;
        end
    end
    if flag
        flag=0;
%         disp('excuse')
        continue
    end
    
    sumy = zeros(1,length(clss));
    for j=1:length(xmlobject) % 一个xml中的每个标签
        ratiow = width/xmlsizewidth  ;
        ratioh = height/xmlsizeheight  ;
        
        xmin = str2num(xmlobject(j).bndbox.xmin)*ratiow;
        ymin = str2num(xmlobject(j).bndbox.ymin)*ratioh;
        xmax = str2num(xmlobject(j).bndbox.xmax)*ratiow;
        ymax = str2num(xmlobject(j).bndbox.ymax)*ratiow;
        
        [y,~]=find(strcmp(clss,xmlobject(j).name));
        sumy(y) = sumy(y) +1;
        if length(sumy(y))>2
            break
        end
        classifier_bbx{y} = [classifier_bbx{y}; [i, y, xmin, ymin, xmax, ymax]]; %名称，种类，边界(1-4)
        WIDTH{y}=[WIDTH{y};[xmlsizewidth]];
        HEIGHT{y}=[HEIGHT{y};[xmlsizeheight]];
        
        if length(classifier_bbx{y}(:,1))~=length(WIDTH{y})
            error('length error')
        end
    end
end 
save('output1/classifier_bbx.mat','classifier_bbx');
save('output1/WIDTH.mat','WIDTH');
save('output1/HEIGHT.mat','HEIGHT');