function info = full_dir(dir_subj, subj, t)
% FULL_DIR [insert desc here]
%   info = full_dir(dir_subj, subj, t)
%
%   Authors: Molly Hermiller
%   Version: 1.0.0, 06.27.2017

try 
    movefile(sprintf('%s/%s*/Sessions',dir_subj,subj),sprintf('%s/',dir_subj)); 
catch
end

timestamps=dir(fullfile(dir_subj,'Sessions/Session*')); timestamps={timestamps.name}; 
for i=1:length(timestamps) 
    temp=timestamps{i}; 
    dates{i}=temp(9:16);
    try 
        xml=parseXML(fullfile(dir_subj,'Sessions/',timestamps{i},'Session.xml')); 
        sessions{i}=xml.Children(4).Children.Data;
    catch
        sessions{i}='empty_xml'; 
    end
end

info(:, 1:3) = [sessions', dates', timestamps']; 
save(fullfile(dir_subj,'info.mat'),'info');

end