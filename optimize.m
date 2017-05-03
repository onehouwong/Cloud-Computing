function [ users, partition ] = optimize(users, partition, index, th_avg)
% This function is to optimize the partition of the specified user(index)
load data.mat;

max_module = users(index).max_module;
max_edge = users(index).max_edge;
temp_th = th_avg; % tempororily store the average throughput and user.
temp_user = users(index);

if isnan(max_edge) % optimize module

    fprintf('Bottleneck: %d \n', max_module);
    % check if the throughput is increased. otherwise, if the increase cost of the
    % edge overwhelms the decrease cost of the module, we simply stop the optimization.
    
    
    % the module executed on server becomes the bottleneck ....
    
    % try to offload the module to see if the throughput is increased.
    [~, server] = min(servers);
    partition(index, max_module) = server;
    servers(server) = servers(server) + 1;
    users(index).theta = users(index).theta - 1;
    save data.mat;
    [th_avg, users] = throughput_avg(users);
     if th_avg < temp_th % the throughput is increased   
         fprintf('Offload module %d of user %d to server %d \n', max_module, index, server);
     else % recover from the optimization, set the best tag to 1 to prevent modification
         fprintf('Try to offload module %d of user %d to server %d \n', max_module, index, server);
         fprintf('Optimized throughput=%f, original throughput=%f, User %d has been optimized.\n', th_avg, temp_th, index);
         partition(index, max_module) = 0;
         servers(server) = servers(server) - 1;
         users(index) = temp_user;
         users(index).best_tag = 1;
         th_avg = temp_th;
     end
else % optimize edge
    % firstly, we should consider that throughput can increase when both of the module
    % deploying at local devices
    % let x be to module to be offloaded, and w be the other module

    fprintf('Bottleneck:(%d, %d) \n', max_edge(1), max_edge(2));
    if (max_edge(1) == 0 || max_edge(1) == 33)    
    % we should consider the start and end node, they can not be offloaded
        fprintf('Module %d can not be offloaded, user %d is optimized.\n', max_edge(1), index);
        users(index).best_tag = 1;
        save data.mat;
        return;
    elseif (max_edge(2) == 0 || max_edge(2) == 33)
        fprintf('Module %d can not be offloaded, user %d is optimized.\n', max_edge(2), index);
        users(index).best_tag = 1;
        save data.mat;
        return;
    elseif partition(index, max_edge(1)) ~= 0 % x and w are not the start or end node
        w = max_edge(1); x = max_edge(2);
    else
        x = max_edge(1); w = max_edge(2);
    end
    
    
    
    % try to offload the module
%     if x == 0 || x == 33
%         % we should consider the start and end node, they can not be offloaded
%         fprintf('')
%         pass;
%         partition(index, x) = 0;
%         servers(server) = servers(server) - 1;
%         users(index).theta = users(index).theta + 1;
%         users(index).best_tag = 1;
%     else
        [~, server] = min(servers);
        partition(index, x) = server;
        servers(server) = servers(server) + 1;
        users(index).theta = users(index).theta - 1;
    save data.mat;
    [th_avg, users] = throughput_avg(users);
    
     if th_avg < temp_th % the throughput is increased   
%          if x == 0 || x == 33
%             fprintf('deploy module %d of user %d to mobile\n', x, index);
%          else
            fprintf('Offload module %d of user %d to server %d \n', x, index, server);
%          end
     else % recover from the optimization, set the best tag to 1 to prevent modification
         fprintf('Try to offload module %d of user %d to server %d \n', x, index, server);
         fprintf('Optimized throughput=%f, original throughput=%f, User %d has been optimized.\n', th_avg, temp_th, index);
         partition(index, x) = 0;
         servers(server) = servers(server) - 1;
         users(index) = temp_user;         
         users(index).best_tag = 1;
         th_avg = temp_th;
     end
    
end
    fprintf('avg_throughput: %f\n\n', th_avg);
    save data.mat;
    %th = users(index).CI(n)*users(index).theta
    % find the related module that is influenced by the optimization, as
    % the edge around the target_module maybe will consume some bandwidth
    % and thus becomes the bottleneck
    
    % upload the module onto the server that has the least number of modules

   
    % update bottleneck and throughput


end



