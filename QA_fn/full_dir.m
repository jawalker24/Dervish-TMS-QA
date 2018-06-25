function [info] = full_dir(dir_subj,subj,t)

try movefile(sprintf('%s/%s*/Sessions',dir_subj,subj),sprintf('%s/',dir_subj)); catch; end

timestamps=dir(fullfile(dir_subj,'Sessions/Session*')); timestamps={timestamps.name}; 
for i=1:length(timestamps); temp=timestamps{i}; dates{i}=temp(9:16);
    try xml=parseXML(fullfile(dir_subj,'Sessions/',timestamps{i},'Session.xml')); sessions{i}=xml.Children(4).Children.Data;
    catch sessions{i}='empty_xml'; end
end

info(:,1)=sessions; info(:,2)=dates; info(:,3)=timestamps; save(fullfile(dir_subj,'info.mat'),'info');

end