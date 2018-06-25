function [calcdev] = full_calcdev(dir_subj,dir_QA,subj,info,soi,triggers,entry,instrmt,RMSdev,tmstmp)
sessions=info(:,1); dates=info(:,2); timestamps=info(:,3); N=3;

for s=1:numel(soi);
% load data
trg{s}=triggers.(sprintf('s%s',sessions{soi(s)})); ins(s,:)=instrmt.(sprintf('s%s',sessions{soi(s)})); ent(s,:)=entry.(sprintf('s%s',sessions{soi(s)}));
try RMS{s,1}=num2str(RMSdev.(sprintf('s%s',sessions{soi(s)})).landmark); catch RMS{s,1}=NaN; end
try RMS{s,2}=num2str(RMSdev.(sprintf('s%s',sessions{soi(s)})).surface); catch RMS{s,2}=NaN; end
% triggers 4d matrix to 3d vector pls
for i=1:numel(trg{s}(:,1));
pls{s}(i,1)=trg{s}(i,1)+trg{s}(i,2)+trg{s}(i,3)+trg{s}(i,4);
pls{s}(i,2)=trg{s}(i,5)+trg{s}(i,6)+trg{s}(i,7)+trg{s}(i,8);
pls{s}(i,3)=trg{s}(i,9)+trg{s}(i,10)+trg{s}(i,11)+trg{s}(i,12);
pls{s}(i,4)=trg{s}(i,13)+trg{s}(i,14)+trg{s}(i,15)+trg{s}(i,16);   
end
% ins 4d matrix to 3d vector imk
imk(s,1)=ins(s,1)+ins(s,2)+ins(s,3)+ins(s,4);
imk(s,2)=ins(s,5)+ins(s,6)+ins(s,7)+ins(s,8);
imk(s,3)=ins(s,9)+ins(s,10)+ins(s,11)+ins(s,12);
imk(s,4)=ins(s,13)+ins(s,14)+ins(s,15)+ins(s,16);   

%% CALCULATE DEVIATIONS AND VARIANCE
% distance imk from ent
imk2ent(s,:)=sqrt(((imk(s,1)-ent(s,1))^2)+((imk(s,2)-ent(s,2))^2)+((imk(s,3)-ent(s,3))^2));
% distance pls from ent and imk
for t=1:length(pls{s}(:,1));   
    pls2ent(s,t)=sqrt(((pls{s}(t,1)-ent(s,1))^2)+((pls{s}(t,2)-ent(s,2))^2)+((pls{s}(t,3)-ent(s,3))^2));
    pls2imk(s,t)=sqrt(((pls{s}(t,1)-imk(s,1))^2)+((pls{s}(t,2)-imk(s,2))^2)+((pls{s}(t,3)-imk(s,3))^2));  
end
% count pls N+ off ent and imk
pls2ent_OFF=(pls2ent(s,:)>=N); pls2ent_ctOFF(s,1)=sum(pls2ent_OFF);
pls2imk_OFF=(pls2imk(s,:)>=N); pls2imk_ctOFF(s,1)=sum(pls2imk_OFF);
% summary pls from ent and imk
ave_pls2ent(s,1)=mean(pls2ent(s,:));std_pls2ent(s,1)=std(pls2ent(s,:));var_pls2ent(s,1)=var(pls2ent(s,:)); 
ave_pls2imk(s,1)=mean(pls2imk(s,:));std_pls2imk(s,1)=std(pls2imk(s,:));var_pls2imk(s,1)=var(pls2imk(s,:)); 

%% TRIGGER & PULSE VARIANCE
% displacement from previous 
for u=1:t-1; trg2prevtrg{s}(u,:)=(trg{s}((u+1),:))-(trg{s}(u,:));    
pls2prevpls(s,u)=sqrt(((pls{s}(u+1,1)-pls{s}(u,1))^2)+((pls{s}(u+1,2)-pls{s}(u,2))^2)+((pls{s}(u+1,3)-pls{s}(u,3))^2));
end
% variance
var_trg(s,:)=var(trg{s}); var_pls(s,:)=var(pls{s}); var_pls_dist0(s,1)=sqrt((var_pls(s,1)^2)+(var_pls(s,2)^2)+(var_pls(s,3)^2));

calcdev.max_trg2prevtrg(s,:)=max(trg2prevtrg{s});
calcdev.ave_trg2prevtrg(s,:)=mean(trg2prevtrg{s});
calcdev.var_pls2prevpls(s,:)=var(pls2prevpls(s,:));
end

disp('==========================================================================='); 
disp('                       TRIGGER DEVIATIONS & VARIANCE                       ');
disp('==========================================================================='); 
disp('MAX DISPLACEMENT FROM PREVIOUS PULSE:'); disp(calcdev.max_trg2prevtrg);
disp('==========================================================================='); 
disp('AVE DISPLACEMENT FROM PREVIOUS PULSE:'); disp(calcdev.ave_trg2prevtrg);
disp('==========================================================================='); 
disp('VARIANCE IN TRIGGER 4D MATRIX:'); disp(var_trg);
disp('==========================================================================='); 
disp('VARIANCE IN TRIGGER 3D VECTOR:'); disp(var_pls);
disp('==========================================================================='); 
disp('TRIGGER VARIANCE FROM ZERO VAR:'); disp(var_pls_dist0');
disp('==========================================================================='); 
disp('DISTANCE BETWEEN ENTRY & INSTMT:'); disp(imk2ent');
disp('==========================================================================='); 
disp('DEVIATION BETWEEN PULSE & ENTRY (ave/std/var):'); disp(ave_pls2ent'); disp(std_pls2ent'); disp(var_pls2ent');
disp('==========================================================================='); 
disp('DEVIATION BETWEEN PULSE & INSTMT (ave/std/var):'); disp(ave_pls2imk'); disp(std_pls2imk'); disp(var_pls2imk');

%% PLOT EACH SESSION
names=strrep(sessions,'_',' day'); names=strrep(names,'dayMT100','STIM'); names=strrep(names,'dayMT10','SHAM');

figure('Name',subj,'NumberTitle','off');
for s=1:numel(soi); subplot(numel(soi),1,s); points=1:numel(pls2ent(s,:)); set(gca,'YGrid','on','GridLineStyle','-');
h=plot(points,pls2ent(s,:),'b'); hold on; h=plot(points,pls2imk(s,:),'r'); hold on; title(sprintf('%s',names{soi(s)})); hold on;
lh=legend(sprintf('DIST FROM ENTRY\n %d triggers >%dmm off\n -------------------------',pls2ent_ctOFF(s,1),N),sprintf('DIST FROM INSTMT\n %d triggers >%dmm off',pls2imk_ctOFF(s,1),N));
set(lh,'Location','East','Orientation','vertical'); ylabel('mm off'); xlabel(sprintf('trigger count: %s',num2str(numel(trg{s}(:,1)))));
end
savefig(fullfile(sprintf('%s/QAfig_%s',subj,tmstmp)));
savefig(fullfile(sprintf('%s/QAfig_%s',dir_QA,tmstmp)));

save(fullfile(sprintf('%s/QAvar_%s.mat',subj,tmstmp)),'calcdev','pls2ent','pls2imk');
save(fullfile(sprintf('%s/QAvar_%s.mat',dir_QA,tmstmp)),'calcdev','pls2ent','pls2imk');
end