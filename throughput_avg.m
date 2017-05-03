function [ throughput, users ] = throughput_avg( users, partition, servers )
% This function is to calculate the average throughput of all users
load data.mat;
len = size(users, 2); % the number of users
sum_throughput = 0; % the sum of throughput

for i=1:len % for each user
    max_module_th = 0; % initialize the maximum module throughput
   
    for n=1:V+2 % go through all modules
        if partition(i, n) == 0 % module n is executed on mobile
           th = users(i).CI(n)*users(i).theta; % calculate module computation cost
           if th > max_module_th % update maximum
               max_module_th = th;
               max_n = n;
           end
        else % the module n is executed on server
           th = server_cost*servers(partition(i, n)); % calculate server computation cost
           if th > max_module_th % update maximum
               max_module_th = th;
               max_n = n;
           end
        end
    end
    users(i).max_module = max_n; % record the bottleneck module
    
    sum_data = 0; % record the sum of data
    max_edge_data = 0; % record the maximum edge throughput
    for u=1:V+2 % go through all edges
        for v=1:V+2
            if Dag(u,v) && xor(partition(i,u), partition(i,v)) % module u and v are executed on different sides
                sum_data = sum_data + CIJ(u,v);
                if CIJ(u, v) > max_edge_data % record the edge that needs the maximum data
                    max_edge_data = CIJ(u,v);
                    max_u = u; max_v = v;
                end
            end
        end
    end
    if partition(i,1) ~= 0 % communication cost of the start node, record the edge if it is the maximum
        sum_data = sum_data + Coo;
        if max_edge_data < Coo
            max_edge_data = Coo;
            max_u = 0; max_v = 1;
        end
    end 
        
    if partition(i,V+2) ~= 0 % communication cost of the end node, record the edge if it is the maximum
        sum_data = sum_data + Cvv;
        if max_edge_data < Cvv
            max_edge_data = Cvv;
            max_u = V+2; max_v = V+3;
        end
    end
    
    users(i).data = sum_data;
    if sum_data / bandwidth_user > max_module_th  % finally, update the maximum module/edge and calculate the throughput
        users(i).max_edge = [max_u,max_v]; % record the bottleneck edge
        users(i).max_module = NaN; % as the bottleneck is on the edge, we eliminate the bottleneck module record
        users(i).throughput = sum_data / bandwidth_user;
    else
        users(i).max_module = max_n;
        users(i).max_edge = NaN;
        users(i).throughput = max_module_th;
    end
    
    sum_throughput = users(i).throughput + sum_throughput;
end
    throughput = sum_throughput / len;
    clear sum_throughput; clear sum_data;
    clear max_module_th; clear max_edge_data;
    clear max_u; clear max_v; clear max_n; clear len;
end

