
*-------------------------------------------------------------------------------------------------*
************************************ Clean Chinese Trade Data *************************************
*-------------------------------------------------------------------------------------------------*
clear all
set more off

cd "/Users/chonge/Documents/Document/Macalester/2020 fall/Honor Thesis/Data/Trade Data"

*** 1. Convert csv to dta
** 2019 data
foreach m in 01 02 03 04 05 06 07 08 09 10 11 12{
import delimited using Data1_2019`m'.csv, clear
gen month = `m'
gen year = 2019
destring usdollar, replace
save data1_2019`m', replace
}

/*
Note: 
Because the 2018 trade data is downloaded in Chinese, I only keep the commodity code, province code, foregin country code, and trade value of each trade.
In this case, I choose to merge the 2018 trade data with the 2019 trade data to get the commodity name, province name, and foregin country name
*/

* Append all 2019 trade data
clear all
foreach m in 01 02 03 04 05 06 07 08 09 10 11 12{
append using data1_2019`m'
}
* Clean trade partner variable:
replace tradingpartner="Taiwan " if tradingpartnercode==143
replace tradingpartner="Macau " if tradingpartnercode==121
replace tradingpartner="Hong Kong " if tradingpartnercode==110
replace tradingpartner="Serbia and Montenegro" if tradingpartnercode==349
* Clean commodity variable:
replace commodity="Soap, organic surfaceactive agents, washing preparations" if commoditycode==34
replace commodity="Coffee, tea, and spices" if commoditycode==9
save data1_2019, replace

* Merged data creation
use data1_2019, clear
preserve 
keep commoditycode commodity 
duplicates drop
save commoditymatch, replace
restore
preserve
keep tradingpartnercode tradingpartner 
duplicates drop
save tradingpartnermatch, replace
restore
preserve
keep locationsofimportersandexporters v6
duplicates drop
save provincematch, replace
restore

** 2018 data
foreach m in 01 02 03 04 05 06 07 08 09 {
import delimited using Data1_2018`m'.csv, clear
merge m:1 commoditycode using commoditymatch
drop _merge
merge m:1 tradingpartnercode using tradingpartnermatch
drop _merge
merge m:1 locationsofimportersandexporters using provincematch
drop _merge
drop if usdollar == ""
gen month = `m'
gen year = 2018
replace usdollar = subinstr(usdollar,",","",.)
destring usdollar, replace
save data1_2018`m', replace
}

/*
Note: 
In 2019, 61.68% of combined Jan. and Feb. trade occurred during January and only 38.32% occurred during Feb. ON AVERAGE.
Becase the January and Feburary 2020 trade data are combined by Chinese government, I split the trade data according to the disaggregated weights of each trade observed in 2019.
If we cannot match the trade in 2019, we will split the trade value in 61.68%-38.32%.
*/

* Calculate province-country-commodity shares:
use data1_2019, clear
keep if month == 1 | month == 2
gen date=ym(year, month)
drop month year
bysort locationsofimportersandexporters tradingpartnercode commoditycode (date): egen total_usdollar=sum(usdollar)
gen share=usdollar/total_usdollar
*Create Year and Month Variable in order to merge:
gen month=1 if date==tm(2019m1)
replace month=2 if date==tm(2019m2)
drop date usdollar total_usdollar
save jan_feb_trade_shares, replace

* January 2020:
import delimited using Data1_20200102.csv, clear
gen month = 1
gen year = 2020
destring usdollar, replace
merge 1:1 locationsofimportersandexporters commoditycode tradingpartnercode month using jan_feb_trade_shares
drop if _merge==2
*If we have no share information because trade didn't occur, we use the average shares from above:
replace share=0.6168 if share==. 
replace usdollar = usdollar*share
drop _merge  share
save data1_202001,replace

* February 2020:
import delimited using Data1_20200102.csv, clear
gen month = 2
gen year = 2020
destring usdollar, replace
merge 1:1 locationsofimportersandexporters commoditycode tradingpartnercode month using jan_feb_trade_shares
drop if _merge==2
*If we have no share information because trade didn't occur, we use the average shares from above:
replace share=0.3832 if share==. 
replace usdollar = usdollar*share
drop _merge  share
save data1_202002,replace

** 2020 data
foreach m in 03 04 05{
import delimited using Data1_2020`m'.csv, clear
gen month = `m'
gen year = 2020
destring usdollar, replace
save data1_2020`m', replace
}
foreach m in 06 07 08 09{
import delimited using Data1_2020`m'.csv, clear
gen month = `m'
gen year = 2020
replace usdollar = subinstr(usdollar,",","",.)
destring usdollar, replace
save data1_2020`m', replace
}


*** 2. Append all the data
clear all
foreach m in 01 02 03 04 05 06 07 08 09{
append using data1_2018`m'
}
foreach m in 01 02 03 04 05 06 07 08 09 10 11 12{
append using data1_2019`m'
}
foreach m in 01 02 03 04 05 06 07 08 09{
append using data1_2020`m'
}

* Rename variables:
rename locationsofimportersandexporters p_id
rename v6 province
rename usdollar trade
rename tradingpartnercode fc_id
rename commoditycode c_id
rename tradingpartner country

* Label variables:
lab var p_id "Province code"
lab var trade "Trade value"
lab var province "Province"

* Create Date variable:
gen date=ym(year, month)
format date %tm

* Clean trade partner variable:
bysort fc_id: tab country
replace country="Taiwan " if fc_id==143
replace country="Macau " if fc_id==121
replace country="Hong Kong " if fc_id==110
replace country="Serbia and Montenegro" if fc_id==349

* Clean commodity variable:
bysort c_id: tab commodity
replace commodity="Soap, organic surfaceactive agents, washing preparations" if c_id==34
replace commodity="Coffee, tea, and spices" if c_id==9
replace commodity="Silk" if c_id==50
replace commodity="Ceramic" if c_id==69
/*
Note:
Because Commodity 44 and 45 are similar and are grouped together in Upstreamness and Concentration datasets,
I will merge their trade value together
*/
preserve 
keep if c_id == 44 | c_id == 45
collapse (first) country province month year (sum) trade, by(p_id fc_id date)
gen c_id = 44
gen commodity = "Wood and articles of wood; wood charcoal; Cork and articles of cork"
save commodity44, replace
restore
drop if c_id == 44 | c_id == 45
append using commodity44

drop p_id 
egen p_id= group(province)

save data1_orig, replace
save "/Users/chonge/Documents/Document/Macalester/2020 fall/Honor Thesis/Data/Final data/data1_orig", replace

/*
Note:
The current trade data is unbalanced as the zero value trades are not reported. 
In order to make it balanced, I will create a file that has the complete set of province-country-commodity-date combinations:
*/

*** 3. Create a full size template

use data1_orig, replace

* Get complete set of countries:
collapse (first) country, by(fc_id)

* Expand to get complete set of provinces
expand 31
bysort fc_id: gen p_id=_n

* Expand to get complete set of commodities
expand 98
bysort fc_id p_id: gen c_id=_n
drop if c_id==45 /* commodity 45 is combined with 44 */
drop if c_id==77 /* commodity 77 is never traded */

* Expand to get complete set of month:
expand 30
bysort fc_id p_id c_id: gen t_id=_n
gen year=2018
replace year=2019 if t_id>9
replace year=2020 if t_id>21
replace t_id=t_id-9 if t_id>9 & t_id<22
replace t_id=t_id-21 if t_id>21
rename t_id month
gen date=ym(year, month)
format date %tm
drop year month

order p_id fc_id country c_id date

* Save the template:
save template, replace


*** 4. Merge with template to fill in missing observations with zeros:
use data1_orig, clear
merge 1:1 p_id fc_id c_id date using template
replace trade=0 if _merge==2
drop _merge
bysort p_id (province): replace province=province[_N]
bysort date (year): replace year=year[1]
bysort date (month): replace month=month[1]

* Organize and save data:
order province p_id country fc_id c_id date trade
sort p_id fc_id c_id date

save data_1_full_w0, replace
save "/Users/chonge/Documents/Document/Macalester/2020 fall/Honor Thesis/Data/Final data/data_1_full_w0", replace

* Drop those province-country-commodity pairs for which we have no trade data (i.e. all zeros):
bysort p_id fc_id c_id (date): egen total_trade=sum(trade)
drop if total_trade==0
drop total_trade

save data_1_full_some_pos, replace
save "/Users/chonge/Documents/Document/Macalester/2020 fall/Honor Thesis/Data/Final data/data_1_full_some_pos", replace

* Keep only those province-country-commodity pairs for which we have only positive trade data:
bysort p_id fc_id c_id (date): egen min_trade=min(trade)
drop if min_trade==0
drop min_trade

save data_1_full_only_pos, replace
save "/Users/chonge/Documents/Document/Macalester/2020 fall/Honor Thesis/Data/Final data/data_1_full_only_pos", replace




