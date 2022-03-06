
***************************************
* ACFH AER P&P Supplementary Material *
***************************************

by

Pol Antras, Harvard
Davin Chor, Singapore Management University
Thibault Fally, Colorado
Russell Hillberry, University of Melbourne


This readme file describes the supplementary material that accompanies the article "Measuring the Upstreamness of Production and Trade Flows", AER Papers and Proceedings (2012). 


1. The files in the subfolder "Section II - Upstreamness in the US" contain the US 2002 Input-Output Tables ("iousedetail.dta") and the Stata do file ("Do-file to compute Upstreamness.do") that generate the upstreamness measure for the 426 IO-2002 industries. 

The measures are reported in both excel and stata dta format ("upstreamness_by_industry").

For any questions contact Thibault Fally, University of Colorado at Boulder, Department of Economics, fally@colorado.edu 


2. The files in the subfolder "Section III - Upstreamness in Other Countries" relate to the calculations involving the I-O Tables in the OECD STAN database.  

To generate the output update the Stata do file “OECDfiles.do” to refer to your particular file structure and run the file. 

Other files in the folder include “countryfile_05.csv”, which is a master file that lists the countries included in the data set.  The do file calls this file in order to inform stata which other .csv files to run.  The remaining .csv files are the data files.  Each is named with a country abbreviation and a year designator.  For instance “aut05.csv” refers to Austria for the year 2005.  

The output constitutes two Stata files: “prfx.dta” is simply a holding file generated in the course of the program.  “distfile.dta”  contains the calculated values of upstreamness for each country-industry pair.

For any questions contact Russell Hillberry, University of Melbourne Department of Economics, rhhi@unimelb.edu.au. 


3. The files in the subfolder "Section IV - Application to Trade" perform the preliminary exploration related to the country export upstreamness measure. This is constructed from BACI product-level trade data (publicly available) and the US upstreamness measure from Section II above. 

The file "country_upstreamness.dta" contains this country export upstreamness measure. (It also contains country import upstreamness, but this is not used in our paper.) The file "country_characteristics_file.dta" contains the country variables we used to explore the correlations reported in Table 3 in our AER P&P paper. 

The do file "Do-file for Section IV in P&P.do" can be executed to replicate the analysis -- summary statistics and regressions -- contained in Section IV in the paper.

For any questions contact Davin Chor, Singapore Management University School of Economics, davinchor@smu.edu.sg.
