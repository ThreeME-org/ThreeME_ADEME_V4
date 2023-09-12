' Define default directory where the model MODUX is located
cd C:\Users\reynesfgd\GitHub\ThreeME_V3\data\Luxembourg\MODUX

' Open the relevant workfile
wfopen modux_exemple.wf1

' Define sample period
smpl 1970 2022

' List of variable to be exported 
%listvar = "PIB_R EMP POPACT emistotalesd P_VAB P_CFIN  P_XBS RDMEN EQUEXT_R I_R XBS_R SALM  R_EQUEXT_R R_EPMEN R_UBIT R_RCDPSNM R_RCDPSNMPRIM R_EPMEN R_UBIT R_RCDPSNM"

' Define simulation list
%listsimul = @pagelist  ' Use every page in the workfile
' %listsimul = "pibea19_r_1_2130_zero pibea19_r_ss_1a_2130_zero"   ' Define manually the list of pages

For %simul {%listsimul}
	
	' Define here the list pf pages to be ignoged
	if %simul = "Data" or %simul = "Base_2130_zero" then
	
	else
	
	' Select the simulation
	pageselect {%simul} 

	' Add shock extention to the list of variable to export 
	%export_data = ""
  		for %var {%listvar}
     		  	%export_data = %export_data  + " " + %var + "_0" + " " + %var + "_1*"
  		next
	
	' string aa = %export_data   ' To check the created string
	
	' Create a group with exported data for each scenario
	group all_vars_{%simul}  {%export_data}
	' show all_vars_{%simul}
	
	' Save each simulation into a csv file
	delete(noerr) all_vars_{%simul}_table
	freeze(all_vars_{%simul}_table) all_vars_{%simul}
	%pathcsv= @linepath + "\csv\" + %simul + ".csv"
	all_vars_{%simul}_table.save(t=csv) %pathcsv
	endif
next


