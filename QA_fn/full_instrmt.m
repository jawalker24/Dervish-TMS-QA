function instrmt = full_instrmt(dir_subj, dir_QA, info, soi, tmstmp)
%FULL_INSTRMT [insert desc here]
%   instrmt = FULL_INSTRMT(dir_subj, dir_QA, info, soi, tmstmp)
%
%   Authors: Molly Hermiller (with small tweaks by John Walker)
%   Version: 1.0.1, 05.01.2018

sessions=info(:,1);  
timestamps=info(:,3);

for d = 1:numel(soi)
    dir_data = fullfile(dir_subj, 'Sessions', timestamps{soi(d)}, 'InstrumentMarkers');

    % open InstrumentMarker_timestamp.xml   
    files = dir(fullfile(dir_data, sprintf('InstrumentMarker*.xml'))); 
    xml = char({files(end).name});
    pxml = parseXML(fullfile(dir_data, xml));
    instrmt_timeset = xml(17:24);

    % get instrument markers 4dmatrix; save in rows
    ins = [];
    for i = 1:numel(pxml.Children)
        if strcmp(pxml.Children(i).Name, 'InstrumentMarker') == 1 && ...
           strcmp(pxml.Children(i).Attributes(3).Value, 'true') == 1
            ins(end+1, 1) = i;
        end
    end

    matrix = [];
    for i = 1:numel(ins)
        for m = 1:16
            matrix(i, m) = str2num(pxml.Children(ins(i)).Children(2).Children(2).Attributes(m).Value);
        end
    end
    
    instrmt.(sprintf('s%s', sessions{soi(d)})) = matrix;

end

disp('===========================================================================')
disp('                        CHECK FOR INSTRUMENT CHANGES                       ')
disp('===========================================================================')
disp(instrmt)

save(fullfile(sprintf('%s/instmt_%s.mat', dir_subj, tmstmp)), 'instrmt','instrmt_timeset'); 
save(fullfile(sprintf('%s/instmt_%s.mat', dir_QA, tmstmp)), 'instrmt','instrmt_timeset');
end