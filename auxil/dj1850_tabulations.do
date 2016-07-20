* DJ1850 Tabulations

use output/dj1850.dta, clear

*===============================================================================
* Create variables and categories needed
*===============================================================================

* Generate transfer in MUSD
*-------------------------------------------------------------------------------
ppp dj1850baseimponible, exp(6)

* Create variable with transfer affiliation dependency category
*-------------------------------------------------------------------------------
local catA 11 14 15 17 18 31 32 35
local catB 12 13 16 19 20 33 34 36
local catC 41 42 43 44 45
local catD 99

gen dj1850affiliate_cat = .
foreach code in `catA' {
	replace dj1850affiliate_cat = 1 if dj1850tiporelacion == `code'
}
foreach code in `catB' {
	replace dj1850affiliate_cat = 2 if dj1850tiporelacion == `code'
}
foreach code in `catC' {
	replace dj1850affiliate_cat = 3 if dj1850tiporelacion == `code'
}
replace dj1850affiliate_cat = 4 if dj1850tiporelacion == 99
replace dj1850affiliate_cat = 5 if dj1850affiliate_cat == .

label define dj1850affiliate_cat 1 "A" 2 "B" 3 "C" 4 "D" 5 "Others"
label value dj1850affiliate_cat dj1850affiliate_cat

* Category discrepancy
*-------------------------------------------------------------------------------
// Assumption: IDs 
local valid_ids

encode dj1850taxid, gen(id_recipient)
tostring id, gen(id_declarant)
sort year id id_recipient

forvalues cat = 1/5 {
	gen iscat`cat' = (dj1850affiliate_cat == `cat')
	egen aux`cat' = max(iscat`cat'), by(year id id_recipient)
}
egen catcount = rowtotal(aux*)

* Firm affiliation
*-------------------------------------------------------------------------------
tempvar trans_affiliate
gen `trans_affiliate' = (dj1850affiliate_cat == 1 | dj1850affiliate_cat == 3)
egen dj1850affiliate = max(`trans_affiliate'), by(id year)


*===============================================================================
* Tables and graphs
*===============================================================================
*-------------------------------------------------------------------------------
* Tab: annual sums in MUSD
*-------------------------------------------------------------------------------
eststo clear
// Annual columns:
foreach year of numlist 2007/2013 {
	eststo: estpost tabstat dj1850baseimponible_exp6 if year==`year', ///
		stats(sum) col(stat)
	// Add column percentage matrix
	matrix colupct = e(sum)
	scalar c = colsof(colupct)
	matrix colupct = 100*colupct/colupct[1,c]
	estadd matrix colupct = colupct
}
// Export tab
esttab using docs/dj1850_tabulations/dj1850_transfer_MUSD.tex, ///
	replace booktabs varlabels(, blist(Total "\midrule ")) ///
	cells(sum(fmt(%8.1fc) label(Sum)) colupct(fmt(2) label(Pct.) par)) ///
	mtitles(2007 2008 2009 2010 2011 2012 2013) ///
	collabels(none) nonumber noobs alignment(rr)

*-------------------------------------------------------------------------------
* Tab: annual sums in MUSD by affiliation dependency categories
*-------------------------------------------------------------------------------
eststo clear
// Annual columns:
foreach year of numlist 2007/2013 {
	eststo: estpost tabstat dj1850baseimponible_exp6 if year==`year', ///
		by(dj1850affiliate_cat) stats(sum) col(stat)
	// Add column percentage matrix
	matrix colupct = e(sum)
	scalar c = colsof(colupct)
	matrix colupct = 100*colupct/colupct[1,c]
	estadd matrix colupct = colupct
}
// Export tab
esttab using docs/dj1850_tabulations/dj1850_affilCat_transfer_MUSD.tex, ///
	replace booktabs varlabels(, blist(Total "\midrule ")) ///
	cells(sum(fmt(%8.1fc) label(Sum)) colupct(fmt(2) label(Pct.) par)) ///
	mtitles(2007 2008 2009 2010 2011 2012 2013) ///
	collabels(none) nonumber noobs alignment(rr)

*-------------------------------------------------------------------------------
* Tab: annual sums in MUSD by type of transfer
*-------------------------------------------------------------------------------
eststo clear
// Annual columns:
foreach year of numlist 2007/2013 {
	eststo: estpost tabstat dj1850baseimponible_exp6 if year==`year', ///
		by(dj1850transtype) stats(sum) col(stat)
	// Add column percentage matrix
	matrix colupct = e(sum)
	scalar c = colsof(colupct)
	matrix colupct = 100*colupct/colupct[1,c]
	estadd matrix colupct = colupct
}
// Export tab
esttab using docs/dj1850_tabulations/dj1850_transtype_transfer_MUSD.tex, ///
	replace booktabs varlabels(, blist(Total "\midrule ")) ///
	cells(sum(fmt(%8.1fc) label(Sum)) colupct(fmt(2) label(Pct.) par)) ///
	mtitles(2007 2008 2009 2010 2011 2012 2013) ///
	collabels(none) nonumber noobs alignment(rr)
	
*-------------------------------------------------------------------------------
* Tab: annual sums in MUSD by sector
*-------------------------------------------------------------------------------
merge m:m id using output/firm_chars
encode aceccodrubro, gen(dj1850sector_code)
replace dj1850sector_code = . if dj1850sector_code <4
eststo clear
// Annual columns:
foreach year of numlist 2007/2013 {
	eststo: estpost tabstat dj1850baseimponible_exp6 if year==`year', ///
		by(dj1850sector_code) stats(sum) col(stat)
	// Add column percentage matrix
	matrix colupct = e(sum)
	scalar c = colsof(colupct)
	matrix colupct = 100*colupct/colupct[1,c]
	estadd matrix colupct = colupct
}
// Export tab
esttab using docs/dj1850_tabulations/dj1850_sector_transfer_MUSD.tex, ///
	replace booktabs varlabels(, blist(Total "\midrule ")) ///
	cells(sum(fmt(%8.1fc) label(Sum)) colupct(fmt(2) label(Pct.) par)) ///
	mtitles(2007 2008 2009 2010 2011 2012 2013) ///
	collabels(none) nonumber noobs alignment(rr)
