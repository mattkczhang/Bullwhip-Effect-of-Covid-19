
*-------------------------------------------------------------------------------------------------*
**************************************** Empirical Result *****************************************
*-------------------------------------------------------------------------------------------------*
clear all
set more off

cd "/Users/chonge/Documents/Document/Macalester/2020 fall/Honor Thesis/Data/Final data"

use complete_only_pos, clear
// use complete_some_pos, clear

** Clean the data and control for the sample

keep if month < 10

// Sample List
// 1. US exclusion
// 2. Quality of the two indices
// 3. Foreign country control
// 4. Quality of covid data 

* 1.
drop if fc_id == 502

* 2.
// keep if UQuality == 2 & CQuality == 2
drop if UQuality == 0 | CQuality == 0

* 3. 
// keep if continent == "Asia"
keep if fc_id == 502 | fc_id == 116 | fc_id == 133 | fc_id == 141 | fc_id == 111 | fc_id == 304 | fc_id == 309 | fc_id == 303 | fc_id == 132 | ///
	fc_id == 501 | fc_id == 344 | fc_id == 601 | fc_id == 429 | fc_id == 122 | fc_id == 136 | fc_id == 112 | fc_id == 129 | fc_id == 410 | ///
	fc_id == 307 | fc_id ==  138 | fc_id == 305 | fc_id == 312 | fc_id == 327 | fc_id == 131 | fc_id == 301 | fc_id == 137 | fc_id == 103 | ///
	fc_id == 236 | fc_id == 244 | fc_id == 127 // 30 major trade partners using 2020 data

* 4.
keep if count_case_obs == 10

** Create the growth rate

bysort month p_id fc_id c_id (year): gen growth_abs = trade[_n] - trade[_n-1]

bysort month p_id fc_id c_id (year): gen growth_rel = (trade[_n] - trade[_n-1])/(0.5*(trade[_n] + trade[_n-1]))

** Create the IHS transformation

gen trade_IHS = asinh(trade)

gen growth_abs_IHS = asinh(growth_abs)

gen growth_rel_IHS = asinh(growth_rel)

gen new_cases_IHS = asinh(new_cases)
lab var new_cases_IHS "Foreign new cases"

gen new_deaths_IHS = asinh(new_deaths)
lab var new_deaths_IHS "Foreign death cases"

gen total_cases_IHS = asinh(total_cases)
lab var total_cases_IHS "Foreign cumulative cases"

gen ch_new_cases_IHS = asinh(ch_new_cases)

gen ch_new_death_IHS = asinh(ch_new_death)
lab var ch_new_death_IHS "Chinese death cases"

gen ch_total_cases_IHS = asinh(ch_total_cases)
lab var ch_total_cases_IHS "Chinese cumulative cases"


** Create the binary Upstreamness and Concentration

preserve 

collapse (first) Upstreamness, by(c_id)

_pctile Upstreamness, p(25, 33.33, 50, 66.66, 75)

restore

gen Upstreamness_binary = 0
lab var Upstreamness_binary "Upstream"

replace Upstreamness_binary = 1 if Upstreamness >  `r(r3)'

gen Upstreamness_cat = 0 

replace Upstreamness_cat = 1 if Upstreamness > `r(r2)'

replace Upstreamness_cat = 2 if Upstreamness > `r(r4)'

gen Upstreamness_cat2 = 0

replace Upstream_cat2 = 1 if Upstreamness > `r(r1)'

replace Upstream_cat2 = 2 if Upstreamness > `r(r3)'

replace Upstream_cat2 = 3 if Upstreamness > `r(r5)'

gen Concentration_binary = 0
lab var Concentration_binary "Concentrated"

preserve 

collapse (first) NormalizedConcentration, by(c_id)

sum NormalizedConcentration, det

restore

replace Concentration_binary = 1 if NormalizedConcentration > `r(p50)'

drop if year == 2018

** Fixed Effect Regression

eststo clear //Clean previous saved data 	

* Trade_IHS as outcome variable

reghdfe trade_IHS ch_new_cases_IHS new_cases_IHS, absorb(p_id#fc_id c_id date) cluster(p_id#fc_id) //new cases
est store A
quietly estadd local fixedP "No", replace
quietly estadd local fixedFC "No", replace
quietly estadd local fixedC "Yes", replace
quietly estadd local fixedD "Yes", replace
quietly estadd local fixedB "Yes", replace
quietly estadd local fixedCD "No", replace
reghdfe trade_IHS ch_new_death_IHS new_deaths_IHS, absorb(p_id#fc_id c_id date) cluster(p_id#fc_id) //new death
est store A_death
quietly estadd local fixedP "No", replace
quietly estadd local fixedFC "No", replace
quietly estadd local fixedC "Yes", replace
quietly estadd local fixedD "Yes", replace
quietly estadd local fixedB "Yes", replace
quietly estadd local fixedCD "No", replace
reghdfe trade_IHS ch_total_cases_IHS total_cases_IHS, absorb(p_id#fc_id c_id date) cluster(p_id#fc_id) //total cases
est store A_cum
quietly estadd local fixedP "No", replace
quietly estadd local fixedFC "No", replace
quietly estadd local fixedC "Yes", replace
quietly estadd local fixedD "Yes", replace
quietly estadd local fixedB "Yes", replace
quietly estadd local fixedCD "No", replace

reghdfe trade_IHS ch_new_cases_IHS new_cases_IHS i.Upstreamness_binary#c.new_cases_IHS, absorb(p_id#fc_id c_id date) ///
	cluster(p_id#fc_id) //new cases
est store B
quietly estadd local fixedP "No", replace
quietly estadd local fixedFC "No", replace
quietly estadd local fixedC "Yes", replace
quietly estadd local fixedD "Yes", replace
quietly estadd local fixedB "Yes", replace
quietly estadd local fixedCD "No", replace
reghdfe trade_IHS ch_new_death_IHS new_deaths_IHS i.Upstreamness_binary#c.new_deaths_IHS, absorb(p_id#fc_id c_id date) /// 
	cluster(p_id#fc_id) //new death
est store B_death
quietly estadd local fixedP "No", replace
quietly estadd local fixedFC "No", replace
quietly estadd local fixedC "Yes", replace
quietly estadd local fixedD "Yes", replace
quietly estadd local fixedB "Yes", replace
quietly estadd local fixedCD "No", replace
reghdfe trade_IHS ch_total_cases_IHS total_cases_IHS i.Upstreamness_binary#c.total_cases_IHS, absorb(p_id#fc_id c_id date) /// 
	cluster(p_id#fc_id) //total cases
est store B_cum
quietly estadd local fixedP "No", replace
quietly estadd local fixedFC "No", replace
quietly estadd local fixedC "Yes", replace
quietly estadd local fixedD "Yes", replace
quietly estadd local fixedB "Yes", replace
quietly estadd local fixedCD "No", replace

reghdfe trade_IHS ch_new_cases_IHS new_cases_IHS i.Concentration_binary#c.new_cases_IHS, absorb(p_id#fc_id c_id date) /// 
	cluster(p_id#fc_id) //new cases
est store C
quietly estadd local fixedP "No", replace
quietly estadd local fixedFC "No", replace
quietly estadd local fixedC "Yes", replace
quietly estadd local fixedD "Yes", replace
quietly estadd local fixedB "Yes", replace
quietly estadd local fixedCD "No", replace
reghdfe trade_IHS ch_new_death_IHS new_deaths_IHS i.Concentration_binary#c.new_deaths_IHS, absorb(p_id#fc_id c_id date) ///
	cluster(p_id#fc_id) //new death
est store C_death
quietly estadd local fixedP "No", replace
quietly estadd local fixedFC "No", replace
quietly estadd local fixedC "Yes", replace
quietly estadd local fixedD "Yes", replace
quietly estadd local fixedB "Yes", replace
quietly estadd local fixedCD "No", replace
reghdfe trade_IHS ch_total_cases_IHS total_cases_IHS i.Concentration_binary#c.total_cases_IHS, absorb(p_id#fc_id c_id date) /// 
	cluster(p_id#fc_id) //total cases
est store C_cum
quietly estadd local fixedP "No", replace
quietly estadd local fixedFC "No", replace
quietly estadd local fixedC "Yes", replace
quietly estadd local fixedD "Yes", replace
quietly estadd local fixedB "Yes", replace
quietly estadd local fixedCD "No", replace

reghdfe trade_IHS ch_new_cases_IHS new_cases_IHS i.Upstreamness_binary#c.new_cases_IHS i.Concentration_binary#c.new_cases_IHS ///
	, absorb(p_id#fc_id c_id date) cluster(p_id#fc_id) //new cases
est store D
quietly estadd local fixedP "No", replace
quietly estadd local fixedFC "No", replace
quietly estadd local fixedC "Yes", replace
quietly estadd local fixedD "Yes", replace
quietly estadd local fixedB "Yes", replace
quietly estadd local fixedCD "No", replace
reghdfe trade_IHS ch_new_death_IHS new_deaths_IHS i.Upstreamness_binary#c.new_deaths_IHS i.Concentration_binary#c.new_deaths_IHS ///
	, absorb(p_id#fc_id c_id date) cluster(p_id#fc_id) //new death
est store D_death
quietly estadd local fixedP "Yes", replace
quietly estadd local fixedFC "Yes", replace
quietly estadd local fixedC "Yes", replace
quietly estadd local fixedD "Yes", replace
quietly estadd local fixedB "No", replace
quietly estadd local fixedCD "No", replace
quietly estadd local fixedBC "No", replace
reghdfe trade_IHS ch_total_cases_IHS total_cases_IHS i.Upstreamness_binary#c.total_cases_IHS i.Concentration_binary#c.total_cases_IHS ///
	, absorb(p_id#fc_id c_id date) cluster(p_id#fc_id) //total cases
est store D_cum
quietly estadd local fixedP "Yes", replace
quietly estadd local fixedFC "Yes", replace
quietly estadd local fixedC "Yes", replace
quietly estadd local fixedD "Yes", replace
quietly estadd local fixedB "No", replace
quietly estadd local fixedCD "No", replace

reghdfe trade_IHS ch_new_cases_IHS new_cases_IHS i.Upstreamness_binary#c.new_cases_IHS i.Concentration_binary#c.new_cases_IHS ///
	i.Upstreamness_binary#i.Concentration_binary#c.new_cases_IHS, absorb(p_id#fc_id c_id date) cluster(p_id#fc_id) //new cases
est store E
quietly estadd local fixedP "No", replace
quietly estadd local fixedFC "No", replace
quietly estadd local fixedC "Yes", replace
quietly estadd local fixedD "Yes", replace
quietly estadd local fixedB "Yes", replace
quietly estadd local fixedCD "No", replace
reghdfe trade_IHS ch_new_death_IHS new_deaths_IHS i.Upstreamness_binary#c.new_deaths_IHS ///
	i.Concentration_binary#c.new_deaths_IHS i.Upstreamness_binary#i.Concentration_binary#c.new_deaths_IHS ///
	, absorb(p_id#fc_id c_id date) cluster(p_id#fc_id) //new death
est store E_death
quietly estadd local fixedP "No", replace
quietly estadd local fixedFC "No", replace
quietly estadd local fixedC "Yes", replace
quietly estadd local fixedD "Yes", replace
quietly estadd local fixedB "Yes", replace
quietly estadd local fixedCD "No", replace
reghdfe trade_IHS ch_total_cases_IHS total_cases_IHS i.Upstreamness_binary#c.total_cases_IHS /// 
	i.Concentration_binary#c.total_cases_IHS i.Upstreamness_binary#i.Concentration_binary#c.total_cases_IHS ///
	, absorb(p_id#fc_id c_id date) cluster(p_id#fc_id) //new death
est store E_cum
quietly estadd local fixedP "No", replace
quietly estadd local fixedFC "No", replace
quietly estadd local fixedC "Yes", replace
quietly estadd local fixedD "Yes", replace
quietly estadd local fixedB "Yes", replace
quietly estadd local fixedCD "No", replace

reghdfe trade_IHS ch_new_cases_IHS new_cases_IHS i.Upstreamness_binary#c.new_cases_IHS i.Concentration_binary#c.new_cases_IHS ///
	, absorb(p_id fc_id c_id date) cluster(p_id#fc_id) //new cases
est store F
quietly estadd local fixedP "Yes", replace
quietly estadd local fixedFC "Yes", replace
quietly estadd local fixedC "Yes", replace
quietly estadd local fixedD "Yes", replace
quietly estadd local fixedB "No", replace
quietly estadd local fixedCD "No", replace
quietly estadd local fixedBC "No", replace

reghdfe trade_IHS ch_new_cases_IHS new_cases_IHS i.Upstreamness_binary#c.new_cases_IHS i.Concentration_binary#c.new_cases_IHS ///
	, absorb(p_id#fc_id c_id#date) cluster(p_id#fc_id) //new cases
est store G
quietly estadd local fixedP "No", replace
quietly estadd local fixedFC "No", replace
quietly estadd local fixedC "No", replace
quietly estadd local fixedD "No", replace
quietly estadd local fixedB "Yes", replace
quietly estadd local fixedCD "Yes", replace
quietly estadd local fixedBC "No", replace
 
reghdfe trade_IHS ch_new_cases_IHS new_cases_IHS i.Upstreamness_binary#c.new_cases_IHS i.Concentration_binary#c.new_cases_IHS ///
	, absorb(p_id#fc_id#c_id date) cluster(p_id#fc_id) //new cases
est store H
quietly estadd local fixedP "No", replace
quietly estadd local fixedFC "No", replace
quietly estadd local fixedC "No", replace
quietly estadd local fixedD "Yes", replace
quietly estadd local fixedB "No", replace
quietly estadd local fixedCD "No", replace
quietly estadd local fixedBC "Yes", replace

reghdfe trade_IHS ch_new_cases_IHS new_cases_IHS c.Upstreamness#c.new_cases_IHS c.NormalizedConcentration#c.new_cases_IHS ///
, absorb(p_id#fc_id c_id date) cluster(p_id#fc_id) //new cases
est store I
quietly estadd local fixedP "No", replace
quietly estadd local fixedFC "No", replace
quietly estadd local fixedC "Yes", replace
quietly estadd local fixedD "Yes", replace
quietly estadd local fixedB "Yes", replace
quietly estadd local fixedCD "No", replace
quietly estadd local fixedBC "No", replace

reghdfe trade_IHS ch_new_cases_IHS new_cases_IHS c.Upstreamness#c.new_cases_IHS c.NormalizedConcentration#c.new_cases_IHS c.Upstreamness#c.NormalizedConcentration#c.new_cases_IHS, absorb(p_id#fc_id c_id#date) vce(robust) //new cases


/*
* growth_abs_IHS as outcome variable

reghdfe growth_abs_IHS ch_new_cases_IHS new_cases_IHS, absorb(p_id fc_id c_id date) vce(robust) //new cases
reghdfe growth_abs_IHS ch_new_death_IHS new_deaths_IHS, absorb(p_id fc_id c_id date) vce(robust) //new death

reghdfe growth_abs_IHS ch_new_cases_IHS new_cases_IHS i.Upstreamness_binary#c.new_cases_IHS i.Concentration_binary#c.new_cases_IHS, absorb(p_id#fc_id c_id#date) vce(robust) //new cases
reghdfe growth_abs_IHS ch_new_death_IHS new_deaths_IHS i.Upstreamness_binary#c.new_deaths_IHS i.Concentration_binary#c.new_deaths_IHS, absorb(p_id#fc_id c_id#date) vce(robust) //new death

reghdfe growth_abs_IHS ch_new_cases_IHS new_cases_IHS i.Upstreamness_binary#c.new_cases_IHS i.Concentration_binary#c.new_cases_IHS i.Upstreamness_binary#i.Concentration_binary#c.new_cases_IHS, absorb(p_id#fc_id c_id#date) vce(robust) //new cases
reghdfe growth_abs_IHS ch_new_death_IHS new_deaths_IHS i.Upstreamness_binary#c.new_deaths_IHS i.Concentration_binary#c.new_deaths_IHS i.Upstreamness_binary#i.Concentration_binary#c.new_deaths_IHS, absorb(p_id#fc_id c_id#date) vce(robust) //new death

* growth_rel_IHS as outcome variable

reghdfe growth_rel_IHS ch_new_cases_IHS new_cases_IHS, absorb(p_id fc_id c_id date) vce(robust) //new cases
reghdfe growth_rel_IHS ch_new_death_IHS new_deaths_IHS, absorb(p_id fc_id c_id date) vce(robust) //new death

reghdfe growth_rel_IHS ch_new_cases_IHS new_cases_IHS i.Upstreamness_binary#c.new_cases_IHS i.Concentration_binary#c.new_cases_IHS, absorb(p_id#fc_id c_id#date) vce(robust) //new cases
reghdfe growth_rel_IHS ch_new_death_IHS new_deaths_IHS i.Upstreamness_binary#c.new_deaths_IHS i.Concentration_binary#c.new_deaths_IHS, absorb(p_id#fc_id c_id#date) vce(robust) //new death

reghdfe growth_rel_IHS ch_new_cases_IHS new_cases_IHS i.Upstreamness_binary#c.new_cases_IHS i.Concentration_binary#c.new_cases_IHS i.Upstreamness_binary#i.Concentration_binary#c.new_cases_IHS, absorb(p_id#fc_id c_id#date) vce(robust) //new cases
reghdfe growth_rel_IHS ch_new_death_IHS new_deaths_IHS i.Upstreamness_binary#c.new_deaths_IHS i.Concentration_binary#c.new_deaths_IHS i.Upstreamness_binary#i.Concentration_binary#c.new_deaths_IHS, absorb(p_id#fc_id c_id#date) vce(robust) //new death
*/

*output to txt

esttab A B C D E using "/Users/chonge/Documents/Document/Macalester/2020 fall/Honor Thesis/Tables/Regression_baseline_1.tex", label replace /// 
    b(a2) varwidth(10) nonumbers noconstant booktabs ///
	s(fixedC fixedD fixedB N r2, ///
	label("Commodity" "Time FE" "Bilateral FE" "Observations" "R-Square")) ///
	title(Baseline Fixed Effect Estimates)  ///
	cells(b(fmt(3)) p(fmt(3) par)) ///
    sfmt(%8.0f) mlabels((1) (2) (3) (4) (5)) collabels(none)  ///
	drop(0.Upstreamness_binary#c.new_cases_IHS 0.Concentration_binary#c.new_cases_IHS 0.Upstreamness_binary#0.Concentration_binary#c.new_cases_IHS ///
	1.Upstreamness_binary#0.Concentration_binary#c.new_cases_IHS 0.Upstreamness_binary#1.Concentration_binary#c.new_cases_IHS ///
	_cons) ///
    coef(ch_new_cases_IHS "Chinese new cases" new_cases_IHS "Foreign new cases" ch_new_death_IHS "Chinese new deaths") 

esttab D F G H I using "/Users/chonge/Documents/Document/Macalester/2020 fall/Honor Thesis/Tables/Regression_baseline_2FE.tex", label nobaselevels interaction(" $\times$ ")style(tex) replace /// 
    b(a2) varwidth(10) nonumbers noconstant booktabs ///
	s(fixedP fixedFC fixedC fixedD fixedB fixedCD fixedBC N r2, ///
	label("Province FE" "Foreign Country FE" "Commodity" "Time FE" "Bilateral FE" "Commodity and Time FE" "Bilateral and Commodity FE" "Observations" "R-Square")) ///
	title(Baseline Fixed Effect Regressions)  ///
	cells(b(fmt(3)) p(fmt(3) par)) ///
    sfmt(%8.0f) mlabels((1) (2) (3) (4) (5)) collabels(none)  ///
    coef(ch_new_cases_IHS "Chinese new cases" new_cases_IHS "Foreign new cases" ch_new_death_IHS "Chinese new deaths" ///
	new_deaths_IHS "Foreign new deaths" ch_total_cases_IHS "Chinese cumulative cases" total_cases_IHS "Foreign cumulative cases") 

esttab A_death B_death C_death D_death E_death using "/Users/chonge/Documents/Document/Macalester/2020 fall/Honor Thesis/Tables/Regression_baseline_3Death.tex", label nobaselevels interaction(" $\times$ ")style(tex) replace /// 
    b(a2) varwidth(10) nonumbers noconstant booktabs ///
	s(fixedC fixedD fixedB N r2, ///
	label("Commodity" "Time FE" "Bilateral FE" "Observations" "R-Square")) ///
	title(Baseline Fixed Effect Regressions)  ///
	cells(b(fmt(3)) p(fmt(3) par)) ///
    sfmt(%8.0f) mlabels((1) (2) (3) (4) (5)) collabels(none)  ///
    coef(ch_new_cases_IHS "Chinese new cases" new_cases_IHS "Foreign new cases" ch_new_death_IHS "Chinese new deaths" ///
	new_deaths_IHS "Foreign new deaths" ch_total_cases_IHS "Chinese cumulative cases" total_cases_IHS "Foreign cumulative cases") 

esttab A_cum B_cum C_cum D_cum E_cum using "/Users/chonge/Documents/Document/Macalester/2020 fall/Honor Thesis/Tables/Regression_baseline_3Cum.tex", label nobaselevels interaction(" $\times$ ")style(tex) replace /// 
    b(a2) varwidth(10) nonumbers noconstant booktabs ///
	s(fixedC fixedD fixedB N r2, ///
	label("Commodity" "Time FE" "Bilateral FE" "Observations" "R-Square")) ///
	title(Baseline Fixed Effect Regressions)  ///
	cells(b(fmt(3)) p(fmt(3) par)) ///
    sfmt(%8.0f) mlabels((1) (2) (3) (4) (5)) collabels(none)  ///
    coef(ch_new_cases_IHS "Chinese new cases" new_cases_IHS "Foreign new cases" ch_new_death_IHS "Chinese new deaths" ///
	new_deaths_IHS "Foreign new deaths" ch_total_cases_IHS "Chinese cumulative cases" total_cases_IHS "Foreign cumulative cases") 


* time lag effect

egen panel_id = group(p_id fc_id c_id)
xtset panel_id date

reghdfe trade_IHS ch_new_cases_IHS new_cases_IHS i.Upstreamness_binary#c.new_cases_IHS i.Concentration_binary#c.new_cases_IHS, absorb(p_id#fc_id c_id date) cluster(panel_id)
est store original
quietly estadd local fixedP "No", replace
quietly estadd local fixedFC "No", replace
quietly estadd local fixedC "Yes", replace
quietly estadd local fixedD "Yes", replace
quietly estadd local fixedB "Yes", replace
quietly estadd local fixedCD "No", replace
reghdfe trade_IHS L.ch_new_cases_IHS L.new_cases_IHS i.Upstreamness_binary#c.L.new_cases_IHS i.Concentration_binary#c.L.new_cases_IHS, absorb(p_id#fc_id c_id date) cluster(panel_id)
est store lag_1
quietly estadd local fixedP "No", replace
quietly estadd local fixedFC "No", replace
quietly estadd local fixedC "Yes", replace
quietly estadd local fixedD "Yes", replace
quietly estadd local fixedB "Yes", replace
quietly estadd local fixedCD "No", replace
reghdfe trade_IHS L2.ch_new_cases_IHS L2.new_cases_IHS i.Upstreamness_binary#c.L2.new_cases_IHS i.Concentration_binary#c.L2.new_cases_IHS, absorb(p_id#fc_id c_id date) cluster(panel_id)
est store lag_2
quietly estadd local fixedP "No", replace
quietly estadd local fixedFC "No", replace
quietly estadd local fixedC "Yes", replace
quietly estadd local fixedD "Yes", replace
quietly estadd local fixedB "Yes", replace
quietly estadd local fixedCD "No", replace
reghdfe trade_IHS L3.ch_new_cases_IHS L3.new_cases_IHS i.Upstreamness_binary#c.L3.new_cases_IHS i.Concentration_binary#c.L3.new_cases_IHS, absorb(p_id#fc_id c_id date) cluster(panel_id)
est store lag_3
quietly estadd local fixedP "No", replace
quietly estadd local fixedFC "No", replace
quietly estadd local fixedC "Yes", replace
quietly estadd local fixedD "Yes", replace
quietly estadd local fixedB "Yes", replace
quietly estadd local fixedCD "No", replace
reghdfe trade_IHS L4.ch_new_cases_IHS L4.new_cases_IHS i.Upstreamness_binary#c.L4.new_cases_IHS i.Concentration_binary#c.L4.new_cases_IHS, absorb(p_id#fc_id c_id date) cluster(panel_id)
est store lag_4
quietly estadd local fixedP "No", replace
quietly estadd local fixedFC "No", replace
quietly estadd local fixedC "Yes", replace
quietly estadd local fixedD "Yes", replace
quietly estadd local fixedB "Yes", replace
quietly estadd local fixedCD "No", replace
reghdfe trade_IHS L5.ch_new_cases_IHS L5.new_cases_IHS i.Upstreamness_binary#c.L5.new_cases_IHS i.Concentration_binary#c.L5.new_cases_IHS, absorb(p_id#fc_id c_id date) cluster(panel_id)
est store lag_5
quietly estadd local fixedP "No", replace
quietly estadd local fixedFC "No", replace
quietly estadd local fixedC "Yes", replace
quietly estadd local fixedD "Yes", replace
quietly estadd local fixedB "Yes", replace
quietly estadd local fixedCD "No", replace
reghdfe trade_IHS L6.ch_new_cases_IHS L6.new_cases_IHS i.Upstreamness_binary#c.L6.new_cases_IHS i.Concentration_binary#c.L6.new_cases_IHS, absorb(p_id#fc_id c_id date) cluster(panel_id)
reghdfe trade_IHS L7.ch_new_cases_IHS L7.new_cases_IHS i.Upstreamness_binary#c.L7.new_cases_IHS i.Concentration_binary#c.L7.new_cases_IHS, absorb(p_id#fc_id c_id date) cluster(panel_id)


reghdfe growth_abs_IHS ch_new_cases_IHS new_cases_IHS i.Upstreamness_binary#c.new_cases_IHS i.Concentration_binary#c.new_cases_IHS, absorb(p_id#fc_id c_id#date) cluster(panel_id)
reghdfe growth_abs_IHS L2.ch_new_cases_IHS L2.new_cases_IHS i.Upstreamness_binary#c.L2.new_cases_IHS i.Concentration_binary#c.L2.new_cases_IHS, absorb(p_id#fc_id c_id#date) cluster(panel_id)
reghdfe growth_abs_IHS L4.ch_new_cases_IHS L4.new_cases_IHS i.Upstreamness_binary#c.L4.new_cases_IHS i.Concentration_binary#c.L4.new_cases_IHS, absorb(p_id#fc_id c_id#date) cluster(panel_id)

reghdfe growth_rel_IHS ch_new_cases_IHS new_cases_IHS i.Upstreamness_binary#c.new_cases_IHS i.Concentration_binary#c.new_cases_IHS, absorb(p_id#fc_id c_id#date) cluster(panel_id)
reghdfe growth_rel_IHS L2.ch_new_cases_IHS L2.new_cases_IHS i.Upstreamness_binary#c.L2.new_cases_IHS i.Concentration_binary#c.L2.new_cases_IHS, absorb(p_id#fc_id c_id#date) cluster(panel_id)
reghdfe growth_rel_IHS L4.ch_new_cases_IHS L4.new_cases_IHS i.Upstreamness_binary#c.L4.new_cases_IHS i.Concentration_binary#c.L4.new_cases_IHS, absorb(p_id#fc_id c_id#date) cluster(panel_id)

reghdfe trade_IHS ch_new_death_IHS new_deaths_IHS i.Upstreamness_binary#c.new_deaths_IHS i.Concentration_binary#c.new_deaths_IHS, absorb(p_id#fc_id c_id#date) cluster(panel_id)
reghdfe trade_IHS L2.ch_new_death_IHS L2.new_deaths_IHS i.Upstreamness_binary#c.L2.new_deaths_IHS i.Concentration_binary#c.L2.new_deaths_IHS, absorb(p_id#fc_id c_id#date) cluster(panel_id)
reghdfe trade_IHS L4.ch_new_death_IHS L4.new_deaths_IHS i.Upstreamness_binary#c.L4.new_deaths_IHS i.Concentration_binary#c.L4.new_deaths_IHS, absorb(p_id#fc_id c_id#date) cluster(panel_id)



esttab original lag_1 lag_2 lag_3 lag_4 lag_5 using "/Users/chonge/Documents/Document/Macalester/2020 fall/Honor Thesis/Tables/Regression_time_lag.tex", label nobaselevels interaction(" $\times$ "\\)style(tex) replace /// 
    b(a2) varwidth(10) nonumbers noconstant ///
	rename(L.ch_new_cases_IHS ch_new_cases_IHS L.new_cases_IHS new_cases_IHS 1.Upstreamness_binary#cL.new_cases_IHS 1.Upstreamness_binary#c.new_cases_IHS 1.Concentration_binary#cL.new_cases_IHS 1.Concentration_binary#c.new_cases_IHS /// 
	L2.ch_new_cases_IHS ch_new_cases_IHS L2.new_cases_IHS new_cases_IHS 1.Upstreamness_binary#cL2.new_cases_IHS 1.Upstreamness_binary#c.new_cases_IHS 1.Concentration_binary#cL2.new_cases_IHS 1.Concentration_binary#c.new_cases_IHS ///
	L3.ch_new_cases_IHS ch_new_cases_IHS L3.new_cases_IHS new_cases_IHS 1.Upstreamness_binary#cL3.new_cases_IHS 1.Upstreamness_binary#c.new_cases_IHS 1.Concentration_binary#cL3.new_cases_IHS 1.Concentration_binary#c.new_cases_IHS ///
	L4.ch_new_cases_IHS ch_new_cases_IHS L4.new_cases_IHS new_cases_IHS 1.Upstreamness_binary#cL4.new_cases_IHS 1.Upstreamness_binary#c.new_cases_IHS 1.Concentration_binary#cL4.new_cases_IHS 1.Concentration_binary#c.new_cases_IHS ///
	L5.ch_new_cases_IHS ch_new_cases_IHS L5.new_cases_IHS new_cases_IHS 1.Upstreamness_binary#cL5.new_cases_IHS 1.Upstreamness_binary#c.new_cases_IHS 1.Concentration_binary#cL5.new_cases_IHS 1.Concentration_binary#c.new_cases_IHS) ///
	s(fixedC fixedD fixedB N r2, ///
	label("Commodity" "Time FE" "Bilateral FE" "Observations" "R-Square")) ///
	title(Baseline Fixed Effect Regressions with Time Lagged Effect)  ///
	cells(b(fmt(3)) p(fmt(3) par)) ///
    sfmt(%8.0f) mlabels((Original) (Lag_1) (Lag_2) (Lag_3) (Lag_4) (Lag_5)) collabels(none)  ///
    coef(ch_new_cases_IHS "Chinese new cases" new_cases_IHS "Foreign new cases" ch_new_death_IHS "Chinese new deaths" ///
	new_deaths_IHS "Foreign new deaths" ch_total_cases_IHS "Chinese cumulative cases" total_cases_IHS "Foreign cumulative cases") 

** Margins plot

reghdfe trade_IHS ch_new_cases_IHS new_cases_IHS i.Upstreamness_binary#c.new_cases_IHS i.Concentration_binary#c.new_cases_IHS, absorb(p_id#fc_id c_id date) vce(robust) //new cases

margins Upstreamness_binary, at(new_cases_IHS= (2(1)15))

marginsplot, title("") ytitle("Predicted value of IHS of trade") ///
	xtitle("IHS of foreign new cases") ///
	graphregion(color(white)) bgcolor(white) ///
	legend(order(1 "Downstream industries" 2 "Upstream industries"))
graph export "/Users/chonge/Documents/Document/Macalester/2020 fall/Honor Thesis/Figures/Marginsplot_up.png", replace	  

margins Concentration_binary, at(new_cases_IHS= (2(1)15))

marginsplot, title("") ytitle("Predicted value of IHS of trade") ///
	xtitle("IHS of foreign new cases") ///
	graphregion(color(white)) bgcolor(white) ///
	legend(order(1 "Non-concentrated industries" 2 "Concentrated industries"))
graph export "/Users/chonge/Documents/Document/Macalester/2020 fall/Honor Thesis/Figures/Marginsplot_con.png", replace	  

reghdfe trade_IHS ch_new_cases_IHS new_cases_IHS i.Upstreamness_cat#c.new_cases_IHS i.Concentration_binary#c.new_cases_IHS, absorb(p_id#fc_id c_id date) vce(robust) //new cases

margins Upstreamness_cat, at(new_cases_IHS= (2(1)15))

marginsplot, title("") ytitle("Predicted value of IHS of trade") ///
	xtitle("IHS of foreign new cases")  ///
	graphregion(color(white)) bgcolor(white) ///
 	legend(order(1 "Downstream industry" 2 "Midstream industry" 3 "Upstream industry") row(2))
graph export "/Users/chonge/Documents/Document/Macalester College/2020 fall/Honor Thesis/Figures/Marginsplot_up3.png", replace	  

reghdfe trade_IHS ch_new_cases_IHS new_cases_IHS i.Upstreamness_cat2#c.new_cases_IHS i.Concentration_binary#c.new_cases_IHS, absorb(p_id#fc_id c_id date) vce(robust) //new cases

margins Upstreamness_cat2, at(new_cases_IHS= (2(1)15))

marginsplot, title("") ytitle("Predicted value of IHS of trade") ///
	xtitle("IHS of foreign new cases")  ///
	graphregion(color(white)) bgcolor(white) ///
 	legend(order(1 "Most downstream industry" 2 "Downstream industry" 3 "Upstream industry" 4 "Most Upstream inudstry") row(2))
graph export "/Users/chonge/Documents/Document/Macalester College/2020 fall/Honor Thesis/Figures/Marginsplot_up4.png", replace	  

reghdfe trade_IHS ch_new_cases_IHS new_cases_IHS i.Upstreamness_binary#c.new_cases_IHS i.Concentration_binary#c.new_cases_IHS i.Upstreamness_binary#i.Concentration_binary#c.new_cases_IHS, absorb(p_id#fc_id c_id date) vce(robust) //new cases

margins Concentration_binary#Upstreamness_binary, at(new_cases_IHS= (2(1)15))

marginsplot, title("") legend(order(1 "Non-concentrated and downstream industries" 2 "Non-concentrated and upstream industries" ///
	3 "Concentrated and downstream industries" 4 "Concentrated and Upstream industries") size(small) row(4)) ///
	graphregion(color(white)) bgcolor(white) ///
	xtitle("IHS of foreign new cases") ///
	ytitle("Predicted value of IHS of trade") 
graph export "/Users/chonge/Documents/Document/Macalester/2020 fall/Honor Thesis/Figures/Marginsplot_up_con.png", replace	  


** Coefplot
	
coefplot original lag_1 lag_2 lag_3 lag_4 lag_5, vertical graphregion(fcolor(white)) keep(new_cases_IHS L*.new_cases_IHS) ///
	asequation swapnames bylabel("Foreign new cases") yline(0) graphregion(fcolor(white)) legend(off) ylab(0.1(-0.05)-0.1)
graph export "/Users/chonge/Documents/Document/Macalester/2020 fall/Honor Thesis/Figures/Coefplot_beta2.png", replace	  

coefplot original lag_1 lag_2 lag_3 lag_4 lag_5, vertical graphregion(fcolor(white)) keep(1.Upstreamness_binary#*.new_cases_IHS) ///
	asequation swapnames bylabel("Up x Foreign new cases") yline(0) graphregion(fcolor(white)) legend(off) ylab(0.1(-0.05)-0.1)
graph export "/Users/chonge/Documents/Document/Macalester/2020 fall/Honor Thesis/Figures/Coefplot_beta3.png", replace	  


foreach i in 0 1 2{
    quietly reghdfe trade_IHS ch_new_cases_IHS new_cases_IHS i.Upstreamness_cat#c.new_cases_IHS i.Concentration_binary#c.new_cases_IHS if Upstreamness_cat == `i', absorb(p_id#fc_id c_id date) vce(robust)
    estimates store up_`i'
}
coefplot (up*), keep(new_cases_IHS) asequation swapnames ///
    title("Effect of grade on wages by industry")


	
	
	
	
	

