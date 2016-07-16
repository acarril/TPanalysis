cd "D:\tpricing\analysis\"
use output/dj1850.dta, clear

* Define affiliates
*-------------------------------------------------------------------------------
* We define a firm as "affiliate" if it registers at least type A, B or C transfer
* in any of the pre-treatment years (prior to 2010)

// Create variable with transfer affiliation dependency category
local catA 11 14 15 17 18 31 32 35
local catB 12 13 16 19 20 33 34 36
local catC 41 42 43 44 45
local catD 99
gen dj1850transfer_cat = .
foreach code in `catA' {
	replace dj1850transfer_cat = 1 if dj1850tiporelacion == `code'
}
foreach code in `catB' {
	replace dj1850transfer_cat = 2 if dj1850tiporelacion == `code'
}
foreach code in `catC' {
	replace dj1850transfer_cat = 3 if dj1850tiporelacion == `code'
}
replace dj1850transfer_cat = 4 if dj1850tiporelacion == 99
replace dj1850transfer_cat = 5 if dj1850transfer_cat == .
label define dj1850transfer_cat 1 "A" 2 "B" 3 "C" 4 "D" 5 "Others"
label value dj1850transfer_cat dj1850transfer_cat
label var dj1850transfer_cat "Transfer affiliation category"

// Create binary variable indicating if firm is affiliate
gen trans_affiliate1 = (dj1850transfer_cat == 1 | dj1850transfer_cat == 2 | ///
	dj1850transfer_cat == 3)
egen dj1850affiliate = max(trans_affiliate1), by(id)
drop trans_affiliate1
label var dj1850affiliate "Dummy indicating affiliation by firm"

// Create binary variable indicating if firm is affiliate of a Tax Haven
egen dj1850affiliate_TH = max(taxhaven_SII) if dj1850affiliate == 1, by(id)
label var dj1850affiliate_TH "Dummy indicating affiliation to TH by firm"

* Define treatment (comparison) variables
*-------------------------------------------------------------------------------

// Affiliates vs. non affiliates 
gen treatment1 = dj1850affiliate

// Affiliates of non tax havens vs. non affiliates
gen treatment2 = (dj1850affiliate == 1) if dj1850affiliate_TH != 1

// Affiliates of tax havens vs. non affiliates
gen treatment3 = (dj1850affiliate == 1) if dj1850affiliate_TH == 1

// Affiliates of tax havens vs. affiliates of non tax havens
gen treatment4 = (dj1850affiliate_TH == 1) if dj1850affiliate == 1

// Affiliates of tax havens vs. (affiliates of non tax havens & non affiliates)
gen treatment5 = (dj1850affiliate_TH == 1)

// Apply variable and value labels
label define treatment 0 "Control" 1 "Treated"
forvalues i = 1/4 {
	label var treatment`i' "Comparison `i'"
	label values treatment`i' treatment
}

*-------------------------------------------------------------------------------
* Collapse dataset
*-------------------------------------------------------------------------------
// Preserve variable labels before collapsing
foreach v of var * {
	local l`v' : variable label `v'
	if `"`l`v''"' == "" {
		local l`v' "`v'"
	}
}

// Collapse
collapse ///
	(sum) dj1850baseimponible - dj1850montoliquido dividends - others ///
	(mean) dj1850affiliate* treatment*, by(id year)
// Paste the saved labels
foreach v of var * {
	label var `v' "`l`v''"
}
// Apply treatment value labels
label values treatment* treatment
// Save
label data "dj1850 collapsed at the firm year level"
compress
sort id year
save output/dj1850_collapsed, replace
