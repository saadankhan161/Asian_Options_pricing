function [callPrice, putPrice, callPayoff, putPayoff, S,discountFactor] = AsianOptionPricing(S0, K, r, T, sigma, N, M, type,useControlVariate)
% AsianOptionPricing - Estimates call and put prices for Asian options using Monte Carlo simulations
% Inputs:
% S0 : Initial stock price
% K : Strike price
% r : Risk-free interest rate
% T : Time to maturity
% sigma : Volatility
% N : Number of time steps
% M : Number of simulated paths
% type : 'arithmetic' or 'geometric'

% The time step (dt) based on the total time to maturity (T) and number of time steps (N)
dt = T/N;

% Initialize a matrix (S) to store simulated stock prices
% Rows represent time steps and columns represent different simulation paths
S = zeros(N+1, M);

% This sets the initial stock price for all paths
S(1, :) = S0;

% Simulate stock prices using geometric Brownian motion (GBM)
for i = 1:N
    
    % Generate random numbers (dW) to model the stochastic process in the stock price
    dW = sqrt(dt) * randn(1, M);
    
    % Updating the stock prices using GBM
    S(i+1, :) = S(i, :) .* exp((r - 0.5 * sigma^2) * dt + sigma * dW);
end

% Calculate the average stock price for each simulation path
% depending on the chosen averaging method: 'arithmetic' or 'geometric'
if strcmp(type, 'arithmetic')
    A = mean(S(2:end, :));
elseif strcmp(type, 'geometric')
    A = exp(mean(log(S(2:end, :))));
else
    error('Invalid type. Choose either ''arithmetic'' or ''geometric''.');
end


% The option payoffs for both call and put options
callPayoff = max(A - K, 0);

putPayoff = max(K - A, 0);

% Discount the payoffs to the present value using the risk-free interest rate (r) and time to maturity (T)
discountFactor = exp(-r * T);

% Calculate the average discounted payoffs as the option prices for both call and put options
callPrice = discountFactor * mean(callPayoff);

putPrice = discountFactor * mean(putPayoff);


%Calling the european option pricing formula for variate control
[europeanCallPrice, europeanPutPrice] = EuropeanOptionPricing(S0, K, r, T, sigma);

% Payoffs for European options
europeanCallPayoff = max(S(end, :) - K, 0);
europeanPutPayoff = max(K - S(end, :), 0);

if useControlVariate
    % Covariance and variance for call options
    covarianceCall = cov(callPayoff, europeanCallPayoff);
    varianceCall = var(europeanCallPayoff);

    % The optimal constant for call options
    cCall = -covarianceCall(1, 2) / varianceCall;

    % Adjust the call payoffs using the control variate
    callPayoff = callPayoff + cCall * (europeanCallPayoff - europeanCallPrice);

    % Covariance and variance for put options
    covariancePut = cov(putPayoff, europeanPutPayoff);
    variancePut = var(europeanPutPayoff);

    % The optimal constant for put options
    cPut = -covariancePut(1, 2) / variancePut;

    % Adjust the put payoffs using the control variate
    putPayoff = putPayoff + cPut * (europeanPutPayoff - europeanPutPrice);
    
    % Average discounted payoffs as the option prices for both call and put options
    callPrice = discountFactor * mean(callPayoff);
    
    putPrice = discountFactor * mean(putPayoff);


end




end


