function [callPrice, putPrice] = EuropeanOptionPricing(S0, K, r, T, sigma)

%S0 = Initial stock price
%K = Strike price
%r = risk free interest rate
%T = time to maturity
%sigma = volatility

%The intermediate values d1 and d2
d1 = (log(S0/K) + (r + 0.5 * sigma^2) * T) / (sigma * sqrt(T));

d2 = d1 - sigma * sqrt(T);

%Calculating the cumululative distribution function of a standard normal
%distribution
normcdf_d1 = 0.5 * (1 + erf(d1 / sqrt(2)));

normcdf_d2 = 0.5 * (1 + erf(d2 / sqrt(2)));

normcdf_minus_d1 = 0.5 * (1 + erf(-d1 / sqrt(2)));

normcdf_minus_d2 = 0.5 * (1 + erf(-d2 / sqrt(2)));

%Calculating the call and put price
callPrice = S0 * normcdf_d1 - K * exp(-r * T) * normcdf_d2;

putPrice = K * exp(-r * T) * normcdf_minus_d2 - S0 * normcdf_minus_d1;
end
