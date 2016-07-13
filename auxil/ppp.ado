*! Alvaro Carril
* ppp: converts nominal CLP to current USD -------------------------------------

/* We use the Implied PPP conversion rate reported by the IMF. Spreadsheet is
available in the input folder (\\tpricing\input\WEOApr2015all.xls). Original
spreadsheet is in http://goo.gl/cNGs7H */

program define ppp
syntax varname[, Exp(integer 1) Replace]

quietly{
	tempvar x
	gen `x' = `varlist'
	replace `x' = 0 if `x' == .
	replace `x' = `x' / (314.790 * 10^`exp') if year == 2007 
	replace `x' = `x' / (310.269 * 10^`exp') if year == 2008 
	replace `x' = `x' / (319.449 * 10^`exp') if year == 2009 
	replace `x' = `x' / (343.559 * 10^`exp') if year == 2010 
	replace `x' = `x' / (348.017 * 10^`exp') if year == 2011 
	replace `x' = `x' / (344.646 * 10^`exp') if year == 2012
	replace `x' = `x' / (345.798 * 10^`exp') if year == 2013
	
	if missing("`replace'") {
		gen `varlist'_exp`exp' = `x'
	}
	else {
		replace `varlist' = `x'
		noisily di "`varlist' values were replaced"
	}
}
end
