function [entry,target]=full_entry(dir_subj,dir_QA,subj,info,soi,tmstmp)
sessions=info(:,1); dates=info(:,2); timestamps=info(:,3);

for d=1:numel(soi); dir_data=fullfile(dir_subj,'Sessions',timestamps{soi(d)},'EntryTarget');
%% open EntryTargettimestamp.xml   
files=dir(fullfile(dir_data,sprintf('EntryTarget*.xml'))); 
xml=char({files(end).name}); pxml=parseXML(fullfile(dir_data,xml));

%% get entry coordinates
ent=[]; for m=1:3; ent(1,m)=str2num(pxml.Children(4).Children(2).Children(2).Attributes(m).Value); end;
entry.(sprintf('s%s',sessions{soi(d)}))=ent;

%% get target coordinates
tar=[]; for m=1:3; tar(1,m)=str2num(pxml.Children(6).Children(2).Children(2).Attributes(m).Value); end;
target.(sprintf('s%s',sessions{soi(d)}))=tar;

%% get rotation angle and reference
rotation_ang.(sprintf('s%s',sessions{soi(d)}))=str2num(pxml.Children(8).Attributes(1).Value);
rot=[]; for m=1:3; rot(1,m)=str2num(pxml.Children(8).Children(2).Children(2).Attributes(m).Value); end;
rotation_ref.(sprintf('s%s',sessions{soi(d)}))=rot;

end

disp('==========================================================================='); 
disp('                      CHECK FOR ENTRY & TARGET CHANGES                     ');
disp('===========================================================================');

save(fullfile(sprintf('%s/entry_%s.mat',dir_subj,tmstmp)),'entry','target','rotation_ang','rotation_ref'); 
save(fullfile(sprintf('%s/entry_%s.mat',dir_QA,tmstmp)),'entry','target','rotation_ang','rotation_ref');
end