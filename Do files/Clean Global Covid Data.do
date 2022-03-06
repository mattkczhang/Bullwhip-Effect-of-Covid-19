
*-------------------------------------------------------------------------------------------------*
************************************ Clean Global Covid Data **************************************
*-------------------------------------------------------------------------------------------------*
clear all
set more off

cd "/Users/chonge/Documents/Document/Macalester/2020 fall/Honor Thesis/Data/Foreign Covid-19 data"

*** 1. Import data
import excel WorldCovid.xlsx, clear firstrow

rename location country

*** 2. Create Date variables:
split date, parse("-") gen(date)
drop date

destring date1, replace
destring date2, replace
destring date3, replace

rename date1 year
rename date2 month
rename date3 day

gen date = ym(year, month)
format date %tm

*** 3. Rename variables
rename population pop
rename population_density p_den
rename median_age age
rename gdp_per_capita gdp_pc
rename extreme_poverty pov
rename diabetes_prevalence diabetes
rename female_smokers f_smoke
rename male_smokers m_smoke
rename handwashing_facilities handw
rename hospital_beds_per_thousand hosp_cap
rename life_expectancy le

*** 4. Collapse data to monthly frequency:
collapse (mean) pop p_den age gdp_pc pov diabetes f_smoke m_smoke handw hosp_cap le ///
	(first) iso_code continent (last) total_cases total_deaths total_cases_per_million ///
	total_deaths_per_million total_tests total_tests_per_thousand ///
	(sum) new_cases new_deaths new_cases_per_million, by(country date)

*** 5. Fix Country Spelling to merge:
replace country="Antigua & Barbuda" if country=="Antigua and Barbuda"	
replace country="Bosnia and Hercegovina" if country=="Bosnia and Herzegovina"	
replace country="Bonaire" if country=="Bonaire Sint Eustatius and Saba"	
replace country="Central African Republic." if country=="Central African Republic"	
replace country="Congo,DR" if country=="Democratic Republic of Congo"	
replace country="Estado Plurinacional de Bolivia" if country=="Bolivia"	
replace country="Faroe Islands" if country=="Faeroe Islands"	
replace country="Azerbai jan" if country=="Azerbaijan"	
replace country="Bahrian" if country=="Bahrain"	
replace country="Virgin  Islands, British" if country=="British Virgin Islands"	
replace country="Cote d'lvoire" if country=="Cote d'Ivoire"	
replace country="Lao PDR" if country=="Laos"	
replace country="Libyan Arab Jamahiriya" if country=="Libya"	
replace country="Republic of North Macedonia" if country=="Macedonia"	
replace country="Nepal, FDR" if country=="Nepal"	
replace country="Russian Federation" if country=="Russia"	
replace country="Saint  Kitts and Nevis" if country=="Saint Kitts and Nevis"	
replace country="Saint Vincent and Grenadines" if country=="Saint Vincent and the Grenadines"	
replace country="Saint Martin Islands" if country=="Sint Maarten (Dutch part)"	
replace country="Slovenia " if country=="Slovenia"	
replace country="Korea, Rep." if country=="South Korea"	
replace country="Republic of South Sudan " if country=="South Sudan"	
replace country="Syrian Arab Republic" if country=="Syria"	
replace country="Timor-Leste" if country=="Timor"	
replace country="Vatican City State" if country=="Vatican"	
replace country="Viet Nam" if country=="Vietnam"	

/* 
Note:
Because Serbia and Montenegro are separated in the global Covid data but are combined in the trade data, 
I chooose to combine their Covid data together.
*/

*** 6. Combine Serbia and Montenegro into Serbia
preserve
keep if country == "Serbia" | country == "Montenegro"
collapse (mean) pop p_den age gdp_pc pov diabetes f_smoke m_smoke handw hosp_cap le ///
	(first) iso_code continent (sum) total_cases total_deaths total_cases_per_million ///
	total_deaths_per_million total_tests total_tests_per_thousand /// 
	new_cases new_deaths new_cases_per_million, by(date)
replace iso_code = "SRB" 
gen country = "Serbia"
save SRBCovid, replace
restore

drop if iso_code == "SRB" | iso_code == "MME"
append using SRBCovid

drop if date>tm(2020m9)

*** 7. Count the number of month observed in the data
bysort country (date): gen count_case_obs=_N if total_cases!=.

save global_covid_full, replace
save "/Users/chonge/Documents/Document/Macalester/2020 fall/Honor Thesis/Data/Final data/global_covid_full", replace

