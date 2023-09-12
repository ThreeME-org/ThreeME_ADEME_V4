message_3me <-   function(text_message, colour_bg =  "seagreen2" , text_black = TRUE , symbol_u = "\U2705"){
    
    bg_fn <- crayon::make_style(colour_bg, bg= TRUE) 
    ct_fn <- crayon::make_style(ifelse(text_black,"black","white"), bg= FALSE) 
    
    new_message<- stringr::str_c(text_message, "\n") %>% ct_fn %>% bg_fn %>% crayon::bold()
    cat(stringr::str_c("\n ",symbol_u, " " ,new_message)
        
)
}
    




message_ok <- function(txt_message= "TEST"){
  
message_3me(text_message = txt_message,
            colour_bg = "seagreen2",
            text_black = TRUE,
            symbol_u = "\U2705")
  
}

message_not_ok <- function(txt_message= "TEST"){
  
  message_3me(text_message = txt_message,
              colour_bg = "firebrick",
              text_black = FALSE,
              symbol_u = "\U274C")

}

message_warning <- function(txt_message= "TEST"){
  
  message_3me(text_message = txt_message,
              colour_bg = "darkorange",
              text_black = TRUE,
              symbol_u = "\U2757")
  
}

message_stopbomb <- function(txt_message= "TEST"){
  
  message_3me(text_message = txt_message,
              colour_bg = "firebrick",
              text_black = FALSE,
              symbol_u = "\U1F4A3 \U1F4A3")
  
}

message_save <- function(txt_message= "TEST"){
  
  message_3me(text_message = txt_message,
              colour_bg = "thistle2",
              text_black = TRUE,
              symbol_u = "\U1F4BE")
  
}
message_delete <- function(txt_message= "TEST"){
  
  message_3me(text_message = txt_message,
              colour_bg = "thistle2",
              text_black = TRUE,
              symbol_u = "\U1F6AE")
  
}

message_any <- function(txt_message= "TEST", custom_symbol = ""){
  
  message_3me(text_message = txt_message,
              colour_bg = "thistle2",
              text_black = TRUE,
              symbol_u = custom_symbol)
  
}

message_main_step<-function(txt_message= "TEST"){
  
  message_3me(text_message = txt_message,
              colour_bg = "steelblue3",
              text_black = TRUE,
              symbol_u = "\U1F31F")
  
}

message_sub_step<-function(txt_message= "TEST"){
  
  message_3me(text_message = txt_message,
              colour_bg = "steelblue1",
              text_black = TRUE,
              symbol_u = "\U2B50")
  
}
