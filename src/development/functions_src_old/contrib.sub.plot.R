#' Contrib.sub.plot
#'
#' Créer un graphe de type geom_line à partir d'un vecteur de variables issues d'une base de données 
#' D'autres arguments de la fonction permette de choisir le type d'indicateur et de compléter les labels 
#'
#' @param data double(1) a dataframe created with the function loadResults()
#' @param label_series character(1) string, vecteur avec le label des variables qui seront tracées
#' @param startyear numeric(1), date de début de la période tracée
#' @param endtyear numeric(1), date de fin  de la période tracée
#' @param unit character(1) string , choix de legende pour l'axe des x (en pourcentage ou en niveau)
#' @param decimal numeric(1) , choix de la décimale retenue après la virgule
#' @param titleplot character(1) string , titre du graphique
#' @param template_default character(1) string, nom du thème ggplot retenu pour le plot
#' @return un ggplot
#' @import ggh4x ggplot2
#' @family function
#' @export
contrib.sub.plot <- function(data,
                         label_series = NULL,
                         startyear = NULL,
                         endyear = NULL,
                         line_tot = NULL,
                         unit = "percent",
                         decimal = 0.1,
                         titleplot = "",
                         template=template_default) {
  # To debug the function step by step, activate line below
  # browser()

  
  ## Format of the output plot
  format_img <- c("svg")  # Choose format: "png", "svg"
  
  
  
  data.1 <- data %>% filter(year > startyear & year < endyear, 
                            !is.na(label), 
                            abs(value) > 0.00001)

  series <- unique(data.1$variable)
  
  # Palette de n couleurs (nombre de secteurs distingués) 
  pal <- sequential_hcl(n = length(series), h = c(-80, 78), c = c(60, 75, 55), l = c(40, 91), power = c(0.8, 1), register = )
  
  
  
   if (is.null(label_series)){
    label_series =  unique(data.1$label)
  }
  
  if (is.null(startyear)){startyear  =  min(data$year)}
  if (is.null(endyear)){endyear  =  max(data$year)}
  if (is.null(line_tot)){line_tot  =  FALSE}

  
  plotseries <- ggplot() +
    geom_bar(data = data.1 , aes(x = year, y = value, fill = variable),
             stat= "identity", width = 0.9, position = position_stack(reverse = TRUE)) +
    scale_y_continuous(labels = scales::percent_format(accuracy = decimal)) + 
    scale_fill_manual(values = pal[1:length(series)], limits = series,
                      labels = label_series)  + 
    labs(x = "", title = titleplot) 
 
  
  if (line_tot == TRUE){
    data.2 <- data %>% filter(year > startyear & year < endyear &
                                is.na(label))
    plotseries <-  plotseries + 
      geom_line(data = data.2 , aes(x = year, y = value),  size = .4)
  }
  
  
  if(unit != "percent") {
    plotseries <- plotseries +
      scale_y_continuous(labels = scales::label_number(accuracy = decimal, scale = unit))
  }
  
  ifelse(template =="ofce", 
         
         plotseries <- plotseries +  ofce::theme_ofce(base_family = "Calibri"), 
         
         plotseries <- plotseries +  theme(legend.position = "bottom") 
  ) 
  
  plotseries <- plotseries + theme(legend.title = element_blank(),
                                   axis.title.y = element_blank() ) 
  
  plotseries
}
