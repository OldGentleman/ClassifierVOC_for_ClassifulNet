% % for check
% clc,clear
% close all
% load('output1/classifier_absnumdeal.mat')
% xxx=classifier_finaldealnum
function sumlength=checknum(xxx)

sumlength = 0;
try
    for i = 1:length(xxx)
        for j = 1:length(xxx{i})
        sumlength = sumlength + length(xxx{i}{j});
        end
    end
end
% �����ϲ�Ӧ�����ظ��������ظ�˵��tmd�򻯴���д���� = =
% ��ʵ�ϣ��ظ��� gtmd  3953 1274
try
    for i = 1:length(xxx)
        sumlength = sumlength + length(xxx{i});
    end
end
sumlength
end

% �ų�328�� 4899 