function [  ] = prior( users )
% rank the priority of the given users according to their throughput
load data.mat;
temp_prior = zeros(lambda,1); % tempororily record 
for i=1:lambda
    temp_prior(i) = users(i).throughput;
end

[~, index] = sort(temp_prior, 'descend'); % sort in throughput descending order 

for i=1:lambda
    priority(i) = index(i); % update priorty list
end

clear temp_prior;
clear index;
save data.mat;

end

