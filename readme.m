classifier_bbx -- ��ȡ��groundtruth��Ϣ -- {class}[index,1,xmin,ymin,xmax,ymax]
classifier_bboxnum -- ÿ��index��ÿ�����groundthuth���� -- [index,1-12 class]
classifier_absnum -- ÿ��index�Ķ�Ӧ�ֲ��� -- {index, - - - - -}
classifier_absnumdeal -- classifier_absnum�Ļ����������٣� -- {index, - - - -}
classifier_final -- ����classifier_absnumdeal��IOU��������Խ����ֲ��� -- {classifier_absnumdeal}{index, - - - }
classifier_finaldeal -- classifier_final�ľֲ������� -- {classifier_absnumdeal}{index, - - - }
classifier_finaldealnum -- classifier_finaldeal�Ļ����������٣� -- {classifier_absnumdeal}{index, - - - }
classifier_finaldealnumre -- ����classifier_finaldealnum����Ԫ�ؽ��ٵ��кϵ�һ�� - {classifier_absnumdeal}{index, - - - }
classelse -- ��Ԫ�ؽ��ٵ��кϵ�һ��/ÿ��classifier_finaldealnumre{��}�е����һ�� -[index, - - -]
numlist -- ÿ�������е�С����� [num]

