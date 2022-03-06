
*-------------------------------------------------------------------------------------------------*
************************************ Clean Concentration Data *************************************
*-------------------------------------------------------------------------------------------------*
clear all
set more off

cd "/Users/chonge/Documents/Document/Macalester/2020 fall/Honor Thesis/Data/IO table"

import excel EoraiOtable.xlsx, firstrow clear

egen TotalOutput = rowtotal(Cropcultivation-Acquisitionslessdisposalsofv)

foreach var of varlist Cropcultivation - Acquisitionslessdisposalsofv {
	replace `var' = `var'/TotalOutput
}

gen Concentration = 0

foreach var of varlist Cropcultivation - Acquisitionslessdisposalsofv {
	replace Concentration = Concentration + `var'^2
}

gen NumOfOutput = 0
foreach var of varlist Cropcultivation - Acquisitionslessdisposalsofv {
	replace NumOfOutput = NumOfOutput + 1 if `var' != . & `var' != 0
}

gen NormalizedConcentration = (Concentration - 1/NumOfOutput)/(1 - 1/NumOfOutput)

keep A NormalizedConcentration Concentration

gen industry_id = _n

save Concentration_temp, replace

export excel using Concentration_temp, firstrow(var) replace

*Here is the Concentration index after manual matching
import excel Concentration.xls, firstrow clear

*create matched concentration index
forval i=1/98{
gen C`i' = .
}

foreach var of varlist Match1-Match7 {
	forval i = 1/98{
		replace C`i' = NormalizedConcentration if `var' == `i'
	}
}

keep C1-C98

xpose, clear

gen c_id = _n

egen NormalizedConcentration = rowmean(v1-v129)

keep c_id NormalizedConcentration

*clean data
drop if c_id == 77

gen CQuality = 0 

replace CQuality = 1 if NormalizedConcentration != .

foreach i in 1 2 3 4 10 12 17 22 24 30 31 39 40 48 49 51 52 53 54 69 70 72 86 87 89 95 97 {
	replace CQuality = 2 if c_id == `i'
}

lab var NormalizedConcentration "Concentration index of the product"
lab var CQuality "Quality of match of concentration index"

save Concentration, replace
save "/Users/chonge/Documents/Document/Macalester/2020 fall/Honor Thesis/Data/Final data/Concentration", replace
