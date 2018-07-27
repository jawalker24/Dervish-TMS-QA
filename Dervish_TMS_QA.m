%DERVISH_TMS_QA Takes in Localite Session Folders and Outputs QA in the 
%   forms of figures stored mat files of relevant variables and a text 
%   diary of those variables
%
%   Requires (in separate QA_fn folder):
%       full_calcdev.m v1.1.1
%       full_dir.m v1.0.0
%       full_entry.m v1.0.1
%       full_instrmt.m v1.0.1
%       full_RMSdev.m v1.0.1
%       full_triggers.m v2.0.0
%       parseXML.m v1.0.0
%       rem_NaN_rotmax.m v1.0.1
%
%   Authors Molly Hermiller, John A. Walker
%   Version 1.2.0, 05.23.18


clear all
fprintf('Dervish TMS QA Version 1.2.0\n\n')
fprintf('Please select the participant folder from the menu\n')
dir_subj = uigetdir('/Volumes/fsmresfiles/MSS/Voss_Lab/DERVISH/YoungApollo/TMS','Select Participant Folder');%select starting dir upstairs
slash_idx = strfind(dir_subj, '/');
subj = dir_subj(slash_idx(end)+1:end);
dir_root = dir_subj(1:slash_idx(end));

 
dir_arch = fullfile(dir_root, 'QA_results/backup');
no_break = false;

info = full_dir(dir_subj, subj);
[status,msg] = mkdir(dir_arch, subj); 
dir_QA = fullfile(dir_arch, subj); 

try 
    d = datetime('now'); 
    tmstmp = sprintf('%4g%02g%02g', d(1), d(2), d(3)); 
catch
    d = fix(clock); 
    tmstmp = sprintf('%4g%02g%02g', d(1), d(2), d(3)); 
end

diary(fullfile(sprintf('%sQA_results/QA_%s_%s.txt', dir_root, subj, tmstmp)));

disp('SESSIONS');
disp(info(:, 1)); 
disp('DATES'); 
disp(info(:, 2));
soi = str2num(input('Which sessions:', 's'));

% parse xmls
[triggers, breaks] = full_triggers(dir_subj, dir_QA, info, soi, tmstmp, no_break);
[entry, target] = full_entry(dir_subj, dir_QA, info, soi, tmstmp);
[instrmt] = full_instrmt(dir_subj, dir_QA, info, soi, tmstmp);
[RMSdev] = full_RMSdev(dir_subj, dir_QA, info, soi, tmstmp);

%% calculate deviations
[calcdev] = full_calcdev(dir_subj, dir_QA, subj, info, soi, triggers, entry, instrmt, RMSdev, tmstmp);

diary off


