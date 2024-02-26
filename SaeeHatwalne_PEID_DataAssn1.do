*Saee Hatwalne
*Political Economy of International Development
*Data Assignment 1
*February 2024
*------------------------------------------------------------------------------
cd "/Users/saeehatwalne/Desktop/APU 2023-25/PE Intl Dev/data_assn1_PEID"
clear
use "maddison_coldata_merged.dta"

*Q1.1 Line plot of GDPPC of India and the UK since 1500
twoway (line gdppc year if country == "India" & year >= 1500, lcolor(green) lpattern(dash)) ///
       (line gdppc year if country == "United Kingdom" & year >= 1500), ///
       xtitle("Year") ytitle("GDP per capita") ///
       legend(order(1 "India" 2 "United Kingdom")) ///
       title("GDP per capita of India and the UK since 1500") ///
       name(line_plot, replace)
	   //graph export first_lineplot.png, replace

	   
*Q1.2 Line plot of divergence - divergence is the ratio India's GDPPC to UK's GDPPC
keep year gdppc countrycode pop
keep if countrycode == "IND" | countrycode == "GBR"
//reshape to wide format, since the current long format was not intuitive to work with
reshape wide gdppc pop, i(year) j(countrycode) string 
drop if year < 1500 //condition given
//population in thousands given
gen gdpIND = gdppcIND*popIND*1000 // GDP = GDP per capita * population
gen gdpGBR = gdppcGBR*popGBR*1000
gen divergence_ratio = gdpIND/gdpGBR
//plotting
twoway (line divergence year), ///
    title("Divergence (India GDP divided by British GDP) since 1500") ///
    xtitle("Year") ytitle("Divergence") ///
    name(divergence_plot, replace)


*Q1.3 Creating world regions
clear
use "maddison_coldata_merged.dta"
tab country //tabulation of countries - in order to check which countries are present
gen region = "" //generating new column
replace region = "WE" if inlist(country, "United Kingdom", "France", "Germany", "Netherlands","Belgium")
replace region = "SE" if inlist(country, "Italy", "Spain", "Portugal","Greece")
replace region = "LA" if inlist(country, "Argentina", "Brazil", "Bolivia", "Chile")
replace region = "LA" if inlist(country,"Colombia", "Costa Rica", "Cuba", "Ecuador", "Peru")
replace region = "LA" if inlist(country, "Haiti" "Jamaica","Mexico","El Salvador", "Trinidad & Tobago","Barbados")
replace region = "SSA" if inlist(country, "Angola", "Benin", "Botswana", "Burkina Faso")
replace region = "SSA" if inlist(country, "Burundi", "Cameroon", "Central African Republic")
replace region = "SSA" if inlist(country, "Chad", "Congo - Brazzaville", "Congo - Kinshasa")
replace region = "SSA" if inlist(country,"Ethiopia", "Gabon", "Gambia", "Ghana", "Kenya")
replace region = "SSA" if inlist(country,"Liberia", "Mali", "Malawi","Mozambique", "Niger")
replace region = "SSA" if inlist(country,"Nigeria", "Rwanda", "Senegal", "Sierra Leone", "Liberia")
replace region = "SSA" if inlist(country,"South Africa", "Uganda", "Zambia", "Zimbabwe")
replace region = "SA" if inlist(country, "India", "Nepal", "Sri Lanka","Pakistan")
replace region = "SA" if inlist(country, "Bangladesh")
replace region = "ESEA" if inlist(country, "China", "Indonesia", "Malaysia", "Philippines","Singapore")
replace region = "ESEA" if inlist(country, "South Korea", "Thailand","Vietnam")
replace region = "MENA" if inlist(country,"Lebanon", "Turkey", "Morocco","Libya","Iraq", "Iran")
replace region = "MENA" if inlist(country,"Egypt", "Algeria")
replace region = "EO" if inlist(country, "United States", "Australia","Canada","New Zealand")
drop if missing(region)
save "maddison_coldata_merged_regions.dta", replace //saving this data with the regions created, it will be useful later


*Q1.4 Average GDP per capita within each region over time since 1500 CE.
*one way to do it
clear
use "maddison_coldata_merged_regions.dta"
br
egen region_avg_gdppc = mean(gdppc), by(region year)
sort region year
twoway (line region_avg_gdppc year if region == "WE" & year > 1500) ///
       (line region_avg_gdppc year if region == "LA" & year > 1500) ///
       (line region_avg_gdppc year if region == "MENA" & year > 1500) ///
       (line region_avg_gdppc year if region == "SE" & year > 1500) ///
       (line region_avg_gdppc year if region == "ESEA" & year > 1500) ///
       (line region_avg_gdppc year if region == "EO" & year > 1500) ///
       (line region_avg_gdppc year if region == "SSA" & year > 1500) ///
       (line region_avg_gdppc year if region == "SA" & year > 1500), ///
       title("Region-wise Average GDP per capita since 1500") ///
       xtitle("Year") ytitle("GDP per Capita") ///
       legend(order(1 "Western Europe" 2 "Latin America" 3 "Middle East and North Africa" 4 "Southern Europe" 5 "East and South East Asia" 6 "European offshoots" 7 "Sub Saharan Africa" 8 "South Asia")) ///
       name(region_avg_gdppc_plot, replace)
*another way to do Q1.4
// clear
// use "maddison_coldata_merged_regions.dta"
// collapse (mean) gdppc, by(year region) //collapsing the mean and then reshaping the data to wide
// save "collapsed_data.dta", replace
// clear
// use "collapsed_data.dta"
// reshape wide gdppc, i(year) j(region) string
// twoway (line gdppcWE year if year > 1500) ///
//        ||(line gdppcLA year if year > 1500) ///
// 	   || (line gdppcSE year if year > 1500) ///
// 	   || (line gdppcEO year if year > 1500)  ///
// 	   || (line gdppcESEA year if year > 1500) ///
// 	   || (line gdppcMENA year if year > 1500) ///
// 	   || (line gdppcSA year if year > 1500) ///
// 	   || (line gdppcSSA year if year > 1500), ///
//        title("Region-wise Average GDP per Capita over Time") ///
//        xtitle("Year") ytitle("GDP per Capita") ///
//        legend(order(1 "WE" 2 "LA" 3 "MENA" 4 "SE" 5 "ESEA" 6 "EO" 7 "SSA" 8 "SA")) ///
//        name(region_avg_gdppc_plot, replace)


*Q1.5 Share of world GDP accounted by each region over time 
gen GDP = gdppc * pop * 1000 //making the GDP column, populations in thousands
collapse (sum) GDP, by(year region) //summing up the GDP by year and region
reshape wide GDP, i(year) j(region) string //wide format, since it is better to work with in this case
keep if year > 1500 //for simplicity and mostly there are missing values before 1500
//row total to get addition of GDP of all regions to get world GDP for each year
egen worldGDP = rowtotal(GDPEO GDPESEA GDPLA GDPMENA GDPSA GDPSE GDPSSA GDPWE)
gen shareEO = GDPEO/worldGDP
gen shareWE = GDPWE/worldGDP
gen shareLA = GDPLA/worldGDP
gen shareMENA = GDPMENA/worldGDP
gen shareSE = GDPSE/worldGDP
gen shareESEA = GDPESEA/worldGDP
gen shareSSA = GDPSSA/worldGDP
gen shareSA = GDPSA/worldGDP
gen shareWORLD = worldGDP/worldGDP
//to create the area plot - we want to make it stacked, so cumulative sums of shares taken
//so that when it is plotted, it won't overlap
gen sum2 = shareEO + shareWE
gen sum3 = sum2 + shareLA
gen sum4 = sum3 + shareMENA
gen sum5 = sum4 + shareSA
gen sum6 = sum5 + shareSE
gen sum7 = sum6 + shareSSA
gen sum8 = sum7 + shareESEA
//plotting with the function rarea
//all shares are adding up to 1 i.e. 100% i.e. world GDP
twoway (area shareEO year) ///
       (rarea shareEO sum2 year) ///
       (rarea sum2 sum3 year) ///
       (rarea sum3 sum4 year) ///
       (rarea sum4 sum5 year) ///
       (rarea sum5 sum6 year) ///
       (rarea sum6 sum7 year) ///
       (rarea sum7 sum8 year), ///
       legend(order(1 "shareEO" 2 "shareWE" 3 "shareLA" 4 "shareMENA" 5 "shareSA" ///
                     6 "shareSE" 7 "shareSSA" 8 "shareESEA")) ///
       title("Stacked Area Graph of Shares of GDP of regions") ///
       xtitle("Year") ytitle("Share") ///
       ylabel(, angle(horizontal)) ///
       name(stacked_area_graph, replace)
*or bar graph - discrete
// graph bar shareEO shareWE shareLA shareMENA shareSE shareESEA shareSSA shareSA, over(year) stack


*Q1.6 GDP per capita in Western Europe, Southern Europe and European offshoots over time from 1500-1900
clear
use "maddison_coldata_merged.dta"
*For European offshoot countries
twoway (line gdppc year if country == "United States" & year >= 1500 & year <= 1900, lcolor(green)) ///
       (line gdppc year if country == "New Zealand" & year >= 1500  & year <= 1900, lcolor(blue)) ///
       (line gdppc year if country == "Australia" & year >= 1500  & year <= 1900, lcolor(red)) ///
       (line gdppc year if country == "Canada" & year >= 1500  & year <= 1900, lcolor(purple)), ///
       title("GDP per capita over time for European Offshoots") ///
       xtitle("Year") ytitle("GDP per capita") ///
       legend(order(1 "United States" 2 "New Zealand" 3 "Australia" 4 "Canada")) ///
       name(gdppc_over_time_EO_countries, replace)
	   graph save gdppc_over_time_EO_countries, replace
*For Southern European countries	   
twoway (line gdppc year if country == "Italy" & year >= 1500  & year <= 1900, lcolor(blue)) ///
       (line gdppc year if country == "Spain" & year >= 1500  & year <= 1900, lcolor(red)) ///
       (line gdppc year if country == "Portugal" & year >= 1500 & year <= 1900, lcolor(green)) ///
       (line gdppc year if country == "Greece" & year >= 1500 & year <= 1900, lcolor(purple)), ///
       title("GDP per capita over time for Southern European countries") ///
       xtitle("Year") ytitle("GDP per capita") ///
       legend(order(1 "Italy" 2 "Spain" 3 "Portugal" 4 "Greece")) ///
       name(gdppc_over_time_SE_countries, replace)
	   graph save gdppc_over_time_SE_countries, replace
*For Western European countries
twoway (line gdppc year if country == "United Kingdom" & year >= 1500  & year <= 1900, lcolor(blue)) ///
       (line gdppc year if country == "France" & year >= 1500  & year <= 1900, lcolor(red)) ///
       (line gdppc year if country == "Germany" & year >= 1500  & year <= 1900, lcolor(green)) ///
       (line gdppc year if country == "Netherlands" & year >= 1500  & year <= 1900, lcolor(purple)) ///
       (line gdppc year if country == "Belgium" & year >= 1500  & year <= 1900, lcolor(orange)), ///
       title("GDP per capita over time for Western European countries") ///
       xtitle("Year") ytitle("GDP per capita") ///
       legend(order(1 "United Kingdom" 2 "France" 3 "Germany" 4 "Netherlands" 5 "Belgium")) ///
       name(gdppc_over_time_WE_countries, replace)
	   graph save gdppc_over_time_WE_countries, replace
*Combining the above three graphs
graph combine gdppc_over_time_EO_countries.gph ///
              gdppc_over_time_SE_countries.gph ///
              gdppc_over_time_WE_countries.gph, ///
              col(1) xcommon ycommon
			  graph save WE_SE_EO_graphs, replace
	  
*-------------------------------------------------------------------------------
*Question2 Estimating the impact of colonialism on today's GDP per capita
clear
//using the other dataset provided
use "/Users/saeehatwalne/Desktop/APU 2023-25/PE Intl Dev/data_assn1_PEID/madison_coldat_small.dta"
*general
gen gdpgap = gdppc/col_gdppc //creating variable for GDP ga
gen ln_gdppc = ln(gdppc) //take the natural log and creating another variable for it
describe colonizer
encode colonizer, generate(colonizer_n) //creating categorical variable for colonizer and coding it

*Q2.1 Regress log GDP per capita for 2018 on the variable colonizer
//Limit your analysis to countries which have been colonized and which have a GDP gap (ratio less than 1).
//countries taken only where a colonizer was present, hence dropped if colonizer is missing
//countries taken for which gdp gap < 1 as mentioned
regress ln_gdppc i.colonizer_n if year == 2018 & gdpgap<1 & !missing(colonizer)
eststo reg1
esttab reg1, r r2
esttab reg1 using "reg1.tex", title("reg1") replace
*Q2.2 Regress gdpgap for 2018 on variable colonizer
eststo: regress gdpgap i.colonizer_n if year == 2018 & gdpgap<1 & !missing(colonizer)
eststo reg2
esttab reg2, r r2
esttab reg2 using "reg2.tex", title("reg2") replace

*Q2.3 To the above two models, now add the variable the measures the duration of colonial rule.
//duration of colonial rule added to Q2.1
regress ln_gdppc i.colonizer_n col_duration if year == 2018 & gdpgap<1 & !missing(colonizer)
eststo reg3
esttab reg3, r r2
esttab reg3 using "reg3.tex", title("reg3") replace
//duration of colonial rule added to Q2.2
regress gdpgap i.colonizer_n col_duration if year == 2018 & gdpgap<1 & !missing(colonizer)
eststo reg4
esttab reg4, r r2
esttab reg4 using "reg4.tex", title("reg4") replace
//combined regression table for the four regressions
estout
esttab reg1 reg2 reg3 reg4 using "regressions.tex", r2 ar2 p replace
asdoc esttab reg1 reg2 reg3 reg4, r2 ar2 replace

*Q2.4 Draw overlapping histograms of the GDP gap for Britain, France, Spain and Portugal. Also draw a similar histogram for the duration of colonialism
*GDP gap and colonizer
twoway (histogram gdpgap if colonizer == "Britain", color(blue)) ///
       (histogram gdpgap if colonizer == "France", color(red)) ///
       (histogram gdpgap if colonizer == "Spain", color(orange)) ///
       (histogram gdpgap if colonizer == "Portugal", color(green)), ///
       title("GDP gap histogram for colonizers Britain, France, Spain and Portugal") ///
       legend(order(1 "Britain" 2 "France" 3 "Spain" 4 "Portugal")) ///
       name(gdpgap_histogram_colonizers, replace)
	   graph save GDPgap_hist, replace
	   graph export GDPgap_histogram.png, replace

*Duration of colonialism and colonizer
twoway (histogram col_duration if colonizer == "Britain", color(blue)) ///
       (histogram col_duration if colonizer == "France", color(red)) ///
       (histogram col_duration if colonizer == "Spain", color(orange)) ///
       (histogram col_duration if colonizer == "Portugal", color(green)), ///
       title("Colonial Duration Histogram for Britain, France, Spain, and Portugal") ///
       legend(order(1 "Britain" 2 "France" 3 "Spain" 4 "Portugal")) ///
       name(col_duration_histogram, replace)
	   graph export colduration_histogram.png, replace
  
	   
*Q2.5 Draw a scatter plot of duration of colonialism on the X axis and the GDP gap in the Y axis
// scatter gdpgap col_duration
twoway (scatter gdpgap col_duration), ///
       title("Scatter Plot of Colonial Duration and GDP Gap") ///
       xtitle("Colonial Duration") ytitle("GDP Gap") ///
	   name(scatter_colduration_gdpgap, replace)
	   graph export scatter_colduration_gdpgap.png, replace
	   
	   
