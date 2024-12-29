# Load necessary libraries
library(tidyverse)
library(broom)
library(sandwich)
library(lmtest)
library(haven)

# Import data
data <- read_dta("pwt1001.dta")

# Display first few rows of the dataset
head(data)

# Descriptive statistics
summary(data)

# Scatterplot of the variables (e.g., Y vs X)
ggplot(data, aes(x = X, y = Y)) +
  geom_point() +
  geom_smooth(method = "lm", col = "blue") +
  labs(title = "Scatterplot with Regression Line",
       x = "X Variable",
       y = "Y Variable")

# Run a simple linear regression
model <- lm(Y ~ X, data = data)

# Summary of the regression model
summary(model)

# Extract coefficients
tidy(model)

# Compute robust standard errors
robust_se <- coeftest(model, vcov = vcovHC(model, type = "HC1"))

# Display robust standard errors
print(robust_se)

# Check model diagnostics (e.g., residuals)
par(mfrow = c(2, 2))
plot(model)

# Save model outputs to a file
write.csv(tidy(model), "model_summary.csv")

# Save a diagnostic plot
png("diagnostic_plot.png")
par(mfrow = c(2, 2))
plot(model)
dev.off()
