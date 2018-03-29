function [WIDTH, HEIGHT, xmlgtids]=size_read()
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
WIDTH=cell(length(gtids),1);
HEIGHT=cell(length(gtids),1);
xmlgtids=cell(length(gtids),1);
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
    xmlobject = xmlcontent.annotation.object; % ะ่าช
    if isempty(xmlsizewidth)|isempty(xmlsizeheight)|isempty(xmlobject)
        error('empty:width\height\xmlobject')
    end
    
    WIDTH{i}=xmlsizewidth;
    HEIGHT{i}=xmlsizeheight;
    xmlgtids{i}=gtids{i}(1:end-4);
end 
