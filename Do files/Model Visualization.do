
*-------------------------------------------------------------------------------------------------*
*************************************** Model Visualization ***************************************
*-------------------------------------------------------------------------------------------------*
clear all
set more off

cd "/Users/chonge/Documents/Document/Macalester/2020 fall/Honor Thesis/Data/Final data"

*** 1. Import the Chinese Covid Data
import excel ModelData.xlsx, firstrow clear

twoway (scatter Down Period) (scatter UP Period), title("")  

twoway (line Down Period) (line UP Period), title("")  /// 
	legend(order(1 "Upstream industries" 2 "Downstream industries")) ///
	ytitle("Demand for products") xtitle("Period") ///
	graphregion(color(white)) bgcolor(white) ///
	xlab(1(5)33) ylab(none) yline(100, lcolor(blkack))
graph export "/Users/chonge/Documents/Document/Macalester/2020 fall/Honor Thesis/Figures/Model_graph.png", replace	  


clear
set obs 93
gen x = _n
gen y = cos((x+24)/15.5)
gen y_2 = 0.5*cos((x+30)/15.5)
twoway (line y x) (line y_2 x)
twoway (line y x, lcolor(green)) (line y_2 x, lcolor(navy)), title("")  /// 
	legend(order(1 "Upstream industries" 2 "Downstream industries")) ///
	ytitle("Demand for products") xtitle("Period") ///
	graphregion(color(white)) bgcolor(white) ///
	xlab(1(10)93) ylab(none) yline(0, lcolor(blkack))
graph export "/Users/chonge/Documents/Document/Macalester/2020 fall/Honor Thesis/Figures/Model_graph.png", replace	  


