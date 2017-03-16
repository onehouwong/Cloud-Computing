priority = prior();
[users, partition] = optimize(users, partition, priority(1));
[users, th] = throughput_avg(users);
load data.mat;