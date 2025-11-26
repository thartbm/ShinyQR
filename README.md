# ShinyQR

A Shiny app that takes a link and creates a QR code with it.

## Features

- Enter any URL to generate a QR code
- Preview the generated QR code in the browser
- Download the QR code as a PNG image

## Requirements

- R (version 4.0 or higher)
- R packages: `shiny`
- Python package: `qrcode` (provides the `qr` command-line tool)

### Installation

On Ubuntu/Debian systems, you can install the requirements with:

```bash
# Install R
sudo apt-get install r-base

# Install R Shiny package
sudo apt-get install r-cran-shiny

# Install Python qrcode package (provides the qr command)
sudo apt-get install python3-qrcode
```

## Usage

1. Clone this repository:
   ```bash
   git clone https://github.com/thartbm/ShinyQR.git
   cd ShinyQR
   ```

2. Run the app:
   ```bash
   R -e "shiny::runApp('app.R')"
   ```

   Or from within R:
   ```R
   shiny::runApp("app.R")
   ```

3. Open your browser to the URL shown in the console (typically `http://127.0.0.1:XXXX` where XXXX is a random port)

4. Enter a URL in the text box and click "Generate QR Code"

5. Download the generated QR code using the "Download QR Code" button

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.
