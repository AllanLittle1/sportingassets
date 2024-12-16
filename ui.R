
# UI ---------------------------------------------------
ui <- navbarPage(
  id = "navbarPage",
  theme = my_theme,
  title = NULL,

  # HOME ------------------------------------------------------------------------------------------------------------------
  tabPanel("Home",
           fluidPage(
             theme = my_theme,
             tags$head(
               tags$style(HTML(custom_css))
             ),
             
             # Animated Background
             div(class = "animated-background",
                 tags$img(src = "soccer-ball (1).png", alt = "Market"),
                 tags$img(src = "attack.png", alt = "Football")),
             
             # Home Content
             div(class = "home-content",
                 style = "position: relative; z-index: 1; background-color: rgba(255, 255, 255, 0.9);",
                 
                 div(style = "display: flex; align-items: center; justify-content: center;",
                     h1(HTML('<span style="font-weight: bold; color: rgb(18, 68, 135);">Sporting Assets Value Estimator (SAVE)</span>'), 
                        style = "margin-right: 0px;"),
                     img(src = "sa_logo.png", style = "height: 80px; width: auto; margin-left: 30px;")),
                 
                 h3("Strapline TBD!", 
                    align = "center"),
                 br(),
                 
                 fluidRow(
                   column(1),
                   column(5, div(style = "height: 400px; overflow-y: auto; padding: 20px; border: 2px solid rgb(198, 163, 92); border-radius: 8px;",
                                 # Replace the existing bullet points in the Home page section:
                                 tags$ul(
                                   style = "list-style-type: none; padding-left: 0; font-size: 1.5em; font-weight: 300;",
                                   tagList(
                                     tags$li(
                                       icon("futbol", class = "fa-solid", 
                                            style = "color: rgb(18, 68, 135); margin-right: 10px;"),  # Blue
                                       "Social valuation made accessible, for grassroots clubs in Essex"
                                     ),
                                     tags$li(
                                       icon("futbol", class = "fa-solid", 
                                            style = "color: rgb(206, 50, 49); margin-right: 10px;"),  # Red
                                       "Benefits to players, volunteers, the NHS and the economy"
                                     ),
                                     tags$li(
                                       icon("futbol", class = "fa-solid", 
                                            style = "color: rgb(198, 163, 92); margin-right: 10px;"),  # navy
                                       "For credible investment cases with fully transparent sourcing"
                                     ),
                                     tags$li(
                                       icon("futbol", class = "fa-solid", 
                                            style = "color: rgb(18, 68, 135); margin-right: 10px;"),  # Blue
                                       "Comprehensive reports, media packs and data downloads"
                                     ),
                                     tags$li(
                                       icon("futbol", class = "fa-solid", 
                                            style = "color: rgb(206, 50, 49); margin-right: 10px;"),  # Red
                                       "Consistent with Sport England's new model of social value"
                                     ),
                                     tags$li(
                                       icon("futbol", class = "fa-solid", 
                                            style = "color: rgb(198, 163, 92); margin-right: 10px;"),  # navy
                                       "Professional grade, to Treasury standards"
                                     )
                                   )
                                 )
                                 )),
                   column(5, div(style = "height: 400px; display: flex; align-items: center; justify-content: center; border: 2px solid #C6A35C; border-radius: 8px;",
                                 HTML('<iframe width="480" height="270" src="https://www.powtoon.com/embed/eU5L920Tw9z/" frameborder="0" allowfullscreen></iframe>')
                   )),
                   column(1),
                
                   div(style = "text-align: center; margin-top: 30px;",
                       actionBttn(inputId = "get_started", 
                                  label = "Get Started", 
                                  style = "unite", 
                                  color = "primary", 
                                  size = "lg",
                                  class = "sa-button"))
                 )))),

  # CALCULATOR ------------------------------------------------------------------------------------------------------------------
  tabPanel("Calculator", 
           fluidPage(
             theme = my_theme,
             tags$head(
               tags$style(HTML("
        /* Background styling */
        .calculator-page {
          background: linear-gradient(rgba(255, 255, 255, 0.3), rgba(255, 255, 255, 0.3)), 
                      url('gymnastics.jpg');
          background-size: cover;
          background-position: center;
          background-attachment: fixed;
          min-height: 100vh;
          padding: 20px;
        }
        
        /* Accordion styling */
        .accordion-container {
          max-width: 800px;
          margin: 0 auto;
          background-color: rgba(255, 255, 255, 0.85);
          border-radius: 8px;
          backdrop-filter: blur(5px);
          padding: 20px;
        }
        
        .accordion-section {
          border: 1px solid rgb(198, 163, 92);
          border-radius: 8px;
          margin-bottom: 15px;
          overflow: hidden;
        }
        
        .accordion-header {
          background-color: var(--essex-blue);
          color: white;
          padding: 15px;
          cursor: pointer;
          transition: all 0.3s ease;
        }
        
        .accordion-content {
          padding: 20px;
          background-color: rgba(255, 255, 255, 0.95);
        }

        .heading-container {
          text-align: center;
          margin-bottom: 20px;
        }

        .radio-buttons-centre {
          text-align: center;
          margin: 20px 0;
        }
      ")),
               tags$script(src = "https://polyfill.io/v3/polyfill.min.js?features=es6"),
               tags$script(src = "https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js")
             ),
             useShinyjs(),
             
             # Main container
             div(class = "calculator-page",
                 div(class = "accordion-container",
                     # Header
                     div(class = "heading-container",
                         div(style = "display: flex; justify-content: center; align-items: center; gap: 15px;",
                             tags$img(src = "sa_logo.png", style = "height: 80px; width: auto;"),
                             h2("Value Calculator", style = "margin: 0;")
                         )
                     ),
                     
                     # Accordion Sections
                     # 1. About You
                     div(class = "accordion-section",
                         div(class = "accordion-header", "About You"),
                         div(class = "accordion-content",
                             create_input_field("club_name", "Club Name:", 
                                                textInput("club_name", "", placeholder = " ", width = '100%'),
                                                "Enter the name of your club as you'd like it to appear in your report.")
                         )
                     ),
                     
                     # 2. Costs
                     div(class = "accordion-section",
                         div(class = "accordion-header", "Costs"),
                         div(class = "accordion-content",
                             create_input_field("annual_expenditure", "Annual Expenditure (£):", 
                                                numericInput("annual_expenditure", "", value = 0, min = 0, step = 1000, width = '100%'),
                                                "Enter the total expenditure of your club over the last 12 months. Include all costs such as pitch hire, 
              equipment, insurance, and any other operational expenses.")
                         )
                     ),
                     
                     # 3. Participants
                     div(class = "accordion-section",
                         div(class = "accordion-header", "Participants"),
                         div(class = "accordion-content",
                             create_input_field("adult_players", "Regular Players Aged Over 16:", 
                                                numericInput("adult_players", "", value = 0, min = 0, step = 10, width = '100%'),
                                                "Enter the number of regular adult players and any young players aged 16 plus."),
                             create_input_field("youth_players", "Regular Players Aged Under 16:", 
                                                numericInput("youth_players", "", value = 0, min = 0, step = 10, width = '100%'),
                                                "Enter the number of regular children and young people aged under 16."),
                             create_input_field("volunteers", "Regular Volunteers:", 
                                                numericInput("volunteers", "", value = 0, min = 0, step = 10, width = '100%'),
                                                "Enter the number of regular volunteers who contributed to the club over the last 12 months."),
                             div(style = "text-align: center; margin-top: 20px;",
                                 actionBttn(inputId = "calculate_value", 
                                            label = "Calculate Value", 
                                            style = "unite", 
                                            color = "primary", 
                                            size = "md"))
                         )
                     ),
                     
                     # 4. Results
                     div(class = "accordion-section",
                         div(class = "accordion-header", "Results"),
                         div(class = "accordion-content",
                             htmlOutput("calculated_value", style = "text-align: center;"),
                             div(id = "additional_buttons", 
                                 style = "text-align: center; display: none; margin-top: 20px;",
                                 downloadBttn(outputId = "download_report", 
                                              label = "Download Report", 
                                              style = "unite", 
                                              color = "primary", 
                                              size = "sm"),
                                 downloadBttn(outputId = "download_media_pack", 
                                              label = "Media Pack", 
                                              style = "unite", 
                                              color = "warning", 
                                              size = "sm"),
                                 downloadBttn(outputId = "download_csv", 
                                              label = "Data", 
                                              style = "unite", 
                                              color = "success", 
                                              size = "sm"))
                         )
                     ),
                     
                     # 5. Visualizations
                     div(class = "accordion-section",
                         div(class = "accordion-header", "Visualizations"),
                         div(class = "accordion-content",
                             div(class = "radio-buttons-centre", 
                                 id = "radio_buttons_container", 
                                 style = "display: none;",
                                 radioButtons(inputId = "chart_type", 
                                              label = NULL, 
                                              choices = list("Return" = "return_donut", 
                                                             "Investment" = "investment_donut", 
                                                             "Value" = "waterfall"), 
                                              inline = TRUE)
                             ),
                             conditionalPanel(condition = "input.chart_type == 'waterfall'", 
                                              plotlyOutput("value_stacked_bar")),
                             conditionalPanel(condition = "input.chart_type == 'investment_donut'", 
                                              plotlyOutput("investment_donut")),
                             conditionalPanel(condition = "input.chart_type == 'return_donut'", 
                                              plotlyOutput("return_donut"))
                         )
                     )
                 )
             )
           )
  ),

# FEEDBACK ----------------------------------------------------------------------------

tabPanel("Feedback",
         fluidPage(
           theme = my_theme, 
           tags$head(
             tags$style(HTML("
          .feedback-page {
            background: linear-gradient(rgba(255,255,255,0.3), rgba(255,255,255,0.3)), url('indirock.jpg');
            background-size: cover; background-position:center; background-attachment:fixed; min-height:100vh; padding:0px;
          }
          .panel-container {display:flex; gap:20px; max-width:1400px; margin:0 auto; height:800px;}
          .feedback-form-container,.about-container {
            background-color:rgba(255,255,255,0.75); border:1px solid rgb(198,163,92); border-radius:8px; padding:20px; backdrop-filter:blur(5px); height:100%; overflow-y:auto;
          }
          .feedback-form-container {flex:0 0 640px;}
          .about-container {flex:1;}
          .feedback-form-container iframe {height:100%!important; width:100%;}
          .version-table {width:100%; margin-top:20px; border-collapse:collapse;}
          .version-table th,.version-table td {border:1px solid rgb(198,163,92); padding:8px; text-align:left;}
          .version-table th {background-color:rgba(18,68,135,0.1);}
          .feedback-form-container::-webkit-scrollbar,.about-container::-webkit-scrollbar {width:8px;}
          .feedback-form-container::-webkit-scrollbar-track,.about-container::-webkit-scrollbar-track {background:rgba(255,255,255,0.5);}
          .feedback-form-container::-webkit-scrollbar-thumb,.about-container::-webkit-scrollbar-thumb {background:rgb(198,163,92); border-radius:4px;}
          "))
           ),
           
           div(class = "feedback-page",
               div(class = "panel-container",
                   # About Panel (left side)
                   div(class = "about-container",
                       h2("Tell Us What You Think", 
                          style = "color: rgb(18, 68, 135); margin-bottom: 20px;"),
                       
                       p("SAVE helps grassroots football clubs demonstrate their social value, 
            supporting Essex FA's #MovingForward strategy. Together, we're creating a 
            united #EssexFootball environment that tackles inequalities, delivers 
            inspirational opportunities, and improves health For All."),
                       
                       # Update the paragraph with a more elegant icon:
                       p(
                         "Built by State of Life, we use HM Treasury-approved methods to estimate 
  your club's social, health, and economic benefits. To help us improve the app 
  for you and other clubs, we'd love you to fill in the quick survey opposite ",
                         tags$i(class = "fas fa-arrow-circle-right", 
                                style = "color: rgb(198, 163, 92); 
                 font-size: 24px; 
                 margin-left: 10px;
                 text-shadow: 1px 1px rgb(18, 68, 135);
                 vertical-align: middle;
                 transition: transform 0.3s ease;"),
                         tags$style(HTML("
    .fa-arrow-circle-right:hover {
      transform: translateX(5px);
    }
  "))
                       ),
                       
                       h3("Beta Version", 
                          style = "color: rgb(18, 68, 135); margin-top: 30px;"),
                       
                       p("This is a Beta version of SAVE, meaning it's a pre-release version 
            that's fully functional but still undergoing testing and refinement. 
            Beta testing helps us:"),
                       
                       tags$ul(
                         tags$li("Identify and fix any remaining issues"),
                         tags$li("Gather user feedback for improvements"),
                         tags$li("Refine the user experience"),
                         tags$li("Validate our social value calculations")
                       ),
                       
                       h3("Version History", 
                          style = "color: rgb(18, 68, 135); margin-top: 30px;"),
                       
                       tags$table(class = "version-table",
                                  tags$thead(
                                    tags$tr(
                                      tags$th("Version"),
                                      tags$th("Date"),
                                      tags$th("Description")
                                    )
                                  ),
                                  tags$tbody(
                                    tags$tr(
                                      tags$td("1.0.0-beta"),
                                      tags$td("December 2024"),
                                      tags$td("Initial Beta release with core functionality including social 
                    value calculator, report generation, and AI assistant")
                                    ),
                                    tags$tr(
                                      tags$td("1.0.1-beta"),
                                      tags$td("January 2025"),
                                      tags$td("Enhanced report templates, improved AI assistant responses, 
                    and minor UI refinements")
                                    ),
                                    tags$tr(
                                      tags$td("1.0.2-beta"),
                                      tags$td("February 2025"),
                                      tags$td("(Planned) Additional visualization options and expanded 
                    methodology documentation")
                                    )
                                  )
                       )
                   ),
                   
                   # Feedback Form Panel (right side)
                   div(class = "feedback-form-container",
                       tags$iframe(
                         src = "https://docs.google.com/forms/d/e/1FAIpQLScm2DLPU8rtqdBrYXiGYp4JZ4jl5qStzfh9STrgmLzb9dbU9A/viewform?embedded=true",
                         width = "100%",
                         height = "100%",
                         frameborder = "0",
                         marginheight = "0",
                         marginwidth = "0"
                       )
                   )
               )
           )
         )
))


# ACCORDIAN -----------------------------------------------------------------------------------------------------
ui <- tagList(ui, br(),
              div(class = "accordion-container", 
                  tags$style(HTML("
                .feedback-page {
                  background: linear-gradient(rgba(255,255,255,0.3), rgba(255,255,255,0.3)), url('indirock.jpg');
                  background-size: cover; background-position:center; background-attachment:fixed; min-height:100vh; padding:0px;
                }
                .panel-container {display:flex; gap:20px; max-width:1400px; margin:0 auto; height:800px;}
                .feedback-form-container,.about-container {
                  background-color:rgba(255,255,255,0.75); border:1px solid rgb(198,163,92); border-radius:8px; padding:20px; backdrop-filter:blur(5px); height:100%; overflow-y:auto;
                }
                .feedback-form-container {flex:0 0 640px;}
                .about-container {flex:1;}
                .feedback-form-container iframe {height:100%!important; width:100%;}
                .version-table {width:100%; margin-top:20px; border-collapse:collapse;}
                .version-table th,.version-table td {border:1px solid rgb(198,163,92); padding:8px; text-align:left;}
                .version-table th {background-color:rgba(18,68,135,0.1);}
                .feedback-form-container::-webkit-scrollbar,.about-container::-webkit-scrollbar {width:8px;}
                .feedback-form-container::-webkit-scrollbar-track,.about-container::-webkit-scrollbar-track {background:rgba(255,255,255,0.5);}
                .feedback-form-container::-webkit-scrollbar-thumb,.about-container::-webkit-scrollbar-thumb {background:rgb(198,163,92); border-radius:4px;}
                ")),
                  tags$div(class = "accordion custom-accordion", id = "accordionExample",
                           # Item 1: ASSISTANT
                           div(class = "accordion-item",
                               h2(class = "accordion-header", id = "headingOne",
                                  tags$button(class = "accordion-button collapsed", type = "button", 
                                              `data-bs-toggle` = "collapse", `data-bs-target` = "#collapseOne", 
                                              `aria-expanded` = "false", `aria-controls` = "collapseOne", 
                                              span(class = "icon-padding", icon("comments")), "Chat with AssistantCoach.AI")),
                               div(id = "collapseOne", class = "accordion-collapse collapse", 
                                   `aria-labelledby` = "headingOne", `data-bs-parent` = "#accordionExample",
                                   div(class = "accordion-body",
                                       div(class = "card", 
                                           
                                           # In ui.R, update the div with class "card-body":
                                           div(class = "card-body",
                                               uiOutput("chat_output"),
                                               textInput("user_input", " ", placeholder = "Message"),
                                               actionBttn(inputId = "submit", label = "Send", style = "unite", 
                                                          size = "sm", color = "primary", icon = icon("paper-plane"),
                                                          class = "submit-button"),
                                               br(),
                                               div(class = "custom-spinner", id = "loading-spinner"),
                                               HTML("<small class='text-muted'>AssistantCoach.AI and can make mistakes. Check important info in the tooltip.</small>"),
                                               bslib::tooltip(
                                                 tags$span(id = "ai_tooltip", class = "custom-info-icon", icon("circle-info", class = "fa-light")),
                                                 HTML("Assistant Coach is an AI specifically trained to help you understand and communicate your club's social value using the SAVE tool.<br>
                                                       <strong>Please note:</strong> While AssistantCoach.AI strives to provide accurate and helpful information, it is an AI model and may occasionally make mistakes or have limitations in its knowledge. Always double-check important information and consult official SAVE documentation when needed."),
                                                 placement = "top", 
                                                 options = list(container = "body", html = TRUE, customClass = "custom-tooltip-class")
                                               )
                                           )
                                           )))),
                           
                           # Item 2: SAVE Explained 
                           div(class = "accordion-item",
                               h2(class = "accordion-header", id = "headingTwo",
                                  tags$button(class = "accordion-button collapsed", type = "button", 
                                              `data-bs-toggle` = "collapse", `data-bs-target` = "#collapseTwo", 
                                              `aria-expanded` = "false", `aria-controls` = "collapseTwo", 
                                              span(class = "icon-padding", icon("question-circle")), "SAVE Explained")),
                               div(id = "collapseTwo", class = "accordion-collapse collapse", 
                                   `aria-labelledby` = "headingTwo", `data-bs-parent` = "#accordionExample",
                                   div(class = "accordion-body", 
                                       HTML("
<p><span style='font-weight: bold;'>Value FC:</span> An easy-to-use tool developed by State of Life for the Essex F.A. to estimate the social value of grassroots football clubs in Essex.</p>

<p><span style='font-weight: bold;'>Social Value:</span> You're not just running a football club, you're building a community. SAVE helps you estimate your club's social, health and economic benefits in terms that funders understand.</p>

<p><span style='font-weight: bold;'>Inputs:</span> In the calculator tab, you'll need to tell us about:</p>
<ul>
    <li>Annual club expenditure - all your running costs over the last 12 months</li>
    <li>Regular volunteers - those helping at least monthly</li>
    <li>Regular adult players - those aged over 16 participating twice monthly</li>
    <li>Regular youth players - those aged under 16 participating twice monthly</li>
</ul>

<p><span style='font-weight: bold;'>Outputs:</span> We provide several ways to share your impact:</p>
<ul>
    <li><span style='font-weight: bold;'>Full Report</span> - includes methods, assumptions and detailed analysis</li>
    <li><span style='font-weight: bold;'>Media Pack</span> - press release and social media content</li>
    <li><span style='font-weight: bold;'>Slides</span> - ready to present to partners and investors</li>
    <li><span style='font-weight: bold;'>Data File</span> - CSV showing all calculation components</li>
</ul>

<p style='margin-top: 15px;'><small><span style='font-weight: bold;'>Note:</span> While State of Life ensures the model's integrity, clubs are responsible for the accuracy of their inputs and how they use the results.</small></p>
")))))),
              
              # FOOTNOTE ------------------------------------------------------------------------------------------------------------------
              div(style = "width: 100%; padding: 10px 0; display: flex; justify-content: space-between; align-items: center;",
                  div(style = "margin-left: 20px;", img(src = "SL_Logo-V1-Black.png", style = "height: 130px; width: auto;")),
                  div(style = "margin-right: 20px;", img(src = "sa_logo.png", style = "height: 130px; width: auto;")))
)  # Close final tagList