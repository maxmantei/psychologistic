library(tidyverse)
library(rstan)
options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)
library(tidybayes)

# Load data

toydata <- read_csv("data/toydata.csv")

names(toydata) <- c("subject_id", paste0("block_", names(toydata)[2:15]))
toydata <- toydata %>% mutate(subject_id = 1:n())
data_mat <- toydata %>% select(starts_with("block")) %>% as.matrix()


data_list <- list(
  N = nrow(data_mat),
  T = ncol(data_mat),
  y = data_mat
)

# Run models

mod0 <- stan(file = "model/mod0.stan", data = data_list)
mod1 <- stan(file = "model/mod1.stan", data = data_list)
mod2 <- stan(file = "model/mod2.stan", data = data_list)
mod3 <- stan(file = "model/mod3.stan", data = data_list)
mod4 <- stan(file = "model/mod4.stan", data = data_list)

# Print results

mod0
mod1
mod2
mod3
mod4

# Extract results for plotting

m0 <- spread_draws(mod0, performance)
m1 <- spread_draws(mod1, performance[subject_id])
m2 <- spread_draws(mod2, performance[subject_id, block])
m3 <- spread_draws(mod3, performance[subject_id, block])
m4 <- spread_draws(mod4, performance[subject_id, block])

# Prepare data for plotting

plot_data <- toydata %>% 
  pivot_longer(cols = starts_with("block"), 
               names_to = "block", 
               names_prefix = "block_", 
               values_to = "correct") %>% 
  mutate(block = as.numeric(block),
         performance_point = correct / 8)

# Plot m1 - m4

plot_data %>%
  right_join(median_qi(m1, .width = c(.95, .9, .8, .5))) %>%
  ggplot(aes(y = performance, x = block)) +
    geom_interval() +
    geom_point(aes(y = performance_point)) +
    scale_color_brewer(palette = 1) +
    facet_wrap(~subject_id)

plot_data %>%
  right_join(median_qi(m2, .width = c(.95, .9, .8, .5))) %>%
  ggplot(aes(y = performance, x = block)) +
    geom_interval() +
    geom_point(aes(y = performance_point)) +
    scale_color_brewer(palette = 1) +
    facet_wrap(~subject_id)

plot_data %>%
  right_join(median_qi(m3, .width = c(.95, .9, .8, .5))) %>%
  ggplot(aes(y = performance, x = block)) +
    geom_lineribbon() +
    geom_point(aes(y = performance_point)) +
    scale_fill_brewer(palette = 1) +
    facet_wrap(~subject_id)

plot_data %>%
  right_join(median_qi(m4, .width = c(.95, .9, .8, .5))) %>%
  ggplot(aes(y = performance, x = block)) +
    geom_lineribbon() +
    geom_point(aes(y = performance_point)) +
    scale_fill_brewer(palette = 1) +
    facet_wrap(~subject_id)
