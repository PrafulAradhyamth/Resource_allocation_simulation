classdef Queue < handle
    properties
        Data
    end
    
    methods
        % Constructor
        function obj = Queue()
            obj.Data = {};
        end
        
        % Enqueue method to add an element to the queue
        function enqueue(obj, element)
            obj.Data{end+1} = element;
        end
        
        % Dequeue method to remove an element from the queue
        function element = dequeue(obj)
            if obj.isEmpty()
                error('Queue is empty');
            end
            element = obj.Data{1};
            obj.Data(1) = [];
        end
        
        % Peek method to view the first element without removing it
        function element = peek(obj)
            if obj.isEmpty()
                error('Queue is empty');
            end
            element = obj.Data{1};
        end
        
        % isEmpty method to check if the queue is empty
        function tf = isEmpty(obj)
            tf = isempty(obj.Data);
        end
        
        % Size method to get the number of elements in the queue
        function n = size(obj)
            n = numel(obj.Data);
        end
        
        % Remove element at position i
        function removeAt(obj, i)
            if i < 1 || i > obj.size()
                error('Index out of bounds');
            end
            obj.Data(i) = [];
        end

        % Display 
        function disp(obj)
            disp('Queue contents:');
            % disp(obj.Data)
            for i = 1 : obj.size()
                disp(obj.Data{i})
            end
        end
    end
end
