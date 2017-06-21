function [ groups ] = group_genetic( groups )
% Genetic algorithm in group
%load data.mat;
%mypool = parpool(4);
%addAttachedFiles(mypool, 'data.mat');

parfor i=1:size(groups,2) % for each group
data = load('data.mat');
V = data.V;
NIND = 50;           % Number of individuals per subpopulations
MAXGEN = 300;        % maximal Number of generations
GGAP = 0.8;         % Generation gap, how many new individuals are created
lambda = groups(i).lambda;
NUM = ceil(log2(size(groups(i).servers,1)+1)); % each NUM decide a partition of a module 
NVAR = (V + 2)*lambda*NUM;        % Number of variables of objective function
users = groups(i).users;
partition = groups(i).partition;
servers = groups(i).servers;

SEL_F = 'sus';       % Name of selection function
XOV_F = 'xovsp';     % Name of recombination function for individuals
MUT_F = 'mut';       % Name of mutation function for individuals

minimum = Inf;

%OBJ_F = 'objfun_partition';   % Name of function for objective values

% Create population  
   Chrom = crtbp(NIND, NVAR);

% reset count variables
   gen = 0;
   Best = NaN*ones(MAXGEN,1);

% Iterate population
   while gen < MAXGEN,

   % Calculate objective function for population
      [ObjV, Chrom, users] = objf_throughput(Chrom, users, partition, servers, NUM, groups(i).bandwidth);
      
      [Best(gen+1),in] = min(ObjV);
      if minimum > Best(gen+1)
        minimum = Best(gen+1);
        Best_chrom = Chrom(in, 1:NUM*(V+2)*lambda);
      end
      
      %plot(log10(Best),'ro');
      %plot(Best, 'ro');
      %drawnow;
 
   % Fitness assignement to whole population
      FitnV = ranking(ObjV);
            
   % Select individuals from population
      SelCh = select(SEL_F, Chrom, FitnV, GGAP);
     
   % Recombine selected individuals (crossover)
      SelCh=recombin(XOV_F, SelCh);

   % Mutate offspring
      SelCh=mutate(MUT_F, SelCh);

   % Insert offspring in population replacing parents
      %Chrom = reins(Chrom, SelCh);
      Chrom = reins(Chrom, SelCh, 1, 1, ObjV);
      gen=gen+1;   
   end
   
   [groups(i).users, groups(i).partition, groups(i).servers, Best_chrom] = convert(Best_chrom, users, partition,servers, NUM);
   groups(i) = throughput_avg(groups(i));
end

%delete(gcp('nocreate'));
disp(avg_th(groups));

end

