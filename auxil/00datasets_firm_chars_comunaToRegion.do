*===============================================================================
* START
*===============================================================================
* Name: comunaToRegion
* Description: This is an auxiliary do file used in the do file that creates
* 	       the database of the transfer pricing project (Bustos, Pomeranz,
*	       Zucman 2015). It infers the region of a firm by using the 
*              "comuna" in which is located. We only do this to save space.
* Created: 20151022
* Updated: 
* Author: JI Elorrieta (ji.elorrieta@gmail.com)
* Last editor:
*-------------------------------------------------------------------------------
* I.1. Takes "comuna" SII code and infers region 
*-------------------------------------------------------------------------------
* We infer region (US equivalent: state) from "comuna" (US equivalent: sometimes 
* city, sometimes a subdivision of a city). The names of each "comuna" code can
* be found at https://zeus.sii.cl/avalu_cgi/br/brch10.sh. The conversion was 
* inferred manually.

	quietly {
		gen region = .
		
		replace region = 15 if comucodcomunaprincipal == 1101
		replace region = 15 if comucodcomunaprincipal == 1106
		replace region = 1 if comucodcomunaprincipal == 1201
		replace region = 1 if comucodcomunaprincipal == 1203
		replace region = 1 if comucodcomunaprincipal == 1204
		replace region = 1 if comucodcomunaprincipal == 1206
		replace region = 1 if comucodcomunaprincipal == 1208
		replace region = 1 if comucodcomunaprincipal == 1210
		replace region = 1 if comucodcomunaprincipal == 1211
		replace region = 15 if comucodcomunaprincipal == 1301
		replace region = 15 if comucodcomunaprincipal == 1302
		replace region = 2 if comucodcomunaprincipal == 2101
		replace region = 2 if comucodcomunaprincipal == 2103
		replace region = 2 if comucodcomunaprincipal == 2201
		replace region = 2 if comucodcomunaprincipal == 2202
		replace region = 2 if comucodcomunaprincipal == 2203
		replace region = 2 if comucodcomunaprincipal == 2206
		replace region = 2 if comucodcomunaprincipal == 2301
		replace region = 2 if comucodcomunaprincipal == 2302
		replace region = 2 if comucodcomunaprincipal == 2303
		replace region = 3 if comucodcomunaprincipal == 3101
		replace region = 3 if comucodcomunaprincipal == 3102
		replace region = 3 if comucodcomunaprincipal == 3201
		replace region = 3 if comucodcomunaprincipal == 3202
		replace region = 3 if comucodcomunaprincipal == 3203
		replace region = 3 if comucodcomunaprincipal == 3301
		replace region = 3 if comucodcomunaprincipal == 3302
		replace region = 3 if comucodcomunaprincipal == 3303
		replace region = 3 if comucodcomunaprincipal == 3304
		replace region = 4 if comucodcomunaprincipal == 4101
		replace region = 4 if comucodcomunaprincipal == 4102
		replace region = 4 if comucodcomunaprincipal == 4103
		replace region = 4 if comucodcomunaprincipal == 4104
		replace region = 4 if comucodcomunaprincipal == 4105
		replace region = 4 if comucodcomunaprincipal == 4106
		replace region = 4 if comucodcomunaprincipal == 4201
		replace region = 4 if comucodcomunaprincipal == 4203
		replace region = 4 if comucodcomunaprincipal == 4204
		replace region = 4 if comucodcomunaprincipal == 4205
		replace region = 4 if comucodcomunaprincipal == 4206
		replace region = 4 if comucodcomunaprincipal == 4301
		replace region = 4 if comucodcomunaprincipal == 4302
		replace region = 4 if comucodcomunaprincipal == 4303
		replace region = 4 if comucodcomunaprincipal == 4304
		replace region = 5 if comucodcomunaprincipal == 5101
		replace region = 5 if comucodcomunaprincipal == 5201
		replace region = 5 if comucodcomunaprincipal == 5202
		replace region = 5 if comucodcomunaprincipal == 5203
		replace region = 5 if comucodcomunaprincipal == 5204
		replace region = 5 if comucodcomunaprincipal == 5205
		replace region = 5 if comucodcomunaprincipal == 5301
		replace region = 5 if comucodcomunaprincipal == 5302
		replace region = 5 if comucodcomunaprincipal == 5303
		replace region = 5 if comucodcomunaprincipal == 5304
		replace region = 5 if comucodcomunaprincipal == 5305
		replace region = 5 if comucodcomunaprincipal == 5306
		replace region = 5 if comucodcomunaprincipal == 5307
		replace region = 5 if comucodcomunaprincipal == 5308
		replace region = 5 if comucodcomunaprincipal == 5309
		replace region = 5 if comucodcomunaprincipal == 5401
		replace region = 5 if comucodcomunaprincipal == 5402
		replace region = 5 if comucodcomunaprincipal == 5403
		replace region = 5 if comucodcomunaprincipal == 5404
		replace region = 5 if comucodcomunaprincipal == 5405
		replace region = 5 if comucodcomunaprincipal == 5406
		replace region = 5 if comucodcomunaprincipal == 5501
		replace region = 5 if comucodcomunaprincipal == 5502
		replace region = 5 if comucodcomunaprincipal == 5503
		replace region = 5 if comucodcomunaprincipal == 5504
		replace region = 5 if comucodcomunaprincipal == 5505
		replace region = 5 if comucodcomunaprincipal == 5506
		replace region = 5 if comucodcomunaprincipal == 5507
		replace region = 5 if comucodcomunaprincipal == 5601
		replace region = 5 if comucodcomunaprincipal == 5602
		replace region = 5 if comucodcomunaprincipal == 5603
		replace region = 5 if comucodcomunaprincipal == 5604
		replace region = 5 if comucodcomunaprincipal == 5605
		replace region = 5 if comucodcomunaprincipal == 5606
		replace region = 5 if comucodcomunaprincipal == 5701
		replace region = 5 if comucodcomunaprincipal == 5702
		replace region = 5 if comucodcomunaprincipal == 5703
		replace region = 5 if comucodcomunaprincipal == 5704
		replace region = 6 if comucodcomunaprincipal == 6101
		replace region = 6 if comucodcomunaprincipal == 6102
		replace region = 6 if comucodcomunaprincipal == 6103
		replace region = 6 if comucodcomunaprincipal == 6104
		replace region = 6 if comucodcomunaprincipal == 6105
		replace region = 6 if comucodcomunaprincipal == 6106
		replace region = 6 if comucodcomunaprincipal == 6107
		replace region = 6 if comucodcomunaprincipal == 6108
		replace region = 6 if comucodcomunaprincipal == 6109
		replace region = 6 if comucodcomunaprincipal == 6110
		replace region = 6 if comucodcomunaprincipal == 6111
		replace region = 6 if comucodcomunaprincipal == 6112
		replace region = 6 if comucodcomunaprincipal == 6113
		replace region = 6 if comucodcomunaprincipal == 6114
		replace region = 6 if comucodcomunaprincipal == 6115
		replace region = 6 if comucodcomunaprincipal == 6116
		replace region = 6 if comucodcomunaprincipal == 6117
		replace region = 6 if comucodcomunaprincipal == 6201
		replace region = 6 if comucodcomunaprincipal == 6202
		replace region = 6 if comucodcomunaprincipal == 6203
		replace region = 6 if comucodcomunaprincipal == 6204
		replace region = 6 if comucodcomunaprincipal == 6205
		replace region = 6 if comucodcomunaprincipal == 6206
		replace region = 6 if comucodcomunaprincipal == 6207
		replace region = 6 if comucodcomunaprincipal == 6208
		replace region = 6 if comucodcomunaprincipal == 6209
		replace region = 6 if comucodcomunaprincipal == 6214
		replace region = 6 if comucodcomunaprincipal == 6301
		replace region = 6 if comucodcomunaprincipal == 6302
		replace region = 6 if comucodcomunaprincipal == 6303
		replace region = 6 if comucodcomunaprincipal == 6304
		replace region = 6 if comucodcomunaprincipal == 6305
		replace region = 6 if comucodcomunaprincipal == 6306
		replace region = 7 if comucodcomunaprincipal == 7101
		replace region = 7 if comucodcomunaprincipal == 7102
		replace region = 7 if comucodcomunaprincipal == 7103
		replace region = 7 if comucodcomunaprincipal == 7104
		replace region = 7 if comucodcomunaprincipal == 7105
		replace region = 7 if comucodcomunaprincipal == 7106
		replace region = 7 if comucodcomunaprincipal == 7107
		replace region = 7 if comucodcomunaprincipal == 7108
		replace region = 7 if comucodcomunaprincipal == 7109
		replace region = 7 if comucodcomunaprincipal == 7201
		replace region = 7 if comucodcomunaprincipal == 7202
		replace region = 7 if comucodcomunaprincipal == 7203
		replace region = 7 if comucodcomunaprincipal == 7204
		replace region = 7 if comucodcomunaprincipal == 7205
		replace region = 7 if comucodcomunaprincipal == 7206
		replace region = 7 if comucodcomunaprincipal == 7207
		replace region = 7 if comucodcomunaprincipal == 7208
		replace region = 7 if comucodcomunaprincipal == 7209
		replace region = 7 if comucodcomunaprincipal == 7210
		replace region = 7 if comucodcomunaprincipal == 7301
		replace region = 7 if comucodcomunaprincipal == 7302
		replace region = 7 if comucodcomunaprincipal == 7303
		replace region = 7 if comucodcomunaprincipal == 7304
		replace region = 7 if comucodcomunaprincipal == 7305
		replace region = 7 if comucodcomunaprincipal == 7306
		replace region = 7 if comucodcomunaprincipal == 7309
		replace region = 7 if comucodcomunaprincipal == 7310
		replace region = 7 if comucodcomunaprincipal == 7401
		replace region = 7 if comucodcomunaprincipal == 7402
		replace region = 7 if comucodcomunaprincipal == 7403
		replace region = 8 if comucodcomunaprincipal == 8101
		replace region = 8 if comucodcomunaprincipal == 8102
		replace region = 8 if comucodcomunaprincipal == 8103
		replace region = 8 if comucodcomunaprincipal == 8104
		replace region = 8 if comucodcomunaprincipal == 8105
		replace region = 8 if comucodcomunaprincipal == 8106
		replace region = 8 if comucodcomunaprincipal == 8107
		replace region = 8 if comucodcomunaprincipal == 8108
		replace region = 8 if comucodcomunaprincipal == 8109
		replace region = 8 if comucodcomunaprincipal == 8110
		replace region = 8 if comucodcomunaprincipal == 8111
		replace region = 8 if comucodcomunaprincipal == 8112
		replace region = 8 if comucodcomunaprincipal == 8113
		replace region = 8 if comucodcomunaprincipal == 8114
		replace region = 8 if comucodcomunaprincipal == 8115
		replace region = 8 if comucodcomunaprincipal == 8116
		replace region = 8 if comucodcomunaprincipal == 8117
		replace region = 8 if comucodcomunaprincipal == 8118
		replace region = 8 if comucodcomunaprincipal == 8119
		replace region = 8 if comucodcomunaprincipal == 8120
		replace region = 8 if comucodcomunaprincipal == 8121
		replace region = 8 if comucodcomunaprincipal == 8201
		replace region = 8 if comucodcomunaprincipal == 8202
		replace region = 8 if comucodcomunaprincipal == 8203
		replace region = 8 if comucodcomunaprincipal == 8204
		replace region = 8 if comucodcomunaprincipal == 8205
		replace region = 8 if comucodcomunaprincipal == 8206
		replace region = 8 if comucodcomunaprincipal == 8207
		replace region = 8 if comucodcomunaprincipal == 8208
		replace region = 8 if comucodcomunaprincipal == 8209
		replace region = 8 if comucodcomunaprincipal == 8210
		replace region = 8 if comucodcomunaprincipal == 8211
		replace region = 8 if comucodcomunaprincipal == 8212
		replace region = 8 if comucodcomunaprincipal == 8301
		replace region = 8 if comucodcomunaprincipal == 8302
		replace region = 8 if comucodcomunaprincipal == 8303
		replace region = 8 if comucodcomunaprincipal == 8304
		replace region = 8 if comucodcomunaprincipal == 8305
		replace region = 8 if comucodcomunaprincipal == 8306
		replace region = 8 if comucodcomunaprincipal == 8307
		replace region = 8 if comucodcomunaprincipal == 8401
		replace region = 8 if comucodcomunaprincipal == 8402
		replace region = 8 if comucodcomunaprincipal == 8403
		replace region = 8 if comucodcomunaprincipal == 8404
		replace region = 8 if comucodcomunaprincipal == 8405
		replace region = 8 if comucodcomunaprincipal == 8406
		replace region = 8 if comucodcomunaprincipal == 8407
		replace region = 8 if comucodcomunaprincipal == 8408
		replace region = 8 if comucodcomunaprincipal == 8409
		replace region = 8 if comucodcomunaprincipal == 8410
		replace region = 8 if comucodcomunaprincipal == 8411
		replace region = 8 if comucodcomunaprincipal == 8412
		replace region = 8 if comucodcomunaprincipal == 8413
		replace region = 8 if comucodcomunaprincipal == 8414
		replace region = 9 if comucodcomunaprincipal == 9101
		replace region = 9 if comucodcomunaprincipal == 9102
		replace region = 9 if comucodcomunaprincipal == 9103
		replace region = 9 if comucodcomunaprincipal == 9104
		replace region = 9 if comucodcomunaprincipal == 9105
		replace region = 9 if comucodcomunaprincipal == 9106
		replace region = 9 if comucodcomunaprincipal == 9107
		replace region = 9 if comucodcomunaprincipal == 9108
		replace region = 9 if comucodcomunaprincipal == 9109
		replace region = 9 if comucodcomunaprincipal == 9110
		replace region = 9 if comucodcomunaprincipal == 9111
		replace region = 9 if comucodcomunaprincipal == 9201
		replace region = 9 if comucodcomunaprincipal == 9202
		replace region = 9 if comucodcomunaprincipal == 9203
		replace region = 9 if comucodcomunaprincipal == 9204
		replace region = 9 if comucodcomunaprincipal == 9205
		replace region = 9 if comucodcomunaprincipal == 9206
		replace region = 9 if comucodcomunaprincipal == 9207
		replace region = 9 if comucodcomunaprincipal == 9208
		replace region = 9 if comucodcomunaprincipal == 9209
		replace region = 9 if comucodcomunaprincipal == 9210
		replace region = 9 if comucodcomunaprincipal == 9211
		replace region = 9 if comucodcomunaprincipal == 9212
		replace region = 9 if comucodcomunaprincipal == 9213
		replace region = 9 if comucodcomunaprincipal == 9214
		replace region = 9 if comucodcomunaprincipal == 9215
		replace region = 9 if comucodcomunaprincipal == 9216
		replace region = 9 if comucodcomunaprincipal == 9217
		replace region = 9 if comucodcomunaprincipal == 9218
		replace region = 9 if comucodcomunaprincipal == 9219
		replace region = 9 if comucodcomunaprincipal == 9220
		replace region = 9 if comucodcomunaprincipal == 9221
		replace region = 14 if comucodcomunaprincipal == 10101
		replace region = 14 if comucodcomunaprincipal == 10102
		replace region = 14 if comucodcomunaprincipal == 10103
		replace region = 14 if comucodcomunaprincipal == 10104
		replace region = 14 if comucodcomunaprincipal == 10105
		replace region = 14 if comucodcomunaprincipal == 10106
		replace region = 14 if comucodcomunaprincipal == 10107
		replace region = 14 if comucodcomunaprincipal == 10108
		replace region = 14 if comucodcomunaprincipal == 10109
		replace region = 14 if comucodcomunaprincipal == 10110
		replace region = 14 if comucodcomunaprincipal == 10111
		replace region = 14 if comucodcomunaprincipal == 10112
		replace region = 10 if comucodcomunaprincipal == 10201
		replace region = 10 if comucodcomunaprincipal == 10202
		replace region = 10 if comucodcomunaprincipal == 10203
		replace region = 10 if comucodcomunaprincipal == 10204
		replace region = 10 if comucodcomunaprincipal == 10205
		replace region = 10 if comucodcomunaprincipal == 10206
		replace region = 10 if comucodcomunaprincipal == 10207
		replace region = 10 if comucodcomunaprincipal == 10301
		replace region = 10 if comucodcomunaprincipal == 10302
		replace region = 10 if comucodcomunaprincipal == 10303
		replace region = 10 if comucodcomunaprincipal == 10304
		replace region = 10 if comucodcomunaprincipal == 10305
		replace region = 10 if comucodcomunaprincipal == 10306
		replace region = 10 if comucodcomunaprincipal == 10307
		replace region = 10 if comucodcomunaprincipal == 10308
		replace region = 10 if comucodcomunaprincipal == 10309
		replace region = 10 if comucodcomunaprincipal == 10401
		replace region = 10 if comucodcomunaprincipal == 10402
		replace region = 10 if comucodcomunaprincipal == 10403
		replace region = 10 if comucodcomunaprincipal == 10404
		replace region = 10 if comucodcomunaprincipal == 10405
		replace region = 10 if comucodcomunaprincipal == 10406
		replace region = 10 if comucodcomunaprincipal == 10407
		replace region = 10 if comucodcomunaprincipal == 10408
		replace region = 10 if comucodcomunaprincipal == 10410
		replace region = 10 if comucodcomunaprincipal == 10415
		replace region = 10 if comucodcomunaprincipal == 10501
		replace region = 10 if comucodcomunaprincipal == 10502
		replace region = 10 if comucodcomunaprincipal == 10503
		replace region = 10 if comucodcomunaprincipal == 10504
		replace region = 11 if comucodcomunaprincipal == 11101
		replace region = 11 if comucodcomunaprincipal == 11102
		replace region = 11 if comucodcomunaprincipal == 11104
		replace region = 11 if comucodcomunaprincipal == 11201
		replace region = 11 if comucodcomunaprincipal == 11203
		replace region = 11 if comucodcomunaprincipal == 11301
		replace region = 11 if comucodcomunaprincipal == 11302
		replace region = 11 if comucodcomunaprincipal == 11303
		replace region = 11 if comucodcomunaprincipal == 11401
		replace region = 11 if comucodcomunaprincipal == 11402
		replace region = 12 if comucodcomunaprincipal == 12101
		replace region = 12 if comucodcomunaprincipal == 12103
		replace region = 12 if comucodcomunaprincipal == 12202
		replace region = 12 if comucodcomunaprincipal == 12204
		replace region = 12 if comucodcomunaprincipal == 12205
		replace region = 12 if comucodcomunaprincipal == 12206
		replace region = 12 if comucodcomunaprincipal == 12301
		replace region = 12 if comucodcomunaprincipal == 12302
		replace region = 12 if comucodcomunaprincipal == 12304
		replace region = 12 if comucodcomunaprincipal == 12401
		replace region = 13 if comucodcomunaprincipal == 13101
		replace region = 13 if comucodcomunaprincipal == 13134
		replace region = 13 if comucodcomunaprincipal == 13135
		replace region = 13 if comucodcomunaprincipal == 13159
		replace region = 13 if comucodcomunaprincipal == 13167
		replace region = 13 if comucodcomunaprincipal == 14107
		replace region = 13 if comucodcomunaprincipal == 14109
		replace region = 13 if comucodcomunaprincipal == 14111
		replace region = 13 if comucodcomunaprincipal == 14113
		replace region = 13 if comucodcomunaprincipal == 14114
		replace region = 13 if comucodcomunaprincipal == 14127
		replace region = 13 if comucodcomunaprincipal == 14155
		replace region = 13 if comucodcomunaprincipal == 14156
		replace region = 13 if comucodcomunaprincipal == 14157
		replace region = 13 if comucodcomunaprincipal == 14158
		replace region = 13 if comucodcomunaprincipal == 14166
		replace region = 13 if comucodcomunaprincipal == 14201
		replace region = 13 if comucodcomunaprincipal == 14202
		replace region = 13 if comucodcomunaprincipal == 14203
		replace region = 13 if comucodcomunaprincipal == 14501
		replace region = 13 if comucodcomunaprincipal == 14502
		replace region = 13 if comucodcomunaprincipal == 14503
		replace region = 13 if comucodcomunaprincipal == 14504
		replace region = 13 if comucodcomunaprincipal == 14505
		replace region = 13 if comucodcomunaprincipal == 14601
		replace region = 13 if comucodcomunaprincipal == 14602
		replace region = 13 if comucodcomunaprincipal == 14603
		replace region = 13 if comucodcomunaprincipal == 14604
		replace region = 13 if comucodcomunaprincipal == 14605
		replace region = 13 if comucodcomunaprincipal == 15103
		replace region = 13 if comucodcomunaprincipal == 15105
		replace region = 13 if comucodcomunaprincipal == 15108
		replace region = 13 if comucodcomunaprincipal == 15128
		replace region = 13 if comucodcomunaprincipal == 15132
		replace region = 13 if comucodcomunaprincipal == 15151
		replace region = 13 if comucodcomunaprincipal == 15152
		replace region = 13 if comucodcomunaprincipal == 15160
		replace region = 13 if comucodcomunaprincipal == 15161
		replace region = 13 if comucodcomunaprincipal == 16106
		replace region = 13 if comucodcomunaprincipal == 16110
		replace region = 13 if comucodcomunaprincipal == 16131
		replace region = 13 if comucodcomunaprincipal == 16153
		replace region = 13 if comucodcomunaprincipal == 16154
		replace region = 13 if comucodcomunaprincipal == 16162
		replace region = 13 if comucodcomunaprincipal == 16163
		replace region = 13 if comucodcomunaprincipal == 16164
		replace region = 13 if comucodcomunaprincipal == 16165
		replace region = 13 if comucodcomunaprincipal == 16301
		replace region = 13 if comucodcomunaprincipal == 16302
		replace region = 13 if comucodcomunaprincipal == 16303
		replace region = 13 if comucodcomunaprincipal == 16401
		replace region = 13 if comucodcomunaprincipal == 16402
		replace region = 13 if comucodcomunaprincipal == 16403
		replace region = 13 if comucodcomunaprincipal == 16404
	}
	
	# delimit ;
	label define region_names
	1 "Tarapaca"
	2 "Antofagasta"
	3 "Atacama"
	4 "Coquimbo"
	5 "Valparaiso"
	6 "O'Higgins"
	7 "Maule"
	8 "Biobio"
	9 "Araucania"
	10 "Los Lagos"
	11 "Aisen"
	12 "Magallanes"
	13 "Santiago"
	14 "Los Rios"
	15 "Arica y Parinacota",
	replace;
	#delimit cr
	
	label values region region_names
	
	label var region "Region"
*===============================================================================
* END
*===============================================================================
