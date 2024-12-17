
# SPORTING ASSETS APP - SERVER #

# AI SET UP -------------------------------------------------------------------------------------------------------------------------

  # Function to retrieve content from a text file
  get_content_from_file <- function(file_path) {
    content <- readLines(file_path, warn = FALSE)
    return(paste(content, collapse = "\n"))
  }
  
  # Function to retrieve relevant sections from a text document based on the user query using grep
  search_relevant_sections <- function(query, file_path) {
    text_content <- readLines(file_path, warn = FALSE)    # Load the text document (Green Book)
    matched_lines <- grep(query, text_content, value = TRUE)    # Use grep to find relevant sections
    return(paste(matched_lines, collapse = "\n"))
  }
  
  # Read the API key from the configuration file
  config <- readLines("config.txt")
  api_key <- gsub("OPENAI_API_KEY=", "", config[grep("OPENAI_API_KEY", config)])
  openai_api_endpoint <- "https://api.openai.com/v1/chat/completions"
  
  # Function to call the OpenAI API
  openai_api_call <- function(prompt_text, conversation_history) {
    # Retrieve the system prompt
    system_prompt <- get_content_from_file("football_system_prompt.txt") 
    
    # Initialize conversation history with initial system prompt if not already set
    if (length(conversation_history) == 0) {conversation_history <- list(list(role = "system", content = system_prompt))}
    
    # Retrieve relevant sections based on the user prompt using grep
    sections <- search_relevant_sections(prompt_text, "football_rag.txt")
    
    # Add the relevant sections to the conversation history
    conversation_history <- c(conversation_history, list(list(role = "system", content = sections)))
    
    # Add the user message to the conversation history
    conversation_history <- c(conversation_history, list(list(role = "user", content = prompt_text)))
    
    # API call
    response <- POST(openai_api_endpoint, add_headers(Authorization = paste0("Bearer ", api_key)),
                     body = list(model = "gpt-4", messages = conversation_history), encode = "json")
    
    # Parse the response
    parsed_response <- content(response, "parsed")
    assistant_message <- parsed_response$choices[[1]]$message$content
    
    # Add the assistant's message to the conversation history
    conversation_history <- c(conversation_history, list(list(role = "assistant", content = assistant_message)))
    
    # Return the assistant's message and the updated conversation history
    return(list(assistant_message, conversation_history))
  }
  
    # Initialize conversation history
    conversation_history <- list()

    # SERVER  -------------------------------------------------------------------------------------------------------------------------
    server <- function(input, output, session) {
      
      # Tooltip ---------
      shinyjs::runjs("$('.custom-tooltip').tooltip({container: 'body', placement: 'top', html: true});")
      
      # Get Started button observer -------
      observeEvent(input$get_started, {updateTabsetPanel(session, "navbarPage", selected = "Calculator")})
      
      useShinyjs() # Added here      
      
      # Initialize reactive values ----
      rv <- reactiveValues(
        calculated_value = NULL, 
        return = NULL, 
        investment = NULL, 
        net_value = NULL, 
        sroi = NULL,
        # NEW: Economic value components
        player_spending = NULL,
        total_spending = NULL,
        economic_value = NULL,
        # Existing components
        adult_players = NULL,
        youth_players = NULL,
        volunteers = NULL,
        annual_expenditure = NULL,
        coeff_adult = 0.093,
        coeff_youth = 0.371,
        coeff_volunteer = 0.123,
        wellby_adult = NULL,
        wellby_youth = NULL,
        wellby_volunteer = NULL,
        wellby_val = 15338.46,
        living_wage = 10.42,
        additionality = 0.6,
        replacement_value_per_volunteer = NULL,
        replacement_value = NULL,
        health_ratio = 315/2815,
        health_value = NULL,
        calculated = FALSE,
        showAlert = FALSE,
        
        adult_additionality = 0.63,  # Default 63% already active
        cyp_additionality = 0.47     # Default 47% already active
      )
      
      # Load Local Data button handler ----
      observeEvent(input$load_local_data, {
        print("Loading local data")
        req(input$postcode)
        
        # Simulate API call (replace with actual API call later)
        tryCatch({
          random_variation <- runif(1, -0.1, 0.1)  # +/- 10%
          local_adult_activity <- min(max(0.63 + random_variation, 0), 1)
          local_cyp_activity <- min(max(0.47 + random_variation, 0), 1)
          
          print(paste("New adult activity:", local_adult_activity))
          print(paste("New CYP activity:", local_cyp_activity))
          
          # Update slider values
          updateSliderInput(session, "adult_additionality", 
                            value = round(local_adult_activity * 100))
          updateSliderInput(session, "cyp_additionality", 
                            value = round(local_cyp_activity * 100))
          
          # Store in reactive values
          rv$adult_additionality <- local_adult_activity
          rv$cyp_additionality <- local_cyp_activity
          
          output$postcode_message <- renderUI({
            div(class = "alert alert-success",
                style = "margin-top: 15px; padding: 10px; border-radius: 4px;",
                sprintf("Local activity levels loaded for %s: Adults %.0f%%, Young People %.0f%%", 
                        toupper(input$postcode),
                        local_adult_activity * 100,
                        local_cyp_activity * 100))
          })
        }, error = function(e) {
          print(paste("Error:", e$message))
          output$postcode_message <- renderUI({
            div(class = "alert alert-danger",
                style = "margin-top: 15px; padding: 10px; border-radius: 4px;",
                "Error loading local data. Please check postcode format.")
          })
        })
      })
      
      # Observe inputs and reactive -----  
      observe({
        input$adult_participants
        input$youth_participants
        input$volunteers
        input$sa_loan
        input$sa_grant
        input$loan_repaid
        input$other_funding
        
        rv$calculated <- FALSE
        rv$showAlert <- FALSE
        output$calculated_value <- renderUI({NULL})
      })
      
      # CALCS ----------------------------------------------------------------------------------------------------------------------------
      observeEvent(input$calculate_value, {
        # Print inputs for debugging
        print("Starting calculation")
        
        # Required inputs ---- 
        req(input$cyp_participants, input$adult_participants, input$volunteers, 
            input$sa_loan, input$sa_grant, input$loan_repaid, input$other_funding)
        
        # Convert inputs to numeric values ----
        rv$adult_players <- as.numeric(input$adult_participants)
        rv$youth_players <- as.numeric(input$cyp_participants)
        rv$volunteers <- as.numeric(input$volunteers)
        
        # Calculate financial values ----
        total_sa_investment <- as.numeric(input$sa_loan) + as.numeric(input$sa_grant) - as.numeric(input$loan_repaid)
        total_investment <- total_sa_investment + as.numeric(input$other_funding)
        rv$annual_expenditure <- total_investment  # This is what's used in later calculations
        
        # Calculate player spending
        rv$player_spending <- rv$adult_players * 122.36  # Non-club spending per player
        rv$total_spending <- rv$annual_expenditure + rv$player_spending
        rv$economic_value <- rv$total_spending * 0.5     # 50% of total spending becomes GVA
        
        print(paste("Total investment calculated:", rv$annual_expenditure))
        
        # Calculate replacement value ----
        rv$replacement_value_per_volunteer <- 12 * 9 * rv$living_wage 
        
        # Calculate wellby values ----
        rv$wellby_adult <- rv$adult_players * rv$coeff_adult * rv$wellby_val * (1 - rv$adult_additionality)
        rv$wellby_youth <- rv$youth_players * rv$coeff_youth * rv$wellby_val * (1 - rv$cyp_additionality)
        rv$wellby_volunteer <- rv$volunteers * rv$coeff_volunteer * rv$wellby_val * rv$additionality
        rv$replacement_value <- rv$volunteers * rv$replacement_value_per_volunteer
        
        # Calculate health values ----
        rv$health_value <- (rv$wellby_adult * rv$health_ratio) # Additionality already included in wellby_adult
        
        # Calculate return, investment, net value, and SROI ----
        return_value <- rv$wellby_adult + rv$wellby_youth + rv$wellby_volunteer + rv$replacement_value + rv$health_value + rv$economic_value
        investment <- rv$annual_expenditure + rv$replacement_value + rv$player_spending
        net_value <- return_value - investment
        sroi <- return_value / investment
        
        # Round values for display ---- 
        rv$return <- round(return_value, -2)
        rv$investment <- round(investment, -2)
        rv$net_value <- round(net_value, -2)
        rv$sroi <- round(sroi, 1)
        
        # Mark calculation as complete ----
        rv$calculated_value <- return_value
        rv$calculated <- TRUE
        
        # Determine project name text ----
        project_name_text <- ifelse(nzchar(input$project_name), input$project_name, "Your project")
        
        # Render UI with headline text -----
        output$calculated_value <- renderUI({
          req(rv$adult_players, rv$youth_players, rv$volunteers, rv$annual_expenditure)
          
          div(style = "text-align: center; position: relative;",
              HTML(paste0(
                '<div style="text-align: center; font-size: 24px; font-family: FS Jack, sans-serif; margin-bottom: 20px;">',
                '<span style="font-weight: 700;">', project_name_text, '</span>',
                ' generates an estimated <span style="color: rgb(206, 50, 49); font-weight: 700;">£',
                format(rv$sroi, nsmall = 2),
                '</span> return for every <span style="color: rgb(18, 68, 135); font-weight: 700;">£1</span> invested.</div>',
                
                '<div style="text-align: center; font-size: 18px; font-family: FS Jack, sans-serif;">',
                'Your net social value is <span style="color: rgb(206, 50, 49); font-weight: 700;">£',
                format(rv$net_value, big.mark = ",", scientific = FALSE),
                '</span> based on an annual return of <span style="color: rgb(18, 68, 135); font-weight: 700;">£',
                format(rv$return, big.mark = ",", scientific = FALSE),
                '</span> and investment of <span style="color: rgb(198, 163, 92); font-weight: 700;">£',
                format(rv$investment, big.mark = ",", scientific = FALSE),
                '</span>.</div>'
              )))
        })
        
        # Show additional buttons and radio buttons -------------
        shinyjs::show("additional_buttons")
        shinyjs::show("radio_buttons_container")
        
        # Save plots when the calculation is complete ----------------
        save_plot_images()
      })
      
# PLOTS ------------------------------------------------------------------------------------------------------------------------------------ 
      save_plot_images <- function() {
        # Investment data remains unchanged
        investment_data <- data.frame(
          Category = rep("Investment", 3),
          SubCategory = c("Club Expenditure", "Player Expenditure", "Volunteer Time Cost"),
          Value = c(rv$annual_expenditure, rv$player_spending, rv$replacement_value))
        
        # Simplified return data
        return_data <- data.frame(
          Category = rep("Return", 4),
          SubCategory = c("Wellbeing Benefits", "Volunteer Time Value", 
                          "Economic Benefit (GVA)", "Health System Benefits"),
          Value = c(rv$wellby_adult + rv$wellby_youth + rv$wellby_volunteer, 
                    rv$replacement_value, rv$economic_value, rv$health_value))
        
        combined_data <- rbind(investment_data, return_data)
        
        combined_data$SubCategory <- factor(combined_data$SubCategory, 
                                            levels = c("Volunteer Time Cost", "Player Expenditure", "Club Expenditure", 
                                                       "Volunteer Time Value", "Wellbeing Benefits", 
                                                       "Economic Benefit (GVA)", "Health System Benefits"))
        
        stacked_bar_chart <- ggplot(combined_data, aes(x = Category, y = Value, fill = SubCategory)) +
          geom_bar(stat = "identity", position = "stack", width = 0.6) +
          scale_fill_manual(values = c(
            "Volunteer Time Cost" = "#C6A35C",   # Gold
            "Player Expenditure" = "#FF69B4",    # Pink for Player Expenditure
            "Club Expenditure" = "#15af97",      # Greenish Blue for Club Expenditure
            "Volunteer Time Value" = "#C6A35C",  # Gold (matches Volunteer Time Cost)
            "Wellbeing Benefits" = "#124487",    # Blue for Wellbeing
            "Economic Benefit (GVA)" = "#CE3231", # Red for GVA
            "Health System Benefits" = "#FFEF66" # Yellow for Health
          ))+
          theme_minimal() +
          theme(text = element_text(family = "Helvetica", size = 14), 
                axis.title = element_blank(), 
                axis.text.x = element_text(size = 12, face = "bold"),
                panel.grid = element_blank(), 
                legend.position = "right", 
                legend.title = element_blank()) +
          scale_y_continuous(labels = scales::dollar_format(prefix = "£", big.mark = ","), 
                             expand = expansion(mult = c(0.05, 0.1)))
        
        ggsave("www/value_stacked_bar.png", plot = stacked_bar_chart, width = 8, height = 6, dpi = 300)
        
        plot_data_investment <- data.frame(
          Label = c("Club Expenditure", "Player Expenditure", "Volunteer Time Cost"),
          Value = c(rv$annual_expenditure, rv$player_spending, rv$replacement_value))
        
        investment_donut_chart <- ggplot(plot_data_investment, aes(x = 2, y = Value, fill = Label)) +
          geom_col(color = "white") +
          coord_polar(theta = "y") +
          theme_void() +
          xlim(0.5, 2.5) +
          geom_text(aes(label = scales::dollar(Value, prefix = "£", big.mark = ",")), 
                    position = position_stack(vjust = 0.5), size = 5) +
          scale_fill_manual(values = c(
            "Club Expenditure" = "#124487", 
            "Player Expenditure" = "#CE3231", 
            "Volunteer Time Cost" = "#C6A35C"))
        
        ggsave("www/investment_donut.png", plot = investment_donut_chart, width = 8, height = 6, dpi = 300)
        
        plot_data_return <- data.frame(
          Label = c("Wellbeing Benefits", "Volunteer Time Value", 
                    "Economic Benefit (GVA)", "Health System Benefits"),
          Value = c(rv$wellby_adult + rv$wellby_youth + rv$wellby_volunteer, 
                    rv$replacement_value, rv$economic_value, rv$health_value))
        
        return_donut_chart <- ggplot(plot_data_return, aes(x = 2, y = Value, fill = Label)) +
          geom_col(color = "white") +
          coord_polar(theta = "y") +
          theme_void() +
          xlim(0.5, 2.5) +
          geom_text(aes(label = scales::dollar(Value, prefix = "£", big.mark = ",")), 
                    position = position_stack(vjust = 0.5), size = 5) +
          scale_fill_manual(values = c(
            "Wellbeing Benefits" = "#124487",
            "Volunteer Time Value" = "#C6A35C", 
            "Economic Benefit (GVA)" = "#CE3231",
            "Health System Benefits" = "#FFEF66"))
        
        ggsave("www/return_donut.png", plot = return_donut_chart, width = 8, height = 6, dpi = 300)
      }
      
      output$value_stacked_bar <- renderPlotly({
        req(rv$calculated)
        
        investment_data <- data.frame(
          Category = rep("Investment", 3),
          SubCategory = c("Club Expenditure", "Player Expenditure", "Volunteer Time Cost"),
          Value = c(rv$annual_expenditure, rv$player_spending, rv$replacement_value))
        
        return_data <- data.frame(
          Category = rep("Return", 4),
          SubCategory = c("Wellbeing Benefits", "Volunteer Time Value", 
                          "Economic Benefit (GVA)", "Health System Benefits"),
          Value = c(rv$wellby_adult + rv$wellby_youth + rv$wellby_volunteer, 
                    rv$replacement_value, rv$economic_value, rv$health_value))
        
        combined_data <- rbind(investment_data, return_data)
        
        combined_data$SubCategory <- factor(combined_data$SubCategory, 
                                            levels = c("Volunteer Time Cost", "Player Expenditure", "Club Expenditure", 
                                                       "Volunteer Time Value", "Wellbeing Benefits", 
                                                       "Economic Benefit (GVA)", "Health System Benefits"))
        
        stacked_bar_chart <- ggplot(combined_data, 
                                    aes(x = Category, y = Value, 
                                        fill = SubCategory, 
                                        text = paste0("<br>£", format(round(Value, -1), big.mark = ",")))) +
          geom_bar(stat = "identity", position = "stack", width = 0.6) +
          scale_fill_manual(values = c(
            "Volunteer Time Cost" = "#C6A35C",   # Gold
            "Player Expenditure" = "#FF69B4",    # Pink for Player Expenditure
            "Club Expenditure" = "#15af97",      # Greenish Blue for Club Expenditure
            "Volunteer Time Value" = "#C6A35C",  # Gold (matches Volunteer Time Cost)
            "Wellbeing Benefits" = "#124487",    # Blue for Wellbeing
            "Economic Benefit (GVA)" = "#CE3231", # Red for GVA
            "Health System Benefits" = "#FFEF66" # Yellow for Health
          ))+
          theme_minimal() +
          theme(text = element_text(family = "Helvetica", size = 14), 
                axis.title = element_blank(), 
                axis.text.x = element_text(size = 12, face = "bold"),
                panel.grid = element_blank(), 
                legend.position = "right", 
                legend.title = element_blank()) +
          scale_y_continuous(labels = scales::dollar_format(prefix = "£", big.mark = ","), 
                             expand = expansion(mult = c(0.05, 0.1)))
        
        ggplotly(stacked_bar_chart, tooltip = "text") %>%
          layout(font = list(family = "Helvetica", size = 14), 
                 margin = list(l = 50, r = 50, t = 30, b = 30), 
                 legend = list(title = list(text = "")))
      })
      
      output$investment_donut <- renderPlotly({
        req(rv$calculated)
        plot_data <- data.frame(
          Label = c("Club Expenditure", "Player Expenditure", "Volunteer Time Cost"),
          Value = c(rv$annual_expenditure, rv$player_spending, rv$replacement_value),
          HoverText = sprintf("%s<br>£%s<br>%.1f%%",
                              c("Club Expenditure", "Player Expenditure", "Volunteer Time Cost"),
                              format(round(c(rv$annual_expenditure, rv$player_spending, rv$replacement_value), -1), 
                                     big.mark = ","),
                              c(rv$annual_expenditure, rv$player_spending, rv$replacement_value) / 
                                sum(c(rv$annual_expenditure, rv$player_spending, rv$replacement_value)) * 100))
        plot_ly(plot_data, labels = ~Label, values = ~Value, type = 'pie',
                marker = list(colors = c("#124487", "#CE3231", "#C6A35C")),
                hole = 0.4, textinfo = "label", hoverinfo = "text", text = ~HoverText, 
                insidetextorientation = 'radial') %>%
          layout(annotations = list(list(font = list(size = 20, family = "Helvetica"), 
                                         showarrow = FALSE,
                                         text = paste0('£', format(round(sum(plot_data$Value), -2), 
                                                                   big.mark = ",")), 
                                         x = 0.5, y = 0.5)),
                 showlegend = FALSE, 
                 font = list(size = 18, family = "Helvetica"), 
                 margin = list(l = 50, r = 50, t = 50, b = 50))
      })
      
      output$return_donut <- renderPlotly({
        req(rv$calculated)
        
        plot_data <- data.frame(
          Label = c("Wellbeing Benefits", "Volunteer Time Value", 
                    "Economic Benefit (GVA)", "Health System Benefits"),
          Value = c(rv$wellby_adult + rv$wellby_youth + rv$wellby_volunteer, 
                    rv$replacement_value, rv$economic_value, rv$health_value))
        
        plot_data$HoverText <- sprintf("%s<br>£%s<br>%.1f%%",
                                       plot_data$Label,
                                       format(round(plot_data$Value, -1), big.mark = ","),
                                       plot_data$Value / sum(plot_data$Value) * 100)
        plot_ly(plot_data, labels = ~Label, values = ~Value, type = 'pie',
                marker = list(colors = c("#124487", "#C6A35C", "#CE3231", "#FFEF66")),
                hole = 0.4, textinfo = "label", hoverinfo = "text", text = ~HoverText, 
                insidetextorientation = 'radial') %>%
          layout(annotations = list(list(font = list(size = 20, family = "Helvetica"), 
                                         showarrow = FALSE,
                                         text = paste0('£', format(round(sum(plot_data$Value), -2), 
                                                                   big.mark = ",")),
                                         x = 0.5, y = 0.5)),
                 showlegend = FALSE, 
                 font = list(size = 18, family = "Helvetica"), 
                 margin = list(l = 50, r = 50, t = 50, b = 50))
      })
      
# AI  ----------------------------------------------------------------------------------------------------------------------
      conversation_history_rv <- reactiveVal(list())
      
      # In server.R, update the chat_output renderUI:
      
      output$chat_output <- renderUI({
        # Get existing chat messages if any
        chat_contents <- if(length(conversation_history_rv()) > 0) {
          lapply(conversation_history_rv(), function(msg) {
            if(msg$role != "system") {
              if(msg$role == "user") {
                div(class = "chat-message user-message",
                    div(class = "message-content", msg$content)
                )
              } else {
                div(class = "chat-message assistant-message",
                    div(class = "message-content", msg$content)
                )
              }
            }
          })
        }
        
        # Create welcome message
        welcome_message <- div(class = "chat-message assistant-message",
                               div(class = "message-content",
                                   HTML("Hi! I'm your Value F.C. Assistant Coach. I can help you understand your club's social value and create content to share your impact. Here are some things you might want to ask me:
                                 <br><br>
                                 <strong>Content Creation:</strong>
                                 <ul>
                                   <li>'Help me write a piece for our club newsletter about our social value'</li>
                                   <li>'Draft some social media posts about our impact'</li>
                                   <li>'Create a short presentation script about our social return'</li>
                                 </ul>
                                 <br>
                                 <strong>Understanding Social Value:</strong>
                                 <ul>
                                   <li>'Can you explain simply how we put monetary values on wellbeing?'</li>
                                   <li>'Why do you adjust benefits down by 40%?'</li>
                                   <li>'How do you estimate the economic benefits?'</li>
                                 </ul>
                                 <br>
                                 Feel free to ask me anything about your Value F.C. report. Enter a message to kick off our chat!"
                                   )))
        
        # Combine welcome message with existing chat
        div(class = "chat-container",
            if(length(conversation_history_rv()) == 0) {
              welcome_message
            } else {
              chat_contents
            }
        )
      })
      
      observeEvent(input$submit, {
        shinyjs::show("loading-spinner", anim = TRUE, animType = "fade")
        user_message <- input$user_input
        current_conversation_history <- conversation_history_rv()
        
        result <- tryCatch({
          openai_api_call(user_message, current_conversation_history)
        }, error = function(e) {
          print(paste("Error in openai_api_call: ", e$message))
          return(NULL)
        })
        
        if (!is.null(result)) {
          assistant_message <- result[[1]]
          updated_history <- result[[2]]
          conversation_history_rv(updated_history)
          updateTextInput(session, "user_input", value = "")
          
          output$chat_output <- renderUI({
            chat_contents <- lapply(updated_history, function(msg) {
              if (msg$role != "system") {
                if (msg$role == "user") {
                  div(class = "chat-message user-message",
                      div(class = "message-content", msg$content)
                  )
                } else {
                  div(class = "chat-message assistant-message",
                      div(class = "message-content", msg$content)
                  )
                }
              }
            })
            do.call(div, c(list(class = "chat-container"), chat_contents))
          })
          
        }
        shinyjs::hide("loading-spinner", anim = TRUE, animType = "fade")
      })
      
      
# REPORT -----------------------------------------------------------------------------------------------------------------------------
      
      output$download_report <- downloadHandler(
        filename = function() {
          club_name <- if (!is.null(input$club_name) && nzchar(input$club_name)) paste0(input$club_name, " - ") else ""
          paste0(club_name, "Value FC Report ", Sys.Date(), ".docx")
        },
        content = function(file) {
          req(rv$adult_players, rv$youth_players, rv$volunteers, rv$annual_expenditure, rv$economic_value, rv$player_spending)
          
          params <- list(
            club_name = input$club_name,
            sroi = rv$sroi,
            return = rv$return,
            investment = rv$investment,
            net_value = rv$net_value,
            wellby_adult = rv$wellby_adult,
            wellby_youth = rv$wellby_youth,
            wellby_volunteer = rv$wellby_volunteer,
            replacement_value = rv$replacement_value,
            annual_expenditure = rv$annual_expenditure,
            adult_players = rv$adult_players,
            youth_players = rv$youth_players,
            volunteers = rv$volunteers,
            economic_value = rv$economic_value,
            player_spending = rv$player_spending,
            health_value = rv$health_value,
            health_ratio = rv$health_ratio,
            wellby_val = rv$wellby_val
          )
          
          rmarkdown::render("report.Rmd", output_file = file, params = params, envir = new.env(parent = globalenv()))
        }
      )
      
# MEDIA PACK -----------------------------------------------------------------------------------------------------------------------------
      
      output$download_media_pack <- downloadHandler(
        filename = function() {
          club_name <- if (!is.null(input$club_name) && nzchar(input$club_name)) paste0(input$club_name, " - ") else ""
          paste0(club_name, "Value FC Media Pack ", Sys.Date(), ".docx")
        },
        content = function(file) {
          req(rv$adult_players, rv$youth_players, rv$volunteers, rv$annual_expenditure)
          
          params <- list(
            club_name = input$club_name,
            sroi = rv$sroi,
            return = rv$return,
            investment = rv$investment,
            net_value = rv$net_value,
            adult_players = rv$adult_players,
            youth_players = rv$youth_players,
            volunteers = rv$volunteers,
            economic_value = rv$economic_value,
            player_spending = rv$player_spending,
            health_value = rv$health_value,
            wellby_val = rv$wellby_val
          )
          
          rmarkdown::render("football_media_pack.Rmd", output_file = file, params = params, envir = new.env(parent = globalenv()))
        }
      )
      
# CSV ---------------------------------------------------------------------
      output$download_csv <- downloadHandler(
        filename = function() {
          club_name <- if (!is.null(input$club_name) && nzchar(input$club_name)) paste0(input$club_name, " - ") else ""
          paste0(club_name, "Value FC Data ", Sys.Date(), ".csv")
        },
        content = function(file) {
          # Helper functions
          get_value <- function(x) {
            if(is.null(x)) return(NA)
            x
          }
          
          # Format numbers appropriately
          format_number <- function(x, digits = 0) {
            if(is.null(x) || is.na(x)) return(NA)
            if(abs(x) < 1) return(round(x, 3))  # For coefficients
            if(abs(x) >= 1000) return(format(round(x), big.mark = ","))  # For large numbers
            round(x, digits)  # For other numbers
          }
          
          # Create vectors in logical order
          labels <- c(
            # Basic Information
            "Club Name",
            "Date",
            
            # Direct Inputs
            "Annual Expenditure",
            "Number of Adult Players (Over 16)",
            "Number of Youth Players (Under 16)",
            "Number of Volunteers",
            
            # Secondary Inputs
            "WELLBY Annual Value",
            "Adult Player Average Life Satisfaction Gained",
            "Youth Player Average Life Satisfaction Gained",
            "Volunteer Average Life Satisfaction Gained",
            
            # Calculated Investment Values
            "Player Spending",
            "Volunteer Time Value",
            "Total Investment",
            
            # Calculated Benefit Values
            "Adult Players Total Value",
            "Youth Players Total Value",
            "Volunteers Wellbeing Value",
            "Health System Benefits",
            "Economic Benefit (GVA)",
            "Total Social Return",
            
            # Final Metrics
            "Net Social Value",
            "Benefit Cost Ratio"
          )
          
          descriptions <- c(
            # Basic Information
            "Name of the football club",
            "Date of report generation",
            
            # Direct Inputs
            "Annual operational expenditure of the club",
            "Number of adult players participating regularly",
            "Number of youth players participating regularly",
            "Number of regular volunteers",
            
            # Secondary Inputs
            "Treasury value of one WELLBY in 2023 prices",
            "Adult player wellbeing improvement (WELLBYs)",
            "Youth player wellbeing improvement (WELLBYs)",
            "Volunteer wellbeing improvement (WELLBYs)",
            
            # Calculated Investment Values
            "Additional player spending beyond club fees",
            "Value of volunteer time contribution",
            "Total investment including club costs, player spending and volunteer time",
            
            # Calculated Benefit Values
            "Total wellbeing value for adult players",
            "Total wellbeing value for youth players",
            "Wellbeing value from volunteering",
            "Reduced pressure on health services",
            "Local economic value generated",
            "Total social value generated annually",
            
            # Final Metrics
            "Net social value after accounting for investments",
            "Social return on investment ratio (£ per £1)"
          )
          
          # Get values and format appropriately
          values <- c(
            # Basic Information
            input$club_name,
            format(Sys.Date(), "%d/%m/%Y"),
            
            # Direct Inputs
            format_number(rv$annual_expenditure),
            format_number(rv$adult_players),
            format_number(rv$youth_players),
            format_number(rv$volunteers),
            
            # Secondary Inputs
            format_number(rv$wellby_val, 2),
            format_number(rv$coeff_adult),
            format_number(rv$coeff_youth),
            format_number(rv$coeff_volunteer),
            
            # Calculated Investment Values
            format_number(rv$player_spending, 2),
            format_number(rv$replacement_value, 2),
            format_number(rv$investment),
            
            # Calculated Benefit Values
            format_number(rv$wellby_adult, 2),
            format_number(rv$wellby_youth, 2),
            format_number(rv$wellby_volunteer, 2),
            format_number(rv$health_value, 2),
            format_number(rv$economic_value, 2),
            format_number(rv$return),
            
            # Final Metrics
            format_number(rv$net_value),
            format_number(rv$sroi, 2)
          )
          
          # Verify lengths match
          stopifnot(
            length(labels) == length(descriptions),
            length(labels) == length(values)
          )
          
          # Create data frame
          data <- data.frame(
            Label = labels,
            Description = descriptions,
            Value = values,
            stringsAsFactors = FALSE
          )
          
          # Write CSV
          write.csv(data, file, row.names = FALSE)
        }
      ) 
      
# END SERVER ------------------------------------------------------------------------------------------------------------------------
    }