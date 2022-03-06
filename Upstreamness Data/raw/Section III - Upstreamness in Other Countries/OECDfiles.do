set more off
clear
cd "C:\Documents and Settings\Russell\My Documents\Thibault_Jan2012\OECD\AER_files"

/* creates a dummy file  */
clear
insheet using  "C:\Documents and Settings\Russell\My Documents\Thibault_Jan2012\OECD\AER_files\can2005.csv", names
drop if _n > 48
gen trdbl =  1 if _n < 26
replace trdbl = 0 if trdbl == .
gen mfg = 1 if trdbl == 1 & _n>3
replace mfg = 0 if mfg == .
keep industry mfg trdbl
sort industry
save distfile, replace

/*This program loops through the countries in the data set and produces a U measure for each industry-country pair */
clear
insheet using  "C:\Documents and Settings\Russell\My Documents\Thibault_Jan2012\OECD\AER_files\countryfile_05.csv", names
save prfx, replace
levelsof prefix, local(prf)
foreach i of local prf{
      use prfx
      keep if prefix == "`i'"
	levelsof year, local(yr)
	clear
	foreach x of local yr{
		clear
		insheet using `i'`x'.csv, names
		gen netex = exports - imports
		drop if _n > 48
		mkmat netex, matrix(nx) rownames(industry)
            matrix nx`i' = nx
		clear
		insheet using `i'`x'.csv, names
		drop if _n > 48
		gen grossoutput =  totalintermediateuse+ finalconsumptionexpenditurebyhou+ finalconsumptionexpenditurebynon+ finalconsumptionexpenditurebygov+ grossfixedcapitalformation + changesininventories +  changesinvaluables+exports- imports
		gen goinv = 1/(grossoutput - exports + imports- changesininventories - changesinvaluables)
		replace goinv = 0 if goinv == .
		mkmat goinv, rownames(industry)

		clear
		insheet using `i'`x'.csv, names
		drop if _n > 48
		mkmat  agriculturehuntingforestryandfis miningandquarryingenergy miningandquarryingnonenergy foodproductsbeveragesandtobacco textilestextileproductsleatheran woodandproductsofwoodandcork pulppaperpaperproductsprintingan cokerefinedpetroleumproductsandn chemicalsexcludingpharmaceutical pharmaceuticals rubberplasticsproducts othernonmetallicmineralproducts ironsteel nonferrousmetals fabricatedmetalproductsexceptmac machineryequipmentnec officeaccountingcomputingmachine electricalmachineryapparatusnec radiotelevisioncommunicationequi medicalprecisionopticalinstrumen motorvehiclestrailerssemitrailer buildingrepairingofshipsboats aircraftspacecraft railroadequipmenttransportequipn manufacturingnecrecyclinginclude productioncollectionanddistribut manufactureofgasdistributionofga steamandhotwatersupply collectionpurificationanddistrib construction wholesaleretailtraderepairs hotelsrestaurants landtransporttransportviapipelin watertransport airtransport supportingandauxiliarytransporta posttelecommunications financeinsurance realestateactivities rentingofmachineryequipment computerrelatedactivities researchdevelopment otherbusinessactivities publicadmindefencecompulsorysoci education healthsocialwork othercommunitysocialpersonalserv  privatehouseholdswithemployedper, matrix(tot) rownames(industry)
		matrix phi = diag(goinv)*tot
		gen ones = 1
		mkmat ones, matrix(ones) rownames(industry)
		matrix distance = inv(I(48)-phi)*ones
		keep industry
		svmat distance, names(`i')
		replace `i'1 = . if `i'1 == 1
		sort industry
		merge industry using distfile
		drop _merge
		ren `i'1 U`i'
		sort industry
		save distfile, replace 

	}
}


/* The list just shows that to the naked eye the staging idices are relatively stable across countries */
list

/* This gets rid of the U prefix */
renpfix U 

/*This gives us a sense of the total variation across sectors in each country.  It looks pretty stable. */
summarize   usa  eur swe  svn  svk  rou  prt  pol  nor  nld  lux  kor  jpn  ita  isr  irl  idn  hun  grc  gbr  fra  fin  est  esp  dnk  deu  cze  chn  can  bra  bel  aut  aus

/*This puts the variables in capital letters, which is better for display */
renvars usa eur svn  svk  prt  nld  lux  ita  hun  grc  gbr fra fin  est  esp  dnk  deu  cze  bel  aut, upper

/*Spearman rank correlation exercise */

spearman USA EUR AUT BEL CZE DEU DNK ESP EST FIN GRC HUN ITA LUX NLD PRT SVK SVN, stats(p)
spearman USA EUR AUT BEL CZE DEU DNK ESP EST FIN GRC HUN ITA LUX NLD PRT SVK SVN
matrix sp = r(Rho)
/* outtable using spearman, mat(sp) nobox caption("Spearman rank correlation - Upstreamness") format(%6.2f) replace */

spearman USA EUR CZE DEU DNK ESP ITA LUX
matrix sp_sh = r(Rho)
/* outtable using spearman_sh, mat(sp_sh) nobox caption("Rank Correlations of Inustry Upstreamness") format(%6.2f) replace */


/* All of the above is sensitive to the critique that countries have different aggregations of the data. There are a number of European countries with exactly the same aggregation.  We use this subset to reevaluate stability. */
use distfile, clear
renpfix U
keep industry  svn  svk  prt  nld  lux  ita  hun  grc  fin  est  esp  dnk  deu  cze  bel  aut usa

list 

summarize  svn  svk  prt  nld  lux  ita  hun  grc  fin  est  esp  dnk  deu  cze  bel  aut
spearman  svn  svk  prt  nld  lux  ita  hun  grc  fin  est  esp  dnk  deu  cze  bel  aut


/*This is a principal components analysis. All of the correlations are being jointly evaluated here.  PCA is a rotation of the axes, and this is telling us that 75% of the cross-country variation in the indices can be captured by a single dimension.  The second component is barely over 1, which means that it has negligible influence. */
pca   svn  svk  prt  nld lux ita  hun  grc  fin  est  esp  dnk  deu  cze  bel  aut
/* now drop lux
pca   svn  svk  prt  nld ita  hun  grc  fin  est  esp  dnk  deu  cze  bel  aut */
predict f1 f2 
corr f1 f2  svn  svk  prt  nld   ita  hun  grc  fin  est  esp  dnk  deu  cze  bel  aut usa

/* This calculates the mean Upstreamness score across 15 countries in Europe (excluding luxembourg).  This is a fitted value to use for net export calculations.  Note that it is highly correlated with the first component of the pca */ 
gen Umean =  ( svn +  svk +  prt +  nld +  ita+  hun+  grc+  fin+  est+  esp+  dnk+  deu +   cze+  bel+  aut)/15
corr Umean f1
corr Umean  lux
sort Umean
mkmat Umean, rownames(industry)
drop Umean
/* outtable using Umean, mat(Umean) nobox caption("Mean Upstreamness for Europe, by sector") format(%6.2f) replace */



/* here we see how the variation across industries is much larger than the variation across countries */

clear
use distfile
keep industry  Usvn  Usvk  Uprt  Unld   Uita  Uhun  Ugrc  Ufin  Uest  Uesp  Udnk  Udeu  Ucze  Ubel  Uaut
reshape long U, i(industry) j(country) string
gen indno =  substr(industry,1,2)
destring indno, replace

/* some descriptive statistics */
xi: reg U i.indno, robust
/* 71 percent of variation in explained by industry dummies */
xi: reg U i.country, robust
/* Only 9 percent by country dummies */


/* This returns some overall summary stats, ex luxembourg */
summarize U, detail


/*This calculates the standard deviation at industry and country levels.*/
sort industry
egen sdind = sd(U), by(industry)

sort country 
egen sdcntry = sd(U), by(country)

tabstat sdind sdcntry, stats(median mean)
