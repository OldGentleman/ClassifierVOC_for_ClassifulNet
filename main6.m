% 2018-1-10
% 添加上下、左右镜像
% 最后一类更改为else
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
WIDTH = 6600;
HEIGHT = 4400;
%%
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
        classifier_bbx{a(j)+1} = [classifier_bbx{a(j)+1}; [y, a(j)+1, str2num(b1{j}), str2num(b3{j}), str2num(b2{j}), str2num(b4{j})]]; %名称，种类，边界(1-4)
    end
    if mod(i,100)==0
        i
    end  
end
save('output1/classifier_bbx2.mat','classifier_bbx');
%%
% 生成 文件 12-class groundtruth 个数
% 
load('output1/classifier_bbx2.mat')
indexline=cell(1,length(clss));
for class=1:length(classifier_bbx)
    for i=1:length(classifier_bbx{class})
        indexline{class}(i,1) = classifier_bbx{class}(i,1);
    end
end
classifier_bboxnum=zeros(length(gtids),length(class)+1);
for i = 1:length(gtids)
    classifier_bboxnum(i,1)=i;
    for class=1:length(clss)
        [a,b]=find(indexline{class}(:,1)==i);
        classifier_bboxnum(i,class+1) = sum(b);
        a=0;
    end
end
save('output1/classifier_bboxnum.mat','classifier_bboxnum')

% 根据groundtruth个数分类 误差不超过1
absnummax = 0;
classifier_absnum=cell(1);
num=1;
for i=1:length(gtids)
    result=[];
    for j=i+1:length(gtids)
        absnum = sum(abs(classifier_bboxnum(i,2:end)-classifier_bboxnum(j,2:end)));
        if absnum <= absnummax
            result=[result,j];
        end
    end
    if ~isempty(result)
       classifier_absnum{i,1}=[i,result];
       num=num+1;
    else
        classifier_absnum{i,1}=[i];
    end
    if mod(i,100)==0
        i
    end
end
save('output1/classifier_absnum2.mat','classifier_absnum');

% 简化链 没有任何冗余
load('output1/classifier_absnum2.mat')
for i=1:length(classifier_absnum)
    if mod(i,100)==0
    i
    end
    if ~isempty(classifier_absnum{i})
        j=2;
        tempi = classifier_absnum{i}; %搜索队列
        while j<=length(tempi)
            if mod(j,100)==0
                disp(strcat(num2str(j),'/',num2str(length(tempi))))
            end
            indexx=tempi(j);
                for ii=i+1:indexx %可能存在的行数
                    if ~isempty(find(classifier_absnum{ii}==indexx,1)) %若该行数在搜索队列中
                        if length(classifier_absnum{ii})>1   %搜索到的行含有一个元素以上才重置
                            [an,bn]= ismember(classifier_absnum{i},classifier_absnum{ii});
                            classifier_absnum{ii}(bn(find(bn(:))))=[];
                            tempi = [tempi,classifier_absnum{ii}];
                            classifier_absnum{i} = [classifier_absnum{i},classifier_absnum{ii}];

                        end
                        classifier_absnum{ii}=[];
                    end
                end
             j=j+1;
        end
        classifier_absnum{i}=unique(classifier_absnum{i});
    end
end
% % 
% 重排序简化
classifier_absnumdealtemp=cell(1);
num=1;
for i=1:length(classifier_absnum)
    if ~isempty(classifier_absnum{i})
       % classifier_dealnum{class}{num,1}=classifier_deal{class}{i};
        uniquetemp = unique(classifier_absnum{i});
        classifier_absnumdealtemp{num,1}= uniquetemp;
        num=num+1;
    end
end
% 
% 对于部分仅为几个的类别进行保留删除
num=1;
lengthmax = 15;
classifier_elsenum={};
for i=1:length(classifier_absnumdealtemp)
    if ~isempty(classifier_absnumdealtemp{i})
       if length(classifier_absnumdealtemp{i})< lengthmax
        classifier_elsenum{num,1} = classifier_absnumdealtemp{i};
        num=num+1;
        classifier_absnumdealtemp{i}=[];
       end
    end
end
% 重排序简化
classifier_absnumdeal=cell(1);
num=1;
for i=1:length(classifier_absnumdealtemp)
    if ~isempty(classifier_absnumdealtemp{i})
        classifier_absnumdeal{num,1}= classifier_absnumdealtemp{i};
        num=num+1;
    end
end
save('output1/classifier_absnumdeal.mat','classifier_absnumdeal');
save('output1/classifier_elsenum.mat','classifier_elsenum');
% checknum(classifier_absnumdeal)
% imshowperclass4(classifier_absnumdeal)
%%
%根据IOU进行归类
ovmax = 0.4; %0125-0.3 0126-0.2
ovratio = 0.5; %0125-0.3 0126-0.3
classflagratiomax=0.5;
load('output1/classifier_bbx2.mat')
load('output1/classifier_absnumdeal.mat')
load('output1/classifier_bboxnum.mat')
% load('output1/classifier_final.mat')
classifier_result = cell(1,length(clss));
classifier_final = cell(length(classifier_absnumdeal),1);
classifier_bbx1 = classifier_bbx;
classifier_bbx2 = classifier_bbx;
classifier_bbx3 = classifier_bbx;
for class = 1:length(classifier_bbx) % 生成左右、上下变换后的矩形框
    classifier_bbx2{class}(:,[3:6]) = [WIDTH-classifier_bbx{class}(:,5),classifier_bbx{class}(:,4),WIDTH-classifier_bbx{class}(:,3),classifier_bbx{class}(:,6)];
    classifier_bbx3{class}(:,[3:6]) = [classifier_bbx{class}(:,3),HEIGHT-classifier_bbx{class}(:,6),classifier_bbx{class}(:,5),HEIGHT-classifier_bbx{class}(:,4)];
    classifier_bbx4{class}(:,[3:6]) = [WIDTH-classifier_bbx{class}(:,5),HEIGHT-classifier_bbx{class}(:,6),WIDTH-classifier_bbx{class}(:,3),HEIGHT-classifier_bbx{class}(:,4)];
end

for ii=1:length(classifier_absnumdeal)
% for ii=13:13
  disp(strcat(num2str(ii),'/',num2str(length(classifier_absnumdeal))))
        num=0;
        for indexi = 1:length(classifier_absnumdeal{ii})
%          for indexi = 2:2
            if mod(indexi,100)==0
                disp(strcat(num2str(indexi),'/',num2str(length(classifier_absnumdeal{ii}))))
            end
            
            i=classifier_absnumdeal{ii}(indexi);
            result=[i];
            result_change=[1]; % 第一个匹配的永远是原图
            for indexj = indexi+1:length(classifier_absnumdeal{ii})
%              for indexj = indexi+1:3
                j=classifier_absnumdeal{ii}(indexj);
                classflag=0;
                flagsum=[0,0,0,0];
                
%                 for class = 1:length(classifier_bbx)
                for class = 1:length(classifier_bbx)
                    index1=find(classifier_bbx{class}(:,1)==i); %同类别索引
                    index2=find(classifier_bbx{class}(:,1)==j); %同类别索引
                    % 增加 左右、上下翻转 
                    % 增加一列对 index2 的处理量 ： 1-原图 2-左右 3-上下
                    for dealmethod = 1:length(flagsum)
                        flag_perclass = 0;
                        for index1x=1:length(index1)
                            flag_perindex = 0;
                            for index2x=1:length(index2)
                                bb=classifier_bbx{class}(index1(index1x),[3:6]);
                                switch dealmethod
                                    case 1 %原图
                                        bbgt=classifier_bbx{class}(index2(index2x),[3:6]);
                                    case 2 %左右翻转处理
                                        bbgt=classifier_bbx2{class}(index2(index2x),[3:6]);
                                    case 3 %上下翻转处理
                                        bbgt=classifier_bbx3{class}(index2(index2x),[3:6]);
                                    case 4 %对角线翻转处理
                                        bbgt=classifier_bbx4{class}(index2(index2x),[3:6]);
                                end
                                flag = IOU(bb,bbgt,ovmax);
                                flag_perindex = flag_perindex + flag;
                            end
                            if flag_perindex
                                flag_perclass = flag_perclass + 1;
                            end
                        end
                        if flag_perclass/length(index1) >= ovratio % 同一类内的IOU面积大于阈值的个数超过ovratio则判断该类有重叠
                            flagsum(dealmethod) = flagsum(dealmethod) + 1;
                        end
                    end
                end
                [classflag,index]=max(flagsum); % 匹配类别数最多的一个作为正确重叠的类别个数和处理方式[1,2,3]
                [a,~] = find(classifier_bboxnum(i,2:end));
                [b,~] = find(classifier_bboxnum(j,2:end));
                classflagmax = min(sum(a),sum(b));
                if classflag>=classflagratiomax*classflagmax % 所有有重叠类别个数占总类别个数超过阈值则判断这两个图片是同一类
                    result = [result, j];
                    result_change = [result_change, index];
                end
            end

            classifier_final{ii,1}{indexi,1} = [result;result_change];
        end
end
save('output1/classifier_final0.5.mat','classifier_final');
% imshowperclass2(classifier_finaldealnumre)
%%
% 分类精简
load('output1/classifier_final0.5.mat');
classifier_finaldeal = classifier_final;

% 简化链 没有任何冗余 
% 将classifier_final根据每个矩阵的第一行化简，同时根据关系改变对应第二行状态
for in=1:length(classifier_finaldeal)
for i=1:length(classifier_finaldeal{in})
    if mod(i,100)==0
    i
    end
    
    if ~isempty(classifier_finaldeal{in}{i})
        j=2;
        tempi = classifier_finaldeal{in}{i};
        while j<=length(tempi(1,:))
            if mod(j,100)==0
            disp(strcat(num2str(j),'/',num2str(length(tempi(1,:)))))
            end
            
            indexx=tempi(1,j);
            indexy=tempi(2,j);
            for ii=i+1:length(classifier_finaldeal{in}) %可能存在的行数
                if ~isempty(classifier_finaldeal{in}{ii})
                    [~,jresult] = find(classifier_finaldeal{in}{ii}(1,:)==indexx,1);
                if ~isempty(jresult) %若该行数在搜索队列中
                    if length(classifier_finaldeal{in}{ii}(1,:))>1   %搜索到的行含有一个元素以上才重置
                        [an,bn]= ismember(classifier_finaldeal{in}{i}(1,:),classifier_finaldeal{in}{ii}(1,:));
                        classifier_changedeal = changedealmethod(indexy,classifier_finaldeal{in}{ii},jresult);
                        classifier_changedeal(:,bn(find(bn(:))))=[];
                        tempi = [tempi,classifier_changedeal];
                        classifier_finaldeal{in}{i} = [classifier_finaldeal{in}{i},classifier_changedeal];

                    end
                    classifier_finaldeal{in}{ii}=[];
                end
                end
            end
            j=j+1;
        end
        [tempa,tempb,tempc]=unique(classifier_finaldeal{in}{i}(1,:));
        tempb=classifier_finaldeal{in}{i}(2,tempb');
        classifier_finaldeal{in}{i} = [tempa;tempb];
            
    end
end
end
save('output1/classifier_finaldeal2.mat','classifier_finaldeal');
%%
% 再精简
load('output1/classifier_finaldeal2.mat');
classifier_finaldealnum=cell(1,length(classifier_finaldeal));

for class=1:length(classifier_finaldeal)
    num=1;
    for i=1:length(classifier_finaldeal{class})
        if ~isempty(classifier_finaldeal{class}{i})
%             classifier_dealnum{class}{num,1}=classifier_deal{class}{i};
            [tempa,tempb,tempc] = unique(classifier_finaldeal{class}{i}(1,:));
            tempb=classifier_finaldeal{class}{i}(2,tempb');
            classifier_finaldealnum{class}{num,1}= [tempa;tempb];
            num=num+1;
        end
    end
end
save('output1/classifier_finaldealnum2.mat','classifier_finaldealnum');
% 
% %%
% 单个图片分一类归为"其他"类
lengthmax=8;
load('output1/classifier_finaldealnum2.mat');
classifier_finaldealnumre=cell(1,length(classifier_finaldealnum));
classelse = cell(1,length(classifier_finaldealnum));
numlist=[];
for class=1:length(classifier_finaldealnum)
    class
    num=1;
    temp=[];
    for i=1:length(classifier_finaldealnum{class})
        if length(classifier_finaldealnum{class}{i})<=lengthmax
            temp = [temp,classifier_finaldealnum{class}{i}];
        else
            classifier_finaldealnumre{class}{num,1}= classifier_finaldealnum{class}{i};
            num=num+1;
        end
        % 此处把“其他”类直接注释掉
       if i==length(classifier_finaldealnum{class})
%             classifier_finaldealnumre{class}{num,1}=temp;
             classelse{class}=temp;
       end
    end
    numlist=[numlist,num]; %总有效类别数
end
save('output1/classifier_finaldealnumre2.mat','classifier_finaldealnumre');
save('output1/classelse2.mat','classelse');
save('output1/numlist2.mat','numlist');
numsum = length(numlist)
sumlength = checknum(classifier_finaldealnumre)
% imshowperclass3(classifier_finaldealnumre)
% 17 类，3类分类后细分类，改变IOU阈值分别细分类
%%
% load('output1/classifier_absnum.mat')
% load('output1/classifier_absnumdeal.mat')
% JPEGfilename = strcat('../VOCdevkit/',VOCopts.dataset,'/JPEGImages/');
% JPEGname = dir(JPEGfilename);


