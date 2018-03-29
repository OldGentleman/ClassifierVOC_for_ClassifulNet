classifier_bbx -- 读取的groundtruth信息 -- {class}[index,1,xmin,ymin,xmax,ymax]
classifier_bboxnum -- 每个index的每个类别groundthuth个数 -- [index,1-12 class]
classifier_absnum -- 每个index的对应局部链 -- {index, - - - - -}
classifier_absnumdeal -- classifier_absnum的化简（行数变少） -- {index, - - - -}
classifier_final -- 根据classifier_absnumdeal、IOU计算关联性建立局部链 -- {classifier_absnumdeal}{index, - - - }
classifier_finaldeal -- classifier_final的局部链连接 -- {classifier_absnumdeal}{index, - - - }
classifier_finaldealnum -- classifier_finaldeal的化简（行数变少） -- {classifier_absnumdeal}{index, - - - }
classifier_finaldealnumre -- 根据classifier_finaldealnum，把元素较少的行合到一起 - {classifier_absnumdeal}{index, - - - }
classelse -- 把元素较少的行合到一起/每个classifier_finaldealnumre{：}中的最后一行 -[index, - - -]
numlist -- 每个大类中的小类个数 [num]

