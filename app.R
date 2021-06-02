#install.packages("shiny")
library(shiny)
library(ggmap)
library(data.table)
library(tidywerse)

load("data/district_latlon.RData")


ui <- fluidPage(
  titlePanel("2020 PM10 in Seoul"),
  
  sidebarLayout(
    sidebarPanel(
      
      helpText("Monthly PM10 in Seoul"),
      
      selectInput("month",
                  label = "Month",
                  choices = c("01","02","03",
                              "04","05","06",
                              "07","08","09",
                              "10","11","12"),
                  selected = "01"),
      
      checkboxInput("boarder",
                    label = "Province", value = TRUE),
      img(src = "seoulmark.jpg", height = 150, width = 300,align="center")
    ),
    mainPanel(
      h1("2020 Monthly PM10 in Seoul", align="center",
         style = "font-family:'times';font-si10pt"),
      h2("by province",align="center", 
         style = "font-family:'times';font-si7pt"),
      plotOutput("map"))
  )
)



server <- function(input, output){
  
  monthInput <- reactive({
    filter(district_latlon, month == input$month)
  })
  
  boarderInput <- reactive({
    if(input$boarder){
      return(p + geom_polygon(data = seoul_map, 
                              aes(x = long, y = lat,
                                  group = group),
                              fill = "black", alpha = 0.2, 
                              color = "white"))
    }else{
      return(p)
    }
  })
  
output$map <- renderPlot({
  boarderInput() + geom_point(data=monthInput(),mapping=aes(x=lon,y=lat,colour=PM10),,size=12,alpha=0.6)+
        scale_colour_continuous(low='yellow', high='red')
  })
}

shinyApp(ui=ui, server=server)
