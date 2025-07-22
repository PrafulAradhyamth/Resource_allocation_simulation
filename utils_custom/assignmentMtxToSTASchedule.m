function [stationSchedule, MCSSchedule, SNRSchedule] = assignmentMtxToSTASchedule(assignmentMtx, userRUMCS, userRUSNR, stationInformationTemp)    
% Extract user schedule (userSchedule) from assignmentMtx 
[numRows, numCols] = size(assignmentMtx);    
stationSchedule = zeros(1, numCols); % Gives Station # from table (absolute)
for nc = 1 : numCols % for each RU
    schUser = 0; % scheduled user (station)
    for nr = 1 : numRows % find the scheduled user (station)
        schUser = schUser + 1;
        if assignmentMtx(nr, nc) == 1 % scheduled user was found
            break;
        end
    end
    stationSchedule(nc) = stationInformationTemp(schUser, "Station").Station;
end

% Extract MCS from userRUMCS
MCSSchedule = zeros(1, numCols);
for nc = 1 : numCols % for each RU
    for nr = 1 : numRows % find the scheduled user (station)
        if assignmentMtx(nr, nc) == 1
            MCSSchedule(nc) = userRUMCS(nr, nc);
            break;
        end
    end
end

% Extract SNR from userRUSNR
SNRSchedule = zeros(1, numCols);
for nc = 1 : numCols % for each RU
    for nr = 1 : numRows % find the scheduled user (station)
        if assignmentMtx(nr, nc) == 1
            SNRSchedule(nc) = userRUSNR(nr, nc);
            break;
        end
    end
end