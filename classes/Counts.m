classdef Counts < handle
    properties
        Heartbeat
        Plc
        Robot
        Arvr
        Camera
        Worker
    end

    methods
        function obj = Counts(Heartbeat, Plc, Robot, Arvr, Camera, Worker)
            if nargin > 0
                obj.Heartbeat = Heartbeat;
                obj.Plc = Plc;
                obj.Robot = Robot;
                obj.Arvr = Arvr;
                obj.Camera = Camera;
                obj.Worker = Worker;
            else
                obj.Heartbeat = 0;
                obj.Plc = 0;
                obj.Robot = 0;
                obj.Arvr = 0;
                obj.Camera = 0;
                obj.Worker = 0;
            end
        end

        function increment(obj, type)
            switch type
                case "heartbeat"
                    obj.Heartbeat = obj.Heartbeat + 1;
                case "plc"
                    obj.Plc = obj.Plc + 1;
                case "robot"
                    obj.Robot = obj.Robot + 1;
                case "arvr"
                    obj.Arvr = obj.Arvr + 1;                
                case "camera"
                    obj.Camera = obj.Camera + 1;               
                case "worker"
                    obj.Worker = obj.Worker + 1;
                otherwise
                    disp('Invalid frame type!')
            end
        end

        function add(obj, other)
            obj.Heartbeat = obj.Heartbeat + other.Heartbeat;
            obj.Plc = obj.Plc + other.Plc;
            obj.Robot = obj.Robot + other.Robot;
            obj.Arvr = obj.Arvr + other.Arvr;
            obj.Camera = obj.Camera + other.Camera;
            obj.Worker = obj.Worker + other.Worker;
        end

        function subtract(obj, other)
            obj.Heartbeat = obj.Heartbeat - other.Heartbeat;
            obj.Plc = obj.Plc - other.Plc;
            obj.Robot = obj.Robot - other.Robot;
            obj.Arvr = obj.Arvr - other.Arvr;
            obj.Camera = obj.Camera - other.Camera;
            obj.Worker = obj.Worker - other.Worker;
        end
        
        function divide(obj, other)
            obj.Heartbeat = obj.Heartbeat / other.Heartbeat;
            obj.Plc = obj.Plc / other.Plc;
            obj.Robot = obj.Robot / other.Robot;
            obj.Arvr = obj.Arvr / other.Arvr;
            obj.Camera = obj.Camera / other.Camera;
            obj.Worker = obj.Worker / other.Worker;
        end 

        function n = total(obj)
            n = obj.Heartbeat + obj.Plc + obj.Robot + obj.Arvr + obj.Camera + obj.Worker;
        end

        function table = toTable(obj)
            temp = struct();
            temp.Heartbeat = obj.Heartbeat;
            temp.Plc = obj.Plc;
            temp.Robot = obj.Robot;
            temp.Arvr = obj.Arvr;
            temp.Camera = obj.Camera;
            temp.Worker = obj.Worker;
            table = struct2table(temp);
        end
    end
end