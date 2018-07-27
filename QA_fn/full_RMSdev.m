function rms_dev = full_RMSdev(dir_subj, dir_QA, info, soi, tmstmp)
%FULL_RMSDEV [insert desc here]
%   rms_dev = FULL_RMSDEV(dir_subj, dir_QA, subj, info, soi, tmstmp)
%
%   Authors: Molly Hermiller (with small tweaks by John Walker)
%   Version: 1.0.1, 05.01.2018

sessions=info(:,1); 
dates=info(:,2); 
timestamps=info(:,3);

for d = 1:numel(soi)
    dir_data = fullfile(dir_subj, 'Sessions', timestamps{soi(d)}, '/Registrations/LocatorRegistrations/');

    % open Transformationtimestamp.xml
    files_mat = dir(fullfile(dir_data, sprintf('Transformation%s*.xml', dates{soi(d)}))); 
    xml = char({files_mat(end).name});
    pxml = parseXML(fullfile(dir_data, xml));
    trans_timeset = xml(17:24);

    % get transformation 4dmatrix; save in rows
    Transformation = [];
    for i = 1:numel(pxml.Children)
        if strcmp(pxml.Children(i).Name,'TransformationMatrix')
            Transformation(end+1,1) = i;
        end
    end

    matrix = [];
    for i = 1:numel(Transformation)
        for m = 1:16
            matrix(i, m) = str2num(pxml.Children(Transformation(i)).Children(2).Attributes(m).Value);
        end
    end
    
    trans_mat.(sprintf('s%s', sessions{soi(d)})) = matrix;
  
    % open Transformation .txt
    try 
        files = dir(fullfile(dir_data, 'Transformation*.txt'));
        last = char({files(end).name});
        txt = dir(fullfile(dir_data, last));
        filename = char(txt.name);

        file = fopen(fullfile(dir_data, filename), 'r');
        tline = fgetl(file); 
        rms = [];
        rot = [];
        transl = [];
        
        while ischar(tline)
            if ~isempty(strfind(tline, 'RMS Deviation'))
                rms = [rms regexp(tline, '\d*\.\d*', 'match')];
            end
            if ~isempty(strfind(tline, 'Rotation'))
                rot = [rot regexp(tline, '\d*\.\d*', 'match')];
            end
            if ~isempty(strfind(tline,'Translation'))
                transl = [transl regexp(tline,'\d*\.\d*','match')];
            end
            
            tline=fgetl(file);
        end
        
        fclose(file);

        rms_dev.(sprintf('s%s', sessions{soi(d)})).landmark = rms(1);
        rms_dev.(sprintf('s%s', sessions{soi(d)})).surface = rms(2);
        rms_dev.(sprintf('s%s', sessions{soi(d)})).rotation = rot(1);
        rms_dev.(sprintf('s%s', sessions{soi(d)})).translation = transl(1);
        rmsdev(d, :) = rms;

    catch
        rms_dev.(sprintf('s%s', sessions{soi(d)})).landmark = NaN;
        rms_dev.(sprintf('s%s', sessions{soi(d)})).surface = NaN;
    end
end

disp('==========================================================================='); 
disp('                       RMS DEVIATIONS AT REGISTRATION                      ');
disp('===========================================================================');
disp(rmsdev');

save(fullfile(sprintf('%s/RMSdv_%s.mat', dir_subj, tmstmp)), 'rms_dev', 'trans_mat'); 
save(fullfile(sprintf('%s/RMSdv_%s.mat', dir_QA, tmstmp)), 'rms_dev', 'trans_mat');
end