data{
  int<lower=1> N;
  int<lower=1> T;
  int<lower=0, upper=8> y[N, T];
}

transformed data{
  int<lower=1, upper=8> trials[N ,T];
  
  for(t in 1:T)
    for(n in 1:N)
      trials[n, t] = 8;
  
}

parameters{
  real<lower=0,upper=1> performance[N, T];
}

model{
  
  for(n in 1:N)
    for(t in 1:T)
      y[n, t] ~ binomial(trials[n, t], performance[n, t]);
  
}

