function [sol, fval] = optimProbSinglePPDU(numSTA, costMatrix)
% Solves optimization problem for a single PPDU. Takes as arguments
% - number of stations
% - cost matrix

% Create optimization problem
assignment_problem = optimproblem;
% Define optimization variables
x = optimvar('x', numSTA, numSTA, 'Type', 'integer', 'LowerBound', 0, 'UpperBound', 1);
z = optimvar('z');
% Set objective function (cost)
assignment_problem.Objective = z;

% Constraint 1
constraints = [];
for i = 1:numSTA
    for j = 1 : numSTA   % numRU = numSTA
        constraint = z >= costMatrix(i, j)*x(i, j);
        constraints = [constraints, constraint];
    end
end
assignment_problem.Constraints.const_1 = constraints;

% Constraint 2
constraints = [];
for j = 1 : numSTA
    xsum = 0;
    for i = 1 : numSTA
        xsum = xsum + x(i, j);
    end
    constraint = xsum == 1;
    constraints = [constraints, constraint];
end
assignment_problem.Constraints.const_2 = constraints;

% Constraint 3
constraints = [];
for i = 1 : numSTA
    xsum = 0;
    for j = 1 : numSTA
        xsum = xsum + x(i, j);
    end
    constraint = xsum == 1;
    constraints = [constraints, constraint];
end
assignment_problem.Constraints.const_3 = constraints;

% Solve optimization problem
opts = optimoptions('intlinprog','Display','off');
[sol,fval] = solve(assignment_problem, "Options", opts);
end