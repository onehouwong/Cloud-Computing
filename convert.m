function [ users, partition, servers, ch ] = convert( ch, users, partition, servers, NUM )
% this function is to convert the chrom into user partitions.
load data.mat;
index = 1;
c=1; b=1; % two indice of partition
for i=1:size(users, 2)
    users(i).theta = V+2;
end
servers = zeros(size(servers,1), 1);
while(index < size(ch,2)+1)
    pa = bin2dec(num2str(ch(index:index+NUM-1)));
    pa = mod(pa,size(servers, 1)+1);  % make sure that pa ranges from 0~k
    partition(c,b) = pa;
    if pa ~= 0
        users(c).theta = users(c).theta - 1;
        servers(pa) = servers(pa) + 1;
    end
    
    if b == V+2 % switch to the next user
        c = c+1; b=1;
    else % move to the next module
        b = b+1;
    end
    index = index+NUM;

end

flag = 0;
for s=1:size(servers, 1) % determine how many servers are overloaded
    if servers(s) > alpha_server
        flag = flag + 1;
    end
end
% if the modules exceed the server load, we randomly drop some module 
while flag > 0
    ran_x = ceil(rand(1)*size(users, 2));
    ran_y = ceil(rand(1)*(V+2));
    s = partition(ran_x, ran_y);
    if s~=0 && servers(s) > alpha_server % drop the module
        partition(ran_x, ran_y) = 0;
        servers(s) = servers(s) - 1;
        users(ran_x).theta = users(ran_x).theta + 1;
        % modify the chrom
        index = (ran_x-1)*(V+2)*NUM + (ran_y-1)*NUM + 1;
        for i=index:index+NUM-1
            ch(i) = 0;
        end
        if servers(s) == alpha_server
            flag = flag - 1;
        end
    end
end

end


