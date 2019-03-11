library("rgbif")
library("bdvis")
library("shiny")
library("shinydashboard")
library("shinyWidgets")


# key <- name_backbone(name = "Mammalia")$usageKey
# occ <-occ_search(taxonKey = key,country = 'US', limit = 10000 ,return = "data")
# write.csv(occ, file = "MyData.csv")
occ <- read.csv(file="occ.csv", header=TRUE, sep=",")

occ <- format_bdvis(occ, source = "rgbif")
occtemporal <- format_bdvis(occ, source = "rgbif")

occ <- occ[!is.na(occ$Latitude) & !is.na(occ$Longitude),
                     c("scientificName","Longitude", "Latitude")]
occmap <- format_bdvis(occ, source = "rgbif")
occtemp <- format_bdvis(occ, source = "rgbif")



 ui <-  dashboardPage(
     title = "Visualizations for Biodiversity Data", skin = "purple",
     dashboardHeader(title = "Biodiversity Data"),



     dashboardSidebar(
       sidebarMenu(
         menuItem("Introduction", tabName = "introduction", icon = icon("home")),
         menuItem("Data", tabName = "data", icon = icon("table")),
         menuItem("visualization", tabName = "visualization", icon = icon("eye"), 
                  menuSubItem("MapGrid View", tabName = "maps", icon = icon("map")),
                  menuItem("Tempolar View", icon = icon("circle"),
                           menuSubItem("Tempolar (Day wise)", tabName = "td", icon = icon("dyalog")),
                           menuSubItem("Tempolar (Week wise)", tabName = "tw", icon = icon("weebly")),
                           menuSubItem("Tempolar (Month wise)", tabName = "tm", icon = icon("bullseye"))
                           ),
                  menuSubItem("Chronohorogram View", tabName = "ch", icon = icon("dot-circle"))
                  )
         
       )
     ),
     dashboardBody(
       tabItems(
         tabItem(tabName = "introduction",
                 h1("*Enhancing Visualizations for Biodiversity Data"), h3("Medium Test: To make a shiny app."),h4("This shiny application helps to visulaize Biodiversity data comming from GBIF."),h4("You can click on data Tab to see how data from GBIF look. "),h4("Click on visualization to see diffrent visual representation of data."), br(),h3("*BY: Rahul Chauhan")         ),
         tabItem(tabName = "data",
                 fluidRow(h1("Georeferenced records of Mammals"),
                          br(), h3("10,000 GBIF's occurrence records of Mammals in the U.S"), br(), br()),
                 fluidRow(tabPanel(title = "Mammals Geograph Data",status = "primary",solidHeader = T, dataTableOutput('table'), background = "aqua"))
         ),
         tabItem(tabName = "maps",
                 plotOutput("map")
                  ),
         tabItem(tabName = "td",
                 plotOutput("td")),
         tabItem(tabName = "tw",
                 plotOutput("tw")),
         tabItem(tabName = "tm",
                 plotOutput("tm")),
         tabItem(tabName = "ch",
                 plotOutput("cho")
                 )
         
       )
     )
   )


 # server
  server <- function(input, output){
   output$table = renderDataTable(occ)
   output$map = renderPlot({
     mapgrid(indf = occmap, ptype = "records",
             title = "distribution of Mammals",
             bbox = NA, legscale = 0, collow = "blue",
             colhigh = "red", mapdatabase = "county",
             region = ".", customize = NULL)
   })
   output$td = renderPlot({
     tempolar(occtemporal, color="green", title="Tempolar daily",
              plottype="r", timescale="d")
   })
   output$tw = renderPlot({
     tempolar(occtemporal, color="red", title="Tempolar Weekly",
              plottype="r", timescale="w")
   })
   output$tm = renderPlot({
     tempolar(occtemporal, color="blue", title="Tempolar monthly",
              plottype="r", timescale="m")
   })
   output$cho = renderPlot({
     chronohorogram(occtemporal)
   })
   
  }

  shinyApp(ui, server)
