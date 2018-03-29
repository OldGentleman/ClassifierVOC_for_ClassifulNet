clc
clear all
close all
% rand('state',sum(clock));
  set(0,'RecursionLimit',10^3)
p0=0;
tic
for i=1:200
    x=randi([0,99],1,5);
    [f,g]=mengte(x);
    if all(g<=0)
        if p0<f
            x0=x;p0=f;
        end
    end 
end
    toc
