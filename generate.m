% To generate the DAG of n users, the server condition and bandwidth

V = 30; % Actual node number is V+2
lambda = 5; % number of users
k = ceil(lambda/2); % the number of servers
alpha = V; % the maximum module number that a server can hold
bandwidth_total = rand(1)*lambda; % the total bandwidth
bandwidth_user = ones(lambda, 1)*(bandwidth_total/lambda); % the allocation of bandwidth to all users
servers = zeros(k, 1);
Unit = 1; % second
AvgCi = 1*Unit;
server_cost = 0.2*AvgCi*rand(k, 1); % the computation cost on server, which is 1/10 smaller than on mobile

Dout = 2;
Alpha = 2;
depth = Alpha*sqrt(V);
prob = 2*Dout/V;
CDag = zeros(V, V);
Dag = zeros(V+2,V+2);
CCR = 2; 
AvgCij = CCR*Unit;
%%Create the child DAG topology randomly
nEdge = 0;
dtest1 = rand(V, 1);
%Level = zeros(depth, 1);
layer = zeros(V, 1); 
for i = 1:V
    layer(i) = ceil(dtest1(i)*depth);
end

for i = 1:V
    for j = 1:V
       if layer(j) > layer(i)
           if rand(1) < prob
               CDag(i,j) = 1;
               nEdge = nEdge + 1; % number of edges
           end
       end
    end
end

%%%% Adding the start point and end point to the DAG
posmin = find(layer==min(layer)); % minimum position
posmax = find(layer==max(layer)); % maximum position

for i = 1:length(posmin)
    Dag(1, posmin(i)+1) = 1;
end
for i = 1:length(posmax)
    Dag(posmax(i)+1, V+2) = 1;
end
Dag(2:V+1, 2:V+1) = CDag;
nEdge = nEdge + length(posmin) + length(posmax);

% Out put of DAGGen is CI, CIJ, Coo, Cvv 
Coo = 8*AvgCij*bandwidth_total/lambda;  % The amount of data of the start node
Cvv = 8*AvgCij*bandwidth_total/lambda;  % The amount of data of the end node
dtest2 = 2*AvgCij*rand(nEdge, 1);
CIJ = zeros(V+2, V+2); % The amount of data of edges
index = 1;
for i = 1:V+2
    for j = 1:V+2
        if Dag(i,j)>0
            CIJ(i,j) = dtest2(index)*bandwidth_total/lambda;
            index = index +1;
        end       
    end
end

% initialize all the users with the same graph
for num=1:lambda
    users(num).CI = 2*AvgCi*rand(V+2, 1); % only the computation cost of each user is different
    users(num).theta = V+2; % total number of modules that share the mobile computing resource
    % users(num).bandwidth_edge = zeros(V+2,V+2); % bandwidth allocation to all edges
    users(num).max_edge = NaN; % record the bottleneck of edges
    users(num).max_module = NaN; % record the bottleneck of modules
    users(num).throughput = 0; % record the throughput of the user
    %users(num).bandwidth_edge = rand(V+2,V+2); % for test
end

%partition = floor(rand(lambda, users(1).V+2)*(k+1)); % for test
partition = zeros(lambda, V+2); % initialize the partition strategy of users
priority = zeros(lambda, 1); % priority list of users, recorded by user's index
save data.mat;
throughput_avg(); % initialize the bottleneck and throughput record
prior(); % initialize the priority
load data.mat;







