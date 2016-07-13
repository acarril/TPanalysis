local path /nfs/projects/t/tpricing/output
use `path'/temp_indDj1850.dta, clear
cd `path'/results

/*
capture program define ppp
syntax varname[, exp(integer 1)]
quietly{
	tempvar x
	gen `x' = `varlist'
	replace `x' = 0 if `x' == .
	replace `x' = `x' / (314.790 * 10^`exp') if year == 2007 
	replace `x' = `x' / (310.269 * 10^`exp') if year == 2008 
	replace `x' = `x' / (319.449 * 10^`exp') if year == 2009 
	replace `x' = `x' / (343.559 * 10^`exp') if year == 2010 
	replace `x' = `x' / (348.017 * 10^`exp') if year == 2011 
	replace `x' = `x' / (344.646 * 10^`exp') if year == 2012
	replace `x' = `x' / (345.798 * 10^`exp') if year == 2013
	
	gen `varlist'_exp`exp' = `x'
}
end
*/

ppp f1850montoliquidovo, exp(3)
ppp f1850montoliquidovo, exp(6)

// Replace value just for sorting purposes
replace f1850tiporentavo = 99 if f1850tiporentavo == 0

label define iso3166 840 "USA", modify
label define iso3166 850 "Virgin_Islands_USA", modify
label define iso3166 92 "Virgin_Islands_UK", modify
label define iso3166 364 "Iran", modify
label define iso3166 410 "South_Korea", modify
label define iso3166 408 "North_Korea", modify
label define iso3166 862 "Venezuela", modify
label define iso3166 530 "Antilles", modify
label define iso3166 630 "Puerto_Rico", modify
label define iso3166 554 "New_Zealand", modify
label define iso3166 136 "Cayman_Islands", modify
label define iso3166 784 "Arab_Emirates", modify
label define iso3166 710 "South_Africa", modify
label define iso3166 214 "Dominican_Republic", modify

levelsof f1850tiporentavo, local(levels)
local not 8 18 22 24
local levels: list levels-not

gen group = .

foreach code of local levels {
* Top 15 "No type" countries by number of transactions, yearly -------
// Compute sums of no-type transactions of topN countries
local topN = 20
tempvar countrysum group flag aux
gen `aux'=1
egen `countrysum' = sum(`aux') if f1850tiporentavo == `code' ///
	& year>=2008, by(iso3166)
egen `group' = axis(`countrysum' iso3166) if f1850tiporentavo == `code' ///
	& year>=2008, reverse label(iso3166)
gen `flag' = (`group'<=`topN')

// Group non-topN countries as "Others" in 999
replace `group' = 999 if f1850tiporentavo == `code' & year>=2008 & `flag'==0
replace `flag' = 1 if f1850tiporentavo == `code' & year>=2008 & `flag'==0

eststo clear
// Total row
eststo: estpost tabstat `aux' if f1850tiporentavo == `code' ///
	& `flag'==1, statistics(sum) by(`group')
	matrix colupct = e(sum)
	scalar c = colsof(colupct)
	matrix colupct = 100*colupct/colupct[1,c]
	estadd matrix colupct = colupct

// Year rows	
foreach year of numlist 2008/2013 {
eststo: estpost tabstat `aux' if f1850tiporentavo == `code' ///
	& year == `year' & `flag'==1, statistics(sum) by(`group')
// Add column percentages matrices
	matrix colupct = e(sum)
	scalar c = colsof(colupct)
	matrix colupct = 100*colupct/colupct[1,c]
	estadd matrix colupct = colupct
}
// Export
esttab using f1850_trans_type/f1850_transtype`code'_topCount.tex, replace booktabs ///
	cells(sum(fmt(%9.0fc)) colupct(fmt(1) par)) noobs nonumber collabels(none) ///
	varlabels(`e(labels)' 999 "Others countries", blist(Total "\midrule ")) ///
	mtitles(Total 2008 2009 2010 2011 2012 2013) ///
	alignment (rr)

* (II.5.d). Top 15 "No type" countries by transactions in MUSD, yearly ---------

// Compute sums of no-type transactions of topN countries
local topN = 20
tempvar countrysum group flag aux
gen `aux'=f1850montoliquidovo_exp6
egen `countrysum' = sum(`aux') if f1850tiporentavo == `code' ///
	& year>=2008, by(iso3166)
egen `group' = axis(`countrysum' iso3166) if f1850tiporentavo == `code' ///
	& year>=2008, reverse label(iso3166)
gen `flag' = (`group'<=`topN')

// Group non-topN countries as "Others" in 999
replace `group' = 999 if f1850tiporentavo == `code' & year>=2008 & `flag'==0
replace `flag' = 1 if f1850tiporentavo == `code' & year>=2008 & `flag'==0

replace group = `group'

eststo clear
// Total row
eststo: estpost tabstat `aux' if f1850tiporentavo == `code' ///
	& `flag'==1, statistics(sum) by(`group')
	matrix colupct = e(sum)
	scalar c = colsof(colupct)
	matrix colupct = 100*colupct/colupct[1,c]
	estadd matrix colupct = colupct

// Year rows	
foreach year of numlist 2008/2013 {
eststo: estpost tabstat `aux' if f1850tiporentavo == `code' ///
	& year == `year' & `flag'==1, statistics(sum) by(`group')
// Add column percentages matrices
	matrix colupct = e(sum)
	scalar c = colsof(colupct)
	matrix colupct = 100*colupct/colupct[1,c]
	estadd matrix colupct = colupct
}
// Export
esttab using f1850_trans_type/f1850_transtype`code'_topMUSD.tex, replace booktabs ///
	cells(sum(fmt(%9.0fc)) colupct(fmt(1) par)) noobs nonumber collabels(none) ///
	varlabels(`e(labels)' 999 "Others countries", blist(Total "\midrule ")) ///
	mtitles(Total 2008 2009 2010 2011 2012 2013) ///
	alignment (rr)	
}

************************************

* Top 15 "No type" countries by number of transactions, yearly -------
// Compute sums of no-type transactions of topN countries
local topN = 20
tempvar countrysum group flag aux
gen `aux'=1
egen `countrysum' = sum(`aux') if year>=2008, by(iso3166)
egen `group' = axis(`countrysum' iso3166) if year>=2008, reverse label(iso3166)
gen `flag' = (`group'<=`topN')

// Group non-topN countries as "Others" in 999
replace `group' = 999 if year>=2008 & `flag'==0
replace `flag' = 1 if year>=2008 & `flag'==0

eststo clear
// Total row
eststo: estpost tabstat `aux' if `flag'==1, statistics(sum) by(`group')
	matrix colupct = e(sum)
	scalar c = colsof(colupct)
	matrix colupct = 100*colupct/colupct[1,c]
	estadd matrix colupct = colupct

// Year rows	
foreach year of numlist 2008/2013 {
eststo: estpost tabstat `aux' if year == `year' ///
	& `flag'==1, statistics(sum) by(`group')
// Add column percentages matrices
	matrix colupct = e(sum)
	scalar c = colsof(colupct)
	matrix colupct = 100*colupct/colupct[1,c]
	estadd matrix colupct = colupct
}
// Export
esttab using f1850_trans_type/f1850_transtypeAll_topCount.tex, replace booktabs ///
	cells(sum(fmt(%9.0fc)) colupct(fmt(1) par)) noobs nonumber collabels(none) ///
	varlabels(`e(labels)' 999 "Others countries", blist(Total "\midrule ")) ///
	mtitles(Total 2008 2009 2010 2011 2012 2013) ///
	alignment (rr)

* (II.5.d). Top 15 "No type" countries by transactions in MUSD, yearly ---------
// Compute sums of no-type transactions of topN countries
local topN = 20
tempvar countrysum group flag aux
gen `aux'= f1850montoliquidovo_exp6
egen `countrysum' = sum(`aux') if year>=2008, by(iso3166)
egen `group' = axis(`countrysum' iso3166) if year>=2008, reverse label(iso3166)
gen `flag' = (`group'<=`topN')

// Group non-topN countries as "Others" in 999
replace `group' = 999 if year>=2008 & `flag'==0
replace `flag' = 1 if year>=2008 & `flag'==0

eststo clear
// Total row
eststo: estpost tabstat `aux' if `flag'==1, statistics(sum) by(`group')
	matrix colupct = e(sum)
	scalar c = colsof(colupct)
	matrix colupct = 100*colupct/colupct[1,c]
	estadd matrix colupct = colupct

// Year rows	
foreach year of numlist 2008/2013 {
eststo: estpost tabstat `aux' if year == `year' ///
	& `flag'==1, statistics(sum) by(`group')
// Add column percentages matrices
	matrix colupct = e(sum)
	scalar c = colsof(colupct)
	matrix colupct = 100*colupct/colupct[1,c]
	estadd matrix colupct = colupct
}
// Export
esttab using f1850_trans_type/f1850_transtypeAll_topMUSD.tex, replace booktabs ///
	cells(sum(fmt(%9.0fc)) colupct(fmt(1) par)) noobs nonumber collabels(none) ///
	varlabels(`e(labels)' 999 "Others countries", blist(Total "\midrule ")) ///
	mtitles(Total 2008 2009 2010 2011 2012 2013) ///
	alignment (rr)
