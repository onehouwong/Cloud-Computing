function [ groups, bool ] = server_allocation( groups )
% In this function, we need to calculate the benefit/decrease of each
% group, then allocate the servers between groups

group_num = size(groups, 2);
benefits = zeros(group_num, 1);
decreases = zeros(group_num, 1);
THRESHOLD = 0.2;
temp_groups = groups;

b_groups = groups;
% calculate benefits
for i=1:group_num
    b_groups(i).servers = zeros(size(groups(i).servers, 1)+1, 1);
    benefits(i) = groups(i).throughput;
end
b_groups = group_genetic(b_groups);
for i=1:group_num
    benefits(i) = b_groups(i).throughput - benefits(i);
end

% check if the average of benefits is over THRESHOLD, if not, end
% allocation
%if sum(benefits) < THRESHOLD * group_num
%    bool = false;
%    fprintf('Servers has been allocated to the best condition.\n\n');
%    return;
%end
    
% calculate decrease
d_groups = groups;
for i=1:group_num
    if size(d_groups(i).servers, 1) ~= 1 % make sure the number of server is at least 1
        d_groups(i).servers = zeros(size(groups(i).servers, 1)-1, 1);
        decreases(i) = groups(i).throughput;
    else
        decreases(i) = 99;
    end
end
d_groups = group_genetic(d_groups);
for i=1:group_num
    decreases(i) = decreases(i) - d_groups(i).throughput;
end

% restore state
%groups = temp_groups;

% start allocation
allocation = zeros(group_num,1);
% sort benefit and decreaase, because we want to get the most benefit while
% have least cost
[~, b_index] = sort(benefits, 1, 'descend');
[~, d_index] = sort(decreases, 1, 'descend');
i=1; j=group_num;
while i < j % stop when i and j meet
    if b_index(i) ~= d_index(j) % note that 1 and -1 must appear in pairs
        %if benefits(b_index(i)) == 0 % if b_index(i) doesn't bring benefit, just end the process
        %    break;
        if size(groups(d_index(j)).servers, 1) > 0 % we should consider that server can not < 0
            if benefits(b_index(i)) - decreases(d_index(j)) < 0 % if the benefit is smaller than decrease, end the process
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
            temp_i = benefits(b_index(i+1)) - decreases(d_index(j)); % move i and keep j unchanged
            temp_j = benefits(b_index(i)) - decreases(d_index(j-1)); % move j and keep i unchanged
            if temp_i >= temp_j
                i = i + 1;
            else
                j = j - 1;
            end
        else % i and j are not only equal but also adjacent, just break
            break;
        end
    end
end

% for i=1:group_num % handle situation that allocation are also zeros
%     if allocation(i) ~= 0
%         break;
%     elseif i == group_num
%         bool = false;
%         fprintf('Servers has been allocated to the best condition.\n\n');
%         return;
%     end
% end

temp_sum = 0;
% allocate servers, we should also consider b can not < 0
for i=1:group_num
    if allocation(i) == 1
        groups(i) = b_groups(i);
        %groups(i).servers = zeros(size(groups(i).servers,1)+1, 1);
        %groups(i).throughput = groups(i).throughput + benefits(i);
        temp_sum = temp_sum + benefits(i);
    elseif allocation(i) == -1
        groups(i) = d_groups(i);
        %groups(i).servers = zeros(size(groups(i).servers,1)-1, 1);
        %groups(i).throughput = groups(i).throughput - decreases(i);
        temp_sum = temp_sum - decreases(i);
    end
end


if temp_sum/group_num <= THRESHOLD % if the increase is under a threshold, stop allocation
    if temp_sum <= 0 % increase is under 0 restore to the original state
       groups = temp_groups;
    end
    fprintf('Servers has been allocated to the best condition. inc=%f\n\n', temp_sum/group_num);
    bool = false;
    return;
end

display(allocation);
benefits
decreases
fprintf('After allocation, increase=%f\n', temp_sum/group_num);
display(avg_th(groups));
for i=1:group_num
    fprintf('%d ', size(groups(i).servers, 1));
end
fprintf('\n');
bool = true;
end

