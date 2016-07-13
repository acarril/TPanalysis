local path /nfs/projects/t/tpricing/tpricing2/analysis
local exp_path /nfs/projects/t/tpricing/tpricing2/analysis/docs/th_vs_nth/tabs_graphs
cd `path'

use output/TPdata_firm, clear


local baseyear 2009
* Post var
gen post = (year > 2010)
* Auxiliary variable for tabulations
gen aux = 1
* Dependant variables
local yvars f22c20 f50c91/* f22c633 dividends royalties interests services f29c20 f29imports */
* Winsorizing at the 1% level
levelsof year, local(years)
foreach v of varlist `yvars' {
	foreach year of local years {
		quietly sum `v' if year == `year', detail
		replace `v' = `r(p99)' if year == `year' & `v' > `r(p99)' & !missing(`v')
	}
}

local graphs = 0
local tables = 1

* Graphs of parallel trends
if `graphs' == 1 {
foreach v of varlist `yvars' {
	// Mean
	areg `v' i.year#i.treatment2 i.year#i.industry_sector, vce(cluster id) absorb(id)
	ghm treatment2 `baseyear' `v'
	graph export `exp_path'/trends_`v'_mean.pdf, as(pdf) replace
	
	// Pr(y>0)
	tempvar `v'_bin
	bys year: gen ``v'_bin' = (`v' > 0 & `v' != .)
	areg ``v'_bin' i.year#i.treatment2 i.year#i.industry_sector, vce(cluster id) absorb(id)
	ghm treatment2 `baseyear' `v'
	graph export `exp_path'/trends_`v'_bin.pdf, as(pdf) replace
	
	// Median
	capture noisily qreg `v' i.year#i.treatment2 i.year#i.industry_sector, vce(robust) q(0.5) wlsiter(25) iterate(2000)
	if _rc ==0 {
		ghm treatment2 `baseyear' `v'
		graph export `exp_path'/trends_`v'_median.pdf, as(pdf) replace
	}
}
}

* Impact tables
if `tables' == 1 {
foreach v of varlist `yvars' {
	eststo clear
	// Mean:
	eststo: reg `v' post#treatment2 i.year#i.industry_sector, vce(cluster id)
	// Pr(y>0)
	tempvar `v'_bin
	bys year: gen ``v'_bin' = (`v' > 0 & `v' != .)
	eststo: reg ``v'_bin' post#treatment2 i.year#i.industry_sector, vce(cluster id)
	// Median:
	capture noisily eststo: qreg `v' post#treatment2 i.year#i.industry_sector, vce(robust) q(0.5) wlsiter(25) iterate(2000)
	// Tabulate da shit
	esttab * using `exp_path'/impact_`v'.tex, replace booktabs ///
		indicate("Year $\times$ Sector FE = *.industry_sector") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		mtitles(Mean "\$Pr(Y>0)\$" Median) ///
		order(1.post#1.treatment2) drop(0.post#0.treatment2) ///
		varlabels(1.post#1.treatment2 "Treated $\times$ Post" 1.post#0.treatment2 "Post" 0.post#1.treatment2 "Treated" _cons "Constant") ///
		stats(N r2)
}
}
********
/*
local balance_covars size ///
	f22c628 f22c630 f29c20 f29c535 f22c631 f22c636 f22c633 f22c20 f22c122 ///
	dividends royalties interests services
orth_out `balance_covars' if year == 2010, by(treatment2) compare test count proportion se ///
	armlabel(Control Treatment)
