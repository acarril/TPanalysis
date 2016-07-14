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
	f50c91 /// Total taxes paid
	f22c20 /// Income tax
	/*
	dividends royalties interests services /// from f50
	f22c628 /// Sales
	f22c630 /// Costs of goods sold
	f22c631 /// Wages
	f22c636 /// Earnings
	f29c20 /// Exports
	f29imports /// Imports
	*/

// Number of treatments
unab treatments : treatment*
local N_treatments : list sizeof treatments

// Extract periods
levelsof year, local(years)

// Post variable
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
foreach treatvar of varlist treatment* {
	eststo: estpost tab `treatvar' if year == `baseyear', nototal
}
esttab using tabs/Nfirms_bytreatment_`baseyear'.tex, replace booktabs ///
	cell(b(fmt(%9.0fc)) pct(fmt(1) par)) nonumber label collabels(none) ///
	stats(N, label("Total")) alignment(r)

* Tab: Summary stats of all comparisons in baseyear
*-------------------------------------------------------------------------------
foreach treatvar of varlist treatment* {
	eststo clear
	eststo: qui estpost ttest `depvars_w' if year == `baseyear', ///
		by(`treatvar') unequal welch

	// Define matrices with various stats: median, standard deviation, N of firms
	qui tabstat `depvars_w' if year == `baseyear', by(`treatvar') stats(p50 sd n) save
	matrix C = r(Stat1)
	matrix T = r(Stat2)
	quietly {
		// Vectors of medians and standard deviations
		estadd matrix p50_1 = C[1...,1...]
		estadd matrix p50_2 = T[1...,1...]
		estadd matrix sd_1 = C[2...,1...]
		estadd matrix sd_2 = T[2...,1...]
		// Scalars with number of firms
		estadd scalar n_1 = C[3,1]
		estadd scalar n_2 = T[3,1]
	}
	// Tabulate statistics
	esttab using tabs/balancetab_`treatvar'_`baseyear'.tex, replace booktabs ///
		prehead( ///
			"{" ///
			"\begin{tabular}{l*{@span}{r}}" ///
			"\toprule" ///
			" & \multicolumn{3}{c}{Control} & \multicolumn{3}{c}{Treated} & \multicolumn{3}{c}{Difference} \\" ///
			" \cmidrule(lr){2-4} \cmidrule(lr){5-7} \cmidrule(lr){8-10} ") ///
		cell((mu_1(fmt(%12.1gc)) sd_1 p50_1 mu_2 sd_2 p50_2 b se t(fmt(2)))) ///
		collabels(Mean SD Median Mean SD Median Mean SE "\$t\$-stat") ///
		nonumbers nomtitles label ///
		stats(n_1 null null n_2, fmt(%9.0gc %9.0gc) layout("@ @ @ @") labels("Nº Firms"))
}

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

	forvalues t = 1/`N_treatments' {
		// Loop over all dependant variables
		foreach yvar in `depvars' {
			// Mean:
			qui xtreg `yvar'_w i.year#i.treatment`t' i.year i.treatment`t', ///
				fe vce(cluster id)
			ddplot treatment`t', `ddplot_opts'
			graph export "figs/ddplot_treat`t'_`yvar'_mean.pdf", as(pdf) replace
			
			// Pr(y>0):
			tempvar `yvar'_bin
			gen ``yvar'_bin' = (`yvar' > 0 & !missing(`yvar'))
			_crcslbl ``yvar'_bin' `yvar'
			qui xtreg ``yvar'_bin' i.year#i.treatment`t' i.year i.treatment`t', ///
				fe vce(cluster id)
			ddplot treatment`t', `ddplot_opts'
			graph export "figs/ddplot_treat`t'_`yvar'_prob.pdf", as(pdf) replace
			
			// Median (q50):
			qui qreg `yvar'_w i.year#i.treatment`t' i.year i.treatment`t', vce(robust)
			ddplot treatment`t', `ddplot_opts'
			graph export "figs/ddplot_treat`t'_`yvar'_q50.pdf", as(pdf) replace
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


/*
********************************************************************************
// D-D pre/post. FE: firms
xtreg `depvars' treatment2 ib2009.year treatmentXpost, fe vce(cluster id)
// D-D annual. FE: firms
xtreg `depvars' i.treatment2##i.year, fe vce(cluster id)


// D-D pre/post. FE: firms, year
xtreg `depvars' i.treatment2##i.post i.year, fe vce(cluster id)

// Difference in Differences. FE: firms
*xtreg `depvars' i.treatment2##ib2009.year, fe vce(cluster id)
*/
