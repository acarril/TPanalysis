cd "D:\tpricing\analysis\"
use output/dj1850.dta, clear

* Define treated firms
*-------------------------------------------------------------------------------
* We define treatment1 as a dummy indicating all firms that reveal at least one
* category A, B or C transfer in pretreatment years.

// Value label for treatments
label define treatment 0 "Control" 1 "Treated"

// Create variable with transfer affiliation dependency category
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
label var dj1850affiliate_cat "Affiliation category of transfer"

// Create variable with firm affiliation by year
gen trans_affiliate1 = (dj1850affiliate_cat == 1 | dj1850affiliate_cat == 2 | ///
	dj1850affiliate_cat == 3)
egen dj1850affiliate = max(trans_affiliate1), by(id year)
drop trans_affiliate1
label var dj1850affiliate "Dummy indicating affiliation by ID and Year"

// Create treatment variable if firm is affiliate in any pretreatment year
egen pretreat1 = max(dj1850affiliate) if year < 2011, by(id)
egen treatment1 = max(pretreat1), by(id)
drop pretreat1
replace treatment1 = 0 if missing(treatment1)
label var treatment1 "Treatment 1"
label values treatment1 treatment

* Define treatment2 subgroup: 
*-------------------------------------------------------------------------------
* We define a treatment subgroup within treated firms acording to treatment1, 
* using as control firms who are not affiliated with a tax haven

// Generate flag for firms that transfer to tax haven in a given year
egen pretreat2 = max(taxhaven_SII) if year < 2011 & treatment1 == 1, by(id)
egen treatment2 = max(pretreat2), by(id)
drop pretreat2
lab var treatment2 "Treatment 2"
lab values treatment2 treatment

* Define treatment3 subgroup 
*-------------------------------------------------------------------------------
gen treatment3 = .
replace treatment3 = 0 if treatment1 == 0 // control if non-affiliate
replace treatment3 = 1 if treatment2 == 0 // treated if affiliate not in TH
label var treatment3 "Treatment 3"
label values treatment3 treatment

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
	(mean) dj1850affiliate treatment*, by(id year)
// Paste the saved labels
foreach v of var * {
	label var `v' "`l`v''"
}
// Apply treatment value labels
label values treatment* treatment
// Save
label data "dj1850 collapsed at the firm year level"
compress
save output/dj1850_collapsed, replace
