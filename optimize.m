function [ users, partition ] = optimize(users, partition, index)
% This function is to optimize the partition of the specified user(index)
load data.mat;

max_module = users(index).max_module;
max_edge = users(index).max_edge;


if isnan(max_edge) % optimize module
    [~, server] = min(servers);
    partition(index, users(index).max_module) = server;
    fprintf('Bottleneck: %d \n', max_module);
    % check if the throughput is increased. otherwise, if the increase cost of the
    % edge overwhelms the decrease cost of the module, we simply stop the optimization.
    
    
    % the module executed on server becomes the bottleneck ....
    
    servers(server) = servers(server) + 1;
    users(index).theta = users(index).theta - 1;
    fprintf('Offload module %d of user %d to server %d \n', max_module, index, server);
else % optimize edge
    % firstly, we should consider that throughput can increase when both of the module
    % deploying at local devices
    % let w pabe the module offloaded, and x the module on mobile
    if partition(index, max_edge(1)) ~= 0
        w = max_edge(1); x = max_edge(2);
    else
        x = max_edge(1); w = max_edge(2);
    end
    
    fprintf('Bottleneck:(%d, %d) \n', x, w);
    
    if x == 0 || x == 33
        % we should consider the start and end node, they can not be offloaded
        % so, we should deploy the other offloaded module to mobile device
        x = w;
        partition(index, x) = 0;
        servers(server) = servers(server) - 1;
        users(index).theta = users(index).theta + 1;
        fprintf('Deploy module %d of user %d to mobile.\n', x, index)
    else
        [~, server] = min(servers);
        partition(index, x) = server;
        servers(server) = servers(server) + 1;
        users(index).theta = users(index).theta - 1;
        fprintf('Offload module %d of user %d to server %d.\n', x, index, server);
    end
    
end
    
    save data.mat;
    %th = users(index).CI(n)*users(index).theta
    % find the related module that is influenced by the optimization, as
    % the edge around the target_module maybe will consume some bandwidth
    % and thus becomes the bottleneck
    
    % upload the module onto the server that has the least number of modules

   
    % update bottleneck and throughput


end

function[throughput] = preCalculate(partition)
% before trying to offload one module
% the function is to check if the throughput is increased after modify

end

