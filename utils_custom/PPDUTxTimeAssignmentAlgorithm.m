function [solution, objectiveValue, ruPartition, userRUMCS_, userRUSNR_, allocationIndex] = PPDUTxTimeAssignmentAlgorithm(numSTAToSchedule, stationInformationTemp, SINRs, tableMCS, targetPDR, userConfig)
% Returns transmission time of a PPDU with numSTAToSchedule stations to
% schedule (minimal; for Assignment algorithm). Takes in as arguments
% - numSTAToSchedule -> Number of stations to schedule
% - stationInformationTemp -> Table with station infomation (Station, FrameSize,
% MaximumLatency)
% - SINRs -> SINR per subcarrier for each station
% - tableMCS -> MCS table
% - targetPDR -> Target packet delivery rate
% - userConfig -> User configuration parameters

% Open allocation table
allocationTable = heRUAllocationTable;
% Filter allocation table
idx = allocationTable.NumUsers == numSTAToSchedule & allocationTable.NumRUs == numSTAToSchedule;    % Condition: numUsers == numSTAToSchedule and numRUs == numSTAToSchedule (OFDMA)
fAllocationTable = allocationTable(idx, :);
% Get allocation indices
allocationIndices = fAllocationTable.Allocation;
% Case 1 user
if numSTAToSchedule == 1
    allocationIndices = [192];
end

% Initialize fval (function value) of the optimization (assignment problem)
objectiveValue = inf;

% For all allocation indices / RU partitions
for alloc_idx = 1 : length(allocationIndices)
    % Create heTBSystemConfig and ruInfo
    cfgSys = heTBSystemConfig(allocationIndices(alloc_idx));
    allocInfo = ruInfo(cfgSys);
    % disp('Allocation information / RU partition: ')
    % disp(allocInfo.RUSizes)

    % Compute SNR per RU for each station
    userRUSNR = zeros(numSTAToSchedule, numSTAToSchedule);
    for i = 1:numSTAToSchedule
        % Get SINR per subcarrier
        sinr = SINRs{stationInformationTemp.Station(i)};
        % Get average SNR per RU (custom function)
        snrsPerRU = getSNRsPerRU(sinr, allocationIndices(alloc_idx));
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

    % Solve assignment problem
    [sol_temp, fval_temp] = optimProbSinglePPDU(numSTAToSchedule, userRUTxTime);

    % Check if fval_temp < fval
    if fval_temp < objectiveValue
        objectiveValue = fval_temp;
        solution = sol_temp;
        ruPartition = allocInfo.RUSizes;
        userRUMCS_ = userRUMCS;
        userRUSNR_ = userRUSNR;
        allocationIndex = allocationIndices(alloc_idx);
    end
end
end