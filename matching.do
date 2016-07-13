* Matching
*********************

* Initial set up
*-------------------------------------------------------------------------------
local treatvar treatment1
local X_b // Sets basic covariates (can be empty)
local C_lin 1

* Step 1
*-------------------------------------------------------------------------------
logit `treatvar' `X_b', iterate(40)
local ll_b =  `e(ll)' // stores log-likelihood value of base model

* Step 2
*-------------------------------------------------------------------------------
local llrt_max = 0 // Store maximum likelihood ratio test
foreach i of local totry {
	local try 1
	foreach included_var of varlist `X_b' {
		if ("`i'" == "`included_var'") local try = 0
	}
	if `try' == 1 {
		// Estimate K+1-K_b logits
		quietly logit `treatvar' `xb' `i', iter(40) nocons
		// Compute LRT stat
		local llrt = 2 * ( `e(ll)' - `ll_b' ) 
		// Skip model if perfect failures or successes, or if it doesn't converge
		local check = (`e(N_cdf)' == 0 & `e(N)' == `N_0' /// 
			& `e(N_cds)' == 0 & `e(converged)' == 1)
		if (`llrt' > `llrt_max' & `check' == 1) { 
			// Add variable	
			local add "`i'"
			// Update maximum likelihood ratio test
			local llrt_max = `llrt'
		}
		local ct = `ct'+1 // counter of 
	}
}
