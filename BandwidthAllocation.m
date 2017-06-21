function [ groups, bool ] = BandwidthAllocation( groups ) % return if the bandwidth is allocated
% This function is to reallocate the total bandwidth to all users
% In each allocation, the 
load data.mat;
b = bandwidth_total/(lambda*100); % allocation unit of bandwidth
bandwidth_user = zeros(lambda, 1); % store the bandwidth of all users
% benefit and decrease that a unit b can bring to the throughput of a user
benefit = zeros(lambda,1); 
decrease = zeros(lambda,1);
allocation = zeros(lambda, 1); % final decision, decide the bandwidth is increase(1), decrease(-1), or maintain(0)

g = 1; % index of group
u = 1; % index of user within a group
for index=1:lambda % calculate benefit and decrease
    bandwidth_user(index) = groups(g).bandwidth(u);
    if isnan(groups(g).users(u).max_module) % bottleneck is on edge
        max_cost = 0;
        for v=2:V+2 % find out the maximum cost of module that deploy on mobile
            if groups(g).partition(u, v) == 0 && groups(g).users(u).CI(v)*groups(g).users(u).theta > max_cost
                max_cost = groups(g).users(u).CI(v)*groups(g).users(u).theta;
            end
        end
        % as we calculate the benefit, we should also consider that one
        % module would become the bottleneck
        if groups(g).users(u).data/(groups(g).bandwidth(u)+b) > max_cost % the edge is still the bottleneck
            benefit(index) = 1/(groups(g).users(u).data/(groups(g).bandwidth(u)+b)) - groups(g).users(u).throughput ;
        else % one module becomes the bottleneck
            benefit(index) = 1/max_cost - groups(g).users(u).throughput;
        end
        
        decrease(index) = groups(g).users(u).throughput - 1/(groups(g).users(u).data/(groups(g).bandwidth(u)-b));
    else % bottleneck is on module
        benefit(index) = 0; % bandwidth does not benefit throughput is this case
        if 1/(groups(g).users(u).data/(groups(g).bandwidth(u)-b)) < groups(g).users(u).throughput % if one edge becomes the bottleneck
            decrease(index) =  groups(g).users(u).throughput - 1/(groups(g).users(u).data/(groups(g).bandwidth(u)-b));
        else % the module is still the bottleneck
            decrease(index) = 0;
        end
    end
    
    % switch to next user (or group, if necessary)
    if u == groups(g).lambda
        u = 1;
        g = g + 1;
    else
        u = u + 1;
    end
end

% sort benefit and decreaase, because we want to get the most benefit while
% have least cost
[~, b_index] = sort(benefit, 1, 'descend');
[~, d_index] = sort(decrease, 1, 'descend');
i=1; j=lambda;
while i < j % stop when i and j meet
    if b_index(i) ~= d_index(j) % note that 1 and -1 must appear in pairs
        %if benefit(b_index(i)) == 0 % if b_index(i) doesn't bring benefit, just end the process
        %    break;
        if bandwidth_user(d_index(j)) - b >= 0.0001 % we should consider that bandwidth can not < 0
            if benefit(b_index(i)) - decrease(d_index(j)) < 0 % if the benefit is smaller than decrease, end the process
                break;
            else
                if allocation(b_index(i)) == 0 && allocation(d_index(j)) == 0
                    allocation(b_index(i)) = 1;
                    allocation(d_index(j)) = -1;
                    i=i+1; j=j-1;
                else
                    if allocation(b_index(i)) ~= 0
                        i=i+1;
                    end
                    if allocation(d_index(j)) ~= 0
                        j=j-1;
                    end
                end
            end
        else % bandwidth will < 0 , so we just move j forward
            j=j-1;
        end
    else % means b_index(i)=d_index(j), in this case, we move j or i forward until i!=j
        if i+1 ~= j % when i and j are not adjacent
            temp_i = benefit(b_index(i+1)) - decrease(d_index(j)); % move i and keep j unchanged
            temp_j = benefit(b_index(i)) - decrease(d_index(j-1)); % move j and keep i unchanged
            if temp_i >= temp_j
                i = i + 1;
            else
                j = j - 1;
            end
        else % i and j is not only equal but adjacent, just break
            break;
        end
    end
end

% for i=1:lambda % handle situation that allocation are also zeros
%     if allocation(i) ~= 0
%         break;
%     elseif i == lambda
%         bool = false;
%         fprintf('Bandwidth has been allocated to the best condition.\n\n');
%         return;
%     end
% end

temp_sum = 0.001;
temp_group = groups;
% allocate bandwidth, we should also consider b can not < 0
for i=1:lambda
    if allocation(i) == 1
        bandwidth_user(i) = bandwidth_user(i) + b;
        temp_sum = temp_sum + benefit(i);
    elseif allocation(i) == -1
        bandwidth_user(i) = bandwidth_user(i) - b;
        temp_sum = temp_sum - decrease(i);
    end
end

THRESHOLD = 0.001;
if temp_sum/lambda <= THRESHOLD % if the increase is under a threshold, stop and restore it.
    fprintf('Bandwidth has been allocated to the best condition.\n\n');
    groups = temp_group;
    bool = false;
    return;
end

% update all the bandwidth in groups
g=1; u=1;
for index=1:lambda
    groups(g).bandwidth(u) = bandwidth_user(index);
    % switch to next user (or group, if necessary)
    if u == groups(g).lambda
        u = 1;
        g = g + 1;
    else
        u = u + 1;
    end
end

%fprintf('Original throughput=%f\n', th_avg);
for g=1:size(groups, 2)
    groups(g) = throughput_avg(groups(g));
end
%display(allocation);
fprintf('After bandwidth allocation, increase=%f\n', temp_sum/lambda);
display(avg_th(groups));
%fprintf('After allocation, throughput=%f\n\n', th_avg);
bool = true;
end

