server <- function(input, output, session) {
        transactions <- reactiveVal(data.frame(
                Currency = character(0),
                Amount = numeric(0),
                Rate = numeric(0),
                Naira = numeric(0),
                stringsAsFactors = FALSE
        ))
        
        observeEvent(input$add, {
                new_transaction <- data.frame(
                        Currency = input$currency,
                        Amount = as.numeric(input$amount),
                        Rate = as.numeric(input$exchange_rate),
                        Naira = as.numeric(input$amount) * as.numeric(input$exchange_rate)
                )
                transactions(rbind(transactions(), new_transaction))
                
                # Reset input fields
                updateNumericInput(session, "amount", value = "")
                updateSelectInput(session, "currency", selected = "")
                updateNumericInput(session, "exchange_rate", value = "")
        })
        
        observeEvent(input$clear, {
                transactions(data.frame(
                        Currency = character(0),
                        Amount = numeric(0),
                        Rate = numeric(0),
                        Naira = numeric(0),
                        stringsAsFactors = FALSE
                ))
        })
        
        observeEvent(input$load_file, {
                req(input$load_file)
                file <- input$load_file$datapath
                loaded_transactions <- read.csv(file, stringsAsFactors = FALSE)
                transactions(loaded_transactions)
        })
        
        observeEvent(input$transactions_table_cell_edit, {
                info <- input$transactions_table_cell_edit
                str(info)
                i <- info$row
                j <- info$col
                v <- info$value
                
                # Update the transactions data frame
                updated_transactions <- transactions()
                updated_transactions[i, j] <- if (j %in% c(2, 3, 4)) as.numeric(v) else v
                
                # Recalculate Naira if Amount or Rate is edited
                if (j %in% c(2, 3)) {
                        updated_transactions$Naira[i] <- updated_transactions$Amount[i] * updated_transactions$Rate[i]
                }
                
                transactions(updated_transactions)
        })
        
        observeEvent(input$delete_button, {
                row_to_delete <- as.numeric(input$delete_button)
                updated_transactions <- transactions()[-row_to_delete, ]
                transactions(updated_transactions)
        })
        
        observeEvent(input$edit_button, {
                row_to_edit <- as.numeric(input$edit_button)
                showModal(modalDialog(
                        title = "Edit Transaction",
                        textInput("edit_currency", "Currency", value = transactions()[row_to_edit, "Currency"]),
                        numericInput("edit_amount", "Amount", value = transactions()[row_to_edit, "Amount"]),
                        numericInput("edit_rate", "Rate", value = transactions()[row_to_edit, "Rate"]),
                        actionButton("save_edit", "Save"),
                        easyClose = TRUE,
                        footer = NULL
                ))
                
                observeEvent(input$save_edit, {
                        updated_transactions <- transactions()
                        updated_transactions[row_to_edit, "Currency"] <- input$edit_currency
                        updated_transactions[row_to_edit, "Amount"] <- input$edit_amount
                        updated_transactions[row_to_edit, "Rate"] <- input$edit_rate
                        updated_transactions[row_to_edit, "Naira"] <- input$edit_amount * input$edit_rate
                        transactions(updated_transactions)
                        removeModal()
                })
        })
        
        output$transactions_table <- renderDT({
                datatable(
                        transactions() %>%
                                mutate(
                                        Amount = format(Amount, big.mark = ","),
                                        Naira = paste("₦", format(Naira, big.mark = ",")),
                                        Edit = paste0('<button id="edit_', row_number(), '" type="button" class="btn btn-primary btn-sm edit_btn">Edit</button>'),
                                        Delete = paste0('<button id="delete_', row_number(), '" type="button" class="btn btn-danger btn-sm delete_btn">Delete</button>')
                                ),
                        options = list(pageLength = 5, autoWidth = TRUE),
                        escape = FALSE,
                        selection = 'none'
                )
        }, server = FALSE)
        
        output$total_naira <- renderText({
                total_naira <- sum(transactions()$Naira, na.rm = TRUE)
                paste("₦", format(total_naira, big.mark = ","))
        })
        
        output$save_file <- downloadHandler(
                filename = function() {
                        paste("transactions-", Sys.Date(), ".csv", sep = "")
                },
                content = function(file) {
                        write.csv(transactions(), file, row.names = FALSE)
                }
        )
        
        output$download_csv <- downloadHandler(
                filename = function() {
                        paste("transactions-", Sys.Date(), ".csv", sep = "")
                },
                content = function(file) {
                        data_to_download <- transactions()
                        total_naira_value <- sum(data_to_download$Naira, na.rm = TRUE)
                        total_row <- data.frame(
                                Currency = "Total",
                                Amount = "",
                                Rate = "",
                                Naira = total_naira_value
                        )
                        data_to_download <- rbind(data_to_download, total_row)
                        data_to_download <- data_to_download %>%
                                mutate(
                                        Amount = format(Amount, big.mark = ","),
                                        Naira = format(Naira, big.mark = ",")
                                )
                        write.csv(data_to_download, file, row.names = FALSE)
                }
        )
        
        output$download_word <- downloadHandler(
                filename = function() {
                        paste("transactions-", Sys.Date(), ".docx", sep = "")
                },
                content = function(file) {
                        data_to_download <- transactions()
                        total_naira_value <- sum(data_to_download$Naira, na.rm = TRUE)
                        total_row <- data.frame(
                                Currency = "Total",
                                Amount = "",
                                Rate = "",
                                Naira = total_naira_value
                        )
                        data_to_download <- rbind(data_to_download, total_row)
                        data_to_download <- data_to_download %>%
                                mutate(
                                        Amount = format(Amount, big.mark = ","),
                                        Naira = format(Naira, big.mark = ",")
                                )
                        doc <- read_docx()
                        doc <- body_add_table(doc, value = data_to_download, style = "table_template")
                        print(doc, target = file)
                }
        )
}
