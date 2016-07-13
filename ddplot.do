clear all
cd "D:\tpricing\analysis"
use output/TPdata_firm.dta, clear

capture program drop epost_bv ddplot

program define epost_bv, eclass
	args b V
	ereturn post `b' `V'
end	

***************************

program define ddplot

syntax varlist(max=1) , Timevar(varname) ///
	[ Baseperiod(integer -999) plotopts(string asis)]

*-------------------------------------------------------------------------------
* Syntax check and locals
*-------------------------------------------------------------------------------

// Rename the treatment var
local treatvar `varlist'

// Store number of time periods
tab `timevar', nofreq
local Nperiods = r(r)

// Extract distinct values of timevar and store pre-first period
quietly levelsof `timevar', local(periods)
tokenize `periods'
local prefirst = `1'-1
if `baseperiod' == -999 {
	local baseperiod `1'
}

// Define matrices
matrix did = J(`Nperiods',3,.) // initialises matrix to store diff in diff
matrix errors = J(`Nperiods',1,.) // errors matrix
matrix rownames did = `periods'

matrix sto_b = e(b) // stores the regression coefficients
matrix sto_V = e(V) // stores the variance covariance matrix	

foreach t in `periods' {

	matrix define b1 = sto_b
	matrix define V1 = sto_V
		
	epost_bv b1 V1 // brings back the areg coefficients after looping thorugh. nlcom updates b and V.
	
	// We estimate the first difference, that is, the average of the
	// treated in the current year minus the base year, and the
	// same for the treated. The ", post" option updates b and V
	// matrices, updating the ones estimated in areg. Necessary 
	// to estimate the second difference.
	qui nlcom	(dc: _b[`t'.`timevar'#0.`treatvar'] - _b[`baseperiod'.`timevar'#0.`treatvar']) /// 
				(dt: _b[`t'.`timevar'#1.`treatvar'] - _b[`baseperiod'.`timevar'#1.`treatvar']), ///
				post

	// We estimate the second difference between the treated and 
	// the controls. The ", post" option updates b and V matrices
	// in order to store in the plot matrix
	quietly nlcom (did: _b[dt] - _b[dc]), post
	
	matrix define b = e(b)
	matrix define V = e(V)
	
	// We store the diff in diff and its confidence interval
	matrix did[`t'-`prefirst',1] = b[1,1]
	matrix errors[`t'-`prefirst',1] = V[1,1]
	
	mata: mataV = st_matrix("errors")
	mata: matase = mataV:^.5
	mata: st_matrix("se",matase)
	
	matrix did[`t'-`prefirst',2] = b[1,1]-se[1,1]
	matrix did[`t'-`prefirst',3] = b[1,1]+se[1,1]
}

// Plots the differences in difference. 
coefplot (matrix(did[,1]), ci((did[,2] did[,3]))), ///
	vertical yline(0, lstyle(foreground)) addplot(line @b @at, lpattern(solid)) ///
	`plotopts'

end

areg f50c91 i.year#i.treatment2 i.year#i.industry_sector, vce(cluster id) absorb(id)
ddplot treatment2, t(year) b(2009) plotopts(xtitle("Year") xline(3.5 4.5, lpattern(shortdash)) ytitle("") aspectratio(0.62))
