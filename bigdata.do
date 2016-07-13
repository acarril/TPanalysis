*-------------------------------------------------------------------------------
* Initial set up
*-------------------------------------------------------------------------------
version 14
set more off
clear all
cd D:\tpricing\analysis\

run do/auxil/ppp.ado

use output/dj1850, clear
foreach dta in firm_chars f22 f29 f50 {
	merge m:1 year id using output/`dta', generate(_merge_`dta')
}

// Replace missing values for zeroes. If filed F22 under full tax reporting,
// all missings are zeros. Validated by SII analyst.
	foreach x in f22c18 f22c19 f22c20 f22c91 f22c87 f22c122 f22c129 ///
		f22c305 f22c366 f22c628 f22c629 f22c643 f22c651 f22c633 ///
		f22c647 f22c648 f22c632 f22c631 f22c630 f22c636 f22c851 ///
		f22c839 f22c785 f22c792 f22c793 f22c772 f22c873 f22c852 ///
		f22897 f22c853 f22c635 f22c825 f22c189 f22c196 f22c79 ///
		f22c114 f22909 f22c755 f22c134 f22c34 f22914 f22925 f22c756 ///
		f22c863 f22c71 f22c849 f22c36 f22c769 f22c612 f22c611 ///
		f22c834 f22c747 f22c757 f22c871 f22c882 f22c181 f22900 ///
		f22c841 f22c123 f50c91 {
		quietly: replace `x' = 0 if `x' == .
	}
	
* Transform all monetary variables to current USD
*-------------------------------------------------------------------------------
local monetary_vars dj1850baseimponible-dj1850montoliquido ///
	dividends-others ///
	f22* f29* f50*
unab monetary_vars : `monetary_vars'
local num : word count `monetary_vars'
local rep 1
nois _dots 0, title(Converting variables from CLP to USD) reps(`num')
foreach var of varlist `monetary_vars' {
	qui ppp `var', exp(6) replace
	nois _dots `rep++' 0
}

* Collapse
*-------------------------------------------------------------------------------

foreach v of var * {
		local l`v' : variable label `v'
		if `"`l`v''"' == "" {
			local l`v' "`v'"
		}
	}

	// Collapse dataset
	collapse (max) region - industry_sector ///
		 (sum) dj1850baseimponible f22* f29* f50* ///
		 dividends - others ///
		 , by(id year)

	// Paste the saved labels
	foreach v of var * {
		label var `v' "`l`v''"
	}
