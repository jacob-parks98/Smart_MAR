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


shinyServer(function(input, output) {
  
  conditions_drugs_filtered <- reactive({
    req(input$cond)
    conditions_drugs_filtered <- conditions_drugs %>%
      filter(Condition %in% input$cond)
    return(conditions_drugs_filtered)
  })
  
  side_effects_filtered <- reactive({
    req(input$drug)
    side_effects_filtered <- side_effects %>%
      filter(webscraping_name %in% input$drug)
    return(side_effects_filtered)
  })
  
  side_effects_filtered_food <- reactive({
    req(input$drugz)
    side_effects_filtered <- side_effects %>%
      filter(webscraping_name %in% input$drugz)
    return(side_effects_filtered)
  })
  
  observeEvent(input$debug, {browser()})
  
  output$preg <- renderTable({
    preg_symbols
  })
  
  output$conditionsnumber <- renderText({
    paste0('Number of Conditions: ', length(input$cond))
  })
  
  output$drugnumber <- renderText({
    paste0('Number of Drugs: ', length(input$drug))
  })
  
  output$conditions <- DT::renderDataTable({
    
    if (is.null(input$cond)) {
      DT::datatable(conditions_drugs %>%
                      select(-c(webscraping_name, CSA)),
                    colnames = c("Drug Name", "Condition", "Type", "Pregnancy","Alcohol")
                   )
    }
    
    else
      DT::datatable(conditions_drugs_filtered() %>%
                      select(-c(webscraping_name, CSA)),
                    colnames = c("Drug Name", "Condition", "Type", "Pregnancy","Alcohol"))
    
  })
  
  output$sidefx <- DT::renderDataTable({
    if(is.null(input$drug)) {
      DT::datatable(side_effects, 
                    colnames = c('Drug Name', 'Medical Attention', 'Commonality', 'Side Effect', "Risk"),
                    options = list(pageLength = 5, scrollX = TRUE))
    }
    else
      DT::datatable(side_effects_filtered(),
                    colnames = c('Drug Name', 'Medical Attention', 'Commonality', 'Side Effect', "Risk"),
                    options = list(pageLength = 5, scrollX = TRUE)) 
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
        coord_flip() +
        theme(plot.background = element_blank()) +
        labs(x = 'Count', y = '', title = "Top 20 Most Common Side Effects") 
        
    }
    
    else if(length(input$drug) == 1) {
      side_effects_filtered() %>%
        filter(Side_effect != 'NA') %>%
        group_by(medical_attention) %>%
        summarize(number = n()) %>%
        ggplot(aes(x = medical_attention, y = number)) +
        geom_col() +
        labs(x = '', y = 'Count', title = paste0("Number of Side Effects by Medical Attention For ", input$drug)) 
    }
    
    else if (length(input$drug) > 1) {
      side_effects_filtered() %>%
      group_by(Side_effect) %>%
      summarize(number = n()) %>%
      arrange(desc(number)) %>%
      head(20) %>%
      ggplot(aes(x = reorder(Side_effect, number), y = number)) +
      geom_col() +
      coord_flip() +
      labs(x = 'Count', y = '', title = "Most Common Side Effects for Selected Drugs")
    }
  })
  
  output$sideeffects <- DT::renderDataTable({
    if(is.null(input$drugz)) {
      DT::datatable(side_effects, colnames = c('Drug Name', 'Medical Attention', 'Commonality', 'Side Effect', "Risk"))
    }
    else
      DT::datatable(side_effects_filtered_food(),colnames = c('Drug Name', 'Medical Attention', 'Commonality', 'Side Effect', "Risk"))
  })
  
  
  output$risk <- DT::renderDataTable({
    if (is.null(input$drugz)) {
     risk <- DT::datatable(side_effects %>%
        filter(Risk_factor != 'None') %>%
        group_by(Risk_factor) %>%
        summarize(num = n()),
        colnames = c("Risk", "Count"))
    }
    
    else 
      risk <- DT::datatable(side_effects_filtered_food() %>%
      filter(Risk_factor != 'None')  %>%
      group_by(Risk_factor) %>%
      summarize(num = n()),
      colnames = c("Risk", "Count"))
    
    risk
  })
  
  output$food <- DT::renderDataTable({
    if (input$risk == 'Choke') {
      DT::datatable(food %>%
        filter(str_detect(description, 'soup')|str_detect(description,'applesauce')|str_detect(description,'yogurt')) %>%
        select(description),
        colnames = c('Food'),
        options = list(pageLength = 5))
    }
    
    else if (input$risk == 'Fall') {
      DT::datatable(fall_risk_food %>%
        select(-c(...1,AVG)),
        colnames = c('Food', "Iron", "Protein", "Total"),
        options = list(pageLength = 5)) %>%
        formatRound(columns = c('Iron, Fe','Protein','Protein and Iron'), digits = 3)
    }
    
    else 
      DT::datatable(skin_breakdown_food %>%
                      filter(SUM > 0),
      colnames = c("Food", 'Vitamin A', 'Vitamin C', 'Vitamin E', "Vitamin E (alpha-tocopherol)", "Zinc", "Total"),
      options = list(pageLength = 5)) %>%
      formatRound(columns = c('Vitamin A, RAE', "Vitamin C, total ascorbic acid","Vitamin E","Vitamin E (alpha-tocopherol)","Zinc, Zn", "SUM"), digits = 3)
  })
  
  output$download <- downloadHandler(
    filename = "Patient_report.html",
    content = function(file) {
      tempreport <- file.path(tempdir(), 'Patient_report.Rmd')
      file.copy('../Patient_report.Rmd', tempreport, overwrite = TRUE)
      params <- list(condition = input$cond,
                     drug = input$drug,
                     side_efx = side_effects_filtered_food() %>%
                       filter(Risk_factor != 'None')  %>%
                       group_by(Risk_factor) %>%
                       summarize(num = n()) %>%
                       rename("Count"=num, "Risk Factor"=Risk_factor) %>%
                       arrange(desc(Count)),
                     common_sfx = side_effects_filtered() %>%
                       group_by(Side_effect) %>%
                       summarize(number = n()) %>%
                       arrange(desc(number)) %>%
                       head(20) %>%
                       ggplot(aes(x = reorder(Side_effect, number), y = number)) +
                       geom_col() +
                       coord_flip() +
                       labs(x = 'Count', y = '', title = "Most Common Side Effects for Selected Drugs" ),
                     med_attention = side_effects_filtered() %>%
                       filter(Side_effect != 'NA') %>%
                       group_by(medical_attention) %>%
                       summarize(number = n()) %>%
                       ggplot(aes(x = medical_attention, y = number)) +
                       geom_col() +
                       labs(x = '', y = 'Count', title = "Number of Side Effects by Medical Attention")
                     )
      rmarkdown::render(tempreport, output_file = file,
                        params = params,
                        envir = new.env(parent = globalenv()))
    }
  )
  
})