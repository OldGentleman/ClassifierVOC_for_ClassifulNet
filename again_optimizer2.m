clc,clear
close all
load('output1/classifier_finaldealnumre2.mat');
load('output1/annotation_bbx.mat')
load('output1/roiscell.mat')
first_classifier_list=zeros(length(annotation_bbx),1);
num=1;% 生成原始分类索引
for i=1:length(classifier_finaldealnumre)
    for j=1:length(classifier_finaldealnumre{i})
        first_classifier_list(num) = i;
        num=num+1;
    end
end

%%
%根据IOU进行归类
WIDTH = 6600;
HEIGHT = 4400;
ovmax1 = 0.4; %来自同一类别 交集/并集比例
ovmax2 = 0.35; %来自不同类别 交集/并集比例
ovratio = 0.5; %0125-0.3 0126-0.3
ovmaxsingle1 = 0.6; %来自同一类别 交集/自身比例
ovmaxsingle2 = 0.55; %来自不同类别 交集/自身比例
classflagratiomax1=0.4; %来自同一类别
classflagratiomax2=0.8; %来自不同类别
load('output1/annotation_bbx.mat')
load('output1/classifier_absnumdeal.mat')
load('output1/classifier_bboxnum.mat')
again_classifier_final = cell(length(annotation_bbx),1);
annotation_bbx1 = annotation_bbx;
annotation_bbx2 = annotation_bbx;
annotation_bbx3 = annotation_bbx;
annotation_bbx4 = annotation_bbx;
for class = 1:length(annotation_bbx) % 生成左右、上下变换后的矩形框
    annotation_bbx2{class}(:,[2:5]) = [WIDTH-annotation_bbx{class}(:,4),annotation_bbx{class}(:,3),WIDTH-annotation_bbx{class}(:,2),annotation_bbx{class}(:,5)];
    annotation_bbx3{class}(:,[2:5]) = [annotation_bbx{class}(:,2),HEIGHT-annotation_bbx{class}(:,5),annotation_bbx{class}(:,4),HEIGHT-annotation_bbx{class}(:,3)];
    annotation_bbx4{class}(:,[2:5]) = [WIDTH-annotation_bbx{class}(:,4),HEIGHT-annotation_bbx{class}(:,5),WIDTH-annotation_bbx{class}(:,2),HEIGHT-annotation_bbx{class}(:,3)];
end
record_flagsum_dealsub = cell(length(annotation_bbx),1);

for indexi = 1:length(annotation_bbx)
% for indexi = 30:30
    indexi
    [index_first,]=find(first_classifier_list == first_classifier_list(indexi));
    record_flagsum=[];
    i=indexi;
    result=[i];
    result_change=[1]; % 第一个匹配的永远是原图
    for indexj = indexi+1:length(annotation_bbx)
%     for indexj = 67:67
        j=indexj;
        classflag=0;
        flagsum=[0,0,0,0];
        % 判断两者是否标签完全一致，若一致降低合并标准
        if find(index_first==indexj)
            ovmax = ovmax1;
            ovmaxsingle = ovmaxsingle1;
            classflagratiomax = classflagratiomax1;
        else
            ovmax = ovmax2;
            ovmaxsingle = ovmaxsingle2;
            classflagratiomax = classflagratiomax2;
        end
        % IOU
        for class = 1:length(annotation_bbx)
            index1=find(annotation_bbx{indexi}(:,1)==class); %同类别索引
            index2=find(annotation_bbx{indexj}(:,1)==class); %同类别索引
            % 增加 左右、上下翻转 
            % 增加一列对 index2 的处理量 ： 1-原图 2-左右 3-上下
            for dealmethod = 1:length(flagsum)
                flag_perclass = 0;
                % 若每类只有一个
                flag = 0;
               if length(index1)==1&&length(index2)==1
                  bb=annotation_bbx{indexi}(index1,2:5);
                  switch dealmethod
                        case 1 %原图
                            bbgt=annotation_bbx{indexj}(index2,[2:5]);
                        case 2 %左右翻转处理
                            bbgt=annotation_bbx2{indexj}(index2,[2:5]);
                        case 3 %上下翻转处理
                            bbgt=annotation_bbx3{indexj}(index2,[2:5]);
                        case 4 %对角线翻转处理
                            bbgt=annotation_bbx4{indexj}(index2,[2:5]);
                  end
                  flag = IOU2(bb,bbgt,ovmax,ovmaxsingle);
                elseif length(index1)==2&&length(index2)==2
                  bb=annotation_bbx{indexi}(index1(:),[2:5]);
                  switch dealmethod
                        case 1 %原图
                            bbgt=annotation_bbx{indexj}(index2(:),[2:5]);
                        case 2 %左右翻转处理
                            bbgt=annotation_bbx2{indexj}(index2(:),[2:5]);
                        case 3 %上下翻转处理
                            bbgt=annotation_bbx3{indexj}(index2(:),[2:5]);
                        case 4 %对角线翻转处理
                            bbgt=annotation_bbx4{indexj}(index2(:),[2:5]);
                  end
                  double_flag = doubleIOU2(bb,bbgt,ovmax,ovmaxsingle);
                  flag=floor(sum(double_flag)/2);
                elseif length(index1)>2
                    error(strcat('WORRING: 同一张图片同一类标签只能出现两种！！~',num2str(index1),'|',num2str(index2)))
                end              
                if flag % 同一类内的IOU面积均大于阈值则判断该类有重叠
                    flagsum(dealmethod) = flagsum(dealmethod) + 1;
                end

            end
        end
        record_flagsum = [record_flagsum; [i,j,flagsum]];
        [classflag,index]=max(flagsum); % 匹配类别数最多的一个作为正确重叠的类别个数和处理方式[1,2,3]
        a=length(annotation_bbx{indexi});
        b=length(annotation_bbx{indexj});
        classflagmax = min(a,b);
        
        if classflag>=classflagratiomax*classflagmax % 所有有重叠类别个数占总类别个数超过阈值则判断这两个图片是同一类
            result = [result, j];
            result_change = [result_change, index];
        end
    end
    again_classifier_final{indexi}= [result;result_change];
    record_flagsum_dealsub{indexi} = record_flagsum;
end

%    record_flagsum_deal{ii}=record_flagsum_dealsub;
% end
save('output1/again_classifier_final2.mat','again_classifier_final');
% imshowperclass5({again_classifier_final})
%%
% 分类精简
load('output1/again_classifier_final2.mat');
again_classifier_finaldeal = again_classifier_final;

% 简化链 没有任何冗余 
% 将classifier_final根据每个矩阵的第一行化简，同时根据关系改变对应第二行状态

for i=1:length(again_classifier_finaldeal)
    if mod(i,100)==0
    i
    end
    
    if ~isempty(again_classifier_finaldeal{i})
        j=2;
        tempi = again_classifier_finaldeal{i};
        while j<=length(tempi(1,:))
            if mod(j,100)==0
            disp(strcat(num2str(j),'/',num2str(length(tempi(1,:)))))
            end
            
            indexx=tempi(1,j);
            indexy=tempi(2,j);
            for ii=i+1:again_classifier_finaldeal{i}(1,end) %可能存在的行数
                if ~isempty(again_classifier_finaldeal{ii})
                    [~,jresult] = find(again_classifier_finaldeal{ii}(1,:)==indexx,1);
                if ~isempty(jresult) %若该行数在搜索队列中
                    if length(again_classifier_finaldeal{ii}(1,:))>1   %搜索到的行含有一个元素以上才重置
                        [an,bn]= ismember(again_classifier_finaldeal{i}(1,:),again_classifier_finaldeal{ii}(1,:));
                        classifier_changedeal = changedealmethod(indexy,again_classifier_finaldeal{ii},jresult);
                        classifier_changedeal(:,bn(find(bn(:))))=[];
                        tempi = [tempi,classifier_changedeal];
                        again_classifier_finaldeal{i} = [again_classifier_finaldeal{i},classifier_changedeal];

                    end
                    again_classifier_finaldeal{ii}=[];
                end
                end
            end
            j=j+1;
        end
        [tempa,tempb,tempc]=unique(again_classifier_finaldeal{i}(1,:));
        tempb=again_classifier_finaldeal{i}(2,tempb');
        again_classifier_finaldeal{i} = [tempa;tempb];
            
    end
end

save('output1/again_classifier_finaldeal2.mat','again_classifier_finaldeal');
%%
% 再精简
load('output1/again_classifier_finaldeal2.mat');
% again_classifier_finaldealnum=cell(length(again_classifier_finaldeal),1);
num=1;
for class=1:length(again_classifier_finaldeal)
    if ~isempty(again_classifier_finaldeal{class})
        [tempa,tempb,tempc] = unique(again_classifier_finaldeal{class}(1,:));
        tempb=again_classifier_finaldeal{class}(2,tempb');
        again_classifier_finaldealnum{num,1}= [tempa;tempb];
        num=num+1;
    end
end
% disp(again_classifier_finaldealnum)
save('output1/again_classifier_finaldealnum2.mat','again_classifier_finaldealnum');
% imshowperclass5({again_classifier_finaldealnum})
%%
load('output1/annotation_bbx.mat')
load('output1/again_classifier_finaldealnum2.mat');
load('output1/classifier_finaldealnumre2.mat');

%生成与again_classifier_finaldealnum索引对应的内容
new_classifier_finaldealnumre = cell(length(annotation_bbx),1);
ind=1;
for i=1:length(classifier_finaldealnumre)
    for j=1:length(classifier_finaldealnumre{i})
        if ~isempty(classifier_finaldealnumre{i}{j})
            new_classifier_finaldealnumre{ind}=classifier_finaldealnumre{i}{j};
            ind=ind+1;
        end
    end
end
%按照索引开始重合内容
final_classifier_finaldealnum = cell(length(again_classifier_finaldealnum),1);
for i=1:length(again_classifier_finaldealnum)
    result_temp=[];
    for j=1:length(again_classifier_finaldealnum{i}(1,:))
        indexy = again_classifier_finaldealnum{i}(2,j);
        classifier_finaldeal = new_classifier_finaldealnumre{again_classifier_finaldealnum{i}(1,j)};
        jresult = 1;
        [result]=changedealmethod(indexy,classifier_finaldeal,jresult);
        result_temp = [result_temp, result];
    end
    final_classifier_finaldealnum{i} = result_temp;
end
save('output1/final_classifeir_finaldealnum.mat','final_classifier_finaldealnum')
%%
printresult_fun({final_classifier_finaldealnum})