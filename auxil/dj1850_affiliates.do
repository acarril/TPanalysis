
version 14
set more off
clear all
local path /nfs/projects/t/tpricing/tpricing2/analysis
cd `path'

*===============================================================================
* dj1907 affiliates
*===============================================================================
use output/dj1907.dta, clear

*-------------------------------------------------------------------------------
* Tab: count of codes of relation type
*-------------------------------------------------------------------------------
eststo clear
// Total row (2013):
eststo: estpost tab dj1907tipo_relacion_ig
esttab using "docs/Affiliates definition/dj1907_typerelation_codes_Count.tex", ///
	cells("b(fmt(%8.0fc) label(Freq.)) pct(fmt(2) label(Pct.))") ///
	varlabels(, blist(Total "\midrule ")) ///
	mgroups(2013, ///
		pattern(1) ///
		prefix(\multicolumn{@span}{c}{) suffix(}) ///
		span erepeat(\cmidrule(lr){@span})) ///
	nonumber nomtitle noobs alignment(rr) replace booktabs
	
*-------------------------------------------------------------------------------
* Tab: sums in MUSD of codes of relation type
*-------------------------------------------------------------------------------
// Generate transfer in MUSD
ppp dj1907monto_operacion_of, exp(6)
// Post and store tab
eststo clear
eststo: estpost tabstat dj1907monto_operacion_of_exp6, ///
		by(dj1907tipo_relacion_ig) stats(sum) col(stat)
	// Add column percentage matrix
	matrix colupct = e(sum)
	scalar c = colsof(colupct)
	matrix colupct = 100*colupct/colupct[1,c]
	estadd matrix colupct = colupct
// Export tab
esttab using "docs/Affiliates definition/dj1907_typerelation_codes_MUSD.tex", ///
	replace booktabs varlabels(, blist(Total "\midrule ")) ///
	cells("sum(fmt(%8.1fc) label(Sum)) colupct(fmt(2) label(Pct.))") ///
	mgroups(2013, ///
		pattern(1) ///
		prefix(\multicolumn{@span}{c}{) suffix(}) ///
		span erepeat(\cmidrule(lr){@span})) ///
	nonumber nomtitle noobs alignment(rr)

*===============================================================================
* dj1850 affiliation by transfer
*===============================================================================
use output/dj1850.dta, clear

*-------------------------------------------------------------------------------
* Create variables and categories needed
*-------------------------------------------------------------------------------

* Generate transfer in MUSD
*-------------------------------------------------------------------------------
ppp dj1850baseimponible, exp(6)

* Create variable with transfer affiliation dependency category
*-------------------------------------------------------------------------------
local catA 11 14 15 17 18 31 32 35 56
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

*-------------------------------------------------------------------------------


* Firm affiliation
*-------------------------------------------------------------------------------

tempvar trans_affiliate
gen `trans_affiliate' = (dj1850affiliate_cat == 1 | dj1850affiliate_cat == 3)
egen dj1850affiliate = max(`trans_affiliate'), by(id year)

*-------------------------------------------------------------------------------
* Tab: count of codes of relation type
*-------------------------------------------------------------------------------
eststo clear
// total row:
eststo: estpost tab dj1850tiporelacion, missing
// annual rows:
foreach year of numlist 2007/2013 {
	eststo: estpost tab dj1850tiporelacion if year==`year', missing
}
esttab using "docs/Affiliates definition/dj1850_typerelation_codes_Count.tex", ///
	cells("b(fmt(%8.0fc) label(Freq.)) pct(fmt(2) label(Pct.))") ///
	varlabels(, blist(Total "\midrule ")) ///
	mgroups(Total 2007 2008 2009 2010 2011 2012 2013, ///
		pattern(1 1 1 1 1 1 1 1) ///
		prefix(\multicolumn{@span}{c}{) suffix(}) ///
		span erepeat(\cmidrule(lr){@span})) ///
	nonumber nomtitle noobs alignment(rr) replace booktabs

*-------------------------------------------------------------------------------
* Tab: sums in MUSD of codes of relation type
*-------------------------------------------------------------------------------
// Post and store tab
eststo clear
eststo: estpost tabstat dj1850baseimponible_exp6, ///
		by(dj1850tiporelacion) stats(sum) col(stat)
	// Add column percentage matrix
	matrix colupct = e(sum)
	scalar c = colsof(colupct)
	matrix colupct = 100*colupct/colupct[1,c]
	estadd matrix colupct = colupct
// Annual columns:
foreach year of numlist 2007/2013 {
	eststo: estpost tabstat dj1850baseimponible_exp6 if year==`year', ///
		by(dj1850tiporelacion) stats(sum) col(stat)
	// Add column percentage matrix
	matrix colupct = e(sum)
	scalar c = colsof(colupct)
	matrix colupct = 100*colupct/colupct[1,c]
	estadd matrix colupct = colupct
}
// Export tab
esttab using "docs/Affiliates definition/dj1850_typerelation_codes_MUSD.tex", ///
	replace booktabs varlabels(, blist(Total "\midrule ")) ///
	cells("sum(fmt(%8.1fc) label(Sum)) colupct(fmt(2) label(Pct.))") ///
	mgroups(Total 2007 2008 2009 2010 2011 2012 2013, ///
		pattern(1 1 1 1 1 1 1 1) ///
		prefix(\multicolumn{@span}{c}{) suffix(}) ///
		span erepeat(\cmidrule(lr){@span})) ///
	nonumber nomtitle noobs alignment(rr)

*-------------------------------------------------------------------------------
* Fig: annual sums of transfers by affiliation directionality category
*-------------------------------------------------------------------------------

preserve
collapse (sum) dj1850baseimponible_exp6, by(year dj1850affiliate_cat)
twoway ///
	(line dj1850baseimponible_exp6 year if dj1850affiliate_cat == 1, sort) ///
	(line dj1850baseimponible_exp6 year if dj1850affiliate_cat == 2, sort lpat(longdash)) ///
	(line dj1850baseimponible_exp6 year if dj1850affiliate_cat == 3, sort lpat(dash)) ///
	(line dj1850baseimponible_exp6 year if dj1850affiliate_cat == 4, sort lpat(shortdash)) ///
	(line dj1850baseimponible_exp6 year if dj1850affiliate_cat == 5, sort lpat(dot)), ///
	scheme(plotplain) ytitle(Transfers in millions of USD) xlabel(2007(1)2013) ///
	legend(order(1 "A" 2 "B" 3 "C" 4 "D" 5 "Other") pos(5) cols(3) colfirst)
restore

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
esttab using "docs/Affiliates definition/dj1850_affiliation_category_MUSD.tex", ///
	replace booktabs varlabels(, blist(Total "\midrule ")) ///
	cells(sum(fmt(%8.1fc) label(Sum)) colupct(fmt(2) label(Pct.) par)) ///
	mtitles(2007 2008 2009 2010 2011 2012 2013) ///
	collabels(none) nonumber noobs alignment(rr)

*===============================================================================
* dj1850 discrepancies
*===============================================================================

* Tab: discrepant transfers by topN declarant to recipients with nonmissing IDs
*-------------------------------------------------------------------------------
// Assumption: missing recipient_id is not valid
local valid_ids id_recipient != .
// Compute sums of no-type transactions of topN declarants
local topN = 50
tempvar sum group flag aux
gen `aux'=dj1850baseimponible_exp6
egen `sum' = sum(`aux') if `valid_ids' & catcount>1, by(id_declarant)
egen `group' = axis(`sum' id_declarant) if `valid_ids' & catcount>1, reverse label(id_declarant)
gen `flag' = (`group'<=`topN')
// Group non-topN countries as "Others" in 999
replace `group' = 999 if `valid_ids' & catcount>1 & `flag'==0
replace `flag' = 1 if `valid_ids' & catcount>1 & `flag'==0
// Count "Others"
qui tab id_recipient if `group' == 999 
local N_others = `r(r)'-1
// Tabulate
eststo clear
eststo: estpost tabstat `aux' if `valid_ids' & catcount>1 ///
	& `flag'==1, statistics(sum count) by(`group')
	// Add sum column percentage matrix
	matrix sumpct = e(sum)
	scalar c = colsof(sumpct)
	matrix sumpct = 100*sumpct/sumpct[1,c]
	estadd matrix sumpct = sumpct
	// Add count column percentage matrix
	matrix countpct = e(count)
	scalar c = colsof(countpct)
	matrix countpct = 100*countpct/countpct[1,c]
	estadd matrix countpct = countpct
// Export
esttab using "docs/Affiliates definition/dj1850_discrepancies_declarant.tex", ///
	cells("sum(fmt(%8.1fc) label(Sum)) sumpct(label(Sum pct.)) count(fmt(%8.0fc) label(Freq.)) countpct(label(Freq. pct.))") ///
	noobs nonumber nomtitle collabels(, lhs("Declarant ID")) ///
	varlabels(`e(labels)' 999 "Others (`N_others')", blist(Total "\midrule ")) ///
	alignment (rrrr) replace booktabs

* Tab: discrepant transfers by topN recipients with nonmissing IDs
*-------------------------------------------------------------------------------
// Assumption: missing recipient_id is not valid
local valid_ids id_recipient != .
// Compute sums of no-type transactions of topN declarants
local topN = 50
tempvar sum group flag aux
gen `aux'=dj1850baseimponible_exp6
egen `sum' = sum(`aux') if `valid_ids' & catcount>1, by(id_recipient)
egen `group' = axis(`sum' id_recipient) if `valid_ids' & catcount>1, reverse label(id_recipient)
gen `flag' = (`group'<=`topN')
// Group non-topN countries as "Others" in 999
replace `group' = 999 if `valid_ids' & catcount>1 & `flag'==0
replace `flag' = 1 if `valid_ids' & catcount>1 & `flag'==0
// Count "Others"
qui tab id_recipient if `group' == 999 
local N_others = `r(r)'-1
// Tabulate
eststo clear
eststo: estpost tabstat `aux' if `valid_ids' & catcount>1 ///
	& `flag'==1, statistics(sum count) by(`group')
	// Add sum column percentage matrix
	matrix sumpct = e(sum)
	scalar c = colsof(sumpct)
	matrix sumpct = 100*sumpct/sumpct[1,c]
	estadd matrix sumpct = sumpct
	// Add count column percentage matrix
	matrix countpct = e(count)
	scalar c = colsof(countpct)
	matrix countpct = 100*countpct/countpct[1,c]
	estadd matrix countpct = countpct
// Export
esttab using "docs/Affiliates definition/dj1850_discrepancies_recipient.tex", ///
	cells("sum(fmt(%8.1fc) label(Sum)) sumpct(label(Sum pct.)) count(fmt(%8.0fc) label(Freq.)) countpct(label(Freq. pct.))") ///
	noobs nonumber nomtitle collabels(, lhs("Recipient ID")) ///
	varlabels(`e(labels)' 999 "Others (`N_others')", blist(Total "\midrule ")) ///
	alignment (rrrr) replace booktabs

* Tab: discrepant transfers by topN recipients with valid IDs
*-------------------------------------------------------------------------------
// Flag id_recipients that are not constant across destination countries
sort id_recipient SIIcountrycode
tempvar diff
by id_recipient (SIIcountrycode), sort: gen `diff' = SIIcountrycode[1] ///
	!= SIIcountrycode[_N]
gen id_recipient_discrepant = (`diff' == 1)
gen dj1850discrepant = (catcount > 1 & id_recipient != . & `diff' == 1)

// Assumption: missing id_recipients or id_recipients that aren't constant across
// countries are not valid.
local valid_ids id_recipient != . & `diff' == 0

// Compute sums of no-type transactions of topN declarants
local topN = 50
tempvar sum group flag aux
gen `aux'=dj1850baseimponible_exp6
egen `sum' = sum(`aux') if `valid_ids' & catcount>1, by(id_recipient)
egen `group' = axis(`sum' id_recipient) if `valid_ids' & catcount>1, ///
	reverse label(id_recipient)
gen `flag' = (`group'<=`topN')

// Group non-topN countries as "Others" in 999
replace `group' = 999 if `valid_ids' & catcount>1 & `flag'==0
replace `flag' = 1 if `valid_ids' & catcount>1 & `flag'==0

// Count "Others"
qui tab id_recipient if `group' == 999 
local N_others = `r(r)'-1

// Tabulate
eststo clear
eststo: estpost tabstat `aux' if `valid_ids' & catcount>1 ///
	& `flag'==1, statistics(sum count) by(`group')
	// Add sum column percentage matrix
	matrix sumpct = e(sum)
	scalar c = colsof(sumpct)
	matrix sumpct = 100*sumpct/sumpct[1,c]
	estadd matrix sumpct = sumpct
	// Add count column percentage matrix
	matrix countpct = e(count)
	scalar c = colsof(countpct)
	matrix countpct = 100*countpct/countpct[1,c]
	estadd matrix countpct = countpct
	
// Export
esttab using "docs/Affiliates definition/dj1850_discrepancies_validrecipient.tex", ///
	cells("sum(fmt(%8.1fc) label(Sum)) sumpct(label(Sum pct.)) count(fmt(%8.0fc) label(Freq.)) countpct(label(Freq. pct.))") ///
	noobs nonumber nomtitle collabels(, lhs("Recipient ID")) ///
	varlabels(`e(labels)' 999 "Others (`N_others')", blist(Total "\midrule ")) ///
	alignment (rrrr) replace booktabs

* Fig: annual discrepant transfers to valid recipient IDs, by affiliation categories
*-------------------------------------------------------------------------------
preserve
collapse (sum) dj1850baseimponible_exp6 if dj1850discrepant, by(year dj1850affiliate_cat)
twoway ///
	(line dj1850baseimponible_exp6 year if dj1850affiliate_cat == 1, sort) ///
	(line dj1850baseimponible_exp6 year if dj1850affiliate_cat == 2, sort lpat(longdash)) ///
	(line dj1850baseimponible_exp6 year if dj1850affiliate_cat == 3, sort lpat(dash)) ///
	(line dj1850baseimponible_exp6 year if dj1850affiliate_cat == 4, sort lpat(shortdash)) ///
	(line dj1850baseimponible_exp6 year if dj1850affiliate_cat == 5, sort lpat(dot)), ///
	scheme(plotplain) ytitle(Transfers in millions of USD) xlabel(2007(1)2013) ///
	legend(order(1 "A" 2 "B" 3 "C" 4 "D" 5 "Other") pos(5) cols(3) colfirst)
restore

*-------------------------------------------------------------------------------
* Firm affiliation
*-------------------------------------------------------------------------------

// Create dummy indicating if firm is affiliate
forvalues cat = 1/5 {
	egen jelp`cat' = max(iscat`cat'), by(year id)
}
egen dj1850affiliate = rowtotal(jelp1 jelp3)
drop jelp*
replace dj1850affiliate = 1 if dj1850affiliate > 0 & dj1850affiliate != .

* Tab: Annual transfers by firm affiliation
*-------------------------------------------------------------------------------

eststo clear
forvalues year = 2007/2013 {
	eststo: estpost tabstat dj1850baseimponible_exp6 if year == `year', ///
		by(dj1850affiliate) stat(sum count)
	// Add sum column percentage matrix
	matrix sumpct = e(sum)
	scalar c = colsof(sumpct)
	matrix sumpct = 100*sumpct/sumpct[1,c]
	estadd matrix sumpct = sumpct
	// Add count column percentage matrix
	matrix countpct = e(count)
	scalar c = colsof(countpct)
	matrix countpct = 100*countpct/countpct[1,c]
	estadd matrix countpct = countpct
}
esttab using "docs/Affiliates definition/dj1850_annualtransfers_firmaffiliation.tex", ///
	cells("sum(fmt(%8.1fc)) count(fmt(%8.0fc))" "sumpct(par) countpct(par)") ///
	varlabels(0 "Non affiliate" 1 "Affiliate", blist(Total "\midrule ")) ///
	mgroups(2007 2008 2009 2010 2011 2012 2013, ///
		pattern(1 1 1 1 1 1 1) ///
		prefix(\multicolumn{@span}{c}{) suffix(}) ///
		span erepeat(\cmidrule(lr){@span})) ///
	collabels(Sum Count) ///
	nonumber nomtitles noobs alignment(rr) replace booktabs
	
	
* Fig: Annual number of firms that change affiliation status w/r previous year
*-------------------------------------------------------------------------------

preserve
collapse (mean) dj1850affiliate*, by(id year)

// Dummy to flag if a firm flips w/r to its 2007 affiliation status
bys id: gen affil_flip = dj1850affiliate[_n] != dj1850affiliate[_n-1]
bys id: replace affil_flip = 0 if affil_flip[1]

// Generate dummies differentiating if if firm flips in or out of affiliation
bys id: gen affil_flip_out = affil_flip if dj1850affiliate[1] == 1
bys id: gen affil_flip_in = affil_flip if dj1850affiliate[1] == 0

// Generate diffirenet variable for percentages (collapses below)
foreach var of varlist affil_flip* {
	gen `var'_pct = `var'
	replace `var'_pct = 0 if `var'_pct == .
}

// Collapse adding out the flips and taking the mean for percentages
collapse (sum) affil_flip - affil_flip_in (mean) *_pct, by(year)
foreach var of varlist *_pct {
	replace `var' = round(`var', .001)
}

// Plot affiliates to non affiliates and vice versa, unstacked
twoway	(line affil_flip year, sort) ///
	(line affil_flip_out year, sort) ///
	(line affil_flip_in year, sort) ///
	(scatter affil_flip year, sort msymbol(circle) mlabel(affil_flip_pct) mlabposition(12) mlabgap(small)) ///
	if year>2007, ///
	ytitle(Number of firms) xlabel(#6) graphregion(margin(sides)) ///
	legend(on order(1 "Total firms switching" 2 "Affilate to non-affiliate" 3 "Non-affiliate to affiliate") position(5)) ///
	yscale(range(0 250))

// Plot affiliates to non affiliates and vice versa, stacked
twoway	(area affil_flip year, sort) ///
	(scatter affil_flip year, ///
		sort mcolor(black) msymbol(circle) mlabel(affil_flip_pct) mlabposition(12) mlabgap(small)) ///
	(area affil_flip_out year, sort fintensity(50)) ///
	(scatter affil_flip_out year, ///
		sort mcolor(black) msymbol(circle) mlabel(affil_flip_out_pct) mlabposition(12) mlabgap(vsmall)) ///
	if year > 2007, ytitle(Number of firms with affiliation status change) ///
	yscale(range(0 250)) xlabel(#6) legend(on order(1 "Non-affiliate to affiliate" 3 "Affilate to non-affiliate" ) position(5)) ///
	graphregion(margin(sides))

restore


* Tab: Total number of affiliation switches by firms
*-------------------------------------------------------------------------------
preserve
collapse (mean) dj1850affiliate* , by(id year)

bys id: gen affil_flip = dj1850affiliate[_n] != dj1850affiliate[_n-1]
bys id: replace affil_flip = 0 if affil_flip[1]
gen affil_flip_pct = affil_flip

collapse (sum) affil_flip, by(id)

eststo clear
eststo: estpost tab affil_flip, nototal
esttab using "docs/Affiliates definition/dj1850_affiliation_Nflips.tex", replace ///
	cell("b(fmt(%8.0fc) label(Count)) pct(fmt(%8.1fc) label(Pct.))") ///
	collabels(, lhs("Nº changes")) nomtitle nonumbers booktabs alignment(rr)
	
restore
	
*******************************************************************************
***************************************** EXPERIMENTAL ZONE *******************
*******************************************************************************
exit
