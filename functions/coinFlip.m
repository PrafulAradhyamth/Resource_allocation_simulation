function result = coinFlip(probability)
% Check if the input probability is valid
if probability < 0 || probability > 1
    error('Probability must be between 0 and 1');
end
% Generate a random number between 0 and 1
randomNumber = rand();
% Compare the random number with the input probability
result = randomNumber < probability;
end