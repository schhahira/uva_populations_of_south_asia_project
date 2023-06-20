library(bigrquery)
library(tidyverse)

# set up bigquery connection 
census_world <- dbConnect(
  bigrquery::bigquery(),
  project = "bigquery-public-data",
  dataset = "census_bureau_international",
  billing = "stat-3280-final-project-385700"
)

dbListTables(census_world)

########################################################################################################################

# life expectancy data 
sa_life_exp <- tbl(census_world, "mortality_life_expectancy")
sa_life_exp %>% count() %>% collect()

# SQL code 

#SELECT country_code, country_name, year, life_expectancy, life_expectancy_male, life_expectancy_female
#FROM bigquery-public-data.census_bureau_international.mortality_life_expectancy
#WHERE country_name IN ("India", "Pakistan", "Sri Lanka", "Nepal", "Bhutan", "Bangladesh", "Maldives", "Afghanistan")
#AND year <= 2023 
#ORDER BY country_name, year;

life_exp_table <- sa_life_exp %>% filter(country_name == "India" |
                                           country_name == "Pakistan" |
                                           country_name == "Sri Lanka" |
                                           country_name == "Nepal" |
                                           country_name == "Bhutan" | 
                                           country_name == "Bangladesh" |
                                           country_name == "Maldives" | 
                                           country_name == "Afghanistan") %>% 
  filter(year <= 2023) %>%
  select(country_code, country_name, year, life_expectancy, life_expectancy_male, life_expectancy_female) %>% collect()

########################################################################################################################

# south asia sqkm 
sa_sqkm <- tbl(census_world, "country_names_area")

# SQL code 
#SELECT *
 # FROM bigquery-public-data.census_bureau_international.country_names_area
#WHERE country_name IN ("India", "Pakistan", "Sri Lanka", "Nepal", "Bhutan", "Bangladesh", "Maldives", "Afghanistan")
#ORDER BY country_name;

sqkm_table <- sa_sqkm %>% filter(country_name == "India" |
                                   country_name == "Pakistan" |
                                   country_name == "Sri Lanka" |
                                   country_name == "Nepal" |
                                   country_name == "Bhutan" | 
                                   country_name == "Bangladesh" |
                                   country_name == "Maldives" | 
                                   country_name == "Afghanistan") %>% collect()

########################################################################################################################

# south asia birth/growth rates 
sa_bg_rates <- tbl(census_world, "birth_death_growth_rates")

# SQL code 
#SELECT *
 # FROM bigquery-public-data.census_bureau_international.birth_death_growth_rates
#WHERE country_name IN ("India", "Pakistan", "Sri Lanka", "Nepal", "Bhutan", "Bangladesh", "Maldives", "Afghanistan")
#AND year <= 2023 
#ORDER BY country_name, year;

bg_rates_table <- sa_bg_rates %>% filter(country_name == "India" |
                                           country_name == "Pakistan" |
                                           country_name == "Sri Lanka" |
                                           country_name == "Nepal" |
                                           country_name == "Bhutan" | 
                                           country_name == "Bangladesh" |
                                           country_name == "Maldives" | 
                                           country_name == "Afghanistan") %>%
  filter(year <= 2023) %>% collect()

########################################################################################################################

# south asia midyear pop 
sa_mid_pop <- tbl(census_world, "midyear_population")

# SQL code 
#SELECT *
# FROM bigquery-public-data.census_bureau_international.midyear_population
#WHERE country_name IN ("India", "Pakistan", "Sri Lanka", "Nepal", "Bhutan", "Bangladesh", "Maldives", "Afghanistan")
#AND year <= 2023 
#ORDER BY country_name, year;

mid_pop_table <- sa_mid_pop %>% filter(country_name == "India" |
                                         country_name == "Pakistan" |
                                         country_name == "Sri Lanka" |
                                         country_name == "Nepal" |
                                         country_name == "Bhutan" | 
                                         country_name == "Bangladesh" |
                                         country_name == "Maldives" | 
                                         country_name == "Afghanistan") %>%
  filter(year <= 2023) %>% collect()

########################################################################################################################

# life expectancy data 
sa_avg_age <- tbl(census_world, "midyear_population_agespecific")

# SQL code 

#SELECT country_code, country_name, year, life_expectancy, life_expectancy_male, life_expectancy_female
#FROM bigquery-public-data.census_bureau_international.mortality_life_expectancy
#WHERE country_name IN ("India", "Pakistan", "Sri Lanka", "Nepal", "Bhutan", "Bangladesh", "Maldives", "Afghanistan")
#AND year <= 2023 
#ORDER BY country_name, year;

avg_age_table <- sa_avg_age %>% filter(country_name == "India" |
                                           country_name == "Pakistan" |
                                           country_name == "Sri Lanka" |
                                           country_name == "Nepal" |
                                           country_name == "Bhutan" | 
                                           country_name == "Bangladesh" |
                                           country_name == "Maldives" | 
                                           country_name == "Afghanistan") %>% 
  filter(year >= 1992 & year <= 2022) %>%
  group_by(country_name, year, age) %>% summarise(age_sum = sum(population)) %>% collect()

########################################################################################################################

# write data to csv files 
# setwd("C:/Users/Student/Documents/UVA/4th Year/Spring 2023/STAT 3280/Final Project")
write.csv(life_exp_table,"sa_life_expectancy_table.csv")
write.csv(sqkm_table,"sa_sqkm_table.csv")
write.csv(bg_rates_table,"sa_birth_growth_rates_table.csv")
write.csv(mid_pop_table,"sa_midyear_pop_table.csv")
write.csv(avg_age_table,"sa_avg_age_table.csv")

########################################################################################################################

# avg age calculation 

age_table2 <- read.csv("sa_avg_age_table.csv")
unique(age_table2$age)

age_table3 <- age_table2 %>% mutate(age_table2, avg_age_total = age_table2$age*age_table2$age_sum)
View(age_table3)

age_table4 <- age_table3 %>% group_by(country_name, year) %>% summarise(avg_age = sum(avg_age_total)/sum(age_sum))
View(age_table4)

write.csv(age_table4,"new_sa_avg_age_table.csv")

