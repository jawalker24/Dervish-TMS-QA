function calcdev = full_calcdev(dir_subj, dir_QA, subj, info, soi, triggers, entry, instrmt, RMSdev, tmstmp)
%FULL_CALCDEV [insert desc here]
%   calcdev = FULL_CALCDEV(dir_subj, dir_QA, subj, info, soi, triggers,...
%                           entry, instrmt, RMSdev, tmstmp)
%
%   Authors: Molly Hermiller (with slight tweaks by John A. Walker)
%   Version: 1.1.1, 05.03.2018

%clear all
%load 50a_trig_input.mat
sessions = info(:,1);
N = 3;
trigger_fields = fieldnames(triggers);
inst_fields = fieldnames(instrmt);
calcdev = struct;
to_graph = 1:length(trigger_fields);
for t = 1:length(trigger_fields)
    % load data
    trg{t} = triggers.(trigger_fields{t});
    num_trig = size(trg{t}, 1);
    %clean trigger file for bad triggers (usually at end of file)
    t2r = 0;
    for i = 1:num_trig
       if any(isnan(trg{t}(i,1:12)))
           t2r(1) = t2r(1) + 1;
           t2r(end+1) = i;
       end
    end
    
    if t2r(1) > 0
        
        warning off backtrace
        warning('\n%.0f triggers removed for session %s due to NaNs, please look at trigger files\n', ...
            t2r(1), trigger_fields{t})
        warning on backtrace
        trg{t}(t2r(2:end),:) = [];  
    end
    
    if t2r(1) == num_trig %if all triggers have been removed replace fields with NaN
        fprintf(2, '\nAll triggers removed for session %s, please make sure correct session was selected and re-run\n\n', trigger_fields{t})
        to_graph(t) = NaN;
        calcdev.max_trg2prevtrg(t, :) = NaN(16,1);
        calcdev.ave_trg2prevtrg(t, :) = NaN(16,1);
        calcdev.var_pls2prevpls(t, :) = NaN(16,1);
        var_trg(t, :) = NaN(16,1);
        var_pls(t, :) = NaN(3,1);
        var_pls_dist0(t, 1) = NaN;
        imk2ent(t, 1) = NaN;
        ave_pls2ent(t, 1) = NaN;
        std_pls2ent(t, 1) = NaN;
        var_pls2ent(t, 1) = NaN;
        ave_pls2imk(t, 1) = NaN;
        std_pls2imk(t, 1) = NaN;
        var_pls2imk(t, 1) = NaN;
        
    else    
        %find matching session for trigger session
        for i = 1:length(inst_fields)
            if strcmp(inst_fields{i}, trigger_fields{t}(1:length(inst_fields{i})))
                s = i;
                break
            elseif i == length(inst_fields)
                fprintf(2, 'ERROR: Cannot find match for session file %s\n', ...
                    trigger_fields{t})
            end
        end
        ins(t, :) = instrmt.(sprintf('s%s', sessions{soi(s)}));
        ent(t, :) = entry.(sprintf('s%s', sessions{soi(s)}));

    %     try
    %         RMS{t, 1} = num2str(RMSdev.(sprintf('s%s', sessions{soi(s)})).landmark);
    %     catch
    %         RMS{t, 1} = NaN;
    %     end
    %     
    %     try
    %         RMS{t, 2} = num2str(RMSdev.(sprintf('s%s', sessions{soi(s)})).surface);
    %     catch
    %         RMS{t, 2} = NaN;
    %     end

        % triggers 4d matrix to 3d vector pls
        for i = 1:numel(trg{t}(:, 1))
            pls{t}(i, 1) = trg{t}(i, 1) + trg{t}(i, 2) + trg{t}(i, 3) + trg{t}(i, 4);
            pls{t}(i, 2) = trg{t}(i, 5) + trg{t}(i, 6) + trg{t}(i, 7) + trg{t}(i, 8);
            pls{t}(i, 3) = trg{t}(i, 9) + trg{t}(i, 10) + trg{t}(i, 11) + trg{t}(i, 12);
            %pls{t}(i, 4) = trg{t}(i, 13) + trg{t}(i, 14) + trg{t}(i, 15) + trg{t}(i, 16);
        end

        % ins 4d matrix to 3d vector imk
        imk(t, 1) = ins(t, 1) + ins(t, 2) + ins(t, 3) + ins(t, 4);
        imk(t, 2) = ins(t, 5) + ins(t, 6) + ins(t, 7) + ins(t, 8);
        imk(t, 3) = ins(t, 9) + ins(t, 10) + ins(t, 11) + ins(t, 12);
        imk(t, 4) = ins(t, 13) + ins(t, 14) + ins(t, 15) + ins(t, 16);

        % CALCULATE DEVIATIONS AND VARIANCE
        % distance imk from ent
        imk2ent(t, :) = sqrt((imk(t, 1) - ent(t, 1))^2 + (imk(t, 2) - ent(t,2))^2 + (imk(t,3) - ent(t,3))^2);

        % distance pls from ent and imk
        for p = 1:length(pls{t}(:, 1))
            pls2ent(t, p) = sqrt(((pls{t}(p, 1) - ent(t, 1))^2) + ((pls{t}(p, 2) - ent(t, 2))^2) + ((pls{t}(p, 3) - ent(t, 3))^2));
            pls2imk(t, p) = sqrt((pls{t}(p, 1) - imk(t, 1))^2 + (pls{t}(p, 2) - imk(t, 2))^2 + (pls{t}(p, 3) - imk(t, 3))^2);
        end

        % count pls N+ off ent and imk
        pls2ent_OFF = (pls2ent(t, :) >= N);
        pls2ent_ctOFF(t, 1) = sum(pls2ent_OFF);

        pls2imk_OFF = (pls2imk(t,:) >= N);
        pls2imk_ctOFF(t, 1) = sum(pls2imk_OFF);

        % summary pls from ent and imk
        ave_pls2ent(t, 1) = mean(pls2ent(t, 1:length(pls{t}(:, 1))));
        std_pls2ent(t, 1) = std(pls2ent(t, 1:length(pls{t}(:, 1))));
        var_pls2ent(t, 1) = var(pls2ent(t, 1:length(pls{t}(:, 1))));
        ave_pls2imk(t, 1) = mean(pls2imk(t, 1:length(pls{t}(:, 1))));
        std_pls2imk(t, 1) = std(pls2imk(t, 1:length(pls{t}(:, 1))));
        var_pls2imk(t, 1) = var(pls2imk(t, 1:length(pls{t}(:, 1))));

        % TRIGGER & PULSE VARIANCE
        % displacement from previous
        for u = 1:p-1 
            trg2prevtrg{t}(u, :) = (trg{t}((u+1), :)) - (trg{t}(u, :));
            pls2prevpls(t, u) = sqrt((pls{t}(u+1, 1) - pls{t}(u, 1))^2 + (pls{t}(u+1, 2) - pls{t}(u, 2))^2 + (pls{t}(u+1, 3) - pls{t}(u, 3))^2);
        end
        % variance
        var_trg(t, :) = var(trg{t}); 
        var_pls(t, :) = var(pls{t}); 
        var_pls_dist0(t, 1) = sqrt(var_pls(t, 1)^2 + var_pls(t, 2)^2 + var_pls(t, 3)^2);

        calcdev.max_trg2prevtrg(t, :) = max(trg2prevtrg{t});
        calcdev.ave_trg2prevtrg(t, :) = mean(trg2prevtrg{t});
        calcdev.var_pls2prevpls(t, :) = var(pls2prevpls(t, :));
    end
end

% make pretty for Command Window
pe_asv_4disp = [ave_pls2ent std_pls2ent var_pls2ent];
pi_asv_4disp = [ave_pls2imk std_pls2imk var_pls2imk];

disp('===========================================================================');
disp('                       TRIGGER DEVIATIONS & VARIANCE                       ');
disp('===========================================================================');
disp('MAX DISPLACEMENT FROM PREVIOUS PULSE:'); 
disp(rem_NaN_rotmax(calcdev.max_trg2prevtrg));
disp('===========================================================================');
disp('AVE DISPLACEMENT FROM PREVIOUS PULSE:'); 
disp(rem_NaN_rotmax(calcdev.ave_trg2prevtrg));
disp('===========================================================================');
disp('VARIANCE IN TRIGGER 4D MATRIX:'); 
disp(rem_NaN_rotmax(var_trg));
disp('===========================================================================');
disp('VARIANCE IN TRIGGER 3D VECTOR:'); 
disp(var_pls);
disp('===========================================================================');
disp('TRIGGER VARIANCE FROM ZERO VAR:'); 
disp(var_pls_dist0);
disp('===========================================================================');
disp('DISTANCE BETWEEN ENTRY & INSTMT:'); 
disp(imk2ent);
disp('===========================================================================');
disp('DEVIATION BETWEEN PULSE & ENTRY (ave/std/var):'); 
disp(pe_asv_4disp); 
disp('===========================================================================');
disp('DEVIATION BETWEEN PULSE & INSTMT (ave/std/var):'); 
disp(pi_asv_4disp); 


%% PLOT EACH SESSION
names = strrep(trigger_fields, '_', ' ');
names = strrep(names, 'dayMT100', 'STIM');
names = strrep(names, 'dayMT10', 'SHAM');

figure('Name', subj, 'NumberTitle', 'off');
to_graph = to_graph(isfinite(to_graph));
for t = 1:length(to_graph)
    subplot(length(to_graph), 1, t);
    points = 1:numel(pls2ent(to_graph(t), :));
    set(gca, 'YGrid', 'on', 'GridLineStyle' ,'-');
    h = plot(points, pls2ent(to_graph(t),:), 'b');
    hold on;
    h = plot(points, pls2imk(to_graph(t),:), 'r');
    hold on;
    title(names{to_graph(t)});
    hold on;
    lh = legend(sprintf('DIST FROM ENTRY\n %d triggers >%dmm off\n -------------------------',...
                    pls2ent_ctOFF(to_graph(t),1),N),...
                sprintf('DIST FROM INSTMT\n %d triggers >%dmm off',...
                    pls2imk_ctOFF(to_graph(t),1),N));
    set(lh, 'Location', 'eastoutside', 'Orientation', 'vertical');
    ylabel('mm off');
    xlabel(sprintf('trigger count: %s', num2str(numel(trg{to_graph(t)}(:, 1)))));
end

savefig(fullfile(sprintf('%s/QAfig_%s', dir_subj, tmstmp)));
saveas(gcf, fullfile(sprintf('%s/%s_QAfig_%s.png', dir_subj, subj, tmstmp)))
savefig(fullfile(sprintf('%s/QAfig_%s', dir_QA, tmstmp)));

save(fullfile(sprintf('%s/QAvar_%s.mat', dir_subj, tmstmp)), 'calcdev', 'pls2ent', 'pls2imk');
save(fullfile(sprintf('%s/QAvar_%s.mat', dir_QA, tmstmp)), 'calcdev', 'pls2ent', 'pls2imk');
%end