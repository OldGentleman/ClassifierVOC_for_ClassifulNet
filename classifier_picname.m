clc,clear
close all
% 用来统计根目录下classifier_again或classifeir.txt中
% 类别 - 图片特征(后4位) - 处理方法 - 个数
%  1  -      2       -   3     -   4
txtname = 'classifier.txt';
xlsname = 'classifeir统计结果.xls';
result={'类别','图片特征(后4位)','处理方法','个数'};
txt = importdata(txtname);

class = txt.data(:,1);
change = txt.data(:,2);
picname = txt.textdata;

for classind = 1:class(end)
    classind
    result_temp={};
    ind = find(class==classind);
    for i=1:length(ind)
        strclassind = picname{ind(i)}(end-3:end);
        chaclassind = change(ind(i));
        if isempty(result_temp)
            result_temp=[result_temp;{classind, strclassind, int2str(chaclassind), 1}];
            continue
        end
        if ismember(strclassind,result_temp(:,2))==0 
            % 与之前不同
            result_temp=[result_temp;{classind, strclassind, int2str(chaclassind), 0}];
        elseif ismember(int2str(chaclassind),result_temp(ismember(result_temp(:,2),strclassind),3))==0
            result_temp=[result_temp;{classind, strclassind, int2str(chaclassind), 0}];
        end
        tempind1 = find(ismember(result_temp(:,2),strclassind));
        tempind2 = find(ismember(result_temp(:,3),int2str(chaclassind)));
        tempind = intersect(tempind1,tempind2);
        result_temp{tempind,4} = result_temp{tempind,4} + 1;
    end
    result = [result;result_temp];
end
xlswrite(xlsname,result)
%%
% 归类所有名字后缀相同的图片到同一目录下
name_list = {};
class_list = {};
for j = 2:length(result)
    if result{j,4}>4
     name_list =[name_list; result{j,2}];
     class_list = [class_list; result{j,1}];
    end
end
filename = strcat('../VOCdevkit/VOC2007','/JPEGImages/');
dirname = dir(filename);
dirname = dirname(3:end);
gtids = {dirname.name};
for i = 1:length(gtids)
    i
    if gtids{i}(1)=='K'
        %只让K开头文件夹进入搜索
        sub_filename = strcat('../VOCdevkit/VOC2007','/JPEGImages/',gtids{i});
        sub_dirname = dir(sub_filename);
        sub_dirname = sub_dirname(3:end);
        sub_gtids = {sub_dirname.name};
        %进入第i个子文件中
        for j=1:length(sub_gtids)
            if ~strcmp(sub_gtids{j}(end-3:end),'.jpg')
                continue
            end
            res_cmp = strcmp(sub_gtids{j}(end-7:end-4),name_list);
            ind_1 = find(res_cmp);
            if ~isempty(ind_1)
                %开始复制
                for jj=1:length(ind_1)
                out_dir = strcat('sample_img1/',num2str(name_list{ind_1(jj)}),'/');
                if ~exist(out_dir)
                    mkdir(out_dir)
                end
                res_cmp_class = strcmp(sub_gtids{j}(1:end-4),picname);
                ind_class = find(res_cmp_class);
                if isempty(ind_class)
                    copyfile(strcat(sub_filename,'/',sub_gtids{j}), strcat(out_dir,sub_gtids{j}));
                else
                    out_dir_class = strcat(out_dir,num2str(class(ind_class)),'/');
                    if ~exist(out_dir_class)
                        mkdir(out_dir_class)
                    end
                    copyfile(strcat(sub_filename,'/',sub_gtids{j}), strcat(out_dir_class,sub_gtids{j}));
                end
                end
            end
        end
    end
end



