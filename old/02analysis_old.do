
version 14
set more off
clear all
local path /nfs/projects/t/tpricing/tpricing2/analysis
cd `path'

local DD = 1

*===============================================================================
* Dif-dif
*===============================================================================

if `DD' == 1 {
	di "hola"
}

*===============================================================================
* dj1850 analysis
*===============================================================================
use output/dj1850.dta, clear

*-------------------------------------------------------------------------------
* Affiliates (treated)
*-------------------------------------------------------------------------------
gen byte dj1850affiliate = ///
	(dj1850tiporelacion >= 11 & dj1850tiporelacion <= 20) | /// 
	(dj1850tiporelacion >= 31 & dj1850tiporelacion <= 36) | ///
	(dj1850tiporelacion >= 41 & dj1850tiporelacion <= 45)
label define isaffiliate 0 "Non Affiliate" 1 "Affiliate"
label values dj1850affiliate isaffiliate

*-------------------------------------------------------------------------------
* F50 transaction type codes
*-------------------------------------------------------------------------------

* Encode f50 transfer types
*-------------------------------------------------------------------------------
// Locals for f50 codes for each type of transaction
local dividends 12 102 105 300 62
local royalties 17 19 23 25 601 603 605 607 27 29
local interests 31 33 35 37 39 41 43 269
local services 45 609 47 49 611 613 109 111 68 84 21
local others 51 254 55 57 59 65 87 273 96 276 625
local unknown 0 999
// Update locals in cases where firm used taxbase code instead of tax code
local dividends `dividends' 137
local royalties `royalties' 16 24 26
local services `services' 244
local others `others' 95
// Define label for f50 type encoding
label define f50types 1 "Dividends" 2 "Royalties" 3 "Interests" 4 "Services" ///
	5 "Others" 99 "Unknown"
qui gen f50transtype = .
// Replace dividends with 1
foreach i in `dividends' {
	qui replace f50transtype = 1 if dj1850codigof50 == `i'
}
// Replace royalties with 2
foreach i in `royalties' {
	qui replace f50transtype = 2 if dj1850codigof50 == `i'
}
// Replace interests with 3
foreach i in `interests' {
	qui replace f50transtype = 3 if dj1850codigof50 == `i'
}
// Replace services with 4
foreach i in `services' {
	qui replace f50transtype = 4 if dj1850codigof50 == `i'
}
// Replace others with 5
foreach i in `others' {
	qui replace f50transtype = 5 if dj1850codigof50 == `i'
}
// Replace unknown with 99
foreach i in `unknown' {
	qui replace f50transtype = 99 if dj1850codigof50 == `i'
}
label values f50transtype f50types

* Generate variables with amounts of transfers, by f50 type
*-------------------------------------------------------------------------------
levelsof f50transtype, local(levels)
foreach l of local levels {
	qui gen `: label (f50transtype) `l'' = .
	qui replace `: label (f50transtype) `l'' = dj1850baseimponible ///
		if f50transtype == `l' & dj1850baseimponible > 0
	rename `: label (f50transtype) `l'', lower
}

* Tab: Count of transfers by f50 type and year
*-------------------------------------------------------------------------------
eststo clear
estpost tabulate f50transtype year
esttab using tabs/dj1850_transferCount_f50type_year.tex, ///
	cells(b(fmt(%8.0fc)) colpct(fmt(1) par(( )))) ///
	collabels(none) unstack noobs nonumber nomtitle booktabs ///
	varlabels(99 "No type", blist(Total "\midrule ")) replace ///
	drop("Total:")

* Tab: Transfers in MUSD by f50 type and year
*-------------------------------------------------------------------------------
// Generate transfer in MUSD
ppp dj1850baseimponible, exp(6)
// Post, tabulate and export results
eststo clear
foreach year of numlist 2007/2013 {
	eststo: estpost tabstat dj1850baseimponible_exp6 if year==`year', ///
		by(f50transtype) stats(sum) col(stat)
	matrix colupct = e(sum)
	scalar c = colsof(colupct)
	matrix colupct = 100*colupct/colupct[1,c]
	estadd matrix colupct = colupct
}
esttab using tabs/dj1850_transferMUSD_f50type_year.tex, booktabs replace ///
	noobs nonumber collabels(none) ///
	cell(sum(fmt(%9.0fc)) colupct(fmt(1) par)) ///
	varlabels(, blist(Total "\midrule ")) ///
	mtitles(2007 2008 2009 2010 2011 2012 2013)

* Tab: Count of transfers by f50 type and year, tax haven vs. non tax haven
*-------------------------------------------------------------------------------
tempvar ones
gen `ones' = (dj1850baseimponible_exp6>0)
eststo clear
forvalues i = 0/1 {
	foreach year of numlist 2007/2013 {
		eststo: estpost tabstat `ones' ///
			if year == `year' & taxhaven == `i', ///
			by(f50transtype) stats(sum) col(stat)
		matrix colupct = e(sum)
		scalar c = colsof(colupct)
		matrix colupct = 100*colupct/colupct[1,c]
		estadd matrix colupct = colupct
	}
}
esttab using tabs/dj1850_transferCount_f50type_year_taxhaven.tex, booktabs replace ///
	noobs nonumber ///
	mgroups("Non Tax Haven" "Tax Haven", pattern(1 0 0 0 0 0 0 1 0 0 0 0 0 0) ///
		prefix(\multicolumn{@span}{c}{) suffix(})   ///
		span erepeat(\cmidrule(lr){@span})) ///
	mtitles(2007 2008 2009 2010 2011 2012 2013 2007 2008 2009 2010 2011 2012 2013) ///
	collabels(none) ///
	cell(sum(fmt(%9.0fc)) colupct(fmt(1) par)) ///
	varlabels(, blist(Total "\midrule "))

* Tab: Transfers in MUSD by f50 type and year, tax haven vs. non tax haven
*-------------------------------------------------------------------------------
eststo clear
forvalues i = 0/1 {
	foreach year of numlist 2007/2013 {
		eststo: estpost tabstat dj1850baseimponible_exp6 ///
			if year == `year' & taxhaven == `i', ///
			by(f50transtype) stats(sum) col(stat)
		matrix colupct = e(sum)
		scalar c = colsof(colupct)
		matrix colupct = 100*colupct/colupct[1,c]
		estadd matrix colupct = colupct
	}
}
esttab using tabs/dj1850_transferMUSD_f50type_year_taxhaven.tex, booktabs replace ///
	noobs nonumber ///
	mgroups("Non Tax Haven" "Tax Haven", pattern(1 0 0 0 0 0 0 1 0 0 0 0 0 0) ///
		prefix(\multicolumn{@span}{c}{) suffix(})   ///
		span erepeat(\cmidrule(lr){@span})) ///
	mtitles(2007 2008 2009 2010 2011 2012 2013 2007 2008 2009 2010 2011 2012 2013) ///
	collabels(none) ///
	cell(sum(fmt(%9.0fc)) colupct(fmt(1) par)) ///
	varlabels(, blist(Total "\midrule "))

*===============================================================================
* f50 analysis
*===============================================================================
use output/f50.dta, clear

*-------------------------------------------------------------------------------
* Count number of types of tax payments declared in each observation
*-------------------------------------------------------------------------------
// Assumption: replace 0 values as missing values:
foreach var of varlist f50c10-f50c625 {
	qui replace `var' =. if `var'==0
}

// Count individual category taxes that are nonmissing (>0):
egen taxes_count = rownonmiss( ///
	f50c12 f50c102 f50c105 f50c300 f50c62 ///
	f50c17 f50c19 f50c21 f50c23 f50c25 f50c601 f50c603 f50c605 f50c607 ///
	f50c27 ///
	f50c29 ///
	f50c31 f50c33 f50c35 f50c37 f50c39 f50c41 f50c43 f50c269 ///
	f50c45 f50c609 f50c47 f50c49 f50c611 f50c613 ///
	f50c51 f50c254 ///
	f50c55 ///
	f50c57 ///
	f50c59 ///
	f50c65 ///
	f50c109 f50c111 f50c68 f50c84 ///
	f50c87 ///
	f50c273 f50c96 f50c276 ///
	f50c625 ///
	)
