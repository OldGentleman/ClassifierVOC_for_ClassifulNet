function [classifier_finaldeal]=changedealmethod(indexy,classifier_finaldeal,jresult)
%indexy - Ŀ��״̬
%classifier_finaldeal - ���仯�б�
%jresult - ƥ��Ŀ�����б��е�λ��

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