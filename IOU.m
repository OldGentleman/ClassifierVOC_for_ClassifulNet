function [flag] = IOU(bb,bbgt,ovmax,ovmaxsingle)
flag=0;
    bi=[max(bb(1),bbgt(1)) ; max(bb(2),bbgt(2)) ; min(bb(3),bbgt(3)) ; min(bb(4),bbgt(4))];
    iw=bi(3)-bi(1)+1;
    ih=bi(4)-bi(2)+1;
    if iw>0 && ih>0 
        bbov = (bb(3)-bb(1)+1)*(bb(4)-bb(2)+1);
        bbgtov = (bbgt(3)-bbgt(1)+1)*(bbgt(4)-bbgt(2)+1);
        minov = iw*ih;
        ua=bbov + bbgtov - minov;
        ov=minov/ua; % I O U
        % 若交集>并集 或 >其中任意一个面积的 ovmax
        if ov >= ovmax
            flag=1;
        end
%         if minov >= ovmaxsingle*bbov
%             flag=1;
%         end
%         if minov >= ovmaxsingle*bbgtov
%             flag=1;
%         end
    end
end