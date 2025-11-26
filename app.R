# ShinyQR - QR Code Generator (qrcode package version)
library(shiny)
library(qrcode)
library(png)

# Define UI
ui <- fluidPage(
  titlePanel("ShinyQR - QR Code Generator"),
  
  sidebarLayout(
    sidebarPanel(
      p("Use a URL starting with https:// to link to a website."),
      p("Use a URL like 'mailto:name@domain.ca' to create an email link."),
      textInput(
        inputId = "url_input",
        label = "Enter URL:",
        value = "https://deniseh.lab.yorku.ca",
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
    
    # Basic URL format validation (allow typical URL characters)
    if (!grepl("^[a-zA-Z0-9:/.?&=_%-@#~+]+$", url)) {
      showNotification("Invalid URL format", type = "error")
      return()
    }
    
    # Create a unique filename
    qr_file <- file.path(qr_dir, paste0("qr_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".png"))
    
    # Generate QR code using the qrcode R package and write a PNG (no external system call)
    success <- tryCatch({
      # Generate QR code matrix (TRUE/FALSE or 1/0). Function name and return shape are from the qrcode package.
      mat <- qrcode::qr_code(url)
      
      # Ensure numeric matrix (1 = dark module, 0 = light)
      if (is.logical(mat)) {
        mat_num <- matrix(as.integer(mat), nrow = nrow(mat), ncol = ncol(mat))
      } else {
        mat_num <- matrix(as.integer(mat), nrow = nrow(mat), ncol = ncol(mat))
      }
      
      # Upsample each QR module to make a nicer PNG (module_size pixels per QR module)
      module_size <- 8L
      img_big <- kronecker(1 - mat_num, matrix(1, module_size, module_size)) # 1 = white, 0 = black
      
      # writePNG expects values in [0,1]. Passing a matrix writes a greyscale PNG.
      png::writePNG(img_big, target = qr_file)
      
      TRUE
    }, error = function(e) {
      FALSE
    })
    
    if (isTRUE(success) && file.exists(qr_file) && file.info(qr_file)$size > 0) {
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
