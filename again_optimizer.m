clc,clear
close all
load('output1/classifier_finaldealnumre2.mat');
load('output1/annotation_bbx.mat')

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
ovmax = 0.2; %0125-0.3 0126-0.2
ovratio = 0.5; %0125-0.3 0126-0.3
ovmaxsingle=0.4;
classflagratiomax=0.4;

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
    indexi
    [index_first,]=find(first_classifier_list == first_classifier_list(indexi));
    record_flagsum=[];
    i=indexi;
    result=[i];
    result_change=[1]; % ��һ��ƥ�����Զ��ԭͼ
    if length(index_first)>=2
    for indexj = indexi+1:index_first(end)
        j=indexj;
        classflag=0;
        flagsum=[0,0,0,0];
%                 for class = 1:length(annotation_bbx)
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
                  bb
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
                  flag = IOU(bb,bbgt,ovmax,ovmaxsingle);
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
                  double_flag = doubleIOU(bb,bbgt,ovmax,ovmaxsingle);
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
    end
    again_classifier_final{indexi}= [result;result_change];
    record_flagsum_dealsub{indexi} = record_flagsum;
end

%    record_flagsum_deal{ii}=record_flagsum_dealsub;
% end
save('output1/classifier_final2.mat','again_classifier_final');
% imshowperclass2(classifier_finaldealnumre)