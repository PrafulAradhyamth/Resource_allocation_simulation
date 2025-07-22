function [solution, objectiveValue, ruPartition, userRUMCS, userRUSNR, allocationIndex] = PPDUTxTimeRoundRobin(numSTAToSchedule, stationInformationTemp, SINRs, tableMCS, targetPDR, userConfig)
% Returns transmission time of a PPDU with numSTAToSchedule stations to
% schedule (for Round robin scheduling). Takes in as arguments
% - numSTAToSchedule -> Number of stations to schedule
% - stationInformationTemp -> Table with station infomation (Station, FrameSize,
% MaximumLatency)
% - SINRs -> SINR per subcarrier for each station
% - tableMCS -> MCS table
% - targetPDR -> Target packet delivery rate
% - userConfig -> User configuration parameters

% Set allocationIndex. 
% Choose most balanced RU configuration
switch numSTAToSchedule
    case 1
        allocationIndex = 192;
    case 2
        allocationIndex = 96;
    case 3
        allocationIndex = 16;
    case 4
        allocationIndex = 112;
    case 5
        allocationIndex = 15;
    case 6
        allocationIndex = 14;
    case 7
        allocationIndex = 5;
    case 8
        allocationIndex = 2;
    case 9
        allocationIndex = 0;
end

% Create heTBSystemConfig and ruInfo
cfgSys = heTBSystemConfig(allocationIndex);
allocInfo = ruInfo(cfgSys);

% Compute SNR per RU for each station
userRUSNR = zeros(numSTAToSchedule, numSTAToSchedule);
for i = 1:numSTAToSchedule
    % Get SINR per subcarrier
    sinr = SINRs{stationInformationTemp.Station(i)};
    % Get average SNR per RU (custom function)
    snrsPerRU = getSNRsPerRU(sinr, allocationIndex);
    for j = 1:numSTAToSchedule
        userRUSNR(i, j) = round(snrsPerRU(j), 1);
    end
end

% Compute MCS per RU for each station
% Create wrapper function for getMaxMCS (custom function)
func = @(x) getMaxMCS(x, tableMCS, targetPDR);
userRUMCS = arrayfun(func, userRUSNR);

% Compute transmission time per RU for each user (station)
userRUTxTime = zeros(numSTAToSchedule, numSTAToSchedule);
for i = 1:numSTAToSchedule
    apep_length = stationInformationTemp.FrameSize(i); % in Bytes
    mcs = userRUMCS(i, :);
    % Length check
    assert(length(allocInfo.RUSizes) == length(mcs), "Mismatch in sizes!")
    for j = 1:numSTAToSchedule
        % Compute transmission time (custom function)
        userRUTxTime(i, j) = getTxTime(userConfig, allocInfo.RUSizes(j), apep_length, mcs(j));
    end
end

objectiveValue = trace(userRUTxTime);
solution = eye(numSTAToSchedule);
ruPartition = allocInfo.RUSizes;
end