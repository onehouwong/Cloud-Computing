function [  ] = optimize(index)
% This function is to optimize the partition of the specified user(index)
load data.mat;

max_module = users(index).max_module;
max_edge = users(index).max_edge;


if isnan(max_edge) % optimize module
    [~, server] = min(servers);
    partition(index, users(index).max_module) = server;
    servers(server) = servers(server) + 1;
    users(index).theta = users(index).theta - 1;
    save data.mat;
else % optimize edge
end
   
% update bottleneck and throughput


end

