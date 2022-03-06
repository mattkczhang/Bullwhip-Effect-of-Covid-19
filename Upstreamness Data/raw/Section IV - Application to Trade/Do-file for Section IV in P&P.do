
* Basic correlations of export upstreamness with country characteristics


use country_upstreamness, clear
rename iso_code isocode
merge 1:1 isocode using country_characteristics_file.dta
drop _m
keep if lrgdppc9605~=.
keep if exp_upstreamness_all~=.
count
summ exp_upstreamness*, det

cap drop inctile
xtile inctile = lrgdppc9605, nq(4)
foreach n of numlist 1/4 {
	summ exp_upstreamness_all if inctile==`n' 
}
foreach n of numlist 1/4 {
	summ exp_upstreamness_manufall if inctile==`n'
}

sort exp_upstreamness_all
list isocode exp_upstreamness_all inctile lrgdppc9605 in 1/10
list isocode exp_upstreamness_all inctile lrgdppc9605 in -10/L

sort exp_upstreamness_manufall
list isocode exp_upstreamness_manufall inctile lrgdppc9605 in 1/10
list isocode exp_upstreamness_manufall inctile lrgdppc9605 in -10/L





local depvarlist "exp_upstreamness_all exp_upstreamness_manufall"
foreach depvar of local depvarlist {

	reg `depvar' lrgdppc9605, r
	
	reg `depvar' lrgdppc9605 rule9605, r
	
	reg `depvar' lrgdppc9605 rule9605 pc9605, r
	
	reg `depvar' lrgdppc9605 rule9605 pc9605 lK_L9605 yr_sch, r

}
