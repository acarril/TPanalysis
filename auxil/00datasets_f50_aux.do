*** F50 Aux Do-file ***
/* This file performs a series of corrections to F50 variables. */

* Rename variables -------------------------------------------------------------
* For security reasons, SII gave us the data whith variable names coded. This 
* section undos that.

	rename ïa1 id
	rename a2 contdv
	rename a3 f50agnomestributario
	rename a4 f50fechapresentacion
	rename b1 f50c10
	rename b2 f50c12
	rename b3 f50c100
	rename b4 f50c102
	rename b5 f50c103
	rename b6 f50c14
	rename b7 f50c300
	rename b8 f50c25
	rename b9 f50c28
	rename b10 f50c26
	rename b11 f50c24
	rename b12 f50c22
	rename b13 f50c23
	rename b14 f50c21
	rename b15 f50c20
	rename b16 f50c62
	rename b17 f50c272
	rename b18 f50c273
	rename b19 f50c276
	rename b20 f50c275
	rename b21 f50c96
	rename b22 f50c95
	rename b23 f50c89
	rename b24 f50c56
	rename b25 f50c86
	rename b26 f50c267
	rename b27 f50c84
	rename b28 f50c83
	rename b29 f50c68
	rename b30 f50c110
	rename b31 f50c111
	rename b32 f50c109
	rename b33 f50c59
	rename b34 f50c65
	rename b35 f50c64
	rename b36 f50c54
	rename b37 f50c49
	rename b38 f50c55
	rename b39 f50c254
	rename b40 f50c19
	rename b41 f50c51
	rename b42 f50c50
	rename b43 f50c47
	rename b44 f50c48
	rename b45 f50c45
	rename b46 f50c46
	rename b47 f50c268
	rename b48 f50c269
	rename b49 f50c36
	rename b50 f50c43
	rename b51 f50c42
	rename b52 f50c41
	rename b53 f50c40
	rename b54 f50c39
	rename b55 f50c38
	rename b56 f50c37
	rename b57 f50c34
	rename b58 f50c35
	rename b59 f50c33
	rename b60 f50c32
	rename b61 f50c31
	rename b62 f50c30
	rename b63 f50c18
	rename b64 f50c27
	rename b65 f50c17
	rename b66 f50c16
	rename b67 f50c61
	rename b68 f50c29
	rename b69 f50c244
	rename b70 f50c52
	rename b71 f50c57
	rename b72 f50c58
	rename b73 f50c108
	rename b74 f50c87
	rename b75 f50c274
	rename b76 f50c91
	rename b77 f50c94
	rename b78 f50c105
	rename b79 f50c609
	rename b80 f50c608
	rename b81 f50c610
	rename b82 f50c602
	rename b83 f50c601
	rename b84 f50c603
	rename b85 f50c604
	rename b86 f50c605
	rename b87 f50c606
	rename b88 f50c607
	rename b89 f50c600
	rename b90 f50c611
	rename b91 f50c612
	rename b92 f50c613
	rename b93 f50c624
	rename b94 f50c625

* Converts data and name variables ---------------------------------------------
* For security reasons, SII gave us the data multiplying each variable with an
* integer. This section undos that.
	
	replace f50agnomestributario = f50agnomestributario / 3
	replace f50c10 = f50c10 / 2
	replace f50c12 = f50c12 / 3
	replace f50c100 = f50c100 / 4
	replace f50c102 = f50c102 / 5
	replace f50c103 = f50c103 / 6
	replace f50c14 = f50c14 / 3
	replace f50c300 = f50c300 / 4
	replace f50c25 = f50c25 / 5
	replace f50c28 = f50c28 / 6
	replace f50c26 = f50c26 / 7
	replace f50c24 = f50c24 / 6
	replace f50c22 = f50c22 / 5
	replace f50c23 = f50c23 / 4
	replace f50c21 = f50c21 / 3
	replace f50c20 = f50c20 / 2
	replace f50c62 = f50c62 / 3
	replace f50c272 = f50c272 / 4
	replace f50c273 = f50c273 / 5
	replace f50c276 = f50c276 / 6
	replace f50c275 = f50c275 / 7
	replace f50c96 = f50c96 / 8
	replace f50c95 = f50c95 / 9
	replace f50c89 = f50c89 / 8
	replace f50c56 = f50c56 / 7
	replace f50c86 = f50c86 / 6
	replace f50c267 = f50c267 / 5
	replace f50c84 = f50c84 / 4
	replace f50c83 = f50c83 / 3
	replace f50c68 = f50c68 / 2
	replace f50c110 = f50c110 / 3
	replace f50c111 = f50c111 / 4
	replace f50c109 = f50c109 / 5
	replace f50c59 = f50c59 / 6
	replace f50c65 = f50c65 / 7
	replace f50c64 = f50c64 / 8
	replace f50c54 = f50c54 / 9
	replace f50c49 = f50c49 / 2
	replace f50c55 = f50c55 / 3
	replace f50c254 = f50c254 / 4
	replace f50c19 = f50c19 / 5
	replace f50c51 = f50c51 / 4
	replace f50c50 = f50c50 / 3
	replace f50c47 = f50c47 / 2
	replace f50c48 = f50c48 / 3
	replace f50c45 = f50c45 / 4
	replace f50c46 = f50c46 / 5
	replace f50c268 = f50c268 / 6
	replace f50c269 = f50c269 / 5
	replace f50c36 = f50c36 / 4
	replace f50c43 = f50c43 / 3
	replace f50c42 = f50c42 / 2
	replace f50c41 = f50c41 / 7
	replace f50c40 = f50c40 / 6
	replace f50c39 = f50c39 / 5
	replace f50c38 = f50c38 / 4
	replace f50c37 = f50c37 / 3
	replace f50c34 = f50c34 / 2
	replace f50c35 = f50c35 / 3
	replace f50c33 = f50c33 / 4
	replace f50c32 = f50c32 / 5
	replace f50c31 = f50c31 / 6
	replace f50c30 = f50c30 / 7
	replace f50c18 = f50c18 / 8
	replace f50c27 = f50c27 / 2
	replace f50c17 = f50c17 / 3
	replace f50c16 = f50c16 / 4
	replace f50c61 = f50c61 / 5
	replace f50c29 = f50c29 / 4
	replace f50c244 = f50c244 / 3
	replace f50c52 = f50c52 / 2
	replace f50c57 = f50c57 / 9
	replace f50c58 = f50c58 / 8
	replace f50c108 = f50c108 / 7
	replace f50c87 = f50c87 / 6
	replace f50c274 = f50c274 / 5
	replace f50c91 = f50c91 / 4
	replace f50c94 = f50c94 / 3
	replace f50c105 = f50c105 / 2
	replace f50c609 = f50c609 / 3
	replace f50c608 = f50c608 / 4
	replace f50c610 = f50c610 / 5
	replace f50c602 = f50c602 / 6
	replace f50c601 = f50c601 / 7
	replace f50c603 = f50c603 / 8
	replace f50c604 = f50c604 / 2
	replace f50c605 = f50c605 / 3
	replace f50c606 = f50c606 / 4
	replace f50c607 = f50c607 / 5
	replace f50c600 = f50c600 / 6
	replace f50c611 = f50c611 / 5
	replace f50c612 = f50c612 / 4
	replace f50c613 = f50c613 / 3
	replace f50c624 = f50c624 / 2
	replace f50c625 = f50c625 / 3

* Variable labels --------------------------------------------------------------
* Variable names correspond to different taxes, so this section labels them.

label var f50c10 "Dividends of permanent establishments (Taxable Base)"
*label var f50c130 "Dividends of permanent establishments (Determined Tax)"
*label var f50c88 "Dividends of permanent establishments (Credit Art. 63)"
label var f50c12 "Dividends of permanent establishments (Tax)"

label var f50c100 "Dividends of foreign stakeholders (Taxable Base)"
*label var f50c131 "Dividends of foreign stakeholders (Determined Tax)"
*label var f50c101 "Dividends of foreign stakeholders (Credit Art. 63)"
label var f50c102 "Dividends of foreign stakeholders (Tax)"

label var f50c103 "Overseas rent distributions (Taxable Base)"
*label var f50c136 "Overseas rent distributions (Determined Tax)"
*label var f50c104 "Overseas rent distributions (Credit Art. 63)"
label var f50c105 "Overseas rent distributions (Tax)"

label var f50c14 "Overseas remittances (Taxable Base)"
*label var f50c137 "Overseas remittances (Determined Tax)"
*label var f50c106 "Overseas remittances (Credit Art. 63)"
label var f50c300 "Overseas remittances (Tax)"

label var f50c61 "Overseas remittances, FUT (Taxable Base)"
*label var f50c138 "Overseas remittances, FUT (Determined Tax)"
*label var f50c107 "Overseas remittances, FUT (Credit Art. 63)"
label var f50c62 "Overseas remittances, FUT (Tax)"

label var f50c16 "Brand remunerations (Taxable Base)"
label var f50c17 "Brand remunerations (Tax)"

label var f50c18 "Patent remunerations (Taxable Base)"
label var f50c19 "Patent remunerations (Tax)"

label var f50c20 "Consulting remunerations (Taxable Base)"
label var f50c21 "Consulting remunerations (Tax)"

label var f50c22 "Formulae remunerations (Taxable Base)"
label var f50c23 "Formulae remunerations (Tax)"

label var f50c24 "Other benefits remunerations (Taxable Base)"
label var f50c25 "Other benefits remunerations (Tax)"

label var f50c600 "Patent remunerations, reduced rate (Taxable Base)"
label var f50c601 "Patent remunerations, reduced rate (Tax)"

label var f50c602 "Patent remunerations (Taxable Base)"
label var f50c603 "Patent remunerations (Tax)"

label var f50c604 "Computer programs remunerations, reduced rate (Taxable Base)"
label var f50c605 "Computer programs remunerations, reduced rate (Tax)"

label var f50c606 "Computer programs remunerations (Taxable Base)"
label var f50c607 "Computer programs remunerations (Tax)"

label var f50c26 "Cinema or TV exhibition remunerations (Taxable Base)"
label var f50c27 "Cinema or TV exhibition remunerations (Tax)"

label var f50c28 "Author or editor rights remunerations (Taxable Base)"
label var f50c29 "Author or editor rights remunerations (Tax)"

label var f50c30 "General interests (Taxable Base)"
label var f50c31 "General interests (Tax)"

label var f50c32 "Interests of deposits in foreign currency (Taxable Base)"
label var f50c33 "Interests of deposits in foreign currency (Tax)"

label var f50c34 "Interests of external credit (Taxable Base)"
label var f50c35 "Interests of external credit (Tax)"

label var f50c36 "Interests of admitted goods (Taxable Base)"
label var f50c37 "Interests of admitted goods (Tax)"

label var f50c38 "Interests of bonds or debentures in foreign currency (Taxable Base)"
label var f50c39 "Interests of bonds or debentures in foreign currency (Tax)"

label var f50c40 "Interests of government or CB securities (Taxable Base)"
label var f50c41 "Interests of government or CB securities (Tax)"

label var f50c42 "Interests of ALADI acceptances (Taxable Base)"
label var f50c43 "Interests of ALADI acceptances (Tax)"

label var f50c268 "Interests of c32, c38 and c40 in national currency (Taxable Base)"
label var f50c269 "Interests of c33, c39 and c41 in national currency (Tax)"

label var f50c244 "Foreign services remunerations (Taxable Base)"
label var f50c45 "Foreign services remunerations (Tax)" // jump is intentional

label var f50c608 "Engineering services remunerations, reduced rate (Taxable Base)"
label var f50c609 "Engineering services remunerations, reduced rate (Tax)"

label var f50c46 "Engineering services remunerations (Taxable Base)"
label var f50c47 "Engineering services remunerations (Tax)"

label var f50c48 "Technical consultancy remunerations (Taxable Base)"
label var f50c49 "Technical consultancy remunerations (Tax)"

label var f50c610 "Professional services remunerations, reduced rate (Taxable Base)"
label var f50c611 "Professional services remunerations, reduced rate (Tax)"

label var f50c612 "Professional services remunerations (Taxable Base)"
label var f50c613 "Professional services remunerations (Tax)"

label var f50c50 "Foreign company prime insurance (Taxable Base)"
label var f50c51 "Foreign company prime insurance (Tax)"

label var f50c52 "Foreign company prime reinsurance (Taxable Base)"
label var f50c254 "Foreign company prime reinsurance (Tax)" // jump is intentional

label var f50c54 "Freights, comissions and maritime holdings (Taxable Base)"
label var f50c55 "Freights, comissions and maritime holdings (Tax)"

label var f50c56 "Leasing and usufruct of foreign ships in cabotage (Taxable Base)"
label var f50c57 "Leasing and usufruct of foreign ships in cabotage (Tax)"

label var f50c58 "Leasing of imported capital goods (Taxable Base)"
label var f50c59 "Leasing of imported capital goods (Tax)"

label var f50c64 "Other revenues by non residents (Taxable Base)"
label var f50c65 "Other revenues by non residents (Tax)"

label var f50c108 "Foreign cientific activities revenues (Taxable Base)"
label var f50c109 "Foreign cientific activities revenues (Tax)"

label var f50c110 "Foreign technical activities revenues (Taxable Base)"
label var f50c111 "Foreign technical activities revenues (Tax)"

label var f50c267 "Foreign cultural activities revenues (Taxable Base)"
label var f50c68 "Foreign cultural activities revenues (Tax)" // jump is intentional

label var f50c83 "Foreign sports activities revenues (Taxable Base)"
label var f50c84 "Foreign sports activities revenues (Tax)"

label var f50c86 "National rents of chileans residents abroad (Taxable Base)"
label var f50c87 "National rents of chileans residents abroad (Tax)"

label var f50c272 "Tax withholdments on rent payments (Taxable Base)"
label var f50c273 "Tax withholdments on rent payments (Tax)"

label var f50c89 "Deductions from incomes subject to trade agreements (Rate)"
label var f50c95 "Deductions from incomes subject to trade agreements (Taxable Base)"
label var f50c96 "Deductions from incomes subject to trade agreements (Tax)"

label var f50c274 "Deductions from incomes subject to trade agreements (Rate)"
label var f50c275 "Deductions from incomes subject to trade agreements (Taxable Base)"
label var f50c276 "Deductions from incomes subject to trade agreements (Tax)"

label var f50c624 "Credit for donations to reconstructions funds (Taxable Base)"
label var f50c625 "Credit for donations to reconstructions funds (Tax)"

label var f50c91 "Total taxes paid"
*label var f50c92 "Total tax to pay + IPC"
*label var f50c93 "Total tax to pay + interests and fines"
label var f50c94 "Total taxes paid"
