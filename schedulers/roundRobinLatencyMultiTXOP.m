function [totalTxTime, latencyInformation] = roundRobinLatencyMultiTXOP(config, stationInformation, sortFlag)
% Round robin scheduler (latency; multi TXOP) : Modified version of the
% round robin scheduler used for latency analysis in Multi TXOP
% simulations.

% Config
channelConfig = config.channelConfig;
snrConfig = config.snrConfig;
mcsConfig = config.mcsConfig;
userConfig = config.userConfig;
constantsConfig = config.constantsConfig;

% Flags
TXOPFlag = 1;

% Number of stations
numSTA = height(stationInformation);

% Confugre channel for each station
tgax = cell(1, numSTA);
for i = 1:numSTA
    % Configure channel for Station i
    tgax{i} = clone(channelConfig.tgaxBase);
    tgax{i}.NumTransmitAntennas = 1;
    tgax{i}.UserIndex = i;
end

% Compute SINR per subcarrier for each station
SINRs = cell(1, numSTA);
for i = 1:numSTA
    % Get SINR per subcarrier (custom function)
    sinr = dictionary(channelConfig.ofdmInfo.ActiveFFTIndices, channelToSINR(tgax{i}, channelConfig.ofdmInfo, snrConfig.SNR, userConfig));
    % Add to SINRs cell
    SINRs{i} = sinr;
end

% Compute mean SINR for each station
stationAverageSINR = zeros(numSTA, 1);
for i = 1:numSTA
    stationAverageSINR(i) = mean(SINRs{i}.values);
end
% Add mean SINR column to stationInformation table
stationInformation.("AverageSINR") = stationAverageSINR;

if sortFlag == "ML"
    % Sort stationInformation table by MaximumLatency column
    stationInformation = sortrows(stationInformation, ["MaximumLatency"]);
elseif sortFlag == "SINR"
    % Sort stationInformation table by AverageSINR column
    stationInformation = sortrows(stationInformation, ["AverageSINR"], {'descend'});
elseif sortFlag == "ML+SINR"
    % Sort stationInformation table by MaximumLatency and AverageSINR columns
    stationInformation = sortrows(stationInformation, ["MaximumLatency", "AverageSINR"], {'ascend', 'descend'});
end

% Create empty output table (latencyInformation)
latencyInformation = table('Size', [numSTA, 8], 'VariableTypes', ["double", "double", "double", "double", "double", "string", "double", "logical"], 'VariableNames', ["Id", "Station", "FrameSize", "TimeSinceGeneration", "MaximumLatency", "Type", "AverageSINR", "Scheduled"]);

% Round robin  
numRemainingSTA = numSTA;
numPPDU = 0;
totalTxTime = 0;
scheduleInfo = struct();
ppduIdx = 1;
while numRemainingSTA > 0
    % Increase number of PPDUs
    numPPDU = numPPDU + 1;
    
    % Set the number of stations to be scheduled in the current PPDU
    numSTAToSchedule = min(9, numRemainingSTA);
    
    % Initialize feasibleFlag
    feasibleFlag = 0;
    
    while 1
        % Check if numSTAToSchedule == 0
        if numSTAToSchedule == 0
            disp("Schedulling is not possible!");
            break;
        end
        
        % Station information of the users to be scheduled
        stationInformationTemp = head(stationInformation, numSTAToSchedule);
        
        % Compute minimal PPDU transmission time
        [solution, objectiveValue, ruPartition, userRUMCS, userRUSNR, allocationIndex] = PPDUTxTimeRoundRobin(numSTAToSchedule, stationInformationTemp, SINRs, mcsConfig.table_mcs, mcsConfig.target_PDR, userConfig);

        feasibleFlag = 1;
        
        % Check if PPDU transmission time would be greater than the PPDU limit
        if objectiveValue >= constantsConfig.PPDULimit
            feasibleFlag = 0;
        end
        
        % Check if the new totalTxTime would be greater than the TXOP limit
        % If TXOPFlag is set to 1
        if TXOPFlag == 1
            if totalTxTime + constantsConfig.triggerFrame + constantsConfig.SIFS + objectiveValue > constantsConfig.TXOPLimit
                feasibleFlag = 0;
            end
        end
        
        % Check if feasible solution was found. Break out of the loop.
        if feasibleFlag == 1
            break;
        end

        % Decrease number of users to schedule
        numSTAToSchedule = numSTAToSchedule - 1;
    end

    if feasibleFlag
        % Increment totalTxTime
        totalTxTime = totalTxTime + constantsConfig.triggerFrame + constantsConfig.SIFS + objectiveValue;
        
        % Compute station and MCS schedule from assignment matrix
        [stationSchedule, MCSSchedule, ~] = assignmentMtxToSTASchedule(solution, userRUMCS, userRUSNR, stationInformationTemp);
        
        % Store results in scheduleInfo struct
        scheduleInfo(ppduIdx).allocationIndex = allocationIndex;
        scheduleInfo(ppduIdx).ruPartition = ruPartition;
        scheduleInfo(ppduIdx).stationSchedule = stationSchedule;
        scheduleInfo(ppduIdx).MCSSchedule = MCSSchedule;
        scheduleInfo(ppduIdx).txTime = objectiveValue;
        
        % Increment ppduIdx
        ppduIdx = ppduIdx + 1;
    else
        break;
    end
    % Decrease number of remaining users
    numRemainingSTA = numRemainingSTA - numSTAToSchedule;
    
    % Increment TimeSinceGeneration
    for rowIdx = 1 : height(stationInformation)
        stationInformation.TimeSinceGeneration(rowIdx) = stationInformation.TimeSinceGeneration(rowIdx) + (constantsConfig.triggerFrame + constantsConfig.SIFS + objectiveValue);
    end
    
    % Update latencyInformation
    for stationIdx = 1 : numSTAToSchedule
        row = stationInformation(stationInformation.Station == stationInformation.Station(stationIdx), :);
        row.Scheduled = true;
        latencyInformation(stationInformation.Station(stationIdx), :) = row;
    end
    
    % Remove the first numSTAToSchedule rows from stationInformation
    stationInformation = stationInformation((numSTAToSchedule + 1):end, :);
end

% Check if there are remaining stations
if numRemainingSTA > 0
    stationIndices = stationInformation.Station;
    for stationIdx = 1 : length(stationIndices)
        row = stationInformation(stationInformation.Station == stationInformation.Station(stationIdx), :);
        row.Scheduled = false;
        latencyInformation(stationInformation.Station(stationIdx), :) = row;
    end
end
end