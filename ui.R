library(shiny)
suppressWarnings(library(shinythemes))
suppressWarnings(library(dplyr))
suppressWarnings(library(DT))
suppressWarnings(library(openxlsx))
suppressWarnings(library(officer))
suppressWarnings(library(scales))


currencies <- c("USD", "EUR", "GBP", "JPY", "AUD", "CAD", "CHF", "CNY", "SEK", "NZD", "NOK", "MXN", "SGD", "HKD", "INR", "BRL", "RUB", "ZAR", "TRY", "KRW", "IDR", "SAR", "MYR", "THB", "VND", "AED", "QAR", "EGP", "KES", "GHS", "NGN")

currency_names <- c("US Dollar", "Euro", "British Pound", "Japanese Yen", "Australian Dollar", "Canadian Dollar", "Swiss Franc", "Chinese Yuan", "Swedish Krona", "New Zealand Dollar", "Norwegian Krone", "Mexican Peso", "Singapore Dollar", "Hong Kong Dollar", "Indian Rupee", "Brazilian Real", "Russian Ruble", "South African Rand", "Turkish Lira", "South Korean Won", "Indonesian Rupiah", "Saudi Riyal", "Malaysian Ringgit", "Thai Baht", "Vietnamese Dong", "Emirati Dirham", "Qatari Riyal", "Egyptian Pound", "Kenyan Shilling", "Ghanaian Cedi", "Nigerian Naira")

currency_codes <- c("Albania", "Algeria", "Antiles","Armenia", "Australia", "Azerbaijan", "Bahamas", "Bahrain", "Bangladesh", 
                    "Barbados", "Belize", "Falkland", "Bermuda", "Bosnia", "Botswana", "Brazil", 
                    "Bulgaria", "Burnei", "Canada", "Old Canada", "Cayman", "Cedes", "dmg Cedes", "Chile", 
                    "Denmark", "Dominican", "Dutch Mark", "Dutch Guilder", "Chzech korun", "Cameroon", "Dubai", 
                    "Eastern Caribbean", "Egypt", "Ethiopia", "DMG euro",  "Euro", "Fiji", "Forint", "Gambia", "Georgia", "Gibraltar", 
                    "Guernsey", "Hong kong", "Honduras", "Iceland", "India", "Old rupees", "Indonesia", "Iraq", "Irish", 
                    "Israel","Old Israel", "Jamaica", "Isle of man", "Jordan", "Kenya", "Korea", "old Korea", "Old Korea", "Old Rand",
                    "Old Riyal", "Kuna", 
                    "Kuwait", "Old Kuwait", "Libya", "Lesotho", "Macau", "Magrib", "old Magrib", "Malaysia", "Maldives", 
                    "Mauritius", "Mexico", "Namibia", "New zealand", "Norway", "Moldova", "Oman", "Pakistan", "Peru", 
                    "Philippines", "Polski", "Pounds", "Old Pounds", "Qatar", "Old Qatar", "Riyal", "Romania", "Russia", 
                    "Rwanda", "Rand", "Scotland", "Serbia", "Slovakia", "Solomon", "white$", "small white$", "Seychelles", 
                    "Singapore", "Suriname", "Swaziland", "Sweden", "Swiss", "Old Swiss", "Taiwan", "Old Taiwan", "Tanzania", "Thailand", 
                    "Trinidad Tobago", "Tunisia", "Turkey", "Uganda", "Ukraine", "Uruguay", "Vietnam", "Big Yuan", "small Yuan", 
                    "Zambia", "1-1 Yuan", "P-coins", "E-coins", "Canada coins", "CFA-coins", "Cameroon coins", "DM-coins", 
                    "SW-coins", "Riyal coins", "Korea coins","Yen", "Yen coins", "UAE-coins", "$-coins", "DMG$", "DMG£", 
                    "MKK", "Half-Half$", "DMG 1-1$", "1-1P", "1-1$", "1-1 Korea")


shinyUI(
        navbarPage("Currency Converter App", theme = shinytheme("cerulean"),
                   tabPanel("Currency Converter",
                            fluidPage(
                                    titlePanel("Currency to Naira Converter"),
                                    sidebarLayout(
                                            sidebarPanel(
                                                    selectInput("currency", "Currency", choices = c("", currency_codes), selected = ""),
                                                    numericInput("amount", "Amount", value = ""),
                                                    numericInput("exchange_rate", "Exchange Rate", value = ""),
                                                    actionButton("add", "Add Transaction"),
                                                    actionButton("clear", "Clear Transactions"),
                                                    fileInput("load_file", "Load Transactions", accept = ".csv"),
                                                    downloadButton("save_file", "Save Transactions"),
                                                    downloadButton("download_csv", "Download CSV"),
                                                    downloadButton("download_word", "Download Word")
                                            ),
                                            mainPanel(
                                                    DTOutput("transactions_table"),
                                                    textOutput("total_naira")
                                            )
                                    ),
                                    tags$script(HTML("
        $(document).on('click', 'button.edit_btn', function() {
            var row_id = $(this).attr('id').split('_')[1];
            Shiny.onInputChange('edit_button', row_id);
        });
        $(document).on('click', 'button.delete_btn', function() {
            var row_id = $(this).attr('id').split('_')[1];
            Shiny.onInputChange('delete_button', row_id);
        });
    "))
                            )
                            

                   )
                   
        )
)
