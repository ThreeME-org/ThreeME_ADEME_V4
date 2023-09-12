### Exemple de couleurs pour constituer des palettes propres aux publi ThreeME 

### Palettes & Couleurs 
rep_pal <- list()

pal <- colorspace::qualitative_hcl(n = 12, h = c(20, 200), c = 70, l = 60, register = "Palette_p2")
rep_pal[[str_c("cb_palette_p1")]]  <- c("#fbc572", "#fb8072", "#9fc7da","#68a6c5","#466963")
rep_pal[[str_c("cb_palette_CTR.FR")]] <- c("#8dd3c7","#ffffb3") #
rep_pal[[str_c("cb_palette_WD1")]] <- c("#8dd3c7","#ffffb3", "#bebada","#fb8072", "#80b1d3","#fdb462","#b3de69", "#fccde5", "#d9d9d9", "#bc80bd", "#ccebc5", "#099122") # 9 Color + 2 Color (APU, Emissions directes
rep_pal[[str_c("cb_palette_WD2")]] <- c("#8dd3c7","#ffffb3", "#bebada","#fb8072", "#80b1d3","#fdb462","#b3de69", "#fccde5", "#d9d9d9", "#bc80bd") #
rep_pal[[str_c("cb_palette_WD3")]] <- c("#8dd3c7","#ffffb3", "#bebada","#fb8072", "#80b1d3","#fdb462","#b3de69", "#fccde5", "#d9d9d9", "#bc80bd") #
rep_pal[[str_c("cb_palette_WD4")]] <- c("#2a5572","#7bbde5", "#bc80bd","#98504a","#858298","#fdb462","#b3de69", "#93bdda","#fb8072" ,"#FDCD2E")
rep_pal[[str_c("cb_palette_ZE")]]  <- qualitative_hcl(21, h = c(20, 200), c = 70, l = 60)
rep_pal[[str_c("cb_palette_EU1")]] <- qualitative_hcl(28, h = c(20, 200), c = 70, l = 60)
rep_pal[[str_c("cb_palette_EU2")]] <- c("#8dd3c7","#ffffb3", "#bebada","#fb8072", "#80b1d3","#fdb462","#b3de69", "#fccde5") #
rep_pal[[str_c("cb_palette_p7")]]  <- c( "#fb8072",	"#466963")
rep_pal[[str_c("cb_palette_p8")]]  <- c("#d35c38","#ffa866")
rep_pal[[str_c("cb_palette_p10")]] <- c("#8dd3c7","#ffffb3", "#bebada","#fb8072", "#80b1d3","#fdb462","#b3de69", "#fccde5", "#FDCD2E", "#bc80bd", "#ccebc5", "#099122")
rep_pal[[str_c("cb_palette_WD1")]] <- c("#2a5572","#7bbde5", "#bebada","#98504a","#858298", "#fccde5","#fdb462","#b3de69", "#93bdda","#fb8072" ,"#FDCD2E","#bc80bd") 
countries.lab <- c("France","Allemagne", "EU28", "Italie", "Espagne")
countries.pal <- c("#9fc7da","#fb8072", "#466963", "#b3de69","#fbc572")
 cb_palette_plot <- c( "#fb8072", "#9fc7da","#466963")
