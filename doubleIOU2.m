function flag = doubleIOU(bb,bbgt,ovmax,ovmaxsingle)
 flag=[0,0];
 % ���ͬһͼ�е�ͬһ����������ǩ����Ҫ�������»�����
    if abs(bb(2,2)-bb(1,2))>=100
        % �����²��ϴ󣬱Ƚ�����������
        if bb(1,2)<bb(2,2) % ����һ�����ϣ��ڶ�������
            [~,maxind]=max(bbgt(:,2)); % ��
            [~,minind]=min(bbgt(:,2)); % ��
            flag(1) = IOU2(bb(1,:),bbgt(minind,:),ovmax,ovmaxsingle);% ��
            flag(2) = IOU2(bb(2,:),bbgt(maxind,:),ovmax,ovmaxsingle);% ��
        else
            [~,maxind]=max(bbgt(:,2));% ��
            [~,minind]=min(bbgt(:,2));% ��
            flag(1) = IOU2(bb(2,:),bbgt(minind,:),ovmax,ovmaxsingle);% ��
            flag(2) = IOU2(bb(1,:),bbgt(maxind,:),ovmax,ovmaxsingle);% ��
        end
    else
        % �����²���С����Ƚ�����������
        if bb(1,1)<bb(2,1)
            [~,maxind]=max(bbgt(:,2)); % ��
            [~,minind]=min(bbgt(:,2)); % ��
            flag(1) = IOU2(bb(1,:),bbgt(minind,:),ovmax,ovmaxsingle);% ��
            flag(2) = IOU2(bb(2,:),bbgt(maxind,:),ovmax,ovmaxsingle);% ��
        else
            [~,maxind]=max(bbgt(:,2)); % ��
            [~,minind]=min(bbgt(:,2)); % ��
            flag(1) = IOU2(bb(2,:),bbgt(minind,:),ovmax,ovmaxsingle);% ��
            flag(2) = IOU2(bb(1,:),bbgt(maxind,:),ovmax,ovmaxsingle);% ��
        end
    end
end