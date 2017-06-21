function [ avg ] = avg_th(groups)
% To calculate the average throughput of all groups
avg = 0;
gSize = size(groups, 2);
for g=1:gSize
    avg = avg + groups(g).throughput;
end
avg = avg / gSize;
end

