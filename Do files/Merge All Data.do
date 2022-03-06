
*-------------------------------------------------------------------------------------------------*
***************************************** Merge All Data ******************************************
*-------------------------------------------------------------------------------------------------*
clear all
set more off

cd "/Users/chonge/Documents/Document/Macalester/2020 fall/Honor Thesis/Data/Final data"

foreach x in "data1_orig" "data_1_full_some_pos" "data_1_full_only_pos" {

use `x', clear

*** 1. Merge Chinese Covid data to trade data:
merge m:1 p_id date using chinese_covid_full
drop if _merge==2

* Replace missing observations with 0:
foreach var of varlist ch_new_cases-ch_total_recov {
replace `var' = 0 if `var'==.
}
drop _merge


*** 2. Merge global Covid data to trade data:
* Fix country names:
replace country = substr(country, 1, length(country) - 1)

* Merge dadta
merge m:1 country date using global_covid_full
drop if _merge==2

bysort country (date): replace count_case_obs=count_case_obs[_N]

foreach var of varlist pop-continent {
bysort country (`var'): replace `var' = `var'[_N]
}

* Replace missing observations with 0:
foreach var of varlist total_cases-total_deaths_per_million {
replace `var' = 0 if `var'==. & count_case_obs == 10
}

drop _merge

*** 3. Merge upstreamness index data to trade data
merge m:1 c_id using Upstreamness
drop if _merge==2
drop _merge

*** 4. Merge concentration index data to trade data
merge m:1 c_id using Concentration
drop if _merge==2
drop _merge

*** 6. Organize and save data:
order province p_id country fc_id c_id date trade 
sort p_id fc_id c_id date

*** 7. Save complete datasets:
if "`x'"=="data1_orig" {
** This dataset is unbalanced and includes only non-zero trade values as recorded by the GACC
save complete_orig, replace
}

else if "`x'"=="data_1_full_some_pos" {
** This dataset is balanced over time but only includes those province-country-commodity pairs for which at least
** one trade value is positive
save complete_some_pos, replace
}

else if "`x'"== "data_1_full_only_pos" {
** This dataset is balanced over time but only includes those province-country-commodity pairs for which ALL
** time periods record a positive trade value
save complete_only_pos, replace
}
}


