
*-------------------------------------------------------------------------------------------------*
*************************************** Data Visualization ****************************************
*-------------------------------------------------------------------------------------------------*
clear all
set more off

cd "/Users/chonge/Documents/Document/Macalester/2020 fall/Honor Thesis/Data/Final data"

*-------------------------*
********* Figures *********
*-------------------------*

*** 1. Aggregate trade value and new Covid cases line graph

use complete_orig, clear

drop if month > 9

keep if year == 2020

bysort p_id date: gen count_p = _N
bysort fc_id date: gen count_fc = _N
replace ch_new_cases = ch_new_cases/count_p
replace new_cases = new_cases/count_fc

collapse (sum) trade ch_new_cases new_cases, by(date)

// gen temp = _n

// gen growth = 0

// replace growth = (trade[_n] - trade[_n-9]) / (0.5*(trade[_n] + trade[_n-9])) if _n>9

// gen growth_2019 = 0 
// replace growth_2019 = growth[_n-9] if _n > 18

// rename growth growth_2020

// keep if year == 2020

// gen growth_dif = growth_2020 - growth_2019

gen trade_bil = trade/1000000000
gen ch_new_cases_t = ch_new_cases / 100
gen new_cases_t = new_cases / 1000


twoway(line growth_2020 month, yaxis(1) ytitle("Midpoint growth rate of trade value", axis(1))) ///
	(line ch_new_cases month, yaxis(2) ytitle("number of new Covid cases", axis(2))) ///
	(line new_cases month, yaxis(2) ytitle("Number of new Covid cases", axis(2))), ///
 	legend(order(1 "Growth rate of trade value" 2 "Chinese new Covid cases" 3 "Foreign new Covid cases") row(3)) ///
	xlabel(1 2 3 4 5 6 7 8 9) ///
	graphregion(color(white)) bgcolor(white) ///
	xtitle("Month",size(medlarge)) 
// 	xline(3, lcolor(black) lwidth(0.5) lpattern(dash))
graph export "/Users/chonge/Documents/Document/Macalester/2020 fall/Honor Thesis/Figures/Trade and Covid (growth).png", replace	  

twoway(line growth_dif month, yaxis(1) ytitle("Difference in Midpoint growth rate", axis(1))) ///
	(line ch_new_cases month, yaxis(2) ytitle("number of new Covid cases", axis(2))) ///
	(line new_cases month, yaxis(2) ytitle("Number of new Covid cases", axis(2))), ///
 	legend(order(1 "Difference in growth rate of trade value" 2 "Chinese new Covid cases" 3 "Foreign new Covid cases") row(3)) ///
	xlabel(1 2 3 4 5 6 7 8 9) ///
	graphregion(color(white)) bgcolor(white) ///
	xtitle("Month",size(medlarge)) 
// 	xline(3, lcolor(black) lwidth(0.5) lpattern(dash))
graph export "/Users/chonge/Documents/Document/Macalester/2020 fall/Honor Thesis/Figures/Trade and Covid (growth_diff).png", replace	  

twoway(line trade_bil date, yaxis(1) ytitle("Trade value ($ bil)", axis(1))) ///
	(line ch_new_cases_t date, yaxis(2) ytitle("Number of new Covid cases", axis(2))) ///
	(line new_cases_t date, yaxis(2) ytitle("Number of new Covid cases", axis(2))), ///
 	legend(order(1 "Trade value in billion" 2 "Chinese new Covid cases in hundred" 3 "Foreign new Covid cases in thousand") row(3)) ///
	graphregion(color(white)) bgcolor(white) 
// 	xtitle("Month",size(medlarge)) 
graph export "/Users/chonge/Documents/Document/Macalester/2020 fall/Honor Thesis/Figures/Trade and Covid (abs).png", replace	  

*** 2. Randomness check of upstreamness and concentration index

use complete_orig, clear

drop if Upstreamness == . | NormalizedConcentration == .

collapse Upstreamness NormalizedConcentration, by(c_id)

scatter Upstreamness NormalizedConcentration, ///
	graphregion(color(white)) bgcolor(white) ///
	xtitle("Normalized concentration index",size(medlarge)) ///
	ytitle("Upstreamness index",size(medlarge)) 
graph export "/Users/chonge/Documents/Document/Macalester/2020 fall/Honor Thesis/Figures/Upstreamness and Concentration.png", replace	  

*** 3. Trade and Upstreamness

use complete_orig, clear

drop if Upstreamness == . | NormalizedConcentration == .

preserve 

collapse (first) Upstreamness, by(c_id)

sum Upstreamness, det

restore

gen Upstream_rank = 0
replace Upstream_rank = 1 if Upstreamness < `r(p50)'
replace Upstream_rank = 2 if Upstreamness > `r(p50)'

drop if month > 9 

collapse (sum) trade (first) date, by(year month Upstream_rank)

bysort month Upstream_rank (year): gen growth = (trade[_n] - trade[_n-1])/(0.5*(trade[_n] + trade[_n-1]))

// gen temp = _n

// gen growth = 0

// replace growth = (trade[_n] - trade[_n-18]) / (0.5*(trade[_n] + trade[_n-18])) if _n>18

keep if year == 2020 

twoway(line growth date if Upstream_rank==1 & year == 2020) ///
      (line growth date if Upstream_rank==2 & year == 2020), ///
 	legend(order(1 "Low Upstreamness" 2 "High Upstreamness") row(2)) ///
	graphregion(color(white)) bgcolor(white) ///
	ytitle("Midpoint growth rate",size(medlarge)) 
graph export "/Users/chonge/Documents/Document/Macalester/2020 fall/Honor Thesis/Figures/Trade and Upstreamness.png", replace	  

*********
use complete_orig, clear

drop if Upstreamness == . | NormalizedConcentration == .

gen Upstream_rank = 0
replace Upstream_rank = 1 if Upstreamness < 2.825
replace Upstream_rank = 2 if Upstreamness > 2.825

drop if month > 9 

collapse (sum) trade, by(year month Upstream_rank)

gen temp = _n

gen growth = 0

replace growth = (trade[_n] - trade[_n-18]) / (0.5*(trade[_n] + trade[_n-18])) if _n>18

keep if year == 2020

twoway(line growth month if Upstream_rank==1) ///
      (line growth month if Upstream_rank==2), ///
 	legend(order(1 "Low Upstreamness" 2 "High Upstreamness") row(2)) ///
	xlabel(1 2 3 4 5 6 7 8 9) ///
	graphregion(color(white)) bgcolor(white) ///
	xtitle("Month",size(medlarge)) ///
	ytitle("Midpoint growth rate",size(medlarge)) 
graph export "/Users/chonge/Documents/Document/Macalester/2020 fall/Honor Thesis/Figures/Trade and Upstreamness.png", replace	  

*********

*** 4. Trade and Concentration

use complete_orig, clear

drop if Upstreamness == . | NormalizedConcentration == .

gen Concen_rank = 0
replace Concen_rank = 1 if NormalizedConcentration < 0.5
replace Concen_rank = 2 if NormalizedConcentration > 0.5

drop if month > 9 

collapse (sum) trade ch_new_cases new_cases, by(year month Concen_rank)

gen temp = _n

gen growth = 0

replace growth = (trade[_n] - trade[_n-18]) / (0.5*(trade[_n] + trade[_n-18])) if _n>18

keep if year == 2020

twoway(line growth month if Concen_rank==1) ///
      (line growth month if Concen_rank==2), ///
 	legend(order(1 "Low Concentration" 2 "High Concentration") row(2)) ///
	xlabel(1 2 3 4 5 6 7 8 9) ///
	graphregion(color(white)) bgcolor(white) ///
	xtitle("Month",size(medlarge)) ///
	ytitle("Midpoint growth rate",size(medlarge)) 
graph export "/Users/chonge/Documents/Document/Macalester/2020 fall/Honor Thesis/Figures/Trade and Concentration.png", replace	  

*** 4.1 Three Most Concetrated and Least Concentrated Commodities and Trade

use complete_orig, clear

drop if Upstreamness == . | NormalizedConcentration == .
 
drop if month > 9 

collapse (first) commodity NormalizedConcentration (sum) trade, by(year month c_id)

keep if c_id == 96 | c_id == 40 | c_id ==48 | c_id == 39 | c_id == 49 | c_id ==28 | c_id == 25 | c_id == 23 | c_id ==31 | c_id == 21 | c_id == 69 | c_id ==95

gen growth = 0

replace growth = (trade[_n] - trade[_n-108]) / (0.5*(trade[_n] + trade[_n-108])) if _n>108

keep if year == 2020

twoway(line growth month if c_id==96, lcolor(red)) ///
    (line growth month if c_id==40, lcolor(orange)) ///
    (line growth month if c_id==48, lcolor(orange_red)) ///
    (line growth month if c_id==25, lcolor(green)) ///
    (line growth month if c_id==23, lcolor(lime)) ///
     (line growth month if c_id==31, lcolor(midgreen)), ///
 	legend(size(small) order(1 "Miscellaneous manufactured article" 2 "Rubber and articles thereof" 3 "Paper and paperboard; articles of paper pulp, of paper or of paperboard" 4 "Salt; sulphur; earths and stone;plastering materials, lime and cement" 5 "Residues and waste from the food industries; prepared animal fodder" 6 "Fertilisers") row(6)) ///
	xlabel(1 2 3 4 5 6 7 8 9) ///
	graphregion(color(white)) bgcolor(white) ///
	xtitle("Month",size(medlarge)) ///
	ytitle("Midpoint growth rate",size(medlarge)) 
graph export "/Users/chonge/Documents/Document/Macalester/2020 fall/Honor Thesis/Figures/Trade and Concentration_Six.png", replace	  

 
 
*-------------------------*
********* Tables *********
*-------------------------*

* 6. Summary Statistics for trade value, new Covid cases, Upstreamness index, and Concentration index

use complete_only_pos, clear

drop if Upstreamness == . | NormalizedConcentration == .

keep if UQuality == 2 & CQuality == 2

* Option to Drop U.S. from the dataset
drop if fc_id == 502

drop if month > 9 
keep if count_case_obs == 10

sort date c_id p_id fc_id 
order date c_id p_id fc_id trade

* Generat midpoint growth rate

gen growth = 0
replace growth = (trade[_n] - trade[_n-272412]) / (0.5*(trade[_n] + trade[_n-272412])) if _n>272412

* Option to Drop U.S. from the dataset
*replace growth = (trade[_n] - trade[_n-265590]) / (0.5*(trade[_n] + trade[_n-265590])) if _n>265590


* Summarize data and output to table
sum trade if year == 2019, det
	scalar trade_mean_19 = r(mean)	
	scalar trade_median_19 = r(p50)
	scalar trade_sd_19=r(sd)
	scalar trade_min_19=r(min) 	
	scalar trade_max_19=r(max) 	
	scalar trade_n_19=r(N) 	
sum trade if year == 2020, det
	scalar trade_mean_20 = r(mean)	
	scalar trade_median_20 = r(p50)
	scalar trade_sd_20=r(sd)
	scalar trade_min_20=r(min) 	
	scalar trade_max_20=r(max) 	
	scalar trade_n_20=r(N) 	
sum growth if year == 2019, det
	scalar growth_mean_19 = r(mean)	
	scalar growth_median_19 = r(p50)
	scalar growth_sd_19=r(sd)
	scalar growth_min_19=r(min) 	
	scalar growth_max_19=r(max) 	
	scalar growth_n_19=r(N) 	
sum growth if year == 2020, det
	scalar growth_mean_20 = r(mean)	
	scalar growth_median_20 = r(p50)
	scalar growth_sd_20=r(sd)
	scalar growth_min_20=r(min) 	
	scalar growth_max_20=r(max) 	
	scalar growth_n_20=r(N) 	
sum ch_new_cases if year ==2020, det
	scalar ch_new_cases_mean = r(mean)	
	scalar ch_new_cases_median = r(p50)
	scalar ch_new_cases_sd=r(sd)
	scalar ch_new_cases_min=r(min) 	
	scalar ch_new_cases_max=r(max) 	
	scalar ch_new_cases_n=r(N) 	
sum new_cases if date > tm(2019m11), det
	scalar new_cases_mean = r(mean)	
	scalar new_cases_median = r(p50)
	scalar new_cases_sd=r(sd)
	scalar new_cases_min=r(min) 	
	scalar new_cases_max=r(max) 	
	scalar new_cases_n=r(N) 	
preserve
collapse (first) Upstreamness NormalizedConcentration, by(c_id)
sum Upstreamness, det
	scalar Upstreamness_mean = r(mean)	
	scalar Upstreamness_median = r(p50)
	scalar Upstreamness_sd=r(sd)
	scalar Upstreamness_min=r(min) 	
	scalar Upstreamness_max=r(max) 	
	scalar Upstreamness_n=r(N) 	
sum NormalizedConcentration, det
	scalar NormalizedConcentration_mean = r(mean)	
	scalar NormalizedConcentration_median = r(p50)
	scalar NormalizedConcentration_sd=r(sd)
	scalar NormalizedConcentration_min=r(min) 	
	scalar NormalizedConcentration_max=r(max) 	
	scalar NormalizedConcentration_n=r(N) 	
restore

* Creating matrix and labels
matrix trade = (scalar(trade_mean_19),     scalar(trade_mean_20),    scalar(growth_mean_19),    scalar(growth_mean_20)  \ ///
			scalar(trade_median_19),     scalar(trade_median_20),    scalar(growth_median_19),    scalar(growth_median_20) \ ///
			scalar(trade_sd_19),     scalar(trade_sd_20),    scalar(growth_sd_19),    scalar(growth_sd_20) \ ///
			scalar(trade_min_19),     scalar(trade_min_20),    scalar(growth_min_19),    scalar(growth_min_20) \ ///
			scalar(trade_max_19),     scalar(trade_max_20),    scalar(growth_max_19),    scalar(growth_max_20) \ ///
			scalar(trade_n_19),     scalar(trade_n_20),    scalar(growth_n_19),    scalar(growth_n_20))
mat rownames trade = "Mean" "Median" "Std Deviation" "Min" "Max" "N" 
mat colnames trade = "Trade(2019)" "Trade(2020)" "Growth(2019)" "Growth(2020)"
esttab matrix(trade, fmt(2)) using "/Users/chonge/Documents/Document/Macalester/2020 fall/Honor Thesis/Tables/Trade_SumStat.tex", replace  ///
     title(Summary Statistics: Trade Value and Midpoint Growth Rate) 

matrix covid = (scalar(ch_new_cases_mean),    scalar(new_cases_mean)  \ ///
			scalar(ch_new_cases_median),    scalar(new_cases_median)  \ ///
			scalar(ch_new_cases_sd),    scalar(new_cases_sd)  \ ///
			scalar(ch_new_cases_min),    scalar(new_cases_min)  \ ///
			scalar(ch_new_cases_max),    scalar(new_cases_max) \ ///
			scalar(ch_new_cases_n),    scalar(new_cases_n))
mat rownames covid = "Mean" "Median" "Std Deviation" "Min" "Max" "N" 
mat colnames covid = "Chinese new Covid cases" "Foregin new Covid cases"
esttab matrix(covid, fmt(2)) using "/Users/chonge/Documents/Document/Macalester/2020 fall/Honor Thesis/Tables/Covid_SumStat.tex", replace  ///
     title(Summary Statistics: Chinese and Global new Covid Cases) 

matrix index = (scalar(Upstreamness_mean),    scalar(NormalizedConcentration_mean)  \ ///
			scalar(Upstreamness_median),    scalar(NormalizedConcentration_median)  \ ///
			scalar(Upstreamness_sd),    scalar(NormalizedConcentration_sd)  \ ///
			scalar(Upstreamness_min),    scalar(NormalizedConcentration_min)  \ ///
			scalar(Upstreamness_max),    scalar(NormalizedConcentration_max) \ ///
			scalar(Upstreamness_n),    scalar(NormalizedConcentration_n))
mat rownames index = "Mean" "Median" "Std Deviation" "Min" "Max" "N" 
mat colnames index = "Upstreamness index" "Concentration index"
esttab matrix(index, fmt(2)) using "/Users/chonge/Documents/Document/Macalester/2020 fall/Honor Thesis/Tables/Index_SumStat.tex", replace  ///
     title(Summary Statistics: Upstreamness and Concentration Index) 

matrix trade = (scalar(trade_mean_19),     scalar(trade_mean_20),    scalar(ch_new_cases_mean),    scalar(new_cases_mean),	scalar(Upstreamness_mean),	scalar(NormalizedConcentration_mean) \ ///
			scalar(trade_median_19),     scalar(trade_median_20),    scalar(ch_new_cases_median),    scalar(new_cases_median),	scalar(Upstreamness_median),	scalar(NormalizedConcentration_median) \ ///
			scalar(trade_sd_19),     scalar(trade_sd_20),    scalar(ch_new_cases_sd),    scalar(new_cases_sd),	scalar(Upstreamness_sd),    scalar(NormalizedConcentration_sd) \ ///
			scalar(trade_min_19),     scalar(trade_min_20),    scalar(ch_new_cases_min),    scalar(new_cases_min),	scalar(Upstreamness_min),    scalar(NormalizedConcentration_min) \ ///
			scalar(trade_max_19),     scalar(trade_max_20),    scalar(ch_new_cases_max),    scalar(new_cases_max),	scalar(Upstreamness_max),    scalar(NormalizedConcentration_max) \ ///
			scalar(trade_n_19),     scalar(trade_n_20),    scalar(ch_new_cases_n),    scalar(new_cases_n),	scalar(Upstreamness_n),    scalar(NormalizedConcentration_n))
mat rownames trade = "Mean" "Median" "Std Deviation" "Min" "Max" "N" 
mat colnames trade = "Trade(2019)" "Trade(2020)" "Chinese new Covid cases" "Foregin new Covid cases" "Upstreamness index" "Concentration index"
esttab matrix(trade, fmt(2)) using "/Users/chonge/Documents/Document/Macalester/2020 fall/Honor Thesis/Tables/SumStat.tex", replace  ///
     title(Summary Statistics: Trade Value, New Covid Cases, and Upstreamness and Concentration Index ) 

matrix trade = (scalar(trade_mean_19),     scalar(trade_median_19),    scalar(trade_sd_19),    scalar(trade_min_19),	scalar(trade_max_19),	scalar(trade_n_19) \ ///
			scalar(trade_mean_20),     scalar(trade_median_20),    scalar(trade_sd_20),    scalar(trade_min_20),	scalar(trade_max_20),	scalar(trade_n_20) \ ///
			scalar(ch_new_cases_mean),     scalar(ch_new_cases_median),    scalar(ch_new_cases_sd),    scalar(ch_new_cases_min),	scalar(ch_new_cases_max),    scalar(ch_new_cases_n) \ ///
			scalar(new_cases_mean),     scalar(new_cases_median),    scalar(new_cases_sd),    scalar(new_cases_min),	scalar(new_cases_max),    scalar(new_cases_n) \ ///
			scalar(Upstreamness_mean),     scalar(Upstreamness_median),    scalar(Upstreamness_sd),    scalar(Upstreamness_min),	scalar(Upstreamness_max),    scalar(Upstreamness_n) \ ///
			scalar(NormalizedConcentration_mean),     scalar(NormalizedConcentration_median),    scalar(NormalizedConcentration_sd),    scalar(NormalizedConcentration_min),	scalar(NormalizedConcentration_max),    scalar(NormalizedConcentration_n))
mat colnames trade = "Mean" "Median" "Std Deviation" "Min" "Max" "N" 
mat rownames trade = "Trade(2019)" "Trade(2020)" "Chinese new Covid cases" "Foreign new Covid cases" "Upstreamness index" "Concentration index"
esttab matrix(trade, fmt(2)) using "/Users/chonge/Documents/Document/Macalester/2020 fall/Honor Thesis/Tables/SumStat.tex", replace  ///
     title(Summary Statistics: Trade Value, New Covid Cases, and Upstreamness and Concentration Index ) 


			
*** 7. Correlation between upstreamness and concentration

use complete_orig, clear

drop if Upstreamness == . | NormalizedConcentration == .

collapse Upstreamness NormalizedConcentration, by(c_id)

estpost correlate Upstreamness NormalizedConcentration, matrix 
	
esttab using "/Users/chonge/Documents/Document/Macalester/2020 fall/Honor Thesis/Tables/Corr_Index.tex", replace unstack not noobs nonote b(2)
	

*** 8. Sample comparison

use complete_only_pos, clear

gen drop_label = 0

replace drop_label = 1 if Upstreamness == . | NormalizedConcentration == .
	
collapse (first) Upstreamness NormalizedConcentration drop_label, by(c_id)
	
sum Upstreamness if drop_label == 0, det
	scalar Upstreamness_0 = r(mean)	
	scalar Upstreamness_0_sd=r(sd)
sum Upstreamness if drop_label == 1, det
	scalar Upstreamness_1 = r(mean)	
	scalar Upstreamness_1_sd=r(sd)
sum NormalizedConcentration if drop_label == 0, det
	scalar NormalizedConcentration_0 = r(mean)	
	scalar NormalizedConcentration_0_sd=r(sd)
sum NormalizedConcentration if drop_label == 1, det
	scalar NormalizedConcentration_1 = r(mean)	
	scalar NormalizedConcentration_1_sd=r(sd)
	
ttest Upstreamness_0, by(drop_label)
ttest NormalizedConcentration, by(drop_label)

	
matrix index = (scalar(Upstreamness_0),   scalar(Upstreamness_0_sd),  scalar(Upstreamness_1),  scalar(Upstreamness_1_sd)  \ ///
			scalar(NormalizedConcentration_0),  scalar(NormalizedConcentration_0_sd),   scalar(NormalizedConcentration_1),  scalar(NormalizedConcentration_1_sd))
mat rownames index = "Upstreamness Index" "Concentration Index"
mat colnames index = "Mean" "Standard Deviation" "Mean" "Standard Deviation"
esttab matrix(index, fmt(2)) using "/Users/chonge/Documents/Document/Macalester/2020 fall/Honor Thesis/Tables/Comparison.tex", replace  ///
     title(Summary Statistics: Comparison of means across keeped observation and dropped observations) 


*** 9. Upstream concordance tables

import delimited using upstreamness_by_industry.csv, clear

forval i=1/98{
gen C`i' = ""
}

foreach var of varlist match1-match4 {
	forval i = 1/98{
		replace C`i' = io_industry_name if `var' == `i'
	}
}

keep C1-C98

sxpose, clear

gen commoditycode = _n

gen MatchCommodity = _var1

foreach var of varlist _var2-_var426 { 
    replace MatchCommodity = MatchCommodity + "; " + `var' if `var' != "" 
} 

replace MatchCommodity = substr(MatchCommodity, 2, length(MatchCommodity)) if substr(MatchCommodity, 1, 1) == ";"

keep commoditycode MatchCommodity

drop if commoditycode == 77

merge 1:m commoditycode using "/Users/chonge/Documents/Document/Macalester/2020 fall/Honor Thesis/Data/Trade Data/commoditymatch"

replace commodity="Soap, organic surfaceactive agents, washing preparations" if commoditycode==34
replace commodity="Coffee, tea, and spices" if commoditycode==9
replace commodity="Silk" if commoditycode==50
replace commodity="Ceramic" if commoditycode==69

drop _merge

rename commoditycode Commodity_Code
rename commodity Commodity
rename MatchCommodity Matched_Commodity
order Commodity_Code Commodity Matched_Commodity

export excel "Concordance_Upstreamness", replace firstrow(variables)


*** 10. Concentration concordance tables

cd "/Users/chonge/Documents/Document/Macalester/2020 fall/Honor Thesis/Data/IO table"

import excel Concentration.xls, firstrow clear

forval i=1/98{
gen C`i' = ""
}

foreach var of varlist Match1-Match7 {
	forval i = 1/98{
		replace C`i' = A if `var' == `i'
	}
}

keep C1-C98

sxpose, clear

gen commoditycode = _n

gen MatchCommodity = _var1

foreach var of varlist _var2-_var129 { 
    replace MatchCommodity = MatchCommodity + "; " + `var' if `var' != "" 
} 

replace MatchCommodity = substr(MatchCommodity, 2, length(MatchCommodity)) if substr(MatchCommodity, 1, 1) == ";"

keep commoditycode MatchCommodity

drop if commoditycode == 77

merge 1:m commoditycode using "/Users/chonge/Documents/Document/Macalester/2020 fall/Honor Thesis/Data/Trade Data/commoditymatch"

replace commodity="Soap, organic surfaceactive agents, washing preparations" if commoditycode==34
replace commodity="Coffee, tea, and spices" if commoditycode==9
replace commodity="Silk" if commoditycode==50
replace commodity="Ceramic" if commoditycode==69

drop _merge

rename commoditycode Commodity_Code
rename commodity Commodity
rename MatchCommodity Matched_Commodity
order Commodity_Code Commodity Matched_Commodity

export excel "Concordance_Concentration", replace firstrow(variables)


*** 11. Trade exposure

cd "/Users/chonge/Documents/Document/Macalester/2020 fall/Honor Thesis/Data/Final data"

use global_covid_full, clear 

collapse (sum) new_cases (last) count_case_obs, by(country)

save global_covid_sum_by_country, replace

use chinese_covid_full, clear

collapse (sum) ch_new_cases, by(p_id)

save chinese_covid_sum_by_province

use complete_only_pos, clear

drop if Upstreamness == . | NormalizedConcentration == .

keep if UQuality == 2 & CQuality == 2

keep if year == 2020

collapse (sum) trade (first) country province commodity Upstreamness NormalizedConcentration, by(p_id c_id fc_id)

merge m:1 p_id using chinese_covid_sum_by_province
drop _merge

merge m:1 country using global_covid_sum_by_country
drop if _merge==2
drop if count_case_obs != 10
drop _merge

egen p_total = total(trade), by(p_id)
egen fc_total = total(trade), by(fc_id)

gen p_perc = trade/p_total
gen fc_perc = trade/fc_total

gen pcovd_ppercent = ch_new_cases * p_perc
gen fccovid_fcpercent = new_cases * fc_perc

egen p_exp = total(pcovd_ppercent), by(c_id)
egen fc_exp = total(fccovid_fcpercent), by(c_id)

collapse (first) commodity Upstreamness NormalizedConcentration p_exp fc_exp, by(c_id)

gen Upstreamness_binary = 0
lab var Upstreamness_binary "Upstream"

preserve 

collapse (first) Upstreamness, by(commodity)

sum Upstreamness, det

restore

replace Upstreamness_binary = 1 if Upstreamness > `r(p50)'

gen Concentration_binary = 0
lab var Concentration_binary "Concentrated"

preserve 

collapse (first) NormalizedConcentration, by(commodity)

sum NormalizedConcentration, det

restore

replace Concentration_binary = 1 if NormalizedConcentration > `r(p50)'

drop c_id Upstreamness_binary Concentration_binary

sort Upstreamness NormalizedConcentration p_exp fc_exp

dataout, save(myfile) tex replace

