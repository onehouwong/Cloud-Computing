delete(gcp('nocreate'));
mypool = parpool(4);
addAttachedFiles(mypool, 'data.mat');
groups = group_genetic(groups);
pre = Inf; % previous average throughput
cur = avg_th(groups);
THRESHOLD = 0.5;
%while pre - cur > THRESHOLD
    b = true;
    %while b == true
        [groups, b] = server_allocation(groups);
        %groups = group_genetic(groups);
    %end

    gen = 0;
    MAX = 100;
    b = true;
    while b == true && gen < MAX
        [groups, b] = BandwidthAllocation(groups);
        gen = gen + 1;
    end
    
    pre = cur;  
    cur = avg_th(groups);
    fprintf('pre=%f, cur=%f, inc=%f\n', pre, cur, cur-pre);
%end
delete(gcp('nocreate'));
