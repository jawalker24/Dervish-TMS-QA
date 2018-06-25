function [triggers] = full_triggers(dir_subj,dir_QA,subj,info,soi,tmstmp)
sessions=info(:,1); dates=info(:,2); timestamps=info(:,3);

disp('============================================================================'); 
disp('> > > >  SELECT SESSION TRIGGER FILE (LIKELY THE LARGEST LAST FILE)  < < < <'); 
disp('============================================================================'); 

for d=1:numel(soi); dir_data=fullfile(dir_subj,'Sessions',timestamps{soi(d)},'TMSTrigger');
files=dir(fullfile(dir_data,sprintf('*Coil0_%s*.xml',dates{soi(d)}))); size={files.bytes}; 
disp(sprintf('%s: ENTER to use last (or type file#)',sessions{soi(d)})); disp(size);
reply=str2num(input('> > ...','s')); if isempty(reply); reply=numel(files); end; use{d}=reply; end

disp('parsing trigger xml files');

%% open TriggerMarkers_Coil0_timestamp.xml   
for d=1:numel(soi); dir_data=fullfile(dir_subj,'Sessions',timestamps{soi(d)},'TMSTrigger');
files=dir(fullfile(dir_data,sprintf('*Coil0_%s*.xml',dates{soi(d)}))); size={files.bytes}; x=use{d}; 
xml=char({files(x).name}); pxml=parseXML(fullfile(dir_data,xml));

%% get trigger markers 4dmatrix; save in rows
TriggerMarker=[]; for i=1:numel(pxml.Children); ct(i)=strcmp(pxml.Children(i).Name,'TriggerMarker');
if strcmp(pxml.Children(i).Name,'TriggerMarker')==1; TriggerMarker(end+1,1)=i; end; end

%% 4Dmatrix of each trigger
matrix=[]; for i=1:numel(TriggerMarker);
for m=1:16; matrix(i,m)=str2num(pxml.Children(TriggerMarker(i)).Children(4).Attributes(m).Value); if matrix(i,m)==0; matrix(i,m)=NaN; end; end
end; triggers.(sprintf('s%s',sessions{soi(d)}))=matrix; ave_pulse(:,d)=nanmean(matrix); 

%% recording time of each trigger
time=[]; for i=1:numel(TriggerMarker); 
time(i)=str2num(pxml.Children(TriggerMarker(i)).Attributes(3).Value); 
end; trig_times.(sprintf('s%s',sessions{soi(d)}))=time;

%% di/dt (A/us) for each trigger
didt=[]; for i=1:numel(TriggerMarker); 
didt(i)=str2num(pxml.Children(TriggerMarker(i)).Children(2).Children(2).Attributes(2).Value);
end; di_dt.(sprintf('s%s',sessions{soi(d)}))=didt; ave_didt(:,d)=nanmean(didt); 

%% amplitude (%output) for each trigger
amp=[]; for i=1:numel(TriggerMarker);
amp(i)=str2num(pxml.Children(TriggerMarker(i)).Children(2).Children(10).Attributes(2).Value);
end; amplitude.(sprintf('s%s',sessions{soi(d)}))=amp;

end

disp('==========================================================================='); 
disp('                          AVERAGE TRIGGER LOCATION                         ');
disp('==========================================================================='); 
avepulse=ave_pulse'; disp(avepulse);
disp('==========================================================================='); 
disp('                           AVERAGE RECORDED di/dt                          ');
disp('===========================================================================');
disp(ave_didt);

save(fullfile(sprintf('%s/pulse_%s.mat',dir_subj,tmstmp)),'triggers','trig_times','avepulse'); 
save(fullfile(sprintf('%s/pulse_%s.mat',dir_QA,tmstmp)),'triggers','trig_times','avepulse');
save(fullfile(sprintf('%s/didt__%s.mat',dir_subj,tmstmp)),'di_dt','amplitude','ave_didt'); 
save(fullfile(sprintf('%s/didt__%s.mat',dir_QA,tmstmp)),'di_dt','amplitude','ave_didt');
end