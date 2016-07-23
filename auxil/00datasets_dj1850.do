// Label for transaction types
label define transtype 1 "Dividends payed abroad" 2 "Royalties payed abroad" 3 "Interests payed abroad" 4 "Services payed abroad" ///
	5 "Other payments abroad", replace
// Tax codes
local 1 12 102 105 300 62
local 2 17 19 23 25 601 603 605 607 27 29
local 3 31 33 35 37 39 41 43 269
local 4 21 45 609 47 49 611 613 109 111 68 84
local 5 51 254 55 57 59 65 87 273 96 276 625

// Add tax base equivalent codes (assuming they were used by mistake)
local 1 `1' 137 
local 2 `2' 16 24 26 
local 3 `3' 
local 4 `4' 244 
local 5 `5' 95

// Generate transfer type
gen dj1850transtype = .
foreach transtype of numlist 1/5 {
	foreach code of numlist ``transtype'' {
		replace dj1850transtype = `transtype' if dj1850codigof50 == `code'
	}
}
label values dj1850transtype transtype
label var dj1850transtype "Transfer type"

// Generate variables with amounts of transfers, by f50 type
levelsof dj1850transtype, local(levels)
foreach l of local levels {
	qui gen `: label (dj1850transtype) `l'' = .
	qui replace `: label (dj1850transtype) `l'' = dj1850baseimponible ///
		if dj1850transtype == `l' & dj1850baseimponible > 0
	lab var `: label (dj1850transtype) `l'' "`: label (dj1850transtype) `l''"
	rename `: label (dj1850transtype) `l'', lower
}

// Encode remmittance date
gen dj1850remittance_date = date(dj1850fecharemesa, "DM20Y")
format %td dj1850remittance_date
lab var dj1850remittance_date "Remittance date"
// Labels
lab var dj1850baseimponible "Transfer"
// Drop some unnecessary variables
drop headerformkey-contdvbenef dj1850codigopaisic ///
	dj1850gastosrechazados-dj1850fecharesidencia timocodmoneda ///
	dj1850creditodonacart69 dj1850fecharemesa
