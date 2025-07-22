classdef Station < handle
    properties
        Id
        FrameArrivalProbability % [60 fps, 250 fps]
        Buffer
        NumGeneratedFrames
        NumExpiredFrames
    end

    methods
        % Constructor
        function obj = Station(Id, FrameArrivalProbability)
            if nargin > 0
                obj.Id = Id;
                obj.FrameArrivalProbability = FrameArrivalProbability;
            end
            obj.Buffer = Queue();
            obj.NumGeneratedFrames = Counts();
            obj.NumExpiredFrames = Counts();
        end

        % Step method
        function step(obj)
            % Flip a coin for a new frame (category: camera, arvr or
            % worker; 60 fps)
            if coinFlip(obj.FrameArrivalProbability(1))
                % Generate new random frame
                newFrame = generateFrame_60fps();
                
                % Display message
                fprintf("Message: New frame arrived in the buffer of station %d! \n", obj.Id);
                disp(newFrame);
                
                % Add frame to buffer
                obj.Buffer.enqueue(newFrame);
                
                % Increment NumGeneratedFrames
                obj.NumGeneratedFrames.increment(newFrame.Type);
            end

            % Flip a coin for a new frame (category: heartbeat, plc or
            % robot; 250 fps)
            if coinFlip(obj.FrameArrivalProbability(2))
                % Generate new random frame
                newFrame = generateFrame_250fps();
                
                % Display message
                fprintf("Message: New frame arrived in the buffer of station %d! \n", obj.Id);
                disp(newFrame);
                
                % Add frame to buffer
                obj.Buffer.enqueue(newFrame);
                
                % Increment NumGeneratedFrames
                obj.NumGeneratedFrames.increment(newFrame.Type);
            end

            % Increase TimeSinceGeneration of the frames in the buffer by 1
            indicesToRemove = [];
            for i = 1 : size(obj.Buffer)
                obj.Buffer.Data{i}.increaseTimeSinceGeneration();
                
                % Collect indices of frames that have expired
                % (TimeSinceGeneration == MaximumLatency)
                if obj.Buffer.Data{i}.hasExpired()
                    indicesToRemove(end+1) = i;
                    
                    % Increment NumExpiredFrames
                    obj.NumExpiredFrames.increment(obj.Buffer.Data{i}.Type);
                end
            end

            % Remove frames at the collected indices
            for i = numel(indicesToRemove):-1:1
                obj.Buffer.removeAt(indicesToRemove(i));
            end

            % Display message
            if numel(indicesToRemove) > 0
                fprintf("Message: %d frame(s) expired in the buffer of station %d! \n", numel(indicesToRemove), obj.Id);
            end
        end

        % Get number of remaining frames in the buffer
        function numRemainingFrames = getNumRemainingFrames(obj)
            numRemainingFrames = Counts();
            while ~obj.Buffer.isEmpty()
                frame = obj.Buffer.dequeue();
                numRemainingFrames.increment(frame.Type);
            end
        end

        % Display
        function disp(obj)
            disp(obj.Buffer);
        end
    end
end