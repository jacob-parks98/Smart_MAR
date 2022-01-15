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
# Define UI for application that draws a histogram
shinyUI(navbarPage("Smart MAR",
                   
                   # Application title
                   
                   
                   # Sidebar with a slider input for number of bins
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
                            
                            # Show a plot of the generated distribution
                            mainPanel(
                              fluidRow(DT::dataTableOutput("conditions")),
                              fluidRow(column(width = 6,
                                              DT::dataTableOutput('sidefx')),
                                       column(width = 6,
                                              selectInput("drug",
                                                          "Select One or More drugs:",
                                                          unique(side_effects$webscraping_name),
                                                          multiple = TRUE,
                                                          selectize = TRUE),
                                              plotOutput('bar')))
                            )),
                   
                   tabPanel('Food and Risks',
                            sidebarPanel(selectInput("drugz",
                                                     "Select One or More drugs:",
                                                     unique(side_effects$webscraping_name),
                                                     multiple = TRUE,
                                                     selectize = TRUE)
                            ),
                            
                  mainPanel(
                    fluidRow(DT::dataTableOutput('sideeffects')),
                    fluidRow(column(width = 6),
                             column(width = 6, DT::dataTableOutput('risk')))
                  )   
                   )
))
