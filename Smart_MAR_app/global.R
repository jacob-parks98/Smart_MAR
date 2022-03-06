library(tidyverse)

conditions_drugs <- read_csv('Data_for_app/fullconditions2.csv')

side_effects <- read_csv('Data_for_app/SE_df_update2.csv')

side_effects<- side_effects %>%
  select(-c(`Unnamed: 0`, `...1`))

choke_food <- read_csv('Data_for_app/choke_foods.csv')

fall_risk_food <- read_csv('Data_for_app/fall_foods.csv')

skin_breakdown_food <- read_csv('Data_for_app/skin_break_food.csv')

 skin_breakdown_food <- skin_breakdown_food %>%
  select(-c(...1,AVG)) 

side_effects$Risk_factor[side_effects$Risk_factor == 'nan'] <- 'None'

pregnancy_symbols <-  c("A","B","C","D","X","N")

pregnancy_meanings <- c("Adequate and well-controlled studies have failed to demonstrate a risk to the fetus in the first trimester of pregnancy (and there is no evidence of risk in later trimesters)",
                        "Animal reproduction studies have failed to demonstrate a risk to the fetus and there are no adequate and well-controlled studies in pregnant women.",
                        "Animal reproduction studies have shown an adverse effect on the fetus and there are no adequate and well-controlled studies in humans, but potential benefits may warrant use in pregnant women despite potential risks.",
                        "There is positive evidence of human fetal risk based on adverse reaction data from investigational or marketing experience or studies in humans, but potential benefits may warrant use in pregnant women despite potential risks.",
                        "Studies in animals or humans have demonstrated fetal abnormalities and/or there is positive evidence of human fetal risk based on adverse reaction data from investigational or marketing experience, and the risks involved in use in pregnant women clearly outweigh potential benefits.",
                        "FDA has not classified the drug.")

preg_symbols <- tibble(Symbol = pregnancy_symbols, Definition = pregnancy_meanings)

