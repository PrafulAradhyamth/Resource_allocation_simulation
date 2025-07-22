function counts = getTypeCountsFromTable(table)
conditionHeartbeat = strcmp(table.Type, 'heartbeat');
conditionPlc = strcmp(table.Type, 'plc');
conditionRobot = strcmp(table.Type, 'robot');
conditionArvr = strcmp(table.Type, 'arvr');
conditionCamera = strcmp(table.Type, 'camera');
conditionWorker = strcmp(table.Type, 'worker');
% Create a Counts object
counts = Counts(sum(conditionHeartbeat), sum(conditionPlc), sum(conditionRobot), sum(conditionArvr), sum(conditionCamera), sum(conditionWorker));
end