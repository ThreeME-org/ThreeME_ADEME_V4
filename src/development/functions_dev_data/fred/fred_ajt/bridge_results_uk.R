
bridgeResultsUK <- function() {
  bridge_results <- list(
    "Agriculture and land use" = c("sagr", "sfor"),
    "Industry-energy intensive EUETS" = c("smin", "spla", "spap", "sgla", "sigo"),
    "Industry-non-energy-intensive" = c("sfoo", "sveh", "scgo"),
    "Surface transport" = c("sroa", "srai"),
    "Aviation and shipping" = c("swat", "sair"),
    "Buildings" = c("scon"),
    "Services" = c("spri", "spub", "senu", "sewi", "seso", "sehy", "seot"),
    "Fuel EUETS" = c("sche", "soil", "sgas", "seoi", "sega", "seco")
  )
  
  lapply(1:length(bridge_results), function(i) {
    tibble(agg_sec = names(bridge_results)[i], sec = bridge_results[[i]])
  }) %>% bind_rows
}
