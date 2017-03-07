function [  ] = throughput_index(index)
load data.mat;
% This function is to calculate throughput and bottleneck of users(index)

    max_module_th = 0; % initialize the maximum module throughput
    for n=1:V+2 % go through all modules
        if partition(index, n) == 0 % module n is executed on mobile
           th = users(index).CI(n)*users(index).theta; % calculate module computation cost
           if th > max_module_th % update maximum
               max_module_th = th;
               max_n = n;
           end
        end
    end
    users(index).max_module = max_n; % record the bottleneck module
    
    sum_data = 0; % record the sum of data
    max_edge_data = 0; % record the maximum edge throughput
    for u=1:V+2 % go through all edges
        for v=1:V+2
            if Dag(u,v) && xor(partition(index,u), partition(index,v)) % module u and v are executed on different sides
                sum_data = sum_data + CIJ(u,v);
                if CIJ(u, v) > max_edge_data % record the edge that needs the maximum data
                    max_u = u; max_v = v;
                end
            end
        end
    end
    if partition(index,1) ~= 0 % communication cost of the start node, record the edge if it is the maximum
        sum_data = sum_data + Coo;
        if max_edge_data < Coo
            max_edge_data = Coo;
            max_u = 0; max_v = 1;
        end
    end 
        
    if partition(index,V+2) ~= 0 % communication cost of the end node, record the edge if it is the maximum
        sum_data = sum_data + Cvv;
        if max_edge_data < Cvv
            max_edge_data = Cvv;
            max_u = V+2; max_v = V+3;
        end
    end

    if sum_data / bandwidth_user(index) > max_module_th  % finally, update the maximum module/edge and calculate the throughput
        users(index).max_edge = [max_u,max_v]; % record the bottleneck edge
        users(index).max_module = NaN; % as the bottleneck is on the edge, we eliminate the bottleneck module record
        users(index).throughput = sum_data / bandwidth_user(index);
    else
        users(index).max_module = max_n;
        users(index).max_edge = NaN;
        users(index).throughput = max_module_th;
    end
    
    users(index).throughput
    clear sum_data;
    clear max_module_th; clear max_edge_data;
    clear max_u; clear max_v; clear max_n;
    clear throughput; clear index;
    save data.mat;
end

