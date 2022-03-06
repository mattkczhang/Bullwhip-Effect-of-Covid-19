
*-------------------------------------------------------------------------------------------------*
************************************ Clean Chinese Covid Data *************************************
*-------------------------------------------------------------------------------------------------*
clear all
set more off

cd "/Users/chonge/Documents/Document/Macalester/2020 fall/Honor Thesis/Data/Chinese domestic Covid-19 data"

*** 1. Import the Chinese Covid Data
import excel ChineseDomesticCovidFinal.xlsx, firstrow clear

*** 2. Fix Province variable
rename Province province
drop if province == "Taiwan" | province == "Hong Kong" | province == "Macau" | province == "TAiwan"

*** 3. Reshape dataset into right format:
* Reshape long to get province-month
local i=1
foreach var of varlis Jan-Oct {
rename `var' m_`i'
local i=`i'+1
}

egen p_i_id=group(province Indicator)

reshape long m_, i(p_i_id) j(month)

*** 4. Reshape wide to get province-month and 3 variables for confirmed, death, and recovered
drop p_i*
egen p_m_id = group(province month) 
egen i_id=group(Indicator)
drop Indicator

reshape wide m_, i(p_m_id) j(i_id)

order province month p_m* 
rename m_1 ch_new_cases
rename m_2 ch_new_death
rename m_3 ch_new_recov
drop p_m*

gen year=2020
gen date=ym(year, month)
format date %tm
drop year month

order province date 

*** 5. Calculate cumulative cases, deaths, and recoveries
bysort province (date): gen ch_total_cases=sum(ch_new_cases)
bysort province (date): gen ch_total_death=sum(ch_new_death)
bysort province (date): gen ch_total_recov=sum(ch_new_recov)

*** 6. Label variables
lab var ch_new_cases "monthly change in Covid confirmed cases"
lab var ch_new_death "monthly change in Covid death cases"
lab var ch_new_recov "monthly change in Covid recovered cases"
lab var ch_total_cases "total Covid confirmed cases"
lab var ch_total_death "total Covid death cases"
lab var ch_total_recov "total Covid recovered case"

egen p_id = group(province)

save chinese_covid_full, replace
save "/Users/chonge/Documents/Document/Macalester/2020 fall/Honor Thesis/Data/Final data/chinese_covid_full", replace
