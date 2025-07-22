classdef AccessPoint < handle
    properties
        NumStations
        StationFrameArrivalProbability
        ChannelAccessProbability
        Scheduler
        ReceivedSNR
        Stations
        WaitTimeUntilChannelAccess
        TXOPDuration
        TotalTXOPDuration
        NumGainedTXOPs
        NumTransmittedFrames
    end

    methods
        % Constructor
        function obj = AccessPoint(NumStations, StationFrameArrivalProbability, ChannelAccessProbability, Scheduler, ReceivedSNR)
            if nargin > 0
                obj.NumStations = NumStations;
                obj.StationFrameArrivalProbability = StationFrameArrivalProbability;
                obj.ChannelAccessProbability = ChannelAccessProbability;
                obj.Scheduler = Scheduler;
                obj.ReceivedSNR = ReceivedSNR;
            end
            obj.Stations = {};
            for i = 1 : obj.NumStations
                obj.Stations{end+1} = Station(i, obj.StationFrameArrivalProbability);
            end
            obj.WaitTimeUntilChannelAccess = 100;
            obj.TXOPDuration = 0;
            obj.TotalTXOPDuration = 0;
            obj.NumGainedTXOPs = 0;
            obj.NumTransmittedFrames = Counts();
        end

        % Step method
        function step(obj)
            if obj.WaitTimeUntilChannelAccess > 0
                % Decrease WaitTimeUntilChannelAccess
                obj.WaitTimeUntilChannelAccess = obj.WaitTimeUntilChannelAccess - 1;

                % Check if access point is in TXOP
                if obj.TXOPDuration > 0
                    % Access point is in TXOP
                    % Decrease TXOP Duration
                    obj.TXOPDuration = obj.TXOPDuration - 1;
                    
                    % Check if TXOP has finished
                    if obj.TXOPDuration == 0
                        fprintf("Message: TXOP %d has finished! \n", obj.NumGainedTXOPs);
                    end
                end
            else
                % Attempt to gain TXOP/gain channel access
                channelAccess = coinFlip(obj.ChannelAccessProbability);

                if channelAccess == true
                    % Access point has gained TXOP
                    disp("Message: AP gained TXOP!")

                    % Increment NumGainedTXOPs
                    obj.NumGainedTXOPs = obj.NumGainedTXOPs + 1;

                    % Get station information (frames in the buffers of the stations)
                    stationInformation = getStationInformation(obj.Stations);

                    % Resource allocation
                    if height(stationInformation) ~= 0
                        fprintf("Message: There are %d stations to be scheduled! \n", height(stationInformation));
                        disp(stationInformation);

                        % Change station indices and reorder
                        % stationInformation table
                        newStationIds = (1:height(stationInformation))';
                        stationInformation.Id = stationInformation.Station;
                        stationInformation.Station = newStationIds;
                        stationInformation = stationInformation(:, {'Id', 'Station', 'FrameSize', 'TimeSinceGeneration', 'MaximumLatency', 'Type'});

                        % Run scheduling algorithm
                        fprintf("Message: Running %s scheduler to allocate resources! \n", obj.Scheduler);
                        schedulerInfo = split(obj.Scheduler, "-");
                        
                        % Config
                        config = defaultConfig();
                        config.snrConfig.SNR = obj.ReceivedSNR;
                        
                        % Assignment algorithm 
                        if schedulerInfo(1) == "AA"
                            % Run Assignment algorithm (AA)
                            [obj.TXOPDuration, latencyInformation] = assignmentAlgorithmLatencyMultiTXOP(config, stationInformation, schedulerInfo(2));
                            
                            % Save latencyInformation table
                            tableName = sprintf("results/%s/%dSTA/%ddB/latencyInformation_%d.csv", obj.Scheduler, obj.NumStations, obj.ReceivedSNR, obj.NumGainedTXOPs);
                            writetable(latencyInformation, tableName);

                            % Process latencyInformation table
                            filterCondition = latencyInformation.Scheduled == true;
                            scheduledStationInformation = latencyInformation(filterCondition, :);
                            
                            % Remove scheduled frames from station buffers
                            obj.removeScheduledFrames(scheduledStationInformation.Id);

                            % Increment TotalTXOPDuration
                            obj.TotalTXOPDuration = obj.TotalTXOPDuration + obj.TXOPDuration;
                            
                            % Increment NumTransmittedFrames
                            obj.NumTransmittedFrames.add(getTypeCountsFromTable(scheduledStationInformation));
                            fprintf("Message: TXOP duration is %d microseconds (time steps)! \n", obj.TXOPDuration);
                            fprintf("Message: %d frames transmitted successfully! \n", height(scheduledStationInformation));
                        
                        % Round robin
                        elseif schedulerInfo(1) == "RR"
                            % Run Round robin (RR)
                            [obj.TXOPDuration, latencyInformation] = roundRobinLatencyMultiTXOP(config, stationInformation, schedulerInfo(2));

                            % Save latencyInformation table
                            tableName = sprintf("results/%s/%dSTA/%ddB/latencyInformation_%d.csv", obj.Scheduler, obj.NumStations, obj.ReceivedSNR, obj.NumGainedTXOPs);
                            writetable(latencyInformation, tableName);

                            % Process latencyInformation table
                            filterCondition = latencyInformation.Scheduled == true;
                            scheduledStationInformation = latencyInformation(filterCondition, :);
                            
                            % Remove scheduled frames from station buffers
                            obj.removeScheduledFrames(scheduledStationInformation.Id);
                            
                            % Increment TotalTXOPDuration
                            obj.TotalTXOPDuration = obj.TotalTXOPDuration + obj.TXOPDuration;
                            
                            % Increment NumTransmittedFrames
                            obj.NumTransmittedFrames.add(getTypeCountsFromTable(scheduledStationInformation));
                            fprintf("Message: TXOP duration is %d microseconds (time steps)! \n", obj.TXOPDuration);
                            fprintf("Message: %d frames transmitted successfully! \n",  height(scheduledStationInformation));
                        end
                    else
                        disp("Message: There are no stations to be scheduled!")
                    end
                    % Set WaitTimeUntilChannelAccess
                    obj.WaitTimeUntilChannelAccess = 100 + obj.TXOPDuration;
                else
                    % Access point didn't gain TXOP
                    disp("Message: AP didn't gain TXOP!")
                    % obj.WaitTimeUntilChannelAccess = 5600;
                    obj.WaitTimeUntilChannelAccess = randi([1000, 5600]);
                end
            end
            % Perform step for all stations
            for i = 1 : length(obj.Stations)
                obj.Stations{i}.step();
            end
        end

        % Remove scheduled frames
        function removeScheduledFrames(obj, stationIndices)
            for i = 1 : length(stationIndices)
                stationIdx = stationIndices(i);
                obj.Stations{stationIdx}.Buffer.dequeue();
            end
        end

        % Get total number of generated frames
        function totalNumGeneratedFrames = getNumGeneratedFrames(obj)
            totalNumGeneratedFrames = Counts();
            for i = 1 : length(obj.Stations)
                totalNumGeneratedFrames.add(obj.Stations{i}.NumGeneratedFrames);
            end
        end

        % Ger total number of expired frames
        function totalNumExpiredFrames = getNumExpiredFrames(obj)
            totalNumExpiredFrames = Counts();
            for i = 1 : length(obj.Stations)
                totalNumExpiredFrames.add(obj.Stations{i}.NumExpiredFrames);
            end
        end

        % Get total number of remaining frames
        function totalNumRemainingFrames = getNumRemainingFrames(obj)
            totalNumRemainingFrames = Counts();
            for i = 1 : length(obj.Stations)
                totalNumRemainingFrames.add(obj.Stations{i}.getNumRemainingFrames())
            end
        end
    end
end

