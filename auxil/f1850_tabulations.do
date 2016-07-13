*===============================================================================
* dj1850 tabulations
*===============================================================================
label define iso3166 410 "South_Korea", modify
label define iso3166 344 "Hong_Kong", modify
label define iso3166 630 "Puerto_Rico", modify
label define iso3166 136 "Cayman_Islands", modify
label define iso3166 710 "South_Africa", modify

local top_bytype	= 0

*-------------------------------------------------------------------------------
* Transfers by type and year
*-------------------------------------------------------------------------------

* Count of transfers by f50 type and year
*-------------------------------------------------------------------------------
eststo clear
estpost tabulate f50transtype year
esttab using tabs/dj1850_transferCount_f50type_year.tex, ///
	cells(b(fmt(%8.0fc)) colpct(fmt(1) par(( )))) ///
	collabels(none) unstack noobs nonumber nomtitle booktabs ///
	varlabels(99 "No type", blist(Total "\midrule ")) replace ///
	drop("Total:")

* Transfers in MUSD by f50 type and year
*-------------------------------------------------------------------------------
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

*-------------------------------------------------------------------------------
* Top countries
*-------------------------------------------------------------------------------

* Top N Countries by total count of transfers
*-------------------------------------------------------------------------------

// Compute sums of no-type transactions of top N countries
local topN = 20
tempvar aux countrysum group flag
gen `aux' = 1
egen `countrysum' = sum(`aux'), by(iso3166)
egen `group' = axis(`countrysum' iso3166), ///
	reverse label(iso3166)
gen `flag' = (`group'<=`topN')

// Group non-topN countries as "Others" in 999 and flag them
replace `group' = 999 if `flag'==0
replace `flag' = 1 if `flag'==0

eststo clear
// Total row
eststo: estpost tabstat `aux' if `flag'==1, statistics(sum) by(`group')
	matrix colupct = e(sum)
	scalar c = colsof(colupct)
	matrix colupct = 100*colupct/colupct[1,c]
	estadd matrix colupct = colupct

// Year rows	
foreach year of numlist 2007/2013 {
eststo: estpost tabstat `aux' if ///
	year == `year' & `flag'==1, statistics(sum) by(`group')
// Add column percentages matrices
	matrix colupct = e(sum)
	scalar c = colsof(colupct)
	matrix colupct = 100*colupct/colupct[1,c]
	estadd matrix colupct = colupct
}
// Export
esttab using tabs/dj1850_transferCount_f50typeAll_top`topN'.tex, replace booktabs ///
	cells(sum(fmt(%9.0fc)) colupct(fmt(1) par)) noobs nonumber collabels(none) ///
	varlabels(`e(labels)' 999 "Others countries", blist(Total "\midrule ")) ///
	mtitles(Total 2007 2008 2009 2010 2011 2012 2013) ///
	alignment (rr)

* Top N Countries by total amount of transfers
*-------------------------------------------------------------------------------

// Compute sums of no-type transactions of top N countries
local topN = 20
tempvar aux countrysum group flag
gen `aux' = dj1850baseimponible_exp6
egen `countrysum' = sum(`aux'), by(iso3166)
egen `group' = axis(`countrysum' iso3166), ///
	reverse label(iso3166)
gen `flag' = (`group'<=`topN')

// Group non-topN countries as "Others" in 999 and flag them
replace `group' = 999 if `flag'==0
replace `flag' = 1 if `flag'==0

eststo clear
// Total row
eststo: estpost tabstat `aux' if `flag'==1, statistics(sum) by(`group')
	matrix colupct = e(sum)
	scalar c = colsof(colupct)
	matrix colupct = 100*colupct/colupct[1,c]
	estadd matrix colupct = colupct

// Year rows	
foreach year of numlist 2007/2013 {
eststo: estpost tabstat `aux' if ///
	year == `year' & `flag'==1, statistics(sum) by(`group')
// Add column percentages matrices
	matrix colupct = e(sum)
	scalar c = colsof(colupct)
	matrix colupct = 100*colupct/colupct[1,c]
	estadd matrix colupct = colupct
}
// Export
esttab using tabs/dj1850_transferMUSD_f50typeAll_top`topN'.tex, replace booktabs ///
	cells(sum(fmt(%9.0fc)) colupct(fmt(1) par)) noobs nonumber collabels(none) ///
	varlabels(`e(labels)' 999 "Others countries", blist(Total "\midrule ")) ///
	mtitles(Total 2007 2008 2009 2010 2011 2012 2013) ///
	alignment (rr)

*-------------------------------------------------------------------------------
* Top countries by type
*-------------------------------------------------------------------------------

if `top_bytype' == 1 {
* Top N Countries by total count of transfers
*-------------------------------------------------------------------------------
levelsof f50transtype, local(levels)
foreach code of local levels {
// Compute sums of no-type transactions of top N countries
local topN = 20
tempvar aux countrysum group flag
gen `aux'=1
egen `countrysum' = sum(`aux') if f50transtype == `code', by(iso3166)
egen `group' = axis(`countrysum' iso3166) if f50transtype == `code', ///
	reverse label(iso3166)
gen `flag' = (`group'<=`topN')

// Group non-topN countries as "Others" in 999 and flag them
replace `group' = 999 if f50transtype == `code' & `flag'==0
replace `flag' = 1 if f50transtype == `code' & `flag'==0

eststo clear
// Total row
eststo: estpost tabstat `aux' if f50transtype == `code' ///
	& `flag'==1, statistics(sum) by(`group')
	matrix colupct = e(sum)
	scalar c = colsof(colupct)
	matrix colupct = 100*colupct/colupct[1,c]
	estadd matrix colupct = colupct

// Year rows	
foreach year of numlist 2007/2013 {
eststo: estpost tabstat `aux' if f50transtype == `code' ///
	& year == `year' & `flag'==1, statistics(sum) by(`group')
// Add column percentages matrices
	matrix colupct = e(sum)
	scalar c = colsof(colupct)
	matrix colupct = 100*colupct/colupct[1,c]
	estadd matrix colupct = colupct
}
// Export
esttab using tabs/dj1850_transferCount_f50type`code'_top`topN'.tex, replace booktabs ///
	cells(sum(fmt(%9.0fc)) colupct(fmt(1) par)) noobs nonumber collabels(none) ///
	varlabels(`e(labels)' 999 "Others countries", blist(Total "\midrule ")) ///
	mtitles(Total 2007 2008 2009 2010 2011 2012 2013) ///
	alignment (rr)
}

* Top N Countries by total amount of transfers
*-------------------------------------------------------------------------------
levelsof f50transtype, local(levels)
foreach code of local levels {
// Compute sums of no-type transactions of top N countries
local topN = 20
tempvar aux countrysum group flag
gen `aux' = dj1850baseimponible_exp6
egen `countrysum' = sum(`aux') if f50transtype == `code', by(iso3166)
egen `group' = axis(`countrysum' iso3166) if f50transtype == `code', ///
	reverse label(iso3166)
gen `flag' = (`group'<=`topN')

// Group non-topN countries as "Others" in 999 and flag them
replace `group' = 999 if f50transtype == `code' & `flag'==0
replace `flag' = 1 if f50transtype == `code' & `flag'==0

eststo clear
// Total row
eststo: estpost tabstat `aux' if f50transtype == `code' ///
	& `flag'==1, statistics(sum) by(`group')
	matrix colupct = e(sum)
	scalar c = colsof(colupct)
	matrix colupct = 100*colupct/colupct[1,c]
	estadd matrix colupct = colupct

// Year rows	
foreach year of numlist 2007/2013 {
eststo: estpost tabstat `aux' if f50transtype == `code' ///
	& year == `year' & `flag'==1, statistics(sum) by(`group')
// Add column percentages matrices
	matrix colupct = e(sum)
	scalar c = colsof(colupct)
	matrix colupct = 100*colupct/colupct[1,c]
	estadd matrix colupct = colupct
}
// Export
esttab using tabs/dj1850_transferMUSD_f50type`code'_top`topN'.tex, replace booktabs ///
	cells(sum(fmt(%9.0fc)) colupct(fmt(1) par)) noobs nonumber collabels(none) ///
	varlabels(`e(labels)' 999 "Others countries", blist(Total "\midrule ")) ///
	mtitles(Total 2007 2008 2009 2010 2011 2012 2013) ///
	alignment (rr)
}
}
