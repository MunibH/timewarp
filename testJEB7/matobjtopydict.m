function matobjtopydict()
% load matlab obj
pth = 'C:\Code\subspace-id\data';
fn = 'data_structure_JEB7_2021-04-29.mat';
temp = load(fullfile(pth,fn));
obj = temp.obj;
clear temp

% get data we want for affine warp
% we want to construct Z with the keys below
% data = SpikeData(
%     Z["trials"],     (nspikes,) 
%     Z["spiketimes"], (nspikes,) 
%     Z["neuron_ids"], (nspikes,) 
%     tmin=Z["tmin"],  (scalar)
%     tmax=Z["tmax"],  (scalar)
% )
% how to go from struct to pydict
% S = struct('Robert',357,'Mary',229,'Jack',391);
% studentID = py.dict(S)

probe = 1;
clu = obj.clu{probe};
Nclu = min(30,numel(clu));
Z.trials = cell(Nclu,1);
Z.noshiftspiketimes = cell(size(Z.trials));
Z.spiketimes = cell(size(Z.trials));
Z.neuron_ids = cell(size(Z.trials));

cond = find(obj.bp.R&obj.bp.hit&~obj.bp.stim.enable&(obj.bp.autowater.nums==2)'); 

trix = cond;
for i = 1:Nclu
    ix = ismember(clu(i).trial,trix);
    Z.trials{i} = clu(i).trial(ix);
    Z.noshiftspiketimes{i} = clu(i).trialtm(ix);
    
    Z.spiketimes{i} = Z.noshiftspiketimes{i} ;
    Z.neuron_ids{i} = i * ones(size(Z.trials{i}));
end
Zfn = fieldnames(Z);
for i = 1:numel(Zfn)
    curfn = Zfn{i};
    Z.(curfn) = cell2mat(Z.(curfn));
end

trials = Z.trials;
uTrials = unique(trials);

[~, trials] = ismember(trials, uTrials);

shifts = (0.2+0.2.*randn(size(uTrials)));

noshiftspiketimes = Z.noshiftspiketimes;
spiketimes = noshiftspiketimes+shifts(trials);

trials = trials - 1; % python is zero-indexed

shifts = shifts + obj.bp.ev.goCue(trix);

neuron_ids = Z.neuron_ids;
tmin = 0;
tmax = 5;

save('pydict_JEB7_2021-04-29.mat','trials','noshiftspiketimes','spiketimes','neuron_ids','tmin','tmax','shifts')


end % matobjtopydict















