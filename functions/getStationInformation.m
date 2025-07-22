function stationInformation = getStationInformation(Stations)
% Define empty stationInformation table
stationInformation = table([], [], [], [], [], 'VariableNames', {'Station', 'FrameSize', 'TimeSinceGeneration', 'MaximumLatency', 'Type'});

for i = 1 : length(Stations)
    if Stations{i}.Buffer.isEmpty()
        continue;
    end
    frame = Stations{i}.Buffer.peek();
    row = table(Stations{i}.Id, frame.FrameSize, frame.TimeSinceGeneration, frame.MaximumLatency, {frame.Type}, 'VariableNames', {'Station', 'FrameSize', 'TimeSinceGeneration', 'MaximumLatency', 'Type'});
    % Append row to stationInformation table
    stationInformation = [stationInformation; row];
end
end