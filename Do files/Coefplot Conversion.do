
*-------------------------------------------------------------------------------------------------*
*************************************** Coefplot Conversion ***************************************
*-------------------------------------------------------------------------------------------------*
clear all
set more off

cd "/Users/chonge/Documents/Document/Macalester/2020 fall/Honor Thesis/Data/Final data"

*** 1. Import the Chinese Covid Data
import excel Coefplot_lag.xlsx, firstrow clear

// label values X X2

// label define X 0 "Original" 1 "Lag_1" 2 "Lag_2" 3 "Lag_3" 4 "Lag_4" 5 "Lag_5"

labmask X, values(X2)

twoway (line Beta2 X) (line Beta3 X) (line UP X), title("")  /// 
	legend(order(1 "Exports of downstream industries" 2 "Difference in exports between upstream and downstream industries" ///
	3 "Exports of upstream industries") row(3)) ///
	ytitle("Coefficient estimates") xtitle("Time lagged months") ///
	graphregion(color(white)) bgcolor(white) ///
	yline(0, lcolor(black)) ///
	xlab(0(1)5,valuelabel)
graph export "/Users/chonge/Documents/Document/Macalester/2020 fall/Honor Thesis/Figures/Coefplot_combine.png", replace	  



