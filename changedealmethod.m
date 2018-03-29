function [classifier_finaldeal]=changedealmethod(indexy,classifier_finaldeal,jresult)
%indexy - 目标状态
%classifier_finaldeal - 欲变化列表
%jresult - 匹配目标在列表中的位置

indexx=classifier_finaldeal(2,jresult);
t1234 = [1,2,3,4];
t1234(find(t1234==indexy))=[];
t1234(find(t1234==indexx))=[];
if classifier_finaldeal(2,jresult) == indexy
else
    [~,index1]=find(classifier_finaldeal(2,:)==indexy);
    [~,index2]=find(classifier_finaldeal(2,:)==indexx);
    classifier_finaldeal(2,index1(:))=indexx;
    classifier_finaldeal(2,index2(:))=indexy;
    
    [~,index1]=find(classifier_finaldeal(2,:)==t1234(1));
    [~,index2]=find(classifier_finaldeal(2,:)==t1234(2));
    classifier_finaldeal(2,index1(:))=t1234(2);
    classifier_finaldeal(2,index2(:))=t1234(1);
    
end
end