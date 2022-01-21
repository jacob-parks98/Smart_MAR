#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(DT)
library(shinythemes)

shinyUI(navbarPage("Smart MAR",
                   theme = shinytheme('sandstone'),
                   
                   tabPanel(icon('home'),
                            mainPanel(
                              h2('Summary'),
                              h4("This app was created to assist the Tennessee Department of Intellectual and Developmental Disabilities 
                                         in better using data to influence decisions. Using data from the FDA and drugs.com, the app allows users
                                         to select medical conditions and drugs to see any possible adverse reactions and risks that their patients,
                                         who may not be able to advocate for themselves, might be suffering from. Additionally, the app allows users
                                         to see foods that may help in mitigating risks associated with certain drugs. This will allow users to keep better records
                                         and improve overall patient care."),
                              h3("Pregnancy Symbols"),
                                       tableOutput('preg'))
                            
                            ),
                   
                   
                   tabPanel('Side Effects and Conditions',
                            sidebarPanel(
                              selectInput("cond",
                                          "Select One or More Conditions:",
                                          conditions_drugs$Condition,
                                          multiple = TRUE,
                                          selectize = TRUE
                              ),
                              
                              selectInput("drug",
                                          "Select One or More drugs:",
                                          unique(side_effects$webscraping_name),
                                          multiple = TRUE,
                                          selectize = TRUE
                              ),
                              
                              actionButton('debug', 'Debug')
                            ),
                            
                            
                            mainPanel(
                              fluidRow(h4(textOutput('conditionsnumber')),h4(textOutput('drugnumber')), style = 'height:7vh'),
                              fluidRow(DT::dataTableOutput("conditions")),
                              fluidRow(column(width = 6,
                                              DT::dataTableOutput('sidefx')),
                                       column(width = 6,
                                              # selectInput("drug",
                                              #             "Select One or More drugs:",
                                              #             unique(side_effects$webscraping_name),
                                              #             multiple = TRUE,
                                              #             selectize = TRUE),
                                              plotOutput('bar')))
                            )),
                   
                   tabPanel('Food and Risks',
                            sidebarPanel(selectInput("drugz",
                                                     "Select One or More drugs:",
                                                     unique(side_effects$webscraping_name),
                                                     multiple = TRUE,
                                                     selectize = TRUE),
                                         selectInput('risk',
                                                     'Select Risk factor for foods:',
                                                     unique((side_effects %>%
                                                               filter(Risk_factor != 'None'))$Risk_factor,
                                                            selectize = TRUE)),
                                         downloadButton('download','Download Report')
                            ),
                            
                  mainPanel(
                    fluidRow(DT::dataTableOutput('sideeffects')),
                    fluidRow(
                      column(width = 4, DT::dataTableOutput('risk')),
                      column(width = 8, DT::dataTableOutput('food'))
                             ))
                  )   
                   )
)
