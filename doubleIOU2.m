function flag = doubleIOU(bb,bbgt,ovmax,ovmaxsingle)
 flag=[0,0];
 % 如果同一图中的同一类有两个标签，需要区分上下或左右
    if abs(bb(2,2)-bb(1,2))>=100
        % 若上下差距较大，比较上下来区分
        if bb(1,2)<bb(2,2) % 若第一行在上，第二行在下
            [~,maxind]=max(bbgt(:,2)); % 下
            [~,minind]=min(bbgt(:,2)); % 上
            flag(1) = IOU2(bb(1,:),bbgt(minind,:),ovmax,ovmaxsingle);% 上
            flag(2) = IOU2(bb(2,:),bbgt(maxind,:),ovmax,ovmaxsingle);% 下
        else
            [~,maxind]=max(bbgt(:,2));% 下
            [~,minind]=min(bbgt(:,2));% 上
            flag(1) = IOU2(bb(2,:),bbgt(minind,:),ovmax,ovmaxsingle);% 上
            flag(2) = IOU2(bb(1,:),bbgt(maxind,:),ovmax,ovmaxsingle);% 下
        end
    else
        % 若上下差距较小，则比较左右来区分
        if bb(1,1)<bb(2,1)
            [~,maxind]=max(bbgt(:,2)); % 右
            [~,minind]=min(bbgt(:,2)); % 左
            flag(1) = IOU2(bb(1,:),bbgt(minind,:),ovmax,ovmaxsingle);% 左
            flag(2) = IOU2(bb(2,:),bbgt(maxind,:),ovmax,ovmaxsingle);% 右
        else
            [~,maxind]=max(bbgt(:,2)); % 右
            [~,minind]=min(bbgt(:,2)); % 左
            flag(1) = IOU2(bb(2,:),bbgt(minind,:),ovmax,ovmaxsingle);% 右
            flag(2) = IOU2(bb(1,:),bbgt(maxind,:),ovmax,ovmaxsingle);% 左
        end
    end
end