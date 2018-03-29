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
% tic;
% npos=0;
% counta=zeros(1,length(clss));
% classifier_bbx = cell(1,length(clss));
% 
% for i=1:length(gtids)
%     txt = strcat('../VOCdevkit/',VOCopts.dataset,'/labels/',gtids{i});
%     [a,b1,b2,b3,b4] = textread(txt,'%d%s%s%s%s');
%     for j = 1:length(a)
%         [~,y]=find(strcmp(gtids,gtids{i}));
%         classifier_bbx{a(j)+1} = [classifier_bbx{a(j)+1}; [y, a(j)+1, str2num(b1{j}), str2num(b2{j}), str2num(b3{j}), str2num(b4{j})]]; %名称，种类，边界(1-4)
%     end
%     if mod(i,100)==0
%         i
%     end
% end
% save('output1/classifier_bbx2.mat','classifier_bbx');
%%
% 生成 文件 12-class groundtruth 个数
lengthmax = 10;
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

% % 根据groundtruth个数分类 误差不超过0
% absnummax = 0;
% classifier_absnum=cell(1);
% num=1;
% for i=1:length(gtids)
%     result=[];
%     for j=i+1:length(gtids)
%         absnum = sum(abs(classifier_bboxnum(i,2:end)-classifier_bboxnum(j,2:end)));
%         if absnum <= absnummax
%             result=[result,j];
%         end
%     end
%     if ~isempty(result)
%        classifier_absnum{i,1}=[i,result];
%        num=num+1;
%     else
%         classifier_absnum{i,1}=[i];
%     end
%     if mod(i,100)==0
%         i
%     end
% end
% save('output1/classifier_absnum.mat','classifier_absnum');
% 
% % 简化链
% load('output1/classifier_absnum.mat')
% for i=1:length(classifier_absnum)
%     if ~isempty(classifier_absnum{i})
%         j=2;
%         while j<=length(classifier_absnum{i})
%             indexx=classifier_absnum{i}(j);
%                 if ~isempty(classifier_absnum{indexx})
%                     classifier_absnum{i} = [classifier_absnum{i},classifier_absnum{indexx}];
%                     classifier_absnum{indexx}=[];
%                 end
%             j=j+1;
%         end          
%     end
% end
% % 
% % 重排序简化
% classifier_absnumdealtemp=cell(1);
% num=1;
% for i=1:length(classifier_absnum)
%     if ~isempty(classifier_absnum{i})
%        % classifier_dealnum{class}{num,1}=classifier_deal{class}{i};
%         uniquetemp = unique(classifier_absnum{i});
%         classifier_absnumdealtemp{num,1}= uniquetemp;
%         num=num+1;
%     end
% end
% 
% % 对于部分仅为几个的类别进行保留删除
% num=1;
% classifier_elsenum={};
% for i=1:length(classifier_absnumdealtemp)
%     if ~isempty(classifier_absnumdealtemp{i})
%        if length(classifier_absnumdealtemp{i})< lengthmax
%         classifier_elsenum{num,1} = classifier_absnumdealtemp{i};
%         num=num+1;
%         classifier_absnumdealtemp{i}=[];
%        end
%     end
% end
% % 重排序简化
% classifier_absnumdeal=cell(1);
% num=1;
% for i=1:length(classifier_absnumdealtemp)
%     if ~isempty(classifier_absnumdealtemp{i})
%         classifier_absnumdeal{num,1}= classifier_absnumdealtemp{i};
%         num=num+1;
%     end
% end
% save('output1/classifier_absnumdeal.mat','classifier_absnumdeal');
% save('output1/classifier_elsenum.mat','classifier_elsenum');

%%

ovmax = 0.1;
classflagratiomax=0.1;
load('output1/classifier_bbx2.mat')
load('output1/classifier_absnumdeal.mat')
load('output1/classifier_bboxnum.mat')
% load('output1/classifier_final.mat')
classifier_result = cell(1,length(clss));
classifier_final = cell(length(classifier_absnumdeal),1);

% for ii=1:length(classifier_absnumdeal)
  ii=1;
  disp(strcat(num2str(ii),'/',num2str(length(classifier_absnumdeal))))
        num=0;
        for indexi = 1:length(classifier_absnumdeal{ii})
            if mod(indexi,100)==0
                disp(strcat(num2str(indexi),'/',num2str(length(classifier_absnumdeal{ii}))))
            end
            
            i=classifier_absnumdeal{ii}(indexi);
            result=[i];
            for indexj = indexi+1:length(classifier_absnumdeal{ii})
                j=classifier_absnumdeal{ii}(indexj);
                classflag=0;
                for class = 1:length(classifier_bbx)
                    index1=find(classifier_bbx{class}(:,1)==i);
                    index2=find(classifier_bbx{class}(:,1)==j);
                    flagsum=0;
                    for index1x=1:length(index1)
                        for index2x=1:length(index2)
                            bb=[classifier_bbx{class}(index1(index1x),3),classifier_bbx{class}(index1(index1x),4),classifier_bbx{class}(index1(index1x),5),classifier_bbx{class}(index1(index1x),6)];
                            bbgt=[classifier_bbx{class}(index2(index2x),3),classifier_bbx{class}(index2(index2x),4),classifier_bbx{class}(index2(index2x),5),classifier_bbx{class}(index2(index2x),6)];
                            flag = IOU(bb,bbgt,ovmax);
                            flagsum = flagsum + flag;
                        end
                    end
                    if flagsum/(length(index1)*length(index2)) >= 0.5
                        classflag=classflag+1;
                    end 
                end
                [a,~] = find(classifier_bboxnum(i,2:end));
                [b,~] = find(classifier_bboxnum(j,2:end));
                classflagmax = min(sum(a),sum(b));
                if classflag>=classflagratiomax*classflagmax
                    result = [result, j];
                end
            end
            if ~isempty(result)
                classifier_final{ii,1}{indexi,1} = [result];
            else
                classifier_final{ii,1}{indexi,1} = [];
            end
        end
% end
save('output1/classifier_final0.5.mat','classifier_final');
 
%%

%  % 分类精简
% load('output1/classifier_result.mat');
% load('output1/classifier_final0.5.mat');
% classifier_finaldeal = classifier_final;
% 
% 
% for ii=1:length(classifier_finaldeal)
%     disp(strcat(num2str(ii),'/',num2str(length(classifier_absnumdeal))))
%     for index = 1:length(classifier_finaldeal{ii})
%         indexi=1;
%         while indexi<=length(classifier_finaldeal{ii}{index})
%             fseed = classifier_finaldeal{ii}{index}(indexi);
%             for indexii=index+1:length(classifier_finaldeal{ii})
%                 fseedind = find(classifier_finaldeal{ii}{indexii}==fseed);
%                 if ~isempty(fseedind)
%                     classifier_finaldeal{ii}{index} = [classifier_finaldeal{ii}{index},classifier_finaldeal{ii}{indexii}];
%                     classifier_finaldeal{ii}{indexii}=[];
%                 end
%             end
%             indexi=indexi+1;
%         end
%     end
% end
% save('output1/classifier_finaldeal.mat','classifier_finaldeal');
% %%
% % 再精简
% load('output1/classifier_finaldeal.mat');
% classifier_finaldealnum=cell(1,length(classifier_finaldeal));
% 
% for class=1:length(classifier_finaldeal)
%     num=1;
%     for i=1:length(classifier_finaldeal{class})
%         if ~isempty(classifier_finaldeal{class}{i})
% %             classifier_dealnum{class}{num,1}=classifier_deal{class}{i};
%             uniquetemp = unique(classifier_finaldeal{class}{i});
%             classifier_finaldealnum{class}{num,1}= uniquetemp;
%             num=num+1;
%         end
%     end
% end
% save('output1/classifier_finaldealnum.mat','classifier_finaldealnum');
% 
% %%
% % 单个图片分一类归为"其他"类
% lengthmax=8;
% load('output1/classifier_finaldealnum.mat');
% classifier_finaldealnumre=cell(1,length(classifier_finaldealnum));
% classelse = cell(1,length(classifier_finaldealnum));
% numlist=[];
% for class=1:length(classifier_finaldealnum)
%     class
%     num=1;
%     temp=[];
%     for i=1:length(classifier_finaldealnum{class})
%         if length(classifier_finaldealnum{class}{i})<=lengthmax
%             temp = [temp,classifier_finaldealnum{class}{i}];
%         else
%             classifier_finaldealnumre{class}{num,1}= classifier_finaldealnum{class}{i};
%             num=num+1;
%         end
%         if i==length(classifier_finaldealnum{class})
%             classifier_finaldealnumre{class}{num,1}=temp;
%             classelse{class}=temp;
%         end
%     end
%     numlist=[numlist,num];
% end
% save('output1/classifier_finaldealnumre.mat','classifier_finaldealnumre');
% save('output1/classelse.mat','classelse');
% save('output1/numlist.mat','numlist');
% numsum=sum(numlist)

%%
% load('output1/classifier_absnum.mat')
% load('output1/classifier_absnumdeal.mat')
% JPEGfilename = strcat('../VOCdevkit/',VOCopts.dataset,'/JPEGImages/');
% JPEGname = dir(JPEGfilename);


