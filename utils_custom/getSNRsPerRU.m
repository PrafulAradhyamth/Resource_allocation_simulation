function snrsPerRU = getSNRsPerRU(sinr, allocationIdx)
% Returns average SNR per RU. Takes as arguments:
% - a list of SINR values per subcarrier/tone,
% - allocation index
% Returns a list of average SNR per RU by simply taking the arithmetic
% mean.

% Create heTBSystemConfig
cfgSys = heTBSystemConfig(allocationIdx);
% Create ruInfo
sysInfo = ruInfo(cfgSys);
% Initialize snrsPerRU
snrsPerRU = zeros(sysInfo.NumRUs, 1);

for ruIdx = 1:sysInfo.NumRUs
    ruOFDMInfo = wlanHEOFDMInfo('HE-Data',cfgSys.ChannelBandwidth,cfgSys.GuardInterval, [sysInfo.RUSizes(ruIdx) sysInfo.RUIndices(ruIdx)]);
    snrsPerRU(ruIdx) = mean(sinr(ruOFDMInfo.ActiveFFTIndices));
end
end

%%% OLD VERSION %%%
% function snrsPerRU = getSNRsPerRU(sinr, RUSizes)
% % Returns average SNR per RU. Takes as arguments:
% % - a list of SINR values per subcarrier/tone,
% % - a list of RU sizes, e.g. [106, 26, 106].
% % Returns a list of average SNR per RU by simply taking the arithmetic
% % mean.
% 
% % Initialize snrsPerRU
% snrsPerRU = zeros(length(RUSizes), 1);
% % Initialize idx
% idx = 1;
% for i = 1:length(RUSizes)
%     % Compute average SNR by taking the mean of the SINR values per
%     % subcarrier within RU
%     snrsPerRU(i) = mean(sinr(idx:(idx+RUSizes(i)-1)));
%     % Update starting idx for next RU
%     idx = idx + RUSizes(i);
% end
% end