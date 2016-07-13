*===============================================================================
* START
*===============================================================================
* Name: 20160126 make tables and graphs
* Description: this do file produces the tables and graphs of Bustos, Pomeranz, 
*              Zucman 2015
* Version: v9.0 
* Created: 20150227
* Updated: 20160119
* Author: JI Elorrieta (ji.elorrieta@gmail.com)
* Last editor: Alvaro Carril (acarril@povertyactionlab.org)
*-------------------------------------------------------------------------------
* Notes
* -----
* This file seems messy, but there is a reason. This is the only way I know to 
* produce custom made automatic tables, without requiring any manual 
* adjustments in the process. Maybe there is a better way.
* No manual changes should be made to the tables after exporting them.
*
* Convergence of qreg is elusive, given the numbers of controls we are adding
* we manage to achieve it by fine tunning the number of WLS iterations for 
* troublesome models.
*-------------------------------------------------------------------------------
* WARNINGS
*-------------------------------------------------------------------------------
// check Abadie papers for additional useful tables & robustness checks
*===============================================================================
* I. Preamble
*===============================================================================
*-------------------------------------------------------------------------------
* I.1. Set-up
*-------------------------------------------------------------------------------
	
	clear all
	local path /nfs/projects/t/tpricing/output
	local graph_ext eps
	
*-------------------------------------------------------------------------------
* I.2. Key decisions
*-------------------------------------------------------------------------------

	local tvar treatment4 	// Initialises treatment variable 
	local baseyear = 2009 	// Initialises base year
	local preyear = 2010 	// Initialises pre-treatment year

* (I.2.a) Defines controls to be used in regressions ---------------------------
	
	// controls to be used in the pre-post firm's FE regression
	local ctrl_areg i.year#i.oneDigitSector 
	
	// controls to be used in the pre-post quantile regression
	local ctrl_qreg i.oneDigitSector i.region i.year imp_share`preyear'
	
	// controls to be used in the event study firm's FE and quantile 
	// regression
	local ctrl_ghm i.year#i.oneDigitSector i.year#i.region i.year#c.imp_share`preyear'
	
*-------------------------------------------------------------------------------
* I.3. Select sections to run
*-------------------------------------------------------------------------------	
	
	local tables 		= 1
	local dj1850_trans_type = 0
	local graphs 		= 0
	local subgroup 		= 0
	
*-------------------------------------------------------------------------------
* I.4. Creates programs that make the code more efficient
*-------------------------------------------------------------------------------

	capture program drop epost_bv ghm

* (I.4.a). Defines a program to bring back e(b) and e(V) -----------------------
	
	program define epost_bv, eclass
		args b V
		ereturn post `b' `V'
	end	

* (I.4.b). Implements dif-in-dif multi-year á la GHM 2010 ----------------------
* We follow the event study in table 4 of "Identifying Agglomeration Spillovers: 
* Evidence from Winners and Losers of Large Plant Openings" Greenstone, 
* Hornbeck, and Moretti, Journal of Political Economy, 2010
* Programs takes e(b) and e(V) produced by any regression, and performs all the
* steps to go from year-group average to dif in dif.
	
	program define ghm
	
		args tvar baseyear y 

		matrix did = J(7,1,.) // initialises matrix to store diff in diff
		matrix rownames did = 2007 2008 2009 2010 2011 2012 2013
		
		matrix sto_b = e(b) // stores the regression coefficients
		matrix sto_V = e(V) // stores the regression coefficients	
		
		forvalues t = 2007/2013 {
		
			matrix define b1 = sto_b
			matrix define V1 = sto_V
				
			epost_bv b1 V1 // brings back the areg coefficients after 
				// looping thorugh. nlcom updates b and V.
			
			// We estimate the first difference, that is, the average of the
			// treated in the current year minus the base year, and the
			// same for the treated. The ", post" option updates b and V
			// matrices, updating the ones estimated in areg. Necessary 
			// to estimate the second difference.
			quietly{
			nlcom (dc: _b[`t'.year#0.`tvar'] - _b[`baseyear'.year#0.`tvar']) /// 
			      (dt: _b[`t'.year#1.`tvar'] - _b[`baseyear'.year#1.`tvar']), ///
				post
			}
			// We estimate the second difference between the treated and 
			// the controls. The ", post" option updates b and V matrices
			// in order to store in the plot matrix
			quietly: nlcom (did: _b[dt] - _b[dc]), post
			
			matrix define b = e(b)
			
			// We store the diff in diff and its confidence interval
			matrix did[`t'-2006,1] = b[1,1]
		}
		
		// Plots the differences in difference. 
		coefplot matrix(did[,1]), vertical noci ytitle("`y'") /// 
			msymbol(O) yline(0, lstyle(foreground)) ///
			xtitle("Year") xline(3.5 4.5, lpattern(shortdash) ///
			lcolor(black)) addplot(line @b @at, lpattern(solid)) ///
			aspectratio(0.62)
	
	end

* (I.4.c). Produces balance tables for treatment groups ------------------------

	program define balance_table
	
		args tvar preyear w_psm
	
		count if `tvar' == 0 & year == `preyear' & `w_psm' != .
		local n_c = trim("`: display %10.0fc r(N)'")
		count if `tvar' == 1 & year == `preyear' & `w_psm' != .
		local n_t = trim("`: display %10.0fc r(N)'") 

		local r = 1 // initialises row counter

		foreach x in f22c628 f22c630 totalExportsF29 totalImportsF29 ///
			f22c631 f22c636 net_interest_expense f22c20 f22c122 ///
			royaltiesF50 interestF50 servicesF50 {
			
			local c1_r`r' : variable label `x' // first table's column
		
			sum `x' if `tvar' == 0 & year == `preyear' & ///
				`w_psm' != . [aweight = `w_psm'], detail
			local c2_r`r' = trim("`: display %14.1fc r(mean)'")
			local c3_r`r' = trim("`: display %14.1fc r(sd)'")
			local c4_r`r' = trim("`: display %14.1fc r(p50)'")

			sum `x' if `tvar' == 1 & year == `preyear' & ///
				`w_psm' != . [aweight = `w_psm'], detail
			local c5_r`r' = trim("`: display %14.1fc r(mean)'")
			local c6_r`r' = trim("`: display %14.1fc r(sd)'")
			local c7_r`r' = trim("`: display %14.1fc r(p50)'")
		
			reg `x' `tvar' if year == `preyear' [aweight = `w_psm'] 
			test `tvar' = 0
			local c8_r`r' = trim("`: display %14.3fc r(p)'")
		
			local r = `r' + 1
		}
	
		// this step is only to get the format right
		foreach x in exp_share imp_share bin_f22c20 ///
			bin_net_interest_expense bin_rm bin_royaltiesF50 ///
			bin_interestF50 bin_servicesF50 {
		
			local c1_r`r' : variable label `x' // first table's column
		
			sum `x' if `tvar' == 0 & year == `preyear' & ///
				`w_psm' != . [aweight = `w_psm'], detail
			local c2_r`r' = trim("`: display %14.2fc r(mean)'")
			local c3_r`r' = trim("`: display %14.2fc r(sd)'")
			local c4_r`r' = trim("`: display %14.2fc r(p50)'")

			sum `x' if `tvar' == 1 & year == `preyear' & ///
				`w_psm' != . [aweight = `w_psm'], detail
			local c5_r`r' = trim("`: display %14.2fc r(mean)'")
			local c6_r`r' = trim("`: display %14.2fc r(sd)'")
			local c7_r`r' = trim("`: display %14.2fc r(p50)'")
		
			reg `x' `tvar' if year == `preyear' [aweight = `w_psm'] 
			test `tvar' = 0
			local c8_r`r' = trim("`: display %14.3fc r(p)'")
		
			local r = `r' + 1
		}
	
		file open table using sum_stats_`w_psm'_`preyear'_matched_sample.txt, write text replace
	
		// writes table's header
		file write table "\begin{tabular}{l c c c c c c c}" _n ///
			"\toprule" ///
			" & \multicolumn{3}{c}{Control (n = `n_c')} &" ///
			" \multicolumn{3}{c}{Treated (n = `n_t')} \\" _n ///
			" Variable & Mean & (Std. Dev.) & Median & Mean & (Std. Dev.) &" ///
			" Median & p-value \\" _n "\midrule" _n
	
		// writes table's content //Loopable?
	
		file write table ///
			"`c1_r1' & `c2_r1' & (`c3_r1') & `c4_r1' & `c5_r1' & (`c6_r1') & `c7_r1' & `c8_r1' \\" _n ///
			"`c1_r2' & `c2_r2' & (`c3_r2') & `c4_r2' & `c5_r2' & (`c6_r2') & `c7_r2' & `c8_r2' \\" _n ///
			"`c1_r3' & `c2_r3' & (`c3_r3') & `c4_r3' & `c5_r3' & (`c6_r3') & `c7_r3' & `c8_r3' \\" _n ///
			"`c1_r4' & `c2_r4' & (`c3_r4') & `c4_r4' & `c5_r4' & (`c6_r4') & `c7_r4' & `c8_r4' \\" _n ///
			"`c1_r5' & `c2_r5' & (`c3_r5') & `c4_r5' & `c5_r5' & (`c6_r5') & `c7_r5' & `c8_r5' \\" _n ///
			"`c1_r6' & `c2_r6' & (`c3_r6') & `c4_r6' & `c5_r6' & (`c6_r6') & `c7_r6' & `c8_r6' \\" _n ///
			"`c1_r7' & `c2_r7' & (`c3_r7') & `c4_r7' & `c5_r7' & (`c6_r7') & `c7_r7' & `c8_r7' \\" _n ///
			"`c1_r8' & `c2_r8' & (`c3_r8') & `c4_r8' & `c5_r8' & (`c6_r8') & `c7_r8' & `c8_r8' \\" _n ///
			"`c1_r9' & `c2_r9' & (`c3_r9') & `c4_r9' & `c5_r9' & (`c6_r9') & `c7_r9' & `c8_r9' \\" _n ///
			"`c1_r10' & `c2_r10' & (`c3_r10') & `c4_r10' & `c5_r10' & (`c6_r10') & `c7_r10' & `c8_r10' \\" _n ///
			"`c1_r11' & `c2_r11' & (`c3_r11') & `c4_r11' & `c5_r11' & (`c6_r11') & `c7_r11' & `c8_r11' \\" _n ///
			"`c1_r12' & `c2_r12' & (`c3_r12') & `c4_r12' & `c5_r12' & (`c6_r12') & `c7_r12' & `c8_r12' \\" _n ///
			"`c1_r13' & `c2_r13' & (`c3_r13') & `c4_r13' & `c5_r13' & (`c6_r13') & `c7_r13' & `c8_r13' \\" _n ///
			"`c1_r14' & `c2_r14' & (`c3_r14') & `c4_r14' & `c5_r14' & (`c6_r14') & `c7_r14' & `c8_r14' \\" _n ///
			"`c1_r15' & `c2_r15' & (`c3_r15') & `c4_r15' & `c5_r15' & (`c6_r15') & `c7_r15' & `c8_r15' \\" _n ///
			"`c1_r16' & `c2_r16' & (`c3_r16') & `c4_r16' & `c5_r16' & (`c6_r16') & `c7_r16' & `c8_r16' \\" _n ///
			"`c1_r17' & `c2_r17' & (`c3_r17') & `c4_r17' & `c5_r17' & (`c6_r17') & `c7_r17' & `c8_r17' \\" _n ///
			"`c1_r18' & `c2_r18' & (`c3_r18') & `c4_r18' & `c5_r18' & (`c6_r18') & `c7_r18' & `c8_r18' \\" _n ///
			"`c1_r19' & `c2_r19' & (`c3_r19') & `c4_r19' & `c5_r19' & (`c6_r19') & `c7_r19' & `c8_r19' \\" _n ///
			"`c1_r20' & `c2_r20' & (`c3_r20') & `c4_r20' & `c5_r20' & (`c6_r20') & `c7_r20' & `c8_r20' \\" _n 
		
		// writes table's closing argument
		file write table "\bottomrule" _n ///
			"\end{tabular}"
	
		file close table
	
	end
	
* (I.4.d). Produces result tables and ATE's bar charts -------------------------
	
	program define ate_table_nocontrol
	
		args y tvar w_psm baseyear 
		
		matrix ate_bar = J(8,1,.) // initialises matrix to store ate 
					  // over control post level
		matrix rownames ate_bar = Mean p40 p50 p60 p70 p80 p90 p95
	
		eststo clear
		
		areg `y' c.post##c.`tvar' [aweight = `w_psm'], ///
			cluster(taxId) absorb(taxId)
		count if `w_psm' != . & year == 2009 // balanced panel
		estadd local N_firms "`: display %14.0fc r(N)'", replace
		estadd local fixed "Yes" , replace		
		sum `y' if post == 1 & `tvar' == 0 & `w_psm' != .
		estadd local raw_control "`: display %14.2fc r(mean)'", replace
		estadd local pr_tr "`: display %14.0fc 100 * _b[c.post#c.`tvar'] / r(mean)'\%", replace
		matrix ate_bar[1,1] = 100 * (_b[c.post#c.`tvar'] / `r(mean)')
		estadd local r2_trick "`: display %14.2fc e(r2_a)'", replace
		eststo, title("Mean") 
		
		areg bin_`y' c.post##c.`tvar' [aweight = `w_psm'], ///
			cluster(taxId) absorb(taxId)
		count if `w_psm' != . & year == 2009 // balanced panel
		estadd local N_firms "`: display %14.0fc r(N)'", replace
		estadd local fixed "Yes" , replace
		sum bin_`y' if post == 1 & `tvar' == 0 & `w_psm' != .
		estadd local raw_control "`: display %14.2fc r(mean)'", replace
		estadd local pr_tr "`: display %14.0fc 100 * _b[c.post#c.`tvar'] / r(mean)'\%", replace
		estadd local r2_trick "`: display %14.2fc e(r2_a)'", replace
		eststo, title("Pr($ Y>0$)")

		local j = 2

		foreach i in 0.4 0.5 0.6 0.7 0.8 0.9 0.95 {
			qreg `y' c.post##c.`tvar' [iweight = `w_psm'], ///
				vce(robust) q(`i')		
			estadd local r2_trick "`: display %14.2fc 1 - (`=e(sum_adev)'/`=e(sum_rdev)')'", replace
			count if `w_psm' != . & year == 2009 // balanced panel
			estadd local N_firms "`: display %14.0fc r(N)'", replace
			local rt = `i'*100
			_pctile `y' if post == 1 & `tvar' == 0 & ///
				`w_psm' != ., percentiles(`rt')
			estadd local raw_control "`: display %14.2fc r(r1)'", replace
			estadd local pr_tr "`: display %14.0fc 100 * _b[c.post#c.`tvar'] / r(r1)'\%", replace
			matrix ate_bar[`j',1] = 100* (_b[c.post#c.`tvar'] / `r(r1)')
			estadd local fixed "No" , replace
			eststo, title("Percentile `rt'")
			
			local j = `j' + 1
		}
		
		local num_ctrl = 0
		
		estout * using ate_`y'_`num_ctrl'.txt, ///
			cells(b(star fmt(2)) se(par fmt(2))) ///
			stats(fixed N N_firms r2_trick raw_control pr_tr, ///
			fmt(%10.0fc %10.0fc 2) ///
			labels("Firm's fixed effects" "\midrule Observations" ///
				"Numbers of firms" "Adjusted/Pseudo R$^2$" ///
				"\midrule Control Post Level" ///
				"Effect's percent of Control Post Level")) ///
			starlevels(* 0.10 ** 0.05 *** 0.01) noabbrev  ///
			mlabels(, titles) order("c.post#c.`tvar'") ///
			collabels(none) numbers style(tex) noomitted ///
			varlabels(_cons "Constant" post "Post" `tvar' "Treated" ///
				c.post#c.`tvar' "Treated $\times$ Post") ///
			prehead(\begin{tabular}{l*{@M}{r}} \toprule ) ///
			posthead(\midrule) replace ///
			postfoot(\bottomrule \multicolumn{@span}{l}{\footnotesize @note} \\ \end{tabular})
		
		// Plots ATE divided by control post level (raw) 
		coefplot matrix(ate_bar[,1]), vertical noci ytitle("`y'") ///
			yline(0) format(%5.0fc) mlabel mlabposition(12) ///
			msymbol(none) addplot(bar @b @at, barwidth(0.7) ///
			fcolor(none)) aspectratio(0.62) yscale(range(0))
			
		graph export "ate_bar_`y'_`num_ctrl'.eps", as(eps) replace 		
	
	end
	
*-------------------------------------------------------------------------------
* I.5. Some final and minor details
*-------------------------------------------------------------------------------

	use `path'/transferPricingDatabase.dta, clear
	cd `path'/results	
	set scheme lean1
	set more off	
	local num_ctrl_did = wordcount("`ctrl_did'")
	local num_ctrl_ghm = wordcount("`ctrl_ghm'")
	
	// move to database creation do file
	gen bin_totalExportsF29 = (totalExportsF29 > 0)
	gen bin_totalImportsF29 = (totalImportsF29 > 0)
	gen bin_f22c628 = (totalImportsF29 > 0)
	gen bin_f22c629 = (f22c629 > 0)
	gen bin_f22c651 = (f22c651 > 0)
	gen bin_f22c633 = (f22c633 > 0)
	gen bin_f22c631 = (f22c631 > 0)
	gen bin_f22c630 = (f22c630 > 0)
	gen bin_f22c636 = (f22c636 > 0)
	gen bin_f22c851 = (f22c851 > 0)
	gen w_psm_all = 1
	
*===============================================================================
* II. Tables
*===============================================================================
if (`tables' == 1) {
*-------------------------------------------------------------------------------
* II.1. Summary stats over treatment status, base year, full sample
*-------------------------------------------------------------------------------

	//balance_table treatment4 `baseyear' w_psm_all	
	
*-------------------------------------------------------------------------------
* II.2. Summary stats over treatment status, base year, matched sample 
*-------------------------------------------------------------------------------
	
	//balance_table treatment1 `baseyear' w_psm1
	//balance_table treatment2 `baseyear' w_psm2
	//balance_table treatment4 `baseyear' w_psm4
	//balance_table treatment4 `preyear' w_psm4
	balance_table treatment4 `baseyear' w_psm4
	balance_table treatment4 `preyear' w_psm4
}

*-------------------------------------------------------------------------------
* II.3. Summary stats over treatment status, pre-treatment year, matched sample 
*-------------------------------------------------------------------------------
/*
	balance_table treatment1 `preyear' w_psm1
	balance_table treatment2 `preyear' w_psm2
	balance_table treatment4 `preyear' w_psm4
*/
*-------------------------------------------------------------------------------
* II.4. Key results 
*-------------------------------------------------------------------------------
* (II.4.a). ATE summary table, no controls -------------------------------------

/*
	
	args y tvar w_psm baseyear controls
	ate_table_nocontrol f22c20 treatment4 w_psm4
	ate_table_nocontrol f22c633 treatment4 w_psm4 
	ate_table_nocontrol servicesF50 treatment4 w_psm4 
	ate_table_nocontrol interestF50 treatment4 w_psm4
	ate_table_nocontrol royaltiesF50 treatment4 w_psm4
*/	
* (II.4.b). ATE summary table, with controls -----------------------------------
	
	foreach y in f22c20 f22c633 {


		matrix ate_bar = J(8,1,.) // initialises matrix to store ate 
					  // over control post level
		matrix rownames ate_bar = Mean p40 p50 p60 p70 p80 p90 p95
	
		eststo clear
		
		areg `y' c.post##c.`tvar' `ctrl_areg' [aweight = w_psm4], ///
			cluster(taxId) absorb(taxId)		
		count if w_psm4 != . & year == `baseyear' // balanced panel
		estadd local N_firms "`: display %14.0fc r(N)'", replace
		estadd local fixed "Yes" , replace		
		sum `y' if post == 1 & `tvar' == 0 & w_psm4 != .
		estadd local raw_control "`: display %14.2fc r(mean)'", replace
		estadd local pr_tr "`: display %14.0fc 100 * _b[c.post#c.`tvar'] / r(mean)'\%", replace
		matrix ate_bar[1,1] = 100* (_b[c.post#c.`tvar'] / `r(mean)')
		estadd local r2_trick "`: display %14.2fc e(r2_a)'", replace
		eststo, title("Mean") 

		areg bin_`y' c.post##c.`tvar' `ctrl_areg' [aweight = w_psm4], ///
			cluster(taxId) absorb(taxId)
		count if w_psm4 != . & year == `baseyear' // balanced panel
		estadd local N_firms "`: display %14.0fc r(N)'", replace
		estadd local fixed "Yes" , replace
		sum bin_`y' if post == 1 & `tvar' == 0 & w_psm4 != .
		estadd local raw_control "`: display %14.2fc r(mean)'", replace
		estadd local pr_tr "`: display %14.0fc 100 * _b[c.post#c.`tvar'] / r(mean)'\%", replace
		estadd local r2_trick "`: display %14.2fc e(r2_a)'", replace
		eststo, title("Pr($ Y>0$)")
		
		local j = 2

		foreach i in 0.4 0.5 0.6 0.7 0.8 0.9 0.95 {
			qreg `y' c.post##c.`tvar' `ctrl_qreg' [iweight = w_psm4], ///
				vce(robust) q(`i') wlsiter(50) iterate(2500)		
			estadd local r2_trick "`: display %14.2fc 1 - (`=e(sum_adev)'/`=e(sum_rdev)')'", replace
			count if w_psm4 != . & year == `baseyear' // balanced panel
			estadd local N_firms "`: display %14.0fc r(N)'", replace
			local rt = `i'*100
			_pctile `y' if post == 1 & `tvar' == 0 & ///
				w_psm4 != ., percentiles(`rt')
			estadd local raw_control "`: display %14.2fc r(r1)'", replace
			estadd local pr_tr "`: display %14.0fc 100 * _b[c.post#c.`tvar'] / r(r1)'\%", replace
			matrix ate_bar[`j',1] = 100* (_b[c.post#c.`tvar'] / `r(r1)')
			estadd local fixed "No" , replace
			eststo, title("Percentile `rt'")
			
			local j = `j' + 1
		}
		ate_table_nocontrol f22c20 treatment4 w_psm4
		estout * using ate_`y'_withcontrol.txt, ///
			cells(b(star fmt(2)) se(par fmt(2))) ///
			stats(fixed N N_firms r2_trick raw_control pr_tr, ///
			fmt(%10.0fc %10.0fc 2) ///
			labels("Firm's fixed effects" "\midrule Observations" ///
				"Numbers of firms" "Adjusted/Pseudo R$^2$" ///
				"\midrule Control Post Level" ///
				"Effect's percent of Control Post Level")) ///
			starlevels(* 0.10 ** 0.05 *** 0.01) noabbrev  ///
			mlabels(, titles) order("c.post#c.`tvar'") ///
			collabels(none) numbers style(tex) noomitted ///
			varlabels(_cons "Constant" post "Post" `tvar' "Treated" ///
				c.post#c.`tvar' "Treated $\times$ Post" ///
				imp_share`preyear' ///
				"Imported Share of Direct Costs at `preyear'") ///
			prehead(\begin{tabular}{l*{@M}{r}} \toprule ) ///
			posthead(\midrule) replace ///
			postfoot(\bottomrule \multicolumn{@span}{l}{\footnotesize @note} \\ \end{tabular}) ///
			indicate("Year fixed-effects = *.year" ///
				"Region fixed-effects = *.region" ///
				"Sector fixed-effects= *.oneDigitSector") 

		// Plots ATE divided by control post level (raw) 
		coefplot matrix(ate_bar[,1]), vertical noci ytitle("`y'") ///
			yline(0) format(%5.0fc) mlabel mlabposition(12) ///
			msymbol(none) addplot(bar @b @at, barwidth(0.7) ///
			fcolor(none)) yscale(range(0)) aspectratio(0.62) 
			
		graph export "ate_bar_`y'_withcontrols.`graph_ext'", ///
			as(`graph_ext') replace 

	}


*-------------------------------------------------------------------------------
* II.5. F1850 Tables 
*-------------------------------------------------------------------------------
if (`dj1850_trans_type' == 1) {
local path /nfs/projects/t/tpricing
use `path'/output/temp_indDj1850.dta, clear
cd `path'/output/results

run `path'/do/aux/ppp.ado

ppp f1850montoliquidovo, exp(3)
ppp f1850montoliquidovo, exp(6)

// Replace value just for sorting purposes
replace f1850tiporentavo = 99 if f1850tiporentavo == 0

* (II.5.a). Number of transaction by type & year -------------------------------

eststo clear
estpost tabulate f1850tiporentavo year if (year >= 2008) & ///
	((f1850tiporentavo > 0 & f1850tiporentavo <= 21) | ///
	(f1850tiporentavo == 99))

esttab using f1850_numtrans_type_year.tex, ///
	cells(b(fmt(%8.0fc)) colpct(fmt(1) par(( )))) ///
	collabels(none) unstack noobs nonumber nomtitle booktabs ///
	varlabels(99 "No type", blist(Total "\midrule ")) replace ///
	drop("Total:")

* (II.5.b). Transactions in MUSD by type & year --------------------------------

tempvar tiporenta
gen `tiporenta' = f1850tiporentavo
replace `tiporenta' = 99 if `tiporenta'==0

eststo clear
// Years 2008-2012 (2007 is left out because of inconsistent transaction types).
foreach year of numlist 2008/2013 {
eststo: quietly estpost tabstat f1850montoliquidovo_exp6 if year == `year', ///
	by(`tiporenta') stat(sum)
	matrix colupct = e(sum)
	scalar c = colsof(colupct)
	matrix colupct = 100*colupct/colupct[1,c]
	estadd matrix colupct = colupct
}

esttab * using f1850_transfersMUSD_type_year.tex, replace booktabs ///
	alignment (rrrrrr) cell(sum(fmt(%9.1fc)) colupct(fmt(1) par)) noobs ///
	collabels(none) nonumber mtitles(2008 2009 2010 2011 2012 2013) ///
	varlabels(6 "Real estate" ///
        7 "Corporate benefits" ///
        8 "International Transport" ///
        10 "Dividends" /// The gap is intentional! Blame SII.
        11 "Interests" ///
        12 "Royalties" ///
        13 "Capital gains" ///
        14 "Profits of Independent Labor" ///
        15 "Profits of Dependant Labor" ///
        16 "Directors" ///
        17 "Artistic and Sports activities" ///
        18 "Pensions" ///
        19 "Public Services" ///
        20 "Scholarships" ///
        21 "Others" ///
	99 "No type", blist(Total "\midrule "))

* (II.5.c). Top 15 "No type" countries by number of transactions, yearly -------

// Compute sums of no-type transactions of topN countries
local topN = 15
tempvar countrysum group flag aux
gen `aux'=1
egen `countrysum' = sum(-`aux') if f1850tiporentavo == 99 ///
	& year>=2008, by(iso3166)
egen `group' = axis(`countrysum' iso3166) if f1850tiporentavo == 99 ///
	& year>=2008, label(iso3166)
gen `flag' = (`group'<=`topN')

// Group non-topN countries as "Others" in 999
replace `group' = 999 if f1850tiporentavo == 99 & year>=2008 & `flag'==0
replace `flag' = 1 if f1850tiporentavo == 99 & year>=2008 & `flag'==0

eststo clear
foreach year of numlist 2008/2013 {
eststo: quietly estpost tabstat `aux' if f1850tiporentavo == 99 ///
	& year == `year' & `flag'==1, statistics(sum) by(`group')

	matrix colupct = e(sum)
	scalar c = colsof(colupct)
	matrix colupct = 100*colupct/colupct[1,c]
	estadd matrix colupct = colupct
}

esttab * using f1850_toptrans_notype_country_numtrans.tex, replace booktabs ///
	cells(sum(fmt(%9.0fc)) colupct(fmt(1) par)) noobs nonumber collabels(none) ///
	varlabels(`e(labels)' 999 "Others countries", blist(Total "\midrule ")) ///
	mtitles(2008 2009 2010 2011 2012 2013) ///
	alignment (rr)

* (II.5.d). Top 15 "No type" countries by transactions in MUSD, yearly ---------

// Compute sums of no-type transactions of topN countries
local topN = 14  // not 15, to add later the UK Virgin Islands
tempvar countrysum group flag
egen `countrysum' = sum(-f1850montoliquidovo_exp6) if f1850tiporentavo == 99 ///
	& year>=2008, by(iso3166)
egen `group' = axis(`countrysum' iso3166) if f1850tiporentavo == 99 ///
	& year>=2008, label(iso3166)
gen `flag' = (`group'<=`topN')

// Flag the British Virgin Islands
replace `flag'=1 if iso3166==92

// Group non-topN countries as "Others" in 999
replace `group' = 999 if f1850tiporentavo == 99 & year>=2008 & `flag'==0
replace `flag' = 1 if f1850tiporentavo == 99 & year>=2008 & `flag'==0

eststo clear
foreach year of numlist 2008/2013 {
eststo: quietly estpost tabstat f1850montoliquidovo_exp6 if f1850tiporentavo == 99 ///
	& year == `year' & `flag'==1, statistics(sum) by(`group')

	matrix colupct = e(sum)
	scalar c = colsof(colupct)
	matrix colupct = 100*colupct/colupct[1,c]
	estadd matrix colupct = colupct
}

esttab * using f1850_toptrans_notype_country_MUSD.tex, replace booktabs ///
	cells(sum(fmt(%9.1fc)) colupct(fmt(1) par)) noobs nonumber collabels(none) ///
	varlabels(`e(labels)' 999 "Others countries", blist(Total "\midrule ")) ///
	mtitles(2008 2009 2010 2011 2012 2013) ///
	alignment (rr)
}
*-------------------------------------------------------------------------------
* II.6. F50 and DJ1850 Overlap
*-------------------------------------------------------------------------------
/*
local path /nfs/projects/t/tpricing
use `path'/output/temp_indF50.dta, clear
cd `path'/output/

// Do multiple merges to determine yearly overlap
tempfile f50

collapse (sum) f50_TB, by(year taxId)
drop if year < 2007
save `f50', replace

foreach year of numlist 2007/2013 {
	use temp_indDj1850
	keep if year == `year'
	collapse (sum) f1850baseimponiblevo, by(year taxId)
	tempfile dj1850_`year'
	save `dj1850_`year'', replace
	use `f50', clear
	merge 1:1 year taxId using `dj1850_`year'', generate(merge_`year')
	replace merge_`year' = . if year != `year'
	label values merge_`year' .
	save `f50', replace
	}

keep taxId year f50_TB f1850baseimponiblevo merge*
tempfile f50_dj1850_overlap
save `f50_dj1850_overlap', replace

// Tabulate results
eststo clear
foreach year of numlist 2007/2013 {
	eststo: quietly estpost tab merge_`year'
	}

esttab using results/F50_DJ1850_overlap.tex, replace booktabs ///
	cells(b(fmt(%9.0fc)) pct(fmt(1) par)) noobs nonumber collabels(none) ///
	varlabels(1 "F50 only" 2 "DJ1850 only" 3 "Both", blist(Total "\midrule ")) ///
	mtitles(2007 2008 2009 2010 2011 2012 2013)

****************************

*ppp f50c91, exp(6)
*ppp f1850imptoretenidovo, exp(6)
gen taxpay = f50_TB
foreach year of numlist 2007/2013 {
	replace taxpay = f1850baseimponiblevo if merge_`year' == 2
	}
ppp taxpay, exp(6)

eststo clear
foreach year of numlist 2007/2013 {
	eststo: quietly estpost tabstat taxpay_exp6 if year==`year', ///
		by(merge_`year') stat(sum)
	
	matrix colupct = e(sum)
	scalar c = colsof(colupct)
	matrix colupct = 100*colupct/colupct[1,c]
	estadd matrix colupct = colupct
	}
drop taxpay*

esttab using results/F50_DJ1850_overlap_TaxBase.tex, replace booktabs ///
	cell(sum(fmt(%9.0fc)) colupct(fmt(1) par)) noobs nonumber collabels(none) ///
	varlabels(1 "F50 only" 2 "DJ1850 only" 3 "Both", blist(Total "\midrule ")) ///
	mtitles(2007 2008 2009 2010 2011 2012 2013)

****************************

merge 1:1 taxId year using transferPricingDatabase.dta, keepusing(treatment4)

tempvar merge_treat treat_plus1
gen `treat_plus1' = treatment4 + 1
egen `merge_treat' = rowtotal(merge_2007-merge_2013)
replace `merge_treat' = . if `merge_treat'==0
replace `merge_treat' = `merge_treat'*`treat_plus1'

eststo clear
foreach year of numlist 2007/2013 {
	eststo: quietly estpost tab `merge_treat' if year==`year'
	}
esttab using results/F50_DJ1850_overlap_TvsC.tex, replace booktabs ///
	refcat(1 "\textbf{Control}" 4 "\textbf{Treatment}", nolabel) ///
	cells(b(fmt(%9.0fc)) pct(fmt(1) par)) noobs nonumber collabels(none) ///
	varlabels(1 "F50 only" 2 "DJ1850 only" 3 "Both" 4 "F50 only" 5 "DJ1850 only" 6 "Both", blist(Total "\midrule ")) ///
	mtitles(2007 2008 2009 2010 2011 2012 2013)

*-------------------------------------------------------------------------------
* Table of treatments
*-------------------------------------------------------------------------------
local path /nfs/projects/t/tpricing
cd `path'
use output/transferPricingDatabase.dta, clear
eststo clear
foreach num of numlist 1/3 {
	eststo: estpost tab treatment`num', mi
	}
esttab using output/results/treatments.tex, replace booktabs cells(b(fmt(%9.0fc)) pct(fmt(1) par)) ///
	varlabels(0 "Control" 1 "Treatment" _missing_ "Missing", blist(Total "\midrule ")) ///
	nomtitle collabels(none) noobs
*/
*===============================================================================
* III. Graphs
*===============================================================================
if (`graphs' == 1) {

*-------------------------------------------------------------------------------
* III.1. Differences in differences á la GHM 2010, Corporate income tax
*-------------------------------------------------------------------------------

	foreach y in /*f22c20 f22c633 f22c636 f22c630 f22c631 f22c628 f22c122*/ {

* (III.1.a). Areg --------------------------------------------------------------
		
		// Estimates the regression following table 4 of GHM 2010. We
		// calculate the average of the outcome variabale for each 
		// year and group. 
		areg `y' i.year#i.`tvar' `ctrl_ghm' [aweight = w_psm4], ///
			cluster(taxId) absorb(year)
		
		// Implements all the steps. Program is defined in line 80
		ghm `tvar' `baseyear' `y'
		
		graph export "psm_areg_`y'.`graph_ext'", as(`graph_ext') replace	

* (III.2.a). Areg --------------------------------------------------------------
		
		// Estimates the regression following table 4 of GHM 2010. We
		// calculate the average of the outcome variabale for each 
		// year and group. 
		areg bin_`y' i.year#i.`tvar' `ctrl_ghm' [aweight = w_psm4], ///
			cluster(taxId) absorb(year)

		// Implements all the steps. Program is defined in line 80
		ghm `tvar' `baseyear' `y' 
		
		graph export "psm_areg_bin_`y'.`graph_ext'", as(`graph_ext') replace	
	
* (III.2.a). Qreg p50 ----------------------------------------------------------
		
		// Estimates the regression following table 4 of GHM 2010. We
		// calculate the average of the outcome variabale for each 
		// year and group. 
		qreg `y' i.year#i.`tvar' `ctrl_ghm' [iweight = w_psm4], vce(robust) ///
			q(0.5) wlsiter(25) iterate(2000)
		
		// Implements all the steps. Program is defined in line 80
		ghm `tvar' `baseyear' `y' 
		
		graph export "psm_qregp50_`y'.`graph_ext'", as(`graph_ext') replace

* (III.2.a). Qreg p80 ----------------------------------------------------------
		
		// Estimates the regression following table 4 of GHM 2010. We
		// calculate the average of the outcome variabale for each 
		// year and group. 
		qreg `y' i.year#i.`tvar' `ctrl_ghm' [iweight = w_psm4], vce(robust) ///
			q(0.8) wlsiter(25) iterate(2000)
		
		// Implements all the steps. Program is defined in line 80
		ghm `tvar' `baseyear' `y' 
		
		graph export "psm_qregp80_`y'.`graph_ext'", as(`graph_ext') replace

	}
}
/*
*** Count and Sum of transfers to TH, by year

local path /nfs/projects/t/tpricing
use `path'/output/temp_indDj1850.dta, clear
cd `path'/output/results

run `path'/do/aux/ppp.ado
ppp f1850montoliquidovo, exp(3)
ppp f1850montoliquidovo, exp(6)

replace f1850tiporentavo=99 if f1850tiporentavo==0

set graphics off
graph bar (sum) f1850montoliquidovo_exp6 (count) f1850montoliquidovo_exp6 ///
	if taxhaven==1 & year>=2008, over(year) ///
	legend(order(1 "Transfers in millions of USD" 2 "Count of transfers") position(7))
graph export "f1850_transactions_MUSD_count_year_taxhaven.pdf", as(pdf) replace

*** Count of no-type transfers by year, TH v. NTH
graph bar (count) f1850montoliquidovo_exp6 if f1850tiporentavo==99 & year>=2008, ///
	over(year) ytitle(Count of transfers) by(taxhaven, note(""))
graph export "f1850_notype_transactions_count_year_taxhaven.pdf", as(pdf) replace

*** Sum of no-type transfers by year, TH v. NTH
graph bar (sum) f1850montoliquidovo_exp6 if f1850tiporentavo==99 & year>=2008, ///
	over(year) ytitle(Transfers in millions of USD) by(taxhaven, note(""))
graph export "f1850_notype_transactionsMUSD_year_taxhaven.pdf", as(pdf) replace

*** Affiliates vs. non-affiliates
tempvar montoA montoNA
gen `montoA' = f1850montoliquidovo_exp6 if dj1850affiliate == 1
gen `montoNA' = f1850montoliquidovo_exp6 if dj1850affiliate == 0

graph bar (count) `montoA' `montoNA' if year >= 2008, over(year) ///
	ytitle(Count of transfers) ///
	legend(order(1 "Affiliates" 2 "Non affiliates"))
graph export "f1850_transactions_count_affiliate_year.pdf", as(pdf) replace

graph bar (sum) `montoA' `montoNA' if year >= 2008, over(year) ///
	ytitle(Transfers in millions of USD) ///
	legend(order(1 "Affiliates" 2 "Non affiliates"))
graph export "f1850_transactions_MUSD_affiliate_year.pdf", as(pdf) replace

set graphics on
*===============================================================================
* IV. Subgroup analysis
*===============================================================================
if (`subgroup' == 1) {

	local tvar subgroup_taxhaven

*-------------------------------------------------------------------------------
* IV.1. Summary stats over treatment status, base year, full sample
*-------------------------------------------------------------------------------
// maybe we can loop this and save some lines

	count if `tvar' == 0 & year == `baseyear'
	local n_c = trim("`: display %10.0fc r(N)'")
	count if `tvar' == 1 & year == `baseyear'
	local n_t = trim("`: display %10.0fc r(N)'") 

	local r = 1 // initialises row counter

	foreach x in f22c628 f22c630 totalExportsF29 totalImportsF29 f22c631 ///
		f22c636 ebitda net_interest_expense f22c20 f22c122 ///
		royaltiesF50 interestF50 servicesF50 {
		
		local c1_r`r' : variable label `x' // first table's column
		
		sum `x' if `tvar' == 0 & year == `baseyear', detail
		local c2_r`r' = trim("`: display %14.1fc r(mean)'")
		local c3_r`r' = trim("`: display %14.1fc r(sd)'")
		local c4_r`r' = trim("`: display %14.1fc r(p50)'")
		
		sum `x' if `tvar' == 1 & year == `baseyear', detail
		local c5_r`r' = trim("`: display %14.1fc r(mean)'")
		local c6_r`r' = trim("`: display %14.1fc r(sd)'")
		local c7_r`r' = trim("`: display %14.1fc r(p50)'")
		
		ttest `x' if year == `baseyear', by(`tvar') unequal
		local c8_r`r' = trim("`: display %14.2fc r(t)'")
		
		local r = `r' + 1
	}
	// this step is only to get the formatting right
	foreach x in exp_share imp_share bin_f22c20 bin_net_interest_expense bin_rm ///
		bin_royaltiesF50 bin_interestF50 bin_servicesF50 {
		
		local c1_r`r' : variable label `x' // first table's column
		
		sum `x' if `tvar' == 0 & year == `baseyear', detail
		local c2_r`r' = trim("`: display %14.2fc r(mean)'")
		local c3_r`r' = trim("`: display %14.2fc r(sd)'")
		local c4_r`r' = trim("`: display %14.2fc r(p50)'")
		
		sum `x' if `tvar' == 1 & year == `baseyear', detail
		local c5_r`r' = trim("`: display %14.2fc r(mean)'")
		local c6_r`r' = trim("`: display %14.2fc r(sd)'")
		local c7_r`r' = trim("`: display %14.2fc r(p50)'")
		
		ttest `x' if year == `baseyear', by(`tvar') unequal
		local c8_r`r' = trim("`: display %14.2fc r(t)'")
		
		local r = `r' + 1
	}
	
	file open table using sum_stats_`baseyear'_sg1_full_sample.txt , write ///
		text replace
	
	// writes table's header
	file write table "\begin{tabular}{p{7cm} c c c c c c c}" _n ///
		"\toprule" ///
		" & \multicolumn{3}{c}{Control (n = `n_c')} &" ///
		" \multicolumn{3}{c}{Treated (n = `n_t')} \\" _n ///
		" Variable & Mean & (Std. Dev.) & Median & Mean & (Std. Dev.) &" ///
		" Median & t-Stat \\" _n "\midrule" _n
	
	// writes table's content //Loopable?
	
	file write table ///
		"`c1_r1' & `c2_r1' & (`c3_r1') & `c4_r1' & `c5_r1' & (`c6_r1') & `c7_r1' & `c8_r1' \\" _n ///
		"`c1_r2' & `c2_r2' & (`c3_r2') & `c4_r2' & `c5_r2' & (`c6_r2') & `c7_r2' & `c8_r2' \\" _n ///
		"`c1_r3' & `c2_r3' & (`c3_r3') & `c4_r3' & `c5_r3' & (`c6_r3') & `c7_r3' & `c8_r3' \\" _n ///
		"`c1_r4' & `c2_r4' & (`c3_r4') & `c4_r4' & `c5_r4' & (`c6_r4') & `c7_r4' & `c8_r4' \\" _n ///
		"`c1_r5' & `c2_r5' & (`c3_r5') & `c4_r5' & `c5_r5' & (`c6_r5') & `c7_r5' & `c8_r5' \\" _n ///
		"`c1_r6' & `c2_r6' & (`c3_r6') & `c4_r6' & `c5_r6' & (`c6_r6') & `c7_r6' & `c8_r6' \\" _n ///
		"`c1_r7' & `c2_r7' & (`c3_r7') & `c4_r7' & `c5_r7' & (`c6_r7') & `c7_r7' & `c8_r7' \\" _n ///
		"`c1_r8' & `c2_r8' & (`c3_r8') & `c4_r8' & `c5_r8' & (`c6_r8') & `c7_r8' & `c8_r8' \\" _n ///
		"`c1_r9' & `c2_r9' & (`c3_r9') & `c4_r9' & `c5_r9' & (`c6_r9') & `c7_r9' & `c8_r9' \\" _n ///
		"`c1_r10' & `c2_r10' & (`c3_r10') & `c4_r10' & `c5_r10' & (`c6_r10') & `c7_r10' & `c8_r10' \\" _n ///
		"`c1_r11' & `c2_r11' & (`c3_r11') & `c4_r11' & `c5_r11' & (`c6_r11') & `c7_r11' & `c8_r11' \\" _n ///
		"`c1_r12' & `c2_r12' & (`c3_r12') & `c4_r12' & `c5_r12' & (`c6_r12') & `c7_r12' & `c8_r12' \\" _n ///
		"`c1_r13' & `c2_r13' & (`c3_r13') & `c4_r13' & `c5_r13' & (`c6_r13') & `c7_r13' & `c8_r13' \\" _n ///
		"`c1_r14' & `c2_r14' & (`c3_r14') & `c4_r14' & `c5_r14' & (`c6_r14') & `c7_r14' & `c8_r14' \\" _n ///
		"`c1_r15' & `c2_r15' & (`c3_r15') & `c4_r15' & `c5_r15' & (`c6_r15') & `c7_r15' & `c8_r15' \\" _n ///
		"`c1_r16' & `c2_r16' & (`c3_r16') & `c4_r16' & `c5_r16' & (`c6_r16') & `c7_r16' & `c8_r16' \\" _n ///
		"`c1_r17' & `c2_r17' & (`c3_r17') & `c4_r17' & `c5_r17' & (`c6_r17') & `c7_r17' & `c8_r17' \\" _n ///
		"`c1_r18' & `c2_r18' & (`c3_r18') & `c4_r18' & `c5_r18' & (`c6_r18') & `c7_r18' & `c8_r18' \\" _n ///
		"`c1_r19' & `c2_r19' & (`c3_r19') & `c4_r19' & `c5_r19' & (`c6_r19') & `c7_r19' & `c8_r19' \\" _n ///
		"`c1_r20' & `c2_r20' & (`c3_r20') & `c4_r20' & `c5_r20' & (`c6_r20') & `c7_r20' & `c8_r20' \\" _n 
		
        // writes table's closing argument
	file write table "\bottomrule" _n ///
		"\end{tabular}"
	
	file close table
	
*-------------------------------------------------------------------------------
* IV.1. Summary stats over treatment status, pre-treatment year, matched sample
*       subgroup 1 
*-------------------------------------------------------------------------------

	count if `tvar' == 0 & year == `preyear' & w_psm_sgth == 1
	local n_c = trim("`: display %10.0fc r(N)'")
	count if `tvar' == 1 & year == `preyear' & w_psm_sgth == 1
	local n_t = trim("`: display %10.0fc r(N)'") 

	local r = 1 // initialises row counter

	foreach x in f22c628 f22c630 totalExportsF29 totalImportsF29 f22c631 ///
		f22c636 net_interest_expense f22c20 f22c122 royaltiesF50 interestF50 ///
		servicesF50 {
			
		local c1_r`r' : variable label `x' // first table's column
		
		sum `x' if `tvar' == 0 & year == `preyear' & w_psm_sgth == 1, detail
		local c2_r`r' = trim("`: display %14.1fc r(mean)'")
		local c3_r`r' = trim("`: display %14.1fc r(sd)'")
		local c4_r`r' = trim("`: display %14.1fc r(p50)'")

		sum `x' if `tvar' == 1 & year == `preyear' & w_psm_sgth == 1, detail
		local c5_r`r' = trim("`: display %14.1fc r(mean)'")
		local c6_r`r' = trim("`: display %14.1fc r(sd)'")
		local c7_r`r' = trim("`: display %14.1fc r(p50)'")
		
		ttest `x' if year == `preyear' & w_psm_sgth == 1, by(`tvar') unequal
		local c8_r`r' = trim("`: display %14.2fc r(t)'")
		
		local r = `r' + 1
	}
	
	// this step is only to get the format right
	foreach x in exp_share imp_share bin_f22c20 bin_net_interest_expense bin_rm ///
		bin_royaltiesF50 bin_interestF50 bin_servicesF50 {
		
		local c1_r`r' : variable label `x' // first table's column
		
		sum `x' if `tvar' == 0 & year == `preyear' & w_psm_sgth == 1, detail
		local c2_r`r' = trim("`: display %14.2fc r(mean)'")
		local c3_r`r' = trim("`: display %14.2fc r(sd)'")
		local c4_r`r' = trim("`: display %14.2fc r(p50)'")

		sum `x' if `tvar' == 1 & year == `preyear' & w_psm_sgth == 1, detail
		local c5_r`r' = trim("`: display %14.2fc r(mean)'")
		local c6_r`r' = trim("`: display %14.2fc r(sd)'")
		local c7_r`r' = trim("`: display %14.2fc r(p50)'")
		
		ttest `x' if year == `preyear' & w_psm_sgth == 1, by(`tvar') unequal
		local c8_r`r' = trim("`: display %14.2fc r(t)'")
		
		local r = `r' + 1
	}
	
	file open table using sum_stats_`preyear'_sgth_matched_sample.txt , write text replace
	
	// writes table's header
	file write table "\begin{tabular}{l c c c c c c c}" _n ///
		"\toprule" ///
		" & \multicolumn{3}{c}{Control (n = `n_c')} &" ///
		" \multicolumn{3}{c}{Treated (n = `n_t')} \\" _n ///
		" Variable & Mean & (Std. Dev.) & Median & Mean & (Std. Dev.) &" ///
		" Median & t-Stat \\" _n "\midrule" _n
	
	// writes table's content //Loopable?
	
	file write table ///
		"`c1_r1' & `c2_r1' & (`c3_r1') & `c4_r1' & `c5_r1' & (`c6_r1') & `c7_r1' & `c8_r1' \\" _n ///
		"`c1_r2' & `c2_r2' & (`c3_r2') & `c4_r2' & `c5_r2' & (`c6_r2') & `c7_r2' & `c8_r2' \\" _n ///
		"`c1_r3' & `c2_r3' & (`c3_r3') & `c4_r3' & `c5_r3' & (`c6_r3') & `c7_r3' & `c8_r3' \\" _n ///
		"`c1_r4' & `c2_r4' & (`c3_r4') & `c4_r4' & `c5_r4' & (`c6_r4') & `c7_r4' & `c8_r4' \\" _n ///
		"`c1_r5' & `c2_r5' & (`c3_r5') & `c4_r5' & `c5_r5' & (`c6_r5') & `c7_r5' & `c8_r5' \\" _n ///
		"`c1_r6' & `c2_r6' & (`c3_r6') & `c4_r6' & `c5_r6' & (`c6_r6') & `c7_r6' & `c8_r6' \\" _n ///
		"`c1_r7' & `c2_r7' & (`c3_r7') & `c4_r7' & `c5_r7' & (`c6_r7') & `c7_r7' & `c8_r7' \\" _n ///
		"`c1_r8' & `c2_r8' & (`c3_r8') & `c4_r8' & `c5_r8' & (`c6_r8') & `c7_r8' & `c8_r8' \\" _n ///
		"`c1_r9' & `c2_r9' & (`c3_r9') & `c4_r9' & `c5_r9' & (`c6_r9') & `c7_r9' & `c8_r9' \\" _n ///
		"`c1_r10' & `c2_r10' & (`c3_r10') & `c4_r10' & `c5_r10' & (`c6_r10') & `c7_r10' & `c8_r10' \\" _n ///
		"`c1_r11' & `c2_r11' & (`c3_r11') & `c4_r11' & `c5_r11' & (`c6_r11') & `c7_r11' & `c8_r11' \\" _n ///
		"`c1_r12' & `c2_r12' & (`c3_r12') & `c4_r12' & `c5_r12' & (`c6_r12') & `c7_r12' & `c8_r12' \\" _n ///
		"`c1_r13' & `c2_r13' & (`c3_r13') & `c4_r13' & `c5_r13' & (`c6_r13') & `c7_r13' & `c8_r13' \\" _n ///
		"`c1_r14' & `c2_r14' & (`c3_r14') & `c4_r14' & `c5_r14' & (`c6_r14') & `c7_r14' & `c8_r14' \\" _n ///
		"`c1_r15' & `c2_r15' & (`c3_r15') & `c4_r15' & `c5_r15' & (`c6_r15') & `c7_r15' & `c8_r15' \\" _n ///
		"`c1_r16' & `c2_r16' & (`c3_r16') & `c4_r16' & `c5_r16' & (`c6_r16') & `c7_r16' & `c8_r16' \\" _n ///
		"`c1_r17' & `c2_r17' & (`c3_r17') & `c4_r17' & `c5_r17' & (`c6_r17') & `c7_r17' & `c8_r17' \\" _n ///
		"`c1_r18' & `c2_r18' & (`c3_r18') & `c4_r18' & `c5_r18' & (`c6_r18') & `c7_r18' & `c8_r18' \\" _n ///
		"`c1_r19' & `c2_r19' & (`c3_r19') & `c4_r19' & `c5_r19' & (`c6_r19') & `c7_r19' & `c8_r19' \\" _n ///
		"`c1_r20' & `c2_r20' & (`c3_r20') & `c4_r20' & `c5_r20' & (`c6_r20') & `c7_r20' & `c8_r20' \\" _n 
		
        // writes table's closing argument
	file write table "\bottomrule" _n ///
		"\end{tabular}"
	
	file close table
	
* (II.4.b). ATE summary table, with controls -----------------------------------
	
	foreach y in f22c20 ebitda net_interest_expense f22c628 f22c633 f22c630 royaltiesF50 interestF50 servicesF50 {

		matrix ate_bar = J(8,1,.) // initialises matrix to store ate 
					  // over control post level
		matrix rownames ate_bar = Mean p40 p50 p60 p70 p80 p90 p95
	
		eststo clear
		
		areg `y' c.post##c.`tvar' [fweight = w_psm_sgth], ///
			cluster(taxId) absorb(taxId)		
		count if w_psm_sgth == 1 & year == `baseyear' // balanced panel
		estadd local N_firms "`: display %14.0fc r(N)'", replace
		estadd local fixed "Yes" , replace		
		sum `y' if post == 1 & `tvar' == 0 & w_psm_sgth == 1
		estadd local raw_control "`: display %14.2fc r(mean)'", replace
		estadd local pr_tr "`: display %14.0fc 100 * _b[c.post#c.`tvar'] / r(mean)'\%", replace
		matrix ate_bar[1,1] = 100* (_b[c.post#c.`tvar'] / `r(mean)')
		estadd local r2_trick "`: display %14.2fc e(r2_a)'", replace
		eststo, title("Mean") 

		areg bin_`y' c.post##c.`tvar'  [fweight = w_psm_sgth], ///
			cluster(taxId) absorb(taxId)
		count if w_psm_sgth == 1 & year == `baseyear' // balanced panel
		estadd local N_firms "`: display %14.0fc r(N)'", replace
		estadd local fixed "Yes" , replace
		sum bin_`y' if post == 1 & `tvar' == 0 & w_psm_sgth == 1
		estadd local raw_control "`: display %14.2fc r(mean)'", replace
		estadd local pr_tr "`: display %14.0fc 100 * _b[c.post#c.`tvar'] / r(mean)'\%", replace
		estadd local r2_trick "`: display %14.2fc e(r2_a)'", replace
		eststo, title("Pr($ Y>0$)")
		
		local j = 2

		foreach i in 0.4 0.5 0.6 0.7 0.8 0.9 0.95 {
			qreg `y' c.post##c.`tvar' [fweight = w_psm_sgth], ///
				vce(robust) q(`i') wlsiter(5) iterate(1000)		
			estadd local r2_trick "`: display %14.2fc 1 - (`=e(sum_adev)'/`=e(sum_rdev)')'", replace
			count if w_psm_sgth == 1 & year == `baseyear' // balanced panel
			estadd local N_firms "`: display %14.0fc r(N)'", replace
			local rt = `i'*100
			_pctile `y' if post == 1 & `tvar' == 0 & ///
				w_psm_sgth == 1, percentiles(`rt')
			estadd local raw_control "`: display %14.2fc r(r1)'", replace
			estadd local pr_tr "`: display %14.0fc 100 * _b[c.post#c.`tvar'] / r(r1)'\%", replace
			matrix ate_bar[`j',1] = 100* (_b[c.post#c.`tvar'] / `r(r1)')
			estadd local fixed "No" , replace
			eststo, title("Percentile `rt'")
			
			local j = `j' + 1
		}
		
		estout * using ate_`y'_withoutcontrols_sgth.txt, ///
			cells(b(star fmt(2)) se(par fmt(2))) ///
			stats(fixed N N_firms r2_trick raw_control pr_tr, ///
			fmt(%10.0fc %10.0fc 2) ///
			labels("Firm's fixed effects" "\midrule Observations" ///
				"Numbers of firms" "Adjusted/Pseudo R$^2$" ///
				"\midrule Control Post Level" ///
				"Effect's percent of Control Post Level")) ///
			starlevels(* 0.10 ** 0.05 *** 0.01) noabbrev  ///
			mlabels(, titles) order("c.post#c.`tvar'") ///
			collabels(none) numbers style(tex) noomitted ///
			varlabels(_cons "Constant" post "Post" `tvar' "Affiliate in tax haven" ///
				c.post#c.`tvar' "Affiliate in tax haven $\times$ Post" ///
				imp_share`preyear' ///
				"Imported Share of Direct Costs at `preyear'") ///
			prehead(\begin{tabular}{l*{@M}{r}} \toprule ) ///
			posthead(\midrule) replace ///
			postfoot(\bottomrule \multicolumn{@span}{l}{\footnotesize @note} \\ \end{tabular}) 

		// Plots ATE divided by control post level (raw) 
		coefplot matrix(ate_bar[,1]), vertical noci ytitle("`y'") ///
			yline(0) format(%5.0fc) mlabel mlabposition(12) ///
			msymbol(none) addplot(bar @b @at, barwidth(0.7) ///
			fcolor(none)) yscale(range(0)) aspectratio(0.62) 
			
		graph export "ate_bar_`y'_withoutcontrols_sgth.`graph_ext'", ///
			as(`graph_ext') replace 

	}

*-------------------------------------------------------------------------------
* III.1. Differences in differences á la GHM 2010, Corporate income tax
*-------------------------------------------------------------------------------

	foreach y in f22c20 ebitda net_interest_expense f22c628 f22c630 f22c633 royaltiesF50 interestF50 servicesF50 {

* (III.1.a). Areg --------------------------------------------------------------
		
		// Estimates the regression following table 4 of GHM 2010. We
		// calculate the average of the outcome variabale for each 
		// year and group. 
		areg `y' i.year#i.`tvar' [fweight = w_psm_sgth], ///
			cluster(taxId) absorb(taxId)
		
		// Implements all the steps. Program is defined in line 80
		ghm `tvar' `baseyear' `y'
		
		graph export "psm_areg_sgth_`y'.`graph_ext'", as(`graph_ext') replace	

* (III.2.a). Areg --------------------------------------------------------------
		
		// Estimates the regression following table 4 of GHM 2010. We
		// calculate the average of the outcome variabale for each 
		// year and group. 
		areg bin_`y' i.year#i.`tvar' [fweight = w_psm_sgth], ///
			cluster(taxId) absorb(taxId)

		// Implements all the steps. Program is defined in line 80
		ghm `tvar' `baseyear' `y' 
		
		graph export "psm_areg_bin_sgth_`y'.`graph_ext'", as(`graph_ext') replace	
	
* (III.2.a). Qreg p50 ----------------------------------------------------------
		
		// Estimates the regression following table 4 of GHM 2010. We
		// calculate the average of the outcome variabale for each 
		// year and group. 
		qreg `y' i.year#i.`tvar' [fweight = w_psm_sgth], vce(robust) ///
			q(0.5) wlsiter(25) iterate(1000)
		
		// Implements all the steps. Program is defined in line 80
		ghm `tvar' `baseyear' `y' 
		
		graph export "psm_qregp50_sgth_`y'.`graph_ext'", as(`graph_ext') replace

* (III.2.a). Qreg p80 ----------------------------------------------------------
		
		// Estimates the regression following table 4 of GHM 2010. We
		// calculate the average of the outcome variabale for each 
		// year and group. 
		qreg `y' i.year#i.`tvar' [fweight = w_psm_sgth], vce(robust) ///
			q(0.8) wlsiter(25) iterate(1000)
		
		// Implements all the steps. Program is defined in line 80
		ghm `tvar' `baseyear' `y' 
		
		graph export "psm_qregp80_sgth_`y'.`graph_ext'", as(`graph_ext') replace

	}
}
*===============================================================================
* END
*===============================================================================
