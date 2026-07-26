library(tidyverse)
df <- read.csv("Capstone.csv", header = FALSE, skip = 1)

# Row indices: 3 = White, 4 = Black, 5 = Hispanic/Latino (from inspection)
race_data <- df[3:5, c(3, 6:13)]  # Race column and transplant years 2025–2018


colnames(race_data) <- c("Race", "2025", "2024", "2023", "2022", "2021", "2020", "2019", "2018")


race_data[ , 2:9] <- lapply(race_data[ , 2:9], function(x) as.numeric(gsub(",", "", x)))


long_data <- pivot_longer(race_data,
                          cols = -Race,
                          names_to = "Year",
                          values_to = "Transplants")

long_data$Year <- as.numeric(long_data$Year)

ggplot(long_data, aes(x = Year, y = Transplants, color = Race)) +
  geom_line(size = 1.2) +
  geom_point() +
  labs(title = "Transplant Volumes by Race/Ethnicity (2018–2025)",
       x = "Year", y = "Number of Transplants")

long_data %>%
  group_by(Race) %>%
  summarise(Average = mean(Transplants),
            Max = max(Transplants),
            Min = min(Transplants),
            SD = sd(Transplants))

## ---------------------------------------

# Load libraries
library(tidyverse)

# Load dataset
df <- read.csv("Capstone.csv", header = FALSE, skip = 1)

# === STEP 1: EXTRACT TOTAL AND DECEASED DONOR DATA ===

# Get total transplants for 3 races
total_data <- df[3:5, c(3, 6:13)]  # Races, 2025–2018 columns for All Donor Types
colnames(total_data) <- c("Race", "2025", "2024", "2023", "2022", "2021", "2020", "2019", "2018")
total_data[ , 2:9] <- lapply(total_data[ , 2:9], function(x) as.numeric(gsub(",", "", x)))
total_long <- pivot_longer(total_data, cols = -Race, names_to = "Year", values_to = "Total_Transplants")
total_long$Year <- as.numeric(total_long$Year)

# Get deceased donor transplants
deceased_data <- df[3:5, c(3, 15:22)]
colnames(deceased_data) <- c("Race", "2025", "2024", "2023", "2022", "2021", "2020", "2019", "2018")
deceased_data[ , 2:9] <- lapply(deceased_data[ , 2:9], function(x) as.numeric(gsub(",", "", x)))
deceased_long <- pivot_longer(deceased_data, cols = -Race, names_to = "Year", values_to = "Deceased_Transplants")
deceased_long$Year <- as.numeric(deceased_long$Year)

# === STEP 2: JOIN THE TWO TO CREATE A COMBINED DATASET ===

combined <- left_join(total_long, deceased_long, by = c("Race", "Year"))
combined <- combined %>%
  mutate(Living_Transplants = Total_Transplants - Deceased_Transplants)

# === STEP 3: PLOT COMPARISON OF DONOR TYPES BY RACE ===

# Plot total vs deceased vs living transplants (optional: facet by Race)
ggplot(combined, aes(x = Year)) +
  geom_line(aes(y = Total_Transplants, color = "Total"), size = 1) +
  geom_line(aes(y = Deceased_Transplants, color = "Deceased"), linetype = "dashed", size = 1) +
  geom_line(aes(y = Living_Transplants, color = "Living"), linetype = "dotted", size = 1) +
  facet_wrap(~ Race) +
  labs(title = "Transplant Volumes by Donor Type (2018–2025)",
       y = "Number of Transplants",
       color = "Donor Type") +
  theme_minimal()

# === STEP 4: Summary for disparities ===

combined %>%
  group_by(Race) %>%
  summarise(
    Avg_Total = mean(Total_Transplants),
    Avg_Deceased = mean(Deceased_Transplants),
    Avg_Living = mean(Living_Transplants)
  )
## -------------------------------------------------

# Total transplants by race
race_total <- df[3:5, c(3, 6:13)]
colnames(race_total) <- c("Race", "2025", "2024", "2023", "2022", "2021", "2020", "2019", "2018")
race_total[ , 2:9] <- lapply(race_total[ , 2:9], function(x) as.numeric(gsub(",", "", x)))
race_long <- pivot_longer(race_total, cols = -Race, names_to = "Year", values_to = "Total_Transplants")
race_long$Year <- as.numeric(race_long$Year)

# Deceased donors by race
race_deceased <- df[3:5, c(3, 15:22)]
colnames(race_deceased) <- c("Race", "2025", "2024", "2023", "2022", "2021", "2020", "2019", "2018")
race_deceased[ , 2:9] <- lapply(race_deceased[ , 2:9], function(x) as.numeric(gsub(",", "", x)))
race_deceased_long <- pivot_longer(race_deceased, cols = -Race, names_to = "Year", values_to = "Deceased_Transplants")
race_deceased_long$Year <- as.numeric(race_deceased_long$Year)

# Merge and calculate living donor volumes
race_combined <- left_join(race_long, race_deceased_long, by = c("Race", "Year")) %>%
  mutate(Living_Transplants = Total_Transplants - Deceased_Transplants)

# === AGE-BASED TRANSPLANTS ===

# Extract rows for age groups — adjust rows 6:12 if needed
age_total <- df[6:12, c(1, 6:13)]
colnames(age_total) <- c("AgeGroup", "2025", "2024", "2023", "2022", "2021", "2020", "2019", "2018")
age_total[ , 2:9] <- lapply(age_total[ , 2:9], function(x) as.numeric(gsub(",", "", x)))
age_long <- pivot_longer(age_total, cols = -AgeGroup, names_to = "Year", values_to = "Total_Transplants")
age_long$Year <- as.numeric(age_long$Year)

# === VISUALIZATION ===

# Plot by race and donor type
ggplot(race_combined, aes(x = Year)) +
  geom_line(aes(y = Total_Transplants, color = "Total")) +
  geom_line(aes(y = Deceased_Transplants, color = "Deceased"), linetype = "dashed") +
  geom_line(aes(y = Living_Transplants, color = "Living"), linetype = "dotted") +
  facet_wrap(~ Race) +
  labs(title = "Transplants by Race and Donor Type (2018–2025)",
       y = "Number of Transplants", color = "Donor Type") +
  theme_minimal()

# Plot by age group
ggplot(age_long, aes(x = Year, y = Total_Transplants, color = AgeGroup)) +
  geom_line(size = 1.2) +
  geom_point() +
  labs(title = "Transplants by Age Group (2018–2025)",
       y = "Number of Transplants") +
  theme_minimal()

# === OPTIONAL: Summary Statistics ===

# Race disparities
race_combined %>%
  group_by(Race) %>%
  summarise(Average = mean(Total_Transplants),
            Max = max(Total_Transplants),
            Min = min(Total_Transplants),
            SD = sd(Total_Transplants))

# Age disparities
age_long %>%
  group_by(AgeGroup) %>%
  summarise(Average = mean(Total_Transplants),
            Max = max(Total_Transplants),
            Min = min(Total_Transplants),
            SD = sd(Total_Transplants))

race_combined %>%
  group_by(Race) %>%
  summarise(Average = mean(Total_Transplants),
            Max = max(Total_Transplants),
            Min = min(Total_Transplants),
            SD = sd(Total_Transplants))

library(dplyr)

race_combined %>%
  group_by(Race) %>%
  arrange(Year) %>%
  mutate(Change_Percent = (Total_Transplants - lag(Total_Transplants)) / lag(Total_Transplants) * 100)

race_totals_by_year <- race_combined %>%
  group_by(Year) %>%
  mutate(Percent = Total_Transplants / sum(Total_Transplants) * 100)

ggplot(race_combined, aes(x = Year, y = Deceased_Transplants, color = Race)) +
  geom_line(size = 1.2) +
  labs(title = "Deceased Donor Transplants by Race", y = "Deceased Transplants")


