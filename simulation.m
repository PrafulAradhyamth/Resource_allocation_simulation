% Simulation setups
numStationsList = [10, 12];
schedulerList = ["AA-None", "AA-FS", "AA-SINR", "RR-None", "RR-SINR"];
snrList = [10,20];

% Simulation parameters
StationFrameArrivalProbability = [1/16000, 1/4000];
ChannelAccessProbability = 0.5;
simulationTime = 1000000; % microseconds (time steps)

for schedulerIdx = 1 : length(schedulerList)
    for stationIdx = 1 : length(numStationsList)
        for snrIdx = 1 : length(snrList)
            % Set number of stations
            numStations = numStationsList(stationIdx);

            % Set scheduler
            Scheduler = schedulerList(schedulerIdx);

            % Set received SNR
            ReceivedSNR = snrList(snrIdx);

            % Display
            disp("Number of stations");
            disp(numStations)
            disp("Scheduler")
            disp(Scheduler)
            disp("Received SNR")
            disp(ReceivedSNR)

            % Create AP object
            AP = AccessPoint(numStations, StationFrameArrivalProbability, ChannelAccessProbability, Scheduler, ReceivedSNR);
            
            % Perform simulation
            for i = 1 : simulationTime
                fprintf("Time step %d \n", i);

                % Perform a step
                AP.step()
            end
            
            disp("Number of gained TXOPs: ");
            disp(AP.NumGainedTXOPs);

            disp("Total time in TXOPs: ");
            disp(AP.TotalTXOPDuration);

            disp("Fraction of time in TXOPs: ")
            disp(AP.TotalTXOPDuration / (simulationTime + AP.TXOPDuration));

            disp("Total number of generated frames: ");
            disp(AP.getNumGeneratedFrames().toTable());
            tableName = sprintf("results/%s/%dSTA/%ddB/numGeneratedFrames.csv", Scheduler, numStations, ReceivedSNR);
            writetable(AP.getNumGeneratedFrames().toTable(), tableName);

            disp("Total number of transmitted frames: ");
            disp(AP.NumTransmittedFrames.toTable())
            tableName = sprintf("results/%s/%dSTA/%ddB/numTransmittedFrames.csv", Scheduler, numStations, ReceivedSNR);
            writetable(AP.NumTransmittedFrames.toTable(), tableName);

            disp("Total number of expired frames: ");
            disp(AP.getNumExpiredFrames().toTable());
            tableName = sprintf("results/%s/%dSTA/%ddB/numExpiredFrames.csv", Scheduler, numStations, ReceivedSNR);
            writetable(AP.getNumExpiredFrames().toTable(), tableName);

            disp("Total number of remaining frames: ");
            remainingFrames = AP.getNumRemainingFrames().toTable();
            disp(remainingFrames);
            tableName = sprintf("results/%s/%dSTA/%ddB/numRemainingFrames.csv", Scheduler, numStations, ReceivedSNR);
            writetable(remainingFrames, tableName);

            disp("Success rate: ");
            AP.NumTransmittedFrames.divide(AP.getNumGeneratedFrames());
            disp(AP.NumTransmittedFrames.toTable());
            tableName = sprintf("results/%s/%dSTA/%ddB/successRates.csv", Scheduler, numStations, ReceivedSNR);
            writetable(AP.NumTransmittedFrames.toTable(), tableName)
        end
    end
end






