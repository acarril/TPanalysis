*===============================================================================
* Name: 		00datasets.do
* Description:	Import data from various sources and produce working datasets 
*				for use in Bustos, Pomeranz and Zucman, "Transfer Pricing".
* Notes: 		This code's purpose is to transform and ouput all CSV datasets
*				in DTA format, with no assumptions or loss of information.
* Author:		Alvaro Carril (acarril@povertyactionlab.org)
* Created: 		20160229
* Version:		1.3
* Last edited:	20160502
*===============================================================================

*-------------------------------------------------------------------------------
* Initial set up
*-------------------------------------------------------------------------------
version 14
set more off
clear all
cd D:\tpricing\analysis\

*-------------------------------------------------------------------------------
* Programs
*-------------------------------------------------------------------------------
run do/auxil/ppp.ado // allows transforming variables to current USD exp(X)

*-------------------------------------------------------------------------------
* Build switches (set to 1 in order to build corresponding dataset)
*-------------------------------------------------------------------------------
local dj1907 		= 0	// transfer pricing form (annual)
local dj18XX		= 0	// annual income tax form with additional info
local f50 			= 0	// tax declaration form (monthly)
local f22			= 0	// income tax form
local f29			= 0	// monthly tax form
local firm_chars	= 0	// Firm characteristics
local customs		= 0	// Customs data
local consolidate 	= 1	// Save main dataset (transfer level)
local collapse		= 1	// Save collapsed dataset (firm level)

*===============================================================================
* Import datasets
*===============================================================================
* Data was provided by SII in text format. All data received from SII can be 
* found in analysis/input.
*-------------------------------------------------------------------------------
* DJ1907
*-------------------------------------------------------------------------------
if `dj1907' == 1 {
	// Import raw data:
	import excel input/dj1907.xlsx, sheet("Hoja1") firstrow case(lower) clear
	// Define key variables: firm id and year:
	rename rut id
	gen int year = periodo_dj/100 - 1 //convert fiscal year
	// Country codes and tax haven merge:
	rename cod_pais_ig SIIcountrycode
	merge m:1 SIIcountrycode using input/country_codes.dta, ///
		keep(master match) nogenerate
	// Keep useful variables and sort:
	keep year id SIIcountrycode-metodo_precio_ig country-taxhaven_SII
	order year id
	sort year id
	// Rename and label variables
	label var year "Year"
	label var id "ID Declarant"
	rename tipo_relacion_ig relation_code
	label var relation_code "Relationship with recipient code"
	rename cod_operacion_ig operation_code
	label var operation_code "Operation type code"
	rename cod_moneda_ig currency_code
	label var currency_code "Alphanumeric currency code (SII)"
	rename metodo_precio_ig TP_method_code
	label var TP_method_code "Transfer Pricing method (OECD)"
	// Gen transfer variable
	gen transfer = monto_operacion_ig, after(monto_operacion_ig)
*	ppp transfer, exp(3) replace
*	note transfer : Implied PPP conversion rate reported by the IMF
*	label var transfer "Transfer in thousands of USD"
	// Add dj1907 prefix
	foreach v of varlist relation_code-TP_method_code {
		rename `v' dj1907`v'
	}
	// Compress and save:
	compress
	save output/dj1907.dta, replace
}

*-------------------------------------------------------------------------------
* DJ18XX import (DJ1850, DJ1851, DJ1852, DJ1853, DJ1854, DJ1857, DJ1860)
*-------------------------------------------------------------------------------
if `dj18XX' == 1 {
	foreach form of numlist 1850 1851 1852 1853 1854 1857 1860 {
		// Import raw data:
		import delimited using input/DJ`form'.csv, clear delimiters(";")
		// Add dj19XX stub:
		rename f`form'* dj`form'*
		// Define key variables: firm id and year:
		rename contrut id
		gen int year = periagnomestrib/100 - 1 //convert fiscal year
		drop periagnomestrib
		capture {
		rename dj`form'taxid dj`form'id_recipient
		lab var dj`form'id_recipient "ID Recipient"
		}
		// Country codes and tax haven merge:
		rename dj`form'codigopaisvo SIIcountrycode
		merge m:1 SIIcountrycode using input/country_codes.dta, ///
			keep(master match) nogenerate keepusing(iso3166 taxhaven_SII)
		// Delete *vo stub:
		rename *vo *
		// Drop, order and sort
		order year id
		sort year id
		// Labels:
		label data "dj`form' data"
		lab var id "ID Declarant"
		label var year "Year"
		// 1850
		if `form' == 1850 {
			run do/auxil/00datasets_dj1850.do
		}
		else {
			drop headerformkey-contdv
		}
		// Compress and save:
		compress
		save output/dj`form'.dta, replace
	}
}

*-------------------------------------------------------------------------------
* F50
*-------------------------------------------------------------------------------
if `f50' == 1 {
	local F50FileList archivo001_dic.csv archivo002_dic.csv ///
		archivo003_dic.csv archivo004_dic.csv archivo005_dic.csv ///
		archivo006_dic.csv archivo007_dic.csv archivo008_dic.csv
	local x 0 // counter for inner loop
	foreach filename of local F50FileList {
		import delimited using input/f50/`filename', clear delimiters(";") ///
			numericcols(5/98)
		if `x' == 0 {
			save output/f50.dta, replace	
		}
		else {
			append using output/f50.dta
			save output/f50.dta, replace	
		}
		local x = `x' + 1
	}
	// Decode and rename variables
	run do/auxil/00datasets_f50_aux.do
	// Year variable (it's not fiscal!)
	gen int year = floor(f50agnomestributario / 100)
	// Labels:
	label data "f50 raw data"
	lab var id "Firm ID"
	lab var year "Year"
	// Order variables and drop unneccessary ones
	drop contdv-f50fechapresentacion
	order year id
	// Preserve variable labels before collapsing
	foreach v of var * {
		local l`v' : variable label `v'
		if `"`l`v''"' == "" {
			local l`v' "`v'"
		}
	}
	// Collapse monthly dataset into annual sums
	collapse (sum) f50c10-f50c625, by(id year)
	// Paste the saved labels
	foreach v of var * {
		label var `v' "`l`v''"
	}
	// Compress and save:
	compress
	save output/f50.dta, replace
}

*-------------------------------------------------------------------------------
* F22 (Imports & appends annual income tax forms)
*-------------------------------------------------------------------------------
if `f22' == 1 {
	local f22files F22_At2008_nuevo.csv F22_At2009_nuevo.csv ///
		F22_At2010_nuevo.csv F22_At2011_nuevo.csv F22_At2012_nuevo.csv ///
		F22_At2013_nuevo.csv F22_At2014_nuevo.csv
	local x 0
	foreach filename of local f22files {
		import delimited using input/f22/`filename', clear ///
			delimiters(";") numericcols(3/63)
		rename ïcontrut id								
		gen int year = f22agnomestributariovo / 100 - 1  
		if `x' == 0 {
			save output/f22.dta, replace
		}
		else {
			append using output/f22.dta
			save output/f22.dta, replace
			di "file `filename' appended successfully!"
		}
		local x = `x' + 1 // updates the counter"
	}
	// Labels:
	label data "f22 raw data"
	lab var id "Firm ID"
	lab var year "Year"
	lab var f22c18 "Global Complementary Tax"
	lab var f22c19 "Fiscal Debt (negative savings)"
	lab var f22c20 "Income tax"
	lab var f22c87 "Credit remanent"
	lab var f22c91 "Late payment surcharge"

	label var f22c628 "Sales"
	label var f22c851 "Revenue from foreign sources"
	label var f22c629 "Interest income"
	label var f22c651 "Other revenue"
	label var f22c633 "Interest expenses"
	label var f22c630 "Costs of Goods Sold"
	label var f22c631 "Wages"
	label var f22c636 "Earnings"

	label var f22c122 "Assets"
	// Order and drop unnecessary variables
	order year id
	drop contdv f22agnomestributariovo universo-secuenciacoincidencia
	// Save:
	compress
	save output/f22.dta, replace
}

*-------------------------------------------------------------------------------
* F29
*-------------------------------------------------------------------------------
if `f29' == 1 {
	local f29year_semester  2008s1 2008s2 2009s1 2009s2 2010s1 2010s2 ///
		2011s1 2011s2 2012s1 2012s2 2013s1 2013s2 2014s1 2014s2
local x 0
foreach filename of local f29year_semester {
	import delimited using input/f29/DatosF29_`filename'_filtrado.csv, ///
		clear delimiters(";") numericcols(3/16)
	rename contrut id								
	gen int year = f29agnomestributariovo / 100 - 1  
	if `x' == 0 {
		save output/f29.dta, replace
	}
	else {
		append using output/f29.dta
		save output/f29.dta, replace
		di "file `filename' appended successfully!"
	}
	local x = `x' + 1 // updates the counter"
}
// Collapse monthly data into annual sums
collapse (sum) f29c20-f29c553, by(id year)
order year id
// Correct and sum imports and exports
replace f29c535 = f29c535/0.19 // c535 is the VAT that the purchase originated.
replace f29c553 = f29c553/0.19 // c553 is the VAT that the purchase originated.
egen f29imports = rowtotal(f29c535 f29c553)
replace f29c20 = -f29c20 if f29c20<0
// Label variables
lab var f29c20 Exports
lab var f29c142 "Tax-free Sales and Services"
lab var f29c502 "Sales and Services"
lab var f29c538 "Total Sales and Debits"
lab var f29c521 "Internal Sales or Services purchased (without right to fiscal credit)"
lab var f29c520 "Internal Sales or Services purchased (with right to fiscal credit)"
lab var f29c525 "Internal Fixed Assets purchased (with right to fiscal credit)"
lab var f29c528 "Received Credit Notes"
lab var f29c537 "Total Credits"
lab var f29c532 "Received Debit Notes"
lab var f29c589 "Retention of withdrawals of APV"
lab var f29c535 "Imports (main activity)"
lab var f29c553 "Imports (fixed assets)"
lab var f29imports "Imports"
// Save
compress
save output/f29.dta, replace
}

*-------------------------------------------------------------------------------
* FCXXXX (Firm characteristics, starting in 2009)
*-------------------------------------------------------------------------------
if `firm_chars' == 1 {
tempfile FC2008 FC2009 FC2010 FC2011 FC2012 FC2013 FC2014
foreach year of numlist 2008/2014 {
	import delimited input/FirmChars/comportamientoAt`year'.csv, ///
		clear delimiters(";") numericcols(1/8)
	rename periagnotributariorenta at
	rename contrut id
	lab var id "Declarant ID"
	gen int year = at / 100 - 1
	lab var year "Year"
	save `FC`year'', replace
	}
use `FC2008', clear
foreach year of numlist 2009/2014 {
	append using `FC`year''
}
// Region variable
run do/auxil/00datasets_firm_chars_comunaToRegion.do
drop comucodcomunaprincipal
// Tax payer type in terms of size categories
label define taxpayer_size 1 "SGPE" 2 "SGMI" 3 "SGPM" 4 "SGME" 5 "SGGC" 
encode segmcodsegmento, generate(size) label(taxpayer_size)
lab var size "Firm size"
replace size = . if size == 6
label define taxpayer_size 1 "Natural person" 2 "Micro" 3 "Small" 4 "Medium" 5 "Large", replace
drop segmcodsegmento
// Encode sector codes
run do/auxil/00datasets_firm_chars_industrysectors
label define industry_sector_letter 1 A 2 B 3 C 4 D 5 E 6 F 7 G 8 H 9 I 10 J 11 K 12 L 13 M ///
	14 N 15 O 16 P 17 Q 18 R
# delimit ;
label define industry_sector_name
	1 "Agriculture"
	2 "Fishing"
	3 "Mining"
	4 "Manufacturing - Non-metalic"
	5 "Manufacturing - Metalic"
	6 "Energy"
	7 "Construction"
	8 "Wholesale"
	9 "Hotels and Restaurants"
	10 "Transportation and Comunications"
	11 "Finance"
	12 "Real estate"
	13 "Government"
	14 "Education"
	15 "Social services and health"
	16 "Other communitary services"
	17 "Admin of buildings"
	18 "Foreign governmental organizations";
	#delimit cr
encode industry_code, gen(industry_sector) label(industry_sector_letter)
label var industry_sector "Industry Sector"
label values industry_sector industry_sector_name
drop aceccodrubro aceccodactecoprincipal industry_code

// Year 2007 is missing firm size, replace with 2008 values
sort id year
replace size = size[_n+1] if year==2007

// Final touches and save
format %12.0g id
drop at trvecodtmovta ticosubtpocontr cocomcaesempresa
compress
order year id
save output/firm_chars, replace
}

*-------------------------------------------------------------------------------
* Customs data
*-------------------------------------------------------------------------------
if `customs' == 1 {
* DUS
*-------------------------------------------------------------------------------
	tempfile DUS2008 DUS2009 DUS2010 DUS2011 DUS2012 DUS2013 DUS2014
	forvalues year = 2008/2014 {
		import delimited input/Customs/ADUANAS_DUS`year'.csv, ///
			delimiter(";") varnames(1) clear
		gen year = `year'-1
		save `DUS`year'', replace
		di "Saved tempfile DUS"`year'
	}
	use `DUS2008', clear
	forvalues year = 2009/2014 {
		append using `DUS`year''
		di "Appended tempfile DUS"`year'
	}
	// Renames, labels, order and sort
	rename *vo *
	rename dusi* DUSI*
	rename dusc* DUSC*
	rename contrut id
	label var id "ID Declarant"
	label var year "Year"
	foreach var of varlist * {
		local lab `: var label `var''
	*	local lab `: di subinstr("`lab'", " Vo", "", 1)'
		local lab `: di subinstr("`lab'", "Dusc ", "DUSC ", 1)'
		local lab `: di subinstr("`lab'", "Dusi ", "DUSI ", 1)'
		label var `var' "`lab'"
	}
	order year id
	sort id year
	// Drops unnecessary variables
	drop contdv-DUSCpctjeconsignante DUSCcodrutconsignante-DUSCpctjeconsignantesec
	// Destring numeric variables (CLP)
	destring DUSCvalorfobtotal DUSIcantidadmercancia-DUSIvalorfobtotal, ///
		dpcomma replace ignore(".")
	// Drop remaining string variables
	ds, has(type string)
	drop `r(varlist)'
	// Save
	compress
	save output/DUS, replace
}

*===============================================================================
* Consolidate all datasets
*===============================================================================

* Merge all datasets
*-------------------------------------------------------------------------------
// Use dj1850 as starting point
use output/firm_chars, clear
foreach dta in dj1850_collapsed f22 f29 f50 {
	merge 1:1 year id using output/`dta', generate(_merge_`dta')
	drop if year > 2013
	sort id year
}
	eststo clear
	* Tabulate number of firms per year
	eststo: estpost tabstat id, by(year) stats(count) nototal
	* Add scalar with distinct values (requieres distinct package)
	distinct id
	estadd r(ndistinct)

* Data trimming
*-------------------------------------------------------------------------------
// Keep firms that reported F22
keep if _merge_f22 >= 2
	* Tabulate number of firms per year
	eststo: estpost tabstat id if _merge_f22 >= 2, by(year) stats(count) nototal
	* Add scalar with distinct values (requieres distinct package)
	distinct id if _merge_f22 >= 2
	estadd r(ndistinct)

// Keep firms that were medium or large at baseline
gen aux1 = (size == 4 | size == 5) if year == 2009
egen aux2 = max(aux1), by(id)
keep if aux2 == 1
drop aux*
	* Tabulate number of firms per year
	eststo: estpost tabstat id, by(year) stats(count) nototal
	* Add scalar with distinct values (requieres distinct package)
	distinct id
	estadd r(ndistinct)
	
// Keep only firms under full tax reporting scheme
gen aux1 = (cocoregtributario == 100000) if year == 2009
egen aux2 = max(aux1), by(id)
keep if aux2 == 1
drop aux* cocoregtributario
	* Tabulate number of firms per year
	eststo: estpost tabstat id, by(year) stats(count) nototal
	* Add scalar with distinct values (requieres distinct package)
	distinct id
	estadd r(ndistinct)

// Tabulate trimming steps
esttab using tabs/Nfirms_trimmingsteps.tex, replace booktabs ///
	cell(count(fmt(%12.0gc))) /*alignment(*{@span}{r})*/ collabels(none) ///
	mlabels("All" "F22" "\$>\$Medium" "Full scheme") ///
	scalar("ndistinct Distinct") sfmt(%12.0gc) noobs

* Replace missing values for zeroes. 
*-------------------------------------------------------------------------------
// If filed F22 under full tax reporting, all missings are zeros. 
// Validated by SII analyst.
foreach v of varlist f22* {
	quietly: replace `v' = 0 if missing(`v')
}

* Transform all monetary variables to current USD
*-------------------------------------------------------------------------------
local monetary_vars ///
	dj1850baseimponible-dj1850montoliquido ///
	dividends-others ///
	f22* f29* f50*
unab monetary_vars : `monetary_vars' // expand abbreviated varlist
local reps : word count `monetary_vars' 
local rep 1
nois _dots 0, title(Converting variables from CLP to USD) reps(`reps')
foreach var of varlist `monetary_vars' {
	qui ppp `var', exp(3) replace // thousands of USD
	nois _dots `rep++' 0
}

* Update treatment groups
*-------------------------------------------------------------------------------
replace treatment1 = 0 if missing(treatment1)

*-------------------------------------------------------------------------------
* Save firm level-dataset
*-------------------------------------------------------------------------------
drop _merge*
label data "Transfer Pricing panel dataset with observations at the firm level"
compress
save output/TPdata_firm, replace
