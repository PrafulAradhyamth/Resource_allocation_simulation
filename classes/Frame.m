classdef Frame < handle
    properties
        Id
        FrameSize
        TimeSinceGeneration % in microseconds 
        MaximumLatency  % in microseconds
        Type
    end

    methods
        % Constructor
        function obj = Frame(FrameSize, TimeSinceGeneration, MaximumLatency, Type)
            obj.Id = generateUniqueID(datetime('now'));
            if nargin > 0
                obj.FrameSize = FrameSize;
                obj.TimeSinceGeneration = TimeSinceGeneration;
                obj.MaximumLatency = MaximumLatency;
                obj.Type = Type;
            end
        end
        
        % Increase TimeSinceGeneration by 1 
        function increaseTimeSinceGeneration(obj)
            obj.TimeSinceGeneration = obj.TimeSinceGeneration + 1;
        end
        
        % Check if frame has expired
        % TimeSinceGeneration == MaximumLatency
        function tf = hasExpired(obj)
            if obj.TimeSinceGeneration == obj.MaximumLatency
                tf = true;
            else
                tf = false;
            end
        end

        % Display
        function disp(obj)
            disp("### FRAME ###")
            fprintf("Id: %s \n", obj.Id);
            fprintf("Frame size: %d B \n", obj.FrameSize);
            fprintf("Time since generation: %d microseconds \n", obj.TimeSinceGeneration);
            fprintf("Maximum latency: %d microseconds \n", obj.MaximumLatency);
            fprintf("Type: %s \n", obj.Type);
        end
    end
end

% Helper function to generate a unique ID based on time
function uniqueID = generateUniqueID(creationTime)
% Convert datetime to a formatted string
formattedTime = datestr(creationTime, 'yyyymmddTHHMMSSFFF');
% Create a unique ID by concatenating 'ID_' with the formatted time
uniqueID = ['ID_', formattedTime];
end