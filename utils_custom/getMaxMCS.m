function max_mcs = getMaxMCS(SNR, table, target_PDR)
% Returns the maximum MCS value for a given SNR and target PDR. Takes
% as arguments:
% - SNR value,
% - table of SNR x MCS x PDR values,
% - target PDR (packet delivery rate).

% Limit SNR value to max SNR value in table
SNR = min(SNR, max(table(:, 1)));
% 3dB uncertainty gap
% SNR = SNR - 3; 
% Round SNR to 1 decimal point
SNR = round(SNR, 1);
% Default to MCS0
max_mcs = 0;
% Find the index of SNR in the table
idx = find(table(:, 1) == SNR);
if ~isempty(idx)
    for mcs = 2:length(table(idx, :))
        pdr = table(idx, mcs);
        if pdr >= target_PDR
            max_mcs = mcs - 2; % MATLAB indices start from 1
            % max_mcs = mcs - 3; % More conservative (-3 = 1 MCS lower; -4 = 2 MCS lower) 
        end
    end
end
end