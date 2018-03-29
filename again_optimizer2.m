clc,clear
close all
load('output1/classifier_finaldealnumre2.mat');
load('output1/annotation_bbx.mat')
load('output1/roiscell.mat')
first_classifier_list=zeros(length(annotation_bbx),1);
num=1;% ����ԭʼ��������
for i=1:length(classifier_finaldealnumre)
    for j=1:length(classifier_finaldealnumre{i})
        first_classifier_list(num) = i;
        num=num+1;
    end
end

%%
%����IOU���й���
WIDTH = 6600;
HEIGHT = 4400;
ovmax1 = 0.4; %����ͬһ��� ����/��������
ovmax2 = 0.35; %���Բ�ͬ��� ����/��������
ovratio = 0.5; %0125-0.3 0126-0.3
ovmaxsingle1 = 0.6; %����ͬһ��� ����/�������
ovmaxsingle2 = 0.55; %���Բ�ͬ��� ����/�������
classflagratiomax1=0.4; %����ͬһ���
classflagratiomax2=0.8; %���Բ�ͬ���
load('output1/annotation_bbx.mat')
load('output1/classifier_absnumdeal.mat')
load('output1/classifier_bboxnum.mat')
again_classifier_final = cell(length(annotation_bbx),1);
annotation_bbx1 = annotation_bbx;
annotation_bbx2 = annotation_bbx;
annotation_bbx3 = annotation_bbx;
annotation_bbx4 = annotation_bbx;
for class = 1:length(annotation_bbx) % �������ҡ����±任��ľ��ο�
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
    result_change=[1]; % ��һ��ƥ�����Զ��ԭͼ
    for indexj = indexi+1:length(annotation_bbx)
%     for indexj = 67:67
        j=indexj;
        classflag=0;
        flagsum=[0,0,0,0];
        % �ж������Ƿ��ǩ��ȫһ�£���һ�½��ͺϲ���׼
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
            index1=find(annotation_bbx{indexi}(:,1)==class); %ͬ�������
            index2=find(annotation_bbx{indexj}(:,1)==class); %ͬ�������
            % ���� ���ҡ����·�ת 
            % ����һ�ж� index2 �Ĵ����� �� 1-ԭͼ 2-���� 3-����
            for dealmethod = 1:length(flagsum)
                flag_perclass = 0;
                % ��ÿ��ֻ��һ��
                flag = 0;
               if length(index1)==1&&length(index2)==1
                  bb=annotation_bbx{indexi}(index1,2:5);
                  switch dealmethod
                        case 1 %ԭͼ
                            bbgt=annotation_bbx{indexj}(index2,[2:5]);
                        case 2 %���ҷ�ת����
                            bbgt=annotation_bbx2{indexj}(index2,[2:5]);
                        case 3 %���·�ת����
                            bbgt=annotation_bbx3{indexj}(index2,[2:5]);
                        case 4 %�Խ��߷�ת����
                            bbgt=annotation_bbx4{indexj}(index2,[2:5]);
                  end
                  flag = IOU2(bb,bbgt,ovmax,ovmaxsingle);
                elseif length(index1)==2&&length(index2)==2
                  bb=annotation_bbx{indexi}(index1(:),[2:5]);
                  switch dealmethod
                        case 1 %ԭͼ
                            bbgt=annotation_bbx{indexj}(index2(:),[2:5]);
                        case 2 %���ҷ�ת����
                            bbgt=annotation_bbx2{indexj}(index2(:),[2:5]);
                        case 3 %���·�ת����
                            bbgt=annotation_bbx3{indexj}(index2(:),[2:5]);
                        case 4 %�Խ��߷�ת����
                            bbgt=annotation_bbx4{indexj}(index2(:),[2:5]);
                  end
                  double_flag = doubleIOU2(bb,bbgt,ovmax,ovmaxsingle);
                  flag=floor(sum(double_flag)/2);
                elseif length(index1)>2
                    error(strcat('WORRING: ͬһ��ͼƬͬһ���ǩֻ�ܳ������֣���~',num2str(index1),'|',num2str(index2)))
                end              
                if flag % ͬһ���ڵ�IOU�����������ֵ���жϸ������ص�
                    flagsum(dealmethod) = flagsum(dealmethod) + 1;
                end

            end
        end
        record_flagsum = [record_flagsum; [i,j,flagsum]];
        [classflag,index]=max(flagsum); % ƥ�����������һ����Ϊ��ȷ�ص����������ʹ���ʽ[1,2,3]
        a=length(annotation_bbx{indexi});
        b=length(annotation_bbx{indexj});
        classflagmax = min(a,b);
        
        if classflag>=classflagratiomax*classflagmax % �������ص�������ռ��������������ֵ���ж�������ͼƬ��ͬһ��
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
% ���ྫ��
load('output1/again_classifier_final2.mat');
again_classifier_finaldeal = again_classifier_final;

% ���� û���κ����� 
% ��classifier_final����ÿ������ĵ�һ�л���ͬʱ���ݹ�ϵ�ı��Ӧ�ڶ���״̬

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
            for ii=i+1:again_classifier_finaldeal{i}(1,end) %���ܴ��ڵ�����
                if ~isempty(again_classifier_finaldeal{ii})
                    [~,jresult] = find(again_classifier_finaldeal{ii}(1,:)==indexx,1);
                if ~isempty(jresult) %��������������������
                    if length(again_classifier_finaldeal{ii}(1,:))>1   %���������к���һ��Ԫ�����ϲ�����
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
% �پ���
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

%������again_classifier_finaldealnum������Ӧ������
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
%����������ʼ�غ�����
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