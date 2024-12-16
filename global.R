# Dashboard and UI Frameworks --------------------------------------------------
library(shiny); library(shinydashboard); library(bs4Dash); library(bslib); library(shinythemes)

# Shiny Extensions and Components ----------------------------------------------
library(shinyjs); library(shinyBS); library(shinyWidgets); library(shinyalert); library(shinyjqui); library(bsicons)

# Data Manipulation and Analysis -----------------------------------------------
library(dplyr); library(magrittr); library(scales)

# Visualization ----------------------------------------------------------------
library(ggplot2); library(plotly); library(DT); library(d3r); library(sunburstR); library(waterfalls)

# Document Processing and Reporting --------------------------------------------
library(rmarkdown); library(officer); library(officedown); library(openxlsx2); library(readxl)

# API and Data Exchange --------------------------------------------------------
library(httr); library(jsonlite)

# Error Handling Function ------------------------------------------------------
handle_missing_packages <- function() { required_packages <- c("shiny","shinydashboard","bs4Dash","bslib","shinythemes","shinyjs","shinyBS","shinyWidgets","shinyalert","shinyjqui","bsicons","dplyr","magrittr","scales","ggplot2","plotly","DT","d3r","sunburstR","waterfalls","rmarkdown","officer","officedown","openxlsx2","readxl","httr","jsonlite"); missing_packages <- required_packages[!required_packages %in% installed.packages()[,"Package"]]; if(length(missing_packages)>0){message("Installing missing packages: ", paste(missing_packages, collapse = ", ")); install.packages(missing_packages); sapply(missing_packages, require, character.only=TRUE)} }

# Call the function to check and install missing packages -----------------------
handle_missing_packages()

# SPORTING ASSETS COLORS -------------------------------------------------------
sa_colors <- list(
  white="#FFFFFF",
  gray="#F5F5F7",
  black="#000000",
  blue_pale="#E1F0FF",
  red_orange="#E32C00",
  blue_light="#7CC4FF",
  blue_mid="#0046FF",
  navy_dark="#00003C")

# CUSTOM CSS -------------------------------------------------------------------
custom_css <- sprintf("
/* SA Brand Colors */
:root { --sa-white: %s; --sa-gray: %s; --sa-black: %s; --sa-blue-pale: %s; --sa-red-orange: %s; --sa-blue-light: %s; --sa-blue-mid: %s; --sa-navy-dark: %s; }

/* Typography */
@font-face {font-family:'FS Jack';src:url('FSJack-Light.woff2') format('woff2');font-weight:300;font-style:normal;}
@font-face {font-family:'FS Jack';src:url('FSJack-Bold.woff2') format('woff2');font-weight:700;font-style:normal;}
body {font-family:'FS Jack',sans-serif;font-weight:300;color:var(--sa-navy-dark);background-color:var(--sa-white);}
h1,h2,h3,h4,h5,h6 {font-family:'FS Jack',sans-serif;font-weight:700;color:var(--sa-navy-dark);}
p,li,span,div {font-family:'FS Jack',sans-serif;font-weight:300;color:var(--sa-navy-dark);}

/* Core Layout */
.accordion-button {display:flex;align-items:center;padding-left:10px;background-color:var(--sa-navy-dark);color:var(--sa-white);}
.accordion-button .fa,.accordion-button .icon-padding {margin-right:10px;}
.accordion-container {margin:0 auto;width:70%%;background-color:var(--sa-gray);}

/* Custom Accordion */
.custom-accordion .accordion-body {border:1px solid var(--sa-blue-mid);padding:1.5rem;font-size:16px;background-color:var(--sa-white);font-family:'source-serif-4',serif;font-weight:400;}
.custom-accordion .accordion-header {background-color:var(--sa-navy-dark);color:var(--sa-white);font-family:'source-serif-4',serif;font-weight:700;border:1px solid var(--sa-blue-mid);}

/* Input Fields */
.input-container {display:flex;flex-wrap:wrap;align-items:center;margin-bottom:15px;background-color:var(--sa-white);}
.input-field {flex:1 1 auto;min-width:0;}
.input-label {font-family:'source-serif-4',serif;font-weight:700;color:var(--sa-navy-dark);margin-right:15px;font-size:16px;}

/* Navigation Styles */
.navbar {background:var(--sa-navy-dark)!important;min-height:30px;height:auto!important;padding-bottom:10px;border-bottom:2px solid var(--sa-blue_mid);border:none!important;box-shadow:none!important;}
.navbar-nav {float:none;text-align:center;margin-top:50px;position:relative;left:50%%;transform:translateX(-50%%);display:flex;gap:40px;padding:40px 0 20px 0;}
.navbar-nav>li {float:none;display:inline-block;align-items:center;}
.navbar-nav>li>a {color:var(--sa-white)!important;font-size:24px;padding:10px 20px;text-shadow:2px 2px 4px rgba(0,0,0,0.5);font-family:'FS Jack',sans-serif;font-weight:700;transition:all 0.3s ease;border-radius:4px;white-space:nowrap;text-align:center;line-height:1.2;}
.navbar-nav>li.active>a {background-color:var(--sa-red-orange)!important;color:var(--sa-white)!important;}
.navbar-nav>li>a:hover:not(.active),.navbar-nav>li>a:focus {background-color:var(--sa-blue_mid)!important;opacity:0.8;}
.navbar-header,.navbar-toggle {display:none;}

/* Video Container */
.video-container {display:flex;justify-content:center;flex-wrap:wrap;gap:20px;}
.video-item {flex:0 1 100%%;max-width:100%%;border:2px solid var(--sa-blue_mid);border-radius:8px;}
.video-item video {width:100%%;height:auto;}

/* Background Animation */
.animated-background {position:fixed;top:0;left:0;width:100%%;height:100%%;z-index:-1;overflow:hidden;background:linear-gradient(45deg,rgba(18,68,135,0.05),rgba(198,163,92,0.05));}
.animated-background img {position:absolute;opacity:0.3;}
.animated-background img:nth-child(1) {top:20%%;left:-10%%;animation:float-1 30s infinite linear;filter:sepia(100%%) saturate(300%%) brightness(70%%) hue-rotate(180deg);}
.animated-background img:nth-child(2) {bottom:10%%;right:-5%%;animation:float-2 25s infinite linear;filter:sepia(100%%) saturate(300%%) brightness(70%%) hue-rotate(200deg);}

/* Button Styles */
.sa-button {
  background-color: var(--sa-navy-dark)!important;
  border: 2px solid var(--sa-blue-mid)!important;
  font-family: 'FS Jack', sans-serif!important;
  font-weight: 700!important;
  color: white!important;
  text-shadow: none!important;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1)!important;
  transition: all 0.3s ease!important;
  opacity: 0.9!important;
}

.sa-button:hover {
  background-color: var(--sa-blue-mid)!important;
  border-color: var(--sa-navy-dark)!important;
  color: var(--sa-navy-dark)!important;
  opacity: 1!important;
  transform: translateY(-1px)!important;
  box-shadow: 0 4px 8px rgba(0,0,0,0.2)!important;
}

.sa-button:active,
.sa-button.active {
  background-color: rgb(206,50,49)!important;
  border-color: var(--sa-blue-mid)!important;
  color: white!important;
  transform: translateY(1px)!important;
  box-shadow: 0 1px 2px rgba(0,0,0,0.1)!important;
}

/* Loading Spinner */
.custom-spinner {display:none;border:4px solid #f3f3f3;border-top:4px solid #3498db;border-radius:50%%;width:30px;height:30px;animation:spin 1s linear infinite;margin:0 auto;}

/* Animations */
@keyframes float-1 {0%%{transform:translateX(0) rotate(0deg);}100%%{transform:translateX(120%%) rotate(360deg);}}
@keyframes float-2 {0%%{transform:translateX(0) rotate(0deg);}100%%{transform:translateX(-120%%) rotate(-360deg);}}
@keyframes spin {0%%{transform:rotate(0deg);}100%%{transform:rotate(360deg);}}

/* Responsive Design */
@media (max-width:768px){.accordion-container{width:90%%;} .navbar{min-height:100px;} .navbar-nav{margin-top:20px;position:relative;left:0;transform:none;flex-direction:column;gap:15px;width:100%%;text-align:center;padding:30px 0;} .navbar-nav>li{display:block;margin:8px 0;} .navbar-nav>li>a{font-size:18px;display:inline-block;min-width:150px;padding:10px 20px;}}
@media (max-width:480px){.navbar-nav>li{display:block;} .navbar-nav>li>a{font-size:16px;padding:5px;}}
", sa_colors$white, sa_colors$gray, sa_colors$black, sa_colors$blue_pale, sa_colors$red_orange, sa_colors$blue_light, sa_colors$blue_mid, sa_colors$navy_dark)

# THEME SETUP ------------------------------------------------------------------
my_theme <- bs_theme(bootswatch="flatly",primary=sa_colors$blue_mid,secondary=sa_colors$navy_dark,success=sa_colors$blue_light,warning=sa_colors$red_orange) |> bs_add_rules("@import url('https://fonts.adobe.com/fonts/source-serif');")

# UTILITY FUNCTIONS --------------------------------------------------
create_input_field <- function(id, label, input_field, tooltip_text = NULL) {
  div(
    class = "input-container",
    span(
      class = "input-label",
      tags$strong(label),
      if (!is.null(tooltip_text)) {
        bslib::tooltip(
          tags$span(
            id = paste0(id, "_tooltip"),
            class = "custom-info-icon",
            icon("circle-info", class = "fa-light")
          ),
          tooltip_text,
          placement = "top",
          options = list(
            container = "body", 
            html = TRUE, 
            customClass = "custom-tooltip-class",
            template = sprintf('<div class="tooltip" role="tooltip"><div class="tooltip-arrow"></div><div class="tooltip-inner" style="background-color: var(--sa-white); color: var(--sa-navy-dark); border: 2px solid var(--sa-blue-mid); font-family: source-serif-4, serif; font-weight: 400;"></div></div>')
          )
        )
      }
    ),
    div(
      class = "input-field",
      if (inherits(input_field, "shiny.tag") && input_field$name == "input" && input_field$attribs$type == "number") {
        input_field$attribs$class <- paste(input_field$attribs$class, "numeric-input")
        input_field
      } else {
        input_field
      }
    )
  )
}


