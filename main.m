load data.mat;
flag = 0;
while true
priority = prior(); % initialize the prioirty
for i=1:lambda
    if users(priority(i)).best_tag ~= 1
        [users, partition] = optimize(users, partition, priority(i), th_avg);
        break;
    end
    if i == lambda
        fprintf('All the users have been best optimized.\n');
        flag = 1;
    end
end
    [th_avg, users] = throughput_avg(users);
    if flag == 1
        break;
    end
end

load data.mat;