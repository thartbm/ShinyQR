# ShinyQR - A Shiny app that generates QR codes from links
# 
# This application takes a URL input and generates a QR code image.

library(shiny)

# Define UI
ui <- fluidPage(
  titlePanel("ShinyQR - QR Code Generator"),
  
  sidebarLayout(
    sidebarPanel(
      textInput(
        inputId = "url_input",
        label = "Enter URL:",
        value = "https://github.com",
        placeholder = "Enter a URL here..."
      ),
      actionButton(
        inputId = "generate_btn",
        label = "Generate QR Code"
      ),
      br(),
      br(),
      downloadButton(
        outputId = "download_btn",
        label = "Download QR Code"
      )
    ),
    
    mainPanel(
      h3("Generated QR Code:"),
      imageOutput("qr_image", height = "auto")
    )
  )
)

# Define server logic
server <- function(input, output, session) {
  # Create a unique subdirectory for this session's QR codes
  qr_dir <- file.path(tempdir(), paste0("shinyqr_", Sys.getpid()))
  if (!dir.exists(qr_dir)) {
    dir.create(qr_dir, recursive = TRUE)
  }
  
  # Reactive value to store the path of the generated QR code
  qr_path <- reactiveVal(NULL)
  
  # Generate QR code when button is clicked
  observeEvent(input$generate_btn, {
    req(input$url_input)
    
    # Validate URL is not empty
    url <- trimws(input$url_input)
    if (nchar(url) == 0) {
      showNotification("Please enter a URL", type = "error")
      return()
    }
    
    # Validate URL format (basic validation to prevent malicious input)
    # Allow standard URL characters including protocol, path, query, and fragment
    if (!grepl("^[a-zA-Z0-9:/.?&=_%-@#~+]+$", url)) {
      showNotification("Invalid URL format", type = "error")
      return()
    }
    
    # Create a unique filename
    qr_file <- file.path(qr_dir, paste0("qr_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".png"))
    
    # Generate QR code using the qr command
    # shQuote provides shell escaping for the URL
    cmd <- paste0("qr ", shQuote(url), " > ", shQuote(qr_file))
    result <- tryCatch({
      system(cmd)
    }, error = function(e) {
      -1
    })
    
    # Check if file was created successfully
    file_ok <- tryCatch({
      file.exists(qr_file) && file.info(qr_file)$size > 0
    }, error = function(e) {
      FALSE
    })
    
    if (result == 0 && file_ok) {
      qr_path(qr_file)
      showNotification("QR Code generated successfully!", type = "message")
    } else {
      showNotification("Failed to generate QR code", type = "error")
    }
  })
  
  # Render the QR code image
  output$qr_image <- renderImage({
    req(qr_path())
    
    list(
      src = qr_path(),
      alt = "QR Code",
      width = 330,
      height = 330
    )
  }, deleteFile = FALSE)
  
  # Download handler
  output$download_btn <- downloadHandler(
    filename = function() {
      paste0("qrcode_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".png")
    },
    content = function(file) {
      req(qr_path())
      file.copy(qr_path(), file)
    }
  )
}

# Run the application
shinyApp(ui = ui, server = server)
