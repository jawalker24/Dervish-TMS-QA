%% Localite TMS QA

clear all

dir_root=pwd; addpath('QA_fn/'); addpath('QA_results'); dir_arch=fullfile(dir_root,'QA_results/backup');
subj=input('Which subject:  ','s'); dir_subj=fullfile(dir_root,subj); [info]=full_dir(dir_subj,subj);
[status,msg]=mkdir(dir_arch,subj); dir_QA=fullfile(dir_arch,subj); 

try d=datetime('now'); tmstmp=str2num(yyyymmdd(d)); catch d=fix(clock); tmstmp=sprintf('%.4g%.4g%.2g',d(1,1),d(1,2),d(1,3)); end

diary(fullfile(sprintf('QA_results/QA_%s_%s.txt',subj,tmstmp)));

disp('SESSIONS'); disp(info(:,1)); disp('DATES'); disp(info(:,2));
soi=input('Which sessions:','s'); soi=str2num(soi);

%% parse xmls
[triggers]=full_triggers(dir_subj,dir_QA,subj,info,soi,tmstmp);
[entry,target]=full_entry(dir_subj,dir_QA,subj,info,soi,tmstmp)
[instrmt]=full_instrmt(dir_subj,dir_QA,subj,info,soi,tmstmp)
[RMSdev]=full_RMSdev(dir_subj,dir_QA,subj,info,soi,tmstmp);

%% calculate deviations
[calcdev]=full_calcdev(dir_subj,dir_QA,subj,info,soi,triggers,entry,instrmt,RMSdev,tmstmp);

diary off