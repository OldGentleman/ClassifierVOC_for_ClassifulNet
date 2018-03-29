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
% 理论上不应该有重复，若有重复说明tmd简化代码写错了 = =
% 事实上，重复了 gtmd  3953 1274
try
    for i = 1:length(xxx)
        sumlength = sumlength + length(xxx{i});
    end
end
sumlength
end

% 排除328个 4899 