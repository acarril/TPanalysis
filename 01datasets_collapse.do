*===============================================================================
* Name: 	01datasets_collapse.do
* Description:	Import data created in 00datasets.do and collapse it by firm
*		and year for further analysis
* Notes: 	Since this code collapses data, it only keeps some variables and
*		makes some assumptions while collapsing.
* Author:	Alvaro Carril (acarril@povertyactionlab.org)
* Created: 	20160303
* Version:	1.0
* Last edited:	20160303
*===============================================================================

* Prueba

version 14
set more off
clear all
local path /nfs/projects/t/tpricing/tpricing2/analysis
cd `path'

*-------------------------------------------------------------------------------
* Build switches (set to 1 in order to build corresponding dataset)
*-------------------------------------------------------------------------------
local f50_collapsed 	= 0	//
local dj1850_collapsed	= 0	// income tax

local TPdataset		= 1	// income tax form

*===============================================================================
* Collapse f50 by year and firm id sums
*===============================================================================
if `f50_collapsed' == 1 {
// Use raw f50 dataset (not collapsed):
use output/f50.dta, clear

*-------------------------------------------------------------------------------
* Create totals of tax bases and taxes paid (total and by type)
*-------------------------------------------------------------------------------
// Convert to negative only item that is substracted from total:
replace f50c624 = -f50c624
replace f50c625 = -f50c625

// Generate total taxbase, analogous to f50c91 but for tax bases
egen total_taxbase = rowtotal(f50c10 f50c100 f50c103 f50c14 f50c61 ///
	f50c16 f50c18 f50c20 f50c22 f50c24 f50c600 f50c602 f50c604 f50c606 ///
	f50c26 f50c28 f50c30 f50c32 f50c34 f50c36 f50c38 f50c40 f50c42 f50c268 ///
	f50c244 f50c608 f50c46 f50c48 f50c610 f50c612 f50c50 f50c52 f50c54 ///
	f50c56 f50c58 f50c64 f50c108 f50c110 f50c267 f50c83 f50c86 f50c272 ///
	f50c95 f50c275 f50c624)
	
// Sum all individual category taxes, in theory should be equal to f50c91
egen total_taxes = rowtotal( ///
	f50c12 f50c102 f50c105 f50c300 f50c62 ///
	f50c17 f50c19 f50c21 f50c23 f50c25 f50c601 f50c603 f50c605 f50c607 ///
	f50c27 ///
	f50c29 ///
	f50c31 f50c33 f50c35 f50c37 f50c39 f50c41 f50c43 f50c269 ///
	f50c45 f50c609 f50c47 f50c49 f50c611 f50c613 ///
	f50c51 f50c254 ///
	f50c55 ///
	f50c57 ///
	f50c59 ///
	f50c65 ///
	f50c109 f50c111 f50c68 f50c84 ///
	f50c87 ///
	f50c273 f50c96 f50c276 ///
	f50c625 ///
	)
	
// Generate taxes and tax bases by categories:
* Dividends:
egen dividends_taxbase = rowtotal(f50c10 f50c100 f50c103 f50c14 f50c61)
egen dividends_taxes = rowtotal(f50c12 f50c102 f50c105 f50c300 f50c62)
* Royalties:
egen royalties_taxbase = rowtotal(f50c16 f50c18 f50c22 f50c24 f50c600 ///
	f50c602 f50c604 f50c606 f50c26 f50c28)
egen royalties_taxes = rowtotal(f50c17 f50c19 f50c23 f50c25 f50c601 ///
	f50c603 f50c605 f50c607 f50c27 f50c29)
* Interests:
egen interests_taxbase = rowtotal(f50c30 f50c32 f50c34 f50c36 f50c38 f50c40 ///
	f50c42 f50c268)
egen interests_taxes = rowtotal(f50c31 f50c33 f50c35 f50c37 f50c39 f50c41 ///
	f50c43 f50c269)
* Services:
egen services_taxbase = rowtotal(f50c20 f50c244 f50c608 f50c46 f50c48 ///
	f50c610 f50c612 f50c108 f50c110 f50c267 f50c83)
egen services_taxes = rowtotal(f50c21 f50c45 f50c609 f50c47 f50c49 ///
	f50c611 f50c613 f50c109 f50c111 f50c68 f50c84)
* Other:
egen others_taxbase = rowtotal(f50c50 f50c52 f50c54 f50c56 f50c58 f50c64 ///
	f50c86 f50c272 f50c95 f50c275 f50c624)
egen others_taxes = rowtotal(f50c51 f50c254 f50c55 f50c57 f50c59 f50c65 ///
	f50c87 f50c273 f50c96 f50c276 f50c625)

// Collapse all totals by firms:
collapse (sum) f50c91 *_tax*, by(year id)

// Assumption: replace 0 values of sums as missing values:
foreach var of varlist f50c91-others_taxes {
	replace `var' =. if `var'==0
	}

// Labels:
label data "f50 collapsed by firm and year"
lab var f50c91 "Total taxes paid as reported by F50"
lab var total_taxbase "Total taxbase of taxes paid"
lab var total_taxes "Total taxes paid as a sum of individual taxes types"
foreach type in dividends royalties interests services others {
	lab var `type'_taxbase "Total taxbase of `type' type"
	lab var `type'_taxes "Total taxes of `type' type"
	}

// Save collapsed dataset:
save output/f50_collapsed.dta, replace
}

*===============================================================================
* Collapse dj1850 by year and firm id sums
*===============================================================================
if `dj1850_collapsed' == 1 {
// Use raw dj1850 dataset (not collapsed):
use output/dj1850.dta, clear

*-------------------------------------------------------------------------------
* Create totals of tax bases and taxes paid (total and by type)
*-------------------------------------------------------------------------------
gen byte num_transfers = 1
// Collapse all totals by firms:
collapse (mean) taxhaven  (sum) dj1850baseimponible dj1850imptoretenido ///
	dj1850montoliquido num_transfers, by(year id)
// Labels:
lab data "dj1850 collapsed by firm and year"
lab var taxhaven "Proportion of transfers made to tax havens"
lab var dj1850baseimponible "Total tax bases"
lab var dj1850imptoretenido "Total taxes paid"
lab var dj1850montoliquido "Total transfers"
lab var num_transfers "Number of transfers"
// Save collapsed dataset:
save output/dj1850_collapsed.dta, replace
}

*===============================================================================
* Collapse dj1850 by year and firm id sums
*===============================================================================
if `TPdataset' == 1 {
// Use raw f22 dataset (not collapsed):
use output/f22.dta, clear
}
