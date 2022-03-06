
*-------------------------------------------------------------------------------------------------*
************************************* Clean Upstreamness Data *************************************
*-------------------------------------------------------------------------------------------------*
clear all
set more off

cd "/Users/chonge/Documents/Document/Macalester/2020 fall/Honor Thesis/Data/Upstreamness Data"

*** 1. Import data
import delimited using upstreamness_by_industry.csv, clear

*** 2. create matched upstreamness index
forval i=1/98{
gen C`i' = .
}

foreach var of varlist match1-match4 {
	forval i = 1/98{
		replace C`i' = upstreamness if `var' == `i'
	}
}

keep C1-C98

xpose, clear

gen c_id = _n

egen Upstreamness = rowmean(v1-v426)

keep c_id Upstreamness

*** 3. Clean data
drop if c_id == 77

gen UQuality = 0 

replace UQuality = 1 if Upstreamness != .

foreach i in 4 8 9 10 17 18 19 22 24 30 31 39 40 52 69 70 72 74 76 86 88 89 91 92 93 95 {
	replace UQuality = 2 if c_id == `i'
}

lab var Upstreamness "Upstreamness index of the product"
lab var UQuality "Quality of match of upstreamness index"

save Upstreamness, replace
save "/Users/chonge/Documents/Document/Macalester/2020 fall/Honor Thesis/Data/Final data/Upstreamness", replace

