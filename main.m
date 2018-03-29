clc,clear
close all
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

filename = strcat('../VOCdevkit/',VOCopts.dataset,'/labels/');
dirname = dir(filename);
dirname = dirname(3:end);
gtids = {dirname.name};
%load ground truth objects
tic;
npos=0;
counta=zeros(1,length(clss));
classifier_bbx = cell(1,length(clss));

for i=1:length(gtids)
    txt = strcat('../VOCdevkit/',VOCopts.dataset,'/labels/',gtids{i});
    [a,b1,b2,b3,b4] = textread(txt,'%d%s%s%s%s');
    for j = 1:length(a)
        [~,y]=find(strcmp(gtids,gtids{i}));
        classifier_bbx{a(j)+1} = [classifier_bbx{a(j)+1}; {y, a(j)+1, str2num(b1{j}), str2num(b2{j}), str2num(b3{j}), str2num(b4{j})}]; %名称，种类，边界(1-4)
    end
    if mod(i,100)==0
        i
    end
end
% save('output/classifier_bbx2.mat','classifier_bbx');

%%
% 初始分类
ovmax = 0.5;
load ('output/classifier_bbx.mat')
classifier_result = cell(1,length(clss));
for class = 1:length(classifier_bbx)
    num=1;
    class
    for i = 1:length(classifier_bbx{class})
        result=[];
        bb=[classifier_bbx{class}{i,3},classifier_bbx{class}{i,4},classifier_bbx{class}{i,5},classifier_bbx{class}{i,6}];
        for j = i+1:length(classifier_bbx{class})
            cls1 = classifier_bbx{class}{i,1};
            cls2 = classifier_bbx{class}{j,1};
            if  cls1~=cls2
                bbgt=[classifier_bbx{class}{j,3},classifier_bbx{class}{j,4},classifier_bbx{class}{j,5},classifier_bbx{class}{j,6}];
                bi=[max(bb(1),bbgt(1)) ; max(bb(2),bbgt(2)) ; min(bb(3),bbgt(3)) ; min(bb(4),bbgt(4))];
                iw=bi(3)-bi(1)+1;
                ih=bi(4)-bi(2)+1;
                if iw>0 && ih>0 
                    ua=(bb(3)-bb(1)+1)*(bb(4)-bb(2)+1)+(bbgt(3)-bbgt(1)+1)*(bbgt(4)-bbgt(2)+1)-iw*ih;
                    ov=iw*ih/ua; % I O U
                    if ov >= ovmax
                        [~,y]=find(strcmp(gtids,cls2));
                        result=[result,cls2];
                    end
                end
            end
        end
        if ~isempty(result)
            classifier_result{class}{i,1} = [cls1,result];
            num=num+1;
        else
            classifier_result{class}{i,1} = [];
        end
    end
end
save('output/classifier_result.mat','classifier_result');
 
 %%
 % 分类精简
load('output/classifier_result.mat');
indexline=cell(1,length(clss));
for class=1:length(classifier_bbx)
    for i=1:length(classifier_bbx{class})
        indexline{class}(i,1) = classifier_bbx{class}{i,1};
    end
end
% 
% classifier_deal = classifier_result;
% 
% for class=1:length(classifier_deal)
%     for i=1:length(classifier_deal{class})
%         if ~isempty(classifier_deal{class}{i})
%             for j=2:length(classifier_deal{class}{i})
%                 indexx = find(indexline{class}==classifier_deal{class}{i}(j));
%                 for indexxi=1:length(indexx)
%                     if ~isempty(classifier_deal{class}{indexx(indexxi)})
%                         classifier_deal{class}{i} = [classifier_deal{class}{i},classifier_deal{class}{indexx(indexxi)}];
%                         classifier_deal{class}{indexx(indexxi)}=[];
%                         j
%                         indexx(indexxi)
%                         i
%                     end
%                 end
%             end          
%         end
%     end
% end
% 
% save('output/classifier_deal.mat','classifier_deal');
%%
% 再精简
load('output/classifier_deal.mat');
% classifier_dealnum=cell(1,length(clss));
% 
% for class=1:length(classifier_deal)
%     num=1;
%     for i=1:length(classifier_deal{class})
%         if ~isempty(classifier_deal{class}{i})
% %             classifier_dealnum{class}{num,1}=classifier_deal{class}{i};
%             uniquetemp = unique(classifier_deal{class}{i});
%             classifier_dealnum{class}{num,1}= uniquetemp;
%             num=num+1;
%         end
%     end
% end
% save('output/classifier_dealnum.mat','classifier_dealnum');
%%
% 根据边框个数重新分类
load('output/classifier_dealnum.mat');
classifier_bboxnum=zeros(length(gtids),length(class)+1);
for i = 1:length(gtids)
    classifier_bboxnum(i,1)=i;
    for class=1:length(clss)
        [a,b]=find(indexline{class}(:,1)==i);
        classifier_bboxnum(i,class+1) = sum(b);
        a=0;
    end
end
save('output/classifier_bboxnum.mat','classifier_bboxnum')
% absnummax = 1;
% classifier_absnum=cell(1);
% num=1;
% for i=1:length(gtids)
%     result=[];
%     for j=i+1:length(gtids)
%         absnum = sum(abs(classifier_bboxnum(i,2:end)-classifier_bboxnum(j,2:end)));
%         if absnum <= absnummax
%             result=[result,j];
%             
%         end
%     end
%     if ~isempty(result)
%        classifier_absnum{i,1}=[i,result];
%        num=num+1;
%     else
%         classifier_absnum{i,1}=[];
%     end
%     if mod(i,100)==0
%         i
%     end
% end
% save('output/classifier_absnum.mat','classifier_absnum');
% 
% for i=1:length(classifier_absnum)
%     if ~isempty(classifier_absnum{i})
%         for j=2:length(classifier_absnum{i})
%             indexx=classifier_absnum{i}(j);
%                 if ~isempty(classifier_absnum{indexx})
%                     classifier_absnum{i} = [classifier_absnum{i},classifier_absnum{indexx}];
%                     classifier_absnum{indexx}=[];
%                 end
%         end          
%     end
% end
% 
% classifier_absnumdeal=cell(1);
% num=1;
% for i=1:length(classifier_absnum)
%     if ~isempty(classifier_absnum{i})
%        % classifier_dealnum{class}{num,1}=classifier_deal{class}{i};
%         uniquetemp = unique(classifier_absnum{i});
%         classifier_absnumdeal{num,1}= uniquetemp;
%         num=num+1;
%     end
% end
% save('output/classifier_absnumdeal.mat','classifier_absnumdeal');
%%
load('output/classifier_absnum.mat')
load('output/classifier_absnumdeal.mat')
JPEGfilename = strcat('../VOCdevkit/',VOCopts.dataset,'/JPEGImages/');
JPEGname = dir(JPEGfilename);


