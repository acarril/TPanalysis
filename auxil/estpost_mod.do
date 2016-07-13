* 5. estpost_ttest: wrapper for -ttest- (two-sample)
capture program drop estpost_ttest
prog estpost_ttest, eclass
    version 8.2
    local caller : di _caller() // not used

    // syntax
    syntax varlist(numeric) [if] [in] , by(varname) [ ESample Quietly ///
         LISTwise CASEwise UNEqual Welch ]
    if "`casewise'"!="" local listwise listwise
di "HOLAA"
    // sample
    if "`listwise'"!="" marksample touse
    else {
        marksample touse, nov
        _estpost_markout2 `touse' `varlist'
    }
    markout `touse' `by', strok
    qui count if `touse'
    local N = r(N)
    if `N'==0 error 2000

    // gather results
    local nvars: list sizeof varlist
    tempname diff count
    mat `diff' = J(1, `nvars', .)
    mat coln `diff' = `varlist'
    mat `count' = `diff'
    local mnames se sd t df_t p_l p p_u N_1 mu_1 sd_1 N_2 mu_2 sd_2
    foreach m of local mnames {
        tempname `m'
        mat ``m'' = `diff'
    }
    local i 0
    foreach v of local varlist {
        local ++i
        qui ttest `v' if `touse', by(`by') `unequal' `welch'
        mat `diff'[1,`i'] = r(mu_1) - r(mu_2)
        mat `count'[1,`i'] = r(N_1) + r(N_2)
        foreach m of local mnames {
            mat ``m''[1,`i'] = r(`m')
        }
    }

    // display
    if "`quietly'"=="" {
        tempname res
        mat `res' = `diff'', `count''
        local rescoln "e(b) e(count)"
        foreach m of local mnames {
            mat `res' = `res', ``m'''
            local rescoln `rescoln' e(`m')
        }
        mat coln `res' = `rescoln'
        if c(stata_version)<9 {
            mat list `res', noheader nohalf format(%9.0g)
        }
        else {
            matlist `res', nohalf lines(oneline)
        }
        mat drop `res'
    }

    // post results
    local V
    if c(stata_version)<9 { // V required in Stata 8
        tempname V
        mat `V' = diag(vecdiag(`se'' * `se'))
    }
    if "`esample'"!="" local esample esample(`touse')
    eret post `diff' `V', obs(`N') `esample'

    eret scalar k = `nvars'

    eret local wexp `"`exp'"'
    eret local wtype `"`weight'"'
    eret local welch "`welch'"
    eret local unequal "`unequal'"
    eret local byvar "`by'"
    eret local subcmd "ttest"
    eret local cmd "estpost"

    local nmat: list sizeof mnames
    forv i=`nmat'(-1)1 {
        local m: word `i' of `mnames'
        eret matrix `m' = ``m''
    }
    eret matrix count = `count'
end
