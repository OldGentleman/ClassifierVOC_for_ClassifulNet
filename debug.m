clc,clear
close all
load('output1/classifier_final0.5.mat');
load('output1/classifier_finaldealnumre2.mat');
line = 4;
classifier_finaldeal = classifier_final;
temp=[];
for in=21:21
for i=30:30
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
                            if ii==66
                                temp=tempi;
                                indexx
                                indexy
                                j
%                               error('stop')
                            end
                            [an,bn]= ismember(classifier_finaldeal{in}{i}(1,:),classifier_finaldeal{in}{ii}(1,:));
                            classifier_changedeal = changedealmethod(indexy,classifier_finaldeal{in}{ii},jresult);
                            classifier_changedeal(:,bn(find(bn(:))))=[];
                            if find(classifier_changedeal(1,:)==412)
                                ii
                            end
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

tempjresult=[];

% for in =15:15
%     for ii =1:length(classifier_final{in})
%          [~,jresult] = find(classifier_final{in}{ii}(1,:)==412,1);
%          if ~isempty(jresult)
%              ii
%              jresult
%              classifier_final{in}{ii}(2,jresult)
%              temp = [ii,jresult,classifier_final{in}{ii}(2,jresult)];
%              tempjresult=[tempjresult;temp];
%          end
%     end
% end
%%
%根据IOU进行归类
% clc,clear
% close all
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
WIDTH = 6600;
HEIGHT = 4400;
ovmax = 0.2; %0125-0.3 0126-0.2
ovratio = 0.3; %0125-0.3 0126-0.3
ovmaxsingle=0.2;
classflagratiomax=0.4;
load('output1/classifier_bbx2.mat')
load('output1/classifier_absnumdeal.mat')
load('output1/classifier_bboxnum.mat')
% load('output1/classifier_final.mat')
classifier_result = cell(1,length(clss));
classifier_final = cell(length(classifier_absnumdeal),1);
classifier_bbx1 = classifier_bbx;
classifier_bbx2 = classifier_bbx;
classifier_bbx3 = classifier_bbx;
classifier_bbx4 = classifier_bbx;
for class = 1:length(classifier_bbx) % 生成左右、上下变换后的矩形框
    classifier_bbx2{class}(:,[3:6]) = [WIDTH-classifier_bbx{class}(:,5),classifier_bbx{class}(:,4),WIDTH-classifier_bbx{class}(:,3),classifier_bbx{class}(:,6)];
    classifier_bbx3{class}(:,[3:6]) = [classifier_bbx{class}(:,3),HEIGHT-classifier_bbx{class}(:,6),classifier_bbx{class}(:,5),HEIGHT-classifier_bbx{class}(:,4)];
    classifier_bbx4{class}(:,[3:6]) = [WIDTH-classifier_bbx{class}(:,5),HEIGHT-classifier_bbx{class}(:,6),WIDTH-classifier_bbx{class}(:,3),HEIGHT-classifier_bbx{class}(:,4)];
end

record_flagsum_deal = cell(length(classifier_absnumdeal),1);
% for ii=14:14
%   disp(strcat(num2str(ii),'/',num2str(length(classifier_absnumdeal))))
%         num=0;
%         record_flagsum_dealsub = cell(length(classifier_absnumdeal{ii}),1);
        
%         for indexi = 68:68
%          for indexi = 2:2
%             if mod(indexi,100)== 0
%                 disp(strcat(num2str(indexi),'/',num2str(length(classifier_absnumdeal{ii}))))
%             end
            record_flagsum=[];
%             i=classifier_absnumdeal{ii}(indexi);
            i=151
            result=[i];
            result_change=[1]; % 第一个匹配的永远是原图
%             for indexj = 73:73
%              for indexj = indexi+1:3
%                 j=classifier_absnumdeal{ii}(indexj);
                j=4489
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
                        % 若每类只有一个
                        flag = 0;
                        if length(index1)==1&&length(index2)==1
                          bb=classifier_bbx{class}(index1(1),[3:6]);
                          switch dealmethod
                                case 1 %原图
                                    bbgt=classifier_bbx{class}(index2(1),[3:6]);
                                case 2 %左右翻转处理
                                    bbgt=classifier_bbx2{class}(index2(1),[3:6]);
                                case 3 %上下翻转处理
                                    bbgt=classifier_bbx3{class}(index2(1),[3:6]);
                                case 4 %对角线翻转处理
                                    bbgt=classifier_bbx4{class}(index2(1),[3:6]);
                          end
                          flag = IOU(bb,bbgt,ovmax,classflagratiomax);
                        elseif length(index1)==2&&length(index2)==2
                          bb=classifier_bbx{class}(index1(:),[3:6]);
                          switch dealmethod
                                case 1 %原图
                                    bbgt=classifier_bbx{class}(index2(:),[3:6]);
                                case 2 %左右翻转处理
                                    bbgt=classifier_bbx2{class}(index2(:),[3:6]);
                                case 3 %上下翻转处理
                                    bbgt=classifier_bbx3{class}(index2(:),[3:6]);
                                case 4 %对角线翻转处理
                                    bbgt=classifier_bbx4{class}(index2(:),[3:6]);
                          end
                          double_flag = doubleIOU(bb,bbgt,ovmax,classflagratiomax);
                          flag=floor(sum(double_flag)/2);
                        elseif length(index1)>2
                            error(strcat('WORRING: 同一张图片同一类标签只能出现两种！！~',num2str(index1),'|',num2str(index2)))
                        end              
                        if flag % 同一类内的IOU面积均大于阈值则判断该类有重叠
                            class
                            dealmethod
                            flagsum(dealmethod) = flagsum(dealmethod) + 1;
                        end
                                                
                    end
                end
                record_flagsum = [record_flagsum; [i,j,flagsum]];
                [classflag,index]=max(flagsum); % 匹配类别数最多的一个作为正确重叠的类别个数和处理方式[1,2,3]
                [a,~] = find(classifier_bboxnum(i,2:end));
                [b,~] = find(classifier_bboxnum(j,2:end));
                classflagmax = min(sum(a),sum(b));
                if classflag>=classflagratiomax*classflagmax % 所有有重叠类别个数占总类别个数超过阈值则判断这两个图片是同一类
                    result = [result, j];
                    result_change = [result_change, index];
                end
%             end

%             classifier_final{ii,1}{indexi,1} = [result;result_change];
%             record_flagsum_dealsub{indexi} = record_flagsum;
%         end
%    record_flagsum_deal{ii}=record_flagsum_dealsub;
% end
%%
for i=20:20
    txt = strcat('../VOCdevkit/',VOCopts.dataset,'/labels/',gtids{i});
    [a,b1,b2,b3,b4] = textread(txt,'%d%s%s%s%s');
    for j = 10:10
        [~,y]=find(strcmp(gtids,gtids{i}));
        [wh,~]=find(strcmp(xmlgtids,gtids{i}(1:end-4)));
        ratiow = width/WIDTH{wh};
        ratioh = height/HEIGHT{wh};
        classifier_bbx{a(j)+1} = [classifier_bbx{a(j)+1}; [y, a(j)+1, floor(str2num(b1{j})*ratiow), floor(str2num(b3{j})*ratioh), floor(str2num(b2{j})*ratiow), floor(str2num(b4{j})*ratioh)]]; %名称，种类，边界(1-4)
    end
    if mod(i,100)==0
        i
    end  
end