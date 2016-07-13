*F1850 variable and value labels
********************************

* Key variable labels
label var f1850baseimponiblevo "Taxable base in CLP"
label var f1850imptoretenidovo "Tax witheld (payed in F50)"
label var f1850montoliquidovo "Amount payed to beneficiary"

* Type of rent value labels
label define typerent ///
6 "Real estate" ///
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
21 "Others"
label values f1850tiporentavo typerent
