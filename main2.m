load data.mat;
while(true)
    bool = BandwidthAllocation();
    if bool == false
        break;
    end
end

load data.mat;
for i=1:lambda
    users(i).best_tag = 0;
end
save data.mat;
load data.mat;