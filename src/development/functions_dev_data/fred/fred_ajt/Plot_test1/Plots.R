source("PlotsLoadScripts.R")


# GDP <- simpleplot("oilprice","GDP")
GDP <- simpleplot("oilprice","GDP")
simpleplot("oilprice","CH")
simpleplot("oilprice","I")

simpleplot("oilprice","X")
simpleplot("oilprice","M")

simpleplot("oilprice","PCH")
simpleplot("oilprice","PM")

simpleplot("oilprice","UNR","diffx100")
simpleplot("oilprice","F_L","diff")

combineplots(c( "GDP_reldiffx100.png",
                "CH_reldiffx100.png",
                "I_reldiffx100.png",
                "X_reldiffx100.png",
                "M_reldiffx100.png",
                "PCH_reldiffx100.png",
                "PM_reldiffx100.png",
                "UNR_diffx100.png",
                "F_L_diff.png"))



results <- loadResults("oilprice")





