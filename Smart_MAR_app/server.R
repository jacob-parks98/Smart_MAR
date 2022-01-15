#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(DT)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  conditions_drugs_filtered <- reactive({
    req(input$cond)
    conditions_drugs_filtered <- conditions_drugs %>%
      filter(Condition == input$cond)
    return(conditions_drugs_filtered)
  })
  
  side_effects_filtered <- reactive({
    req(input$drug)
    side_effects_filtered <- side_effects %>%
      filter(webscraping_name == input$drug)
    return(side_effects_filtered)
  })
  
  side_effects_filtered_food <- reactive({
    req(input$drugz)
    side_effects_filtered <- side_effects %>%
      filter(webscraping_name == input$drugz)
    return(side_effects_filtered)
  })
  
  observeEvent(input$debug, {browser()})
  
  output$conditions <- DT::renderDataTable({
    
    if (is.null(input$cond)) {
      DT::datatable(conditions_drugs)
    }
    
    else
      DT::datatable(conditions_drugs_filtered())
    
  })
  
  output$sidefx <- DT::renderDataTable({
    if(is.null(input$drug)) {
      DT::datatable(side_effects)
    }
    else
      DT::datatable(side_effects_filtered())
  })
  
  output$bar <- renderPlot({
    
    if(is.null(input$drug)) {
      side_effects %>%
        filter(Side_effect != 'NA') %>%
        group_by(Side_effect) %>%
        summarize(number = n()) %>%
        arrange(desc(number)) %>%
        head(20) %>%
        ggplot(aes(x = reorder(Side_effect, number), y = number)) +
        geom_col() +
        coord_flip()
    }
    
    else if(length(input$drug) == 1) {
      side_effects_filtered() %>%
        filter(Side_effect != 'NA') %>%
        group_by(medical_attention) %>%
        summarize(number = n()) %>%
        ggplot(aes(x = medical_attention, y = number)) +
        geom_col()
    }
    
    else if (length(input$drug) > 1) {
      side_effects_filtered() %>%
      group_by(Side_effect) %>%
      summarize(number = n()) %>%
      arrange(desc(number)) %>%
      head(20) %>%
      ggplot(aes(x = reorder(Side_effect, number), y = number)) +
      geom_col() +
      coord_flip()
    }
  })
  
  output$sideeffects <- DT::renderDataTable({
    if(is.null(input$drugz)) {
      DT::datatable(side_effects)
    }
    else
      DT::datatable(side_effects_filtered_food())
  })
  
  
  #MAKE THIS INTO A RENDER TEXT, MOST LIKELY.
  output$risk <- DT::renderDataTable({
    if (is.null(input$drugz)) {
      side_effects %>%
        filter(Risk_factor != 'nan') %>%
        group_by(Risk_factor) %>%
        summarize(num = n())
    }
    
    else 
      side_effects_filtered_food() %>%
      filter(Risk_factor != 'nan')  %>%
      group_by(Risk_factor) %>%
      summarize(num = n())
  })
  
})