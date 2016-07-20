*===============================================================================
* Name: 		02analysis.do
* Description:	
* Notes: 		
* Author:		Alvaro Carril (acarril@povertyactionlab.org)
* Created: 		20160229
* Version:		1.2
* Last edited:	20160706
*===============================================================================

*===============================================================================
* Initial set up
*===============================================================================
version 14
clear all
set scheme lean1
cd D:\tpricing\analysis\

local ddplots 	= 1
local ddtables 	= 0

* Set key years for analysis 
*-------------------------------------------------------------------------------
local baseyear 2009
local placeboyear 2010
local treatyear 2011

* Run auxiliary program ddplot for plotting difference-in-differences 
*-------------------------------------------------------------------------------
run do/auxil/ddplot.do

*-------------------------------------------------------------------------------
* Load firm-level panel data
*-------------------------------------------------------------------------------
use output/TPdata_firm.dta, clear
xtset id year

* Force balanced panel
*-------------------------------------------------------------------------------
/*
tempvar nyear
bys id: gen `nyear' = [_N]
quietly tab year
drop if `nyear' != r(r)
*/

* Periods, treatment and covariates locals
*-------------------------------------------------------------------------------
// Outcome variables
local depvars ///
	f22c20 /// Income tax
	dividends royalties interests services /// from f50
	f22c628 /// Sales
	f22c630 /// Costs of goods sold
	f22c631 /// Wages
	f22c636 /// Earnings
	f29c20 /// Exports
	f29imports /// Imports

// Number of treatments
unab comps : comp*
local N_comps : list sizeof comps

// Extract periods
levelsof year, local(years)

// Generate post variable
gen post = (year > 2010)
label define post 0 "Pre" 1 "Post"
label values post post

// Winsorize outcome variables at the 1% level
foreach v of varlist `depvars' {
	qui gen `v'_w = `v'
	_crcslbl `v'_w `v' // copy variable label
	foreach y in `years' {
		qui summ `v' if year == `y', detail
		qui replace `v'_w = r(p99) if year == `y' & `v' > r(p99) & `v' != .
	}
	local depvars_w `depvars_w' `v'_w
}

*-------------------------------------------------------------------------------
* Tables
*-------------------------------------------------------------------------------

* Tab: Observations by treatment group in baseyear
*-------------------------------------------------------------------------------
eststo clear
foreach treatvar of varlist comp* {
	eststo: estpost tab `treatvar' if year == `baseyear', nototal
}
esttab using tabs/Nfirms_bytreatment_`baseyear'.tex, booktabs replace ///
	cell(b(fmt(%9.0fc)) pct(fmt(1) par)) nomtitle collabels(none) ///
	stats(N, label("Total")) alignment(r)

* Tab: Summary stats of by affiliation group at baseline (needs distinct package)
*-------------------------------------------------------------------------------

local non_affiliates year == `baseyear' & dj1850affiliate != 1
local all_affiliates year == `baseyear' & dj1850affiliate == 1
local NTH_affiliates year == `baseyear' & dj1850affiliate_TH == 0
local TH_affiliates year == `baseyear' & dj1850affiliate_TH == 1

eststo clear
foreach group in non all NTH TH {
	// Post main summary statistics:
	eststo: estpost tabstat `depvars' if ``group'_affiliates', ///
		stats(mean sd median) columns(statistics)
	// Add scalar with number of firms:
	distinct id if ``group'_affiliates'
	estadd r(ndistinct)
	// Add winsorized mean and SD:
	foreach stat in mean sd {
		qui tabstat `depvars_w' if ``group'_affiliates', stats(`stat') save
		matrix A = r(StatTotal)
		matrix colnames A = `depvars'
		estadd matrix `stat'_w = A
	}
}

// Tabulate stats
esttab using tabs/summary_stats_byaffiliation.tex, replace booktabs ///
	cell("mean(fmt(%9.0fc)) mean_w p50" "sd(par) sd_w(par)") unstack label alignment(rrr) ///
	mlabels("Non affiliates" "Affiliates" "Affiliates of non tax havens" "Affiliates of tax havens", ///
		span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) ///
	collabels(Mean "W. Mean" Median) nonumber ///
	scalar("ndistinct Firms") sfmt(%12.0gc) noobs

*===============================================================================
* Impact analysis
*===============================================================================

*-------------------------------------------------------------------------------
* Difference-in-Differences plots
*-------------------------------------------------------------------------------

if `ddplots' == 1 {
	// Global plot options
	local ddplot_opts timevar(year) baseperiod(`baseyear') ///
		plotopts(xline(3.5 4.5, lpattern(shortdash)))

	forvalues t = 1/`N_comps' {
		// Loop over all dependant variables
		foreach yvar in `depvars' {
			// Mean:
			qui xtreg `yvar'_w ib2009.year#i.comp`t' ib2009.year i.comp`t' ib2009.year#i.size ib2009.year#i.industry ib2009.year#i.region, ///
				re vce(cluster id)
			ddplot comp`t', `ddplot_opts'
			graph export "figs/ddplot_comp`t'_`yvar'_mean.pdf", as(pdf) replace

			// Pr(y>0):
			tempvar `yvar'_bin
			gen ``yvar'_bin' = (`yvar' > 0 & !missing(`yvar'))
			_crcslbl ``yvar'_bin' `yvar'
			qui xtreg ``yvar'_bin' i.year#i.comp`t' i.year i.comp`t', ///
				fe vce(cluster id)
			ddplot comp`t', `ddplot_opts'
			graph export "figs/ddplot_comp`t'_`yvar'_prob.pdf", as(pdf) replace
			
			// Median (q50):
			qui qreg `yvar'_w i.year#i.comp`t' i.year i.comp`t', vce(robust)
			ddplot comp`t', `ddplot_opts'
			graph export "figs/ddplot_comp`t'_`yvar'_q50.pdf", as(pdf) replace
		}
	}
}
*-------------------------------------------------------------------------------
* Difference-in-Differences estimations
*-------------------------------------------------------------------------------

if `ddtables' == 1 {
	forvalues t = 1/`N_treatments' {
		foreach yvar in `depvars' {
			eststo clear
			// Mean:
			eststo: xtreg `yvar'_w i.treatment2#i.post i.post i.treatment2, ///
				fe vce(cluster id)
			
			// Ln(Y):
			gen `yvar'_ln = ln(`yvar'_w)
			eststo: xtreg `yvar'_ln i.treatment2#i.post i.post i.treatment2, ///
				fe vce(cluster id)
			
			// Poisson:
			capture {
				eststo: poisson `yvar'_w i.treatment2#i.post i.post i.treatment2, ///
					vce(robust)
			}
			
			// Pr(y>0):
			tempvar `yvar'_bin
			gen ``yvar'_bin' = (`yvar'_w > 0 & !missing(`yvar'))
			eststo: xtprobit ``yvar'_bin' i.treatment2#i.post i.post i.treatment2, ///
				pa vce(robust)
			
			// Median (q50):
			eststo: qreg `yvar'_w i.treatment2#i.post i.post i.treatment2, vce(robust)
			
			esttab using tabs/ddimpact_`yvar'.tex, booktabs replace ///
				mtitles(Mean "\$Ln(Y)\$" Poisson "\$Pr(Y>0)\$" Median) ///
				order(1.treatment*#1.post) drop(*0.*) ///
				varlabels(1.treatment2#1.post "Treated $\times$ Post" 1.post "Post" 1.treatment2 "Treated" _cons "Constant") ///
				se star(* 0.10 ** 0.05 *** 0.01) ///
				stats(N r2)
		}
	}
}

*-------------------------------------------------------------------------------
* Propensity Score Matching estimations
*-------------------------------------------------------------------------------
psestimate comp4 if year==2009, notry(id year comp*) genlor(lnodds4)

gen u = runiform()
sort u
drop u

summ lnodds if year == 2009
local caliper_pct = .2
local caliper = `caliper_pct'*`r(sd)'

psmatch comp4 if year == 2009, pscore(lnodds4) noreplacement descending caliper(`caliper')

egen w4_psm = max(_weight), by(id)
