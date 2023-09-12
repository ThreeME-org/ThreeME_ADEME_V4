' Configuration
%iso3 = "fra"
%scenario = "tpf10"

%firstyear = "2012"
%baseyear = "2015"
%lastyear = "2050"

%warning = "FALSE"
%compil = "dynamo"
%recompile_model = "FALSE"
%save_files_res = "FALSE"


%tolerance_calib_check = "0.001"

%path_eviews_default = "C:/Users/Administrator/Documents/GitHub/ThreeME_V3/src/EViews/"

cd %path_eviews_default
' Run main:  c = run program file without display the program file window; q = quiet
run(1,c,q) main


