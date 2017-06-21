if lambda < 10 % too few users, no need to form groups
    return;
else
user_num = 20;
group_num = floor(lambda / user_num);
for i=1:group_num
    groups(i).users = users((i-1)*user_num+1:i*user_num);
    groups(i).lambda = user_num;
    groups(i).bandwidth = bandwidth_user(1) * ones(groups(i).lambda,1);
    groups(i).servers = zeros(floor(k/group_num), 1);
    groups(i).partition = zeros(groups(i).lambda, V+2);
    groups(i).throughput = 0;
    for j=1:groups(i).lambda
        groups(i).throughput = groups(i).throughput + groups(i).users(j).throughput;
    end
    groups(i).throughput = groups(i).throughput / groups(i).lambda;
end

remains_user = lambda - group_num*user_num;
remains_server = k - group_num*floor(k/group_num);
for i=1:remains_user % for the remaining user, divide them randomly into each group, and each get one server
    g = ceil(rand(1)*group_num);
    while groups(g).lambda ~= user_num
        g = ceil(rand(1)*group_num);
    end
    groups(g).lambda = groups(g).lambda+1;
    groups(g).users(groups(g).lambda) = users(group_num*user_num+i);
    groups(g).bandwidth = bandwidth_user * ones(groups(g).lambda,1);
    groups(g).partition = zeros(groups(g).lambda, V+2);
    groups(g).servers = zeros(size(groups(g).servers, 1)+1,1);
end


for i=1:remains_server-remains_user % distribute the remaining server randomly
    g = ceil(rand(1)*group_num);
    groups(g).servers = zeros(size(groups(g).servers, 1)+1,1);
end

for g=1:group_num
    groups(g) = throughput_avg(groups(g));
end
end