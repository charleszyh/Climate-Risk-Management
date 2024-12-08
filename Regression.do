*-------Set Working Directory-------*
{
global root /Users/charles/Library/CloudStorage/OneDrive-Personal/1_Study/0_毕业论文/5_Reg

global financial "$root//1_data/1_financial"	

global results "$root//2_results"
}

cd $root

*-------PRE PROCESS-------*

clear all

import excel "$financial/Yraw.xlsx", firstrow


*声明面板数据索引
xtset id time

gen cef_fwd = f.cef
gen rnd_fwd = f.rnd

save "$financial/Yraw.dta", replace

*-------CEF~TYPH & RND~TYPH-------*
clear all

*导入excel文件

use "$financial/Yraw.dta"

global x "typh ln_size roa lev beta bm"

reghdfe cef_fwd $x, absorb(id time)
reghdfe cef_fwd $x, absorb(id time) cluster(id) // CLUSTER high-dimension fixed effect
*esttab using "$results/ybase_cef.tex", replace booktabs label

reghdfe cef $x, absorb(id time) //high-dimension fixed effect

gen typh_lag = L.typh


reghdfe rnd_fwd $x, absorb(id time) //high-dimension fixed effect
reghdfe rnd $x, absorb(id time) //high-dimension fixed effect



*-------CEF~TYPH WINS-------*

*-------CEF 99%-------*

clear all

use "$financial/Yraw.dta"

winsor2 cef_fwd, replace cuts(1 99) trim

global x "typh ln_size roa lev beta bm"

reghdfe cef_fwd $x, absorb(id time)
reghdfe cef_fwd $x, absorb(id time) cluster(id) // CLUSTER high-dimension fixed effect

reghdfe  $x, absorb(id time) //high-dimension fixed effect


*------- ALL 99%-------*

clear all

use "$financial/Yraw.dta"

winsor2  cef_fwd ln_size roa lev beta bm, replace cuts(1 99) trim

reghdfe cef_fwd $x, absorb(id time)
reghdfe cef_fwd $x, absorb(id time) cluster(id) //CLUSTER high-dimension fixed effect





*-------异质性回归-------*
*-------国企非国企-------*
clear all

use "$financial/Yraw.dta"

winsor2  cef_fwd ln_size roa lev beta bm, replace cuts(1 99) trim

reghdfe cef_fwd $x if soe == 1 , absorb(id time) 
reghdfe cef_fwd $x if soe == 1, absorb(id time) cluster(id) //CLUSTER high-dimension fixed effect

reghdfe cef_fwd $x if soe == 0 , absorb(id time) 
reghdfe cef_fwd $x if soe == 0, absorb(id time) cluster(id) //CLUSTER high-dimension fixed effect

*-------分行业-------*
**不CLUSTER的版本**
reghdfe cef_fwd $x if industry_id == "C" , absorb(id time) //制造业
outreg2 using "$results/base_industry_nocluster.xls", replace addstat(N, e(N))

foreach i in G K H J F E D B I L A {
	reghdfe cef_fwd $x if industry_id == "`i'" , absorb(id time)
	outreg2 using "$results/base_industry_nocluster.xls", append addstat(N, e(N))
}

**CLUSTER的版本**
reghdfe cef_fwd $x if industry_id == "C" , absorb(id time) cluster(id) //制造业
outreg2 using "$results/base_industry_cluster.xls", replace addstat(N, e(N))

foreach i in G K H J F E D B I L A {
	reghdfe cef_fwd $x if industry_id == "`i'" , absorb(id time) cluster(id)
	outreg2 using "$results/base_industry_cluster.xls", append addstat(N, e(N))
}

*-------分年份-------*
**CLUSTER的版本**
reghdfe cef_fwd $x if time <= 2010 & time >= 2000 , absorb(id time) cluster(id) //早年，整体
outreg2 using "$results/base_time_nocluster.xls", replace addstat(N, e(N))

reghdfe cef_fwd $x if time >= 2011 , absorb(id time)  cluster(id) //晚年，整体
outreg2 using "$results/base_time_nocluster.xls", append addstat(N, e(N))

reghdfe cef_fwd $x if time <= 2010 & time >= 2000 & soe==1 , absorb(id time) cluster(id) //早年，国企
outreg2 using "$results/base_time_nocluster.xls", append addstat(N, e(N))
reghdfe cef_fwd $x if time <= 2010 & time >= 2000 & soe==0 , absorb(id time) cluster(id) //早年，非国企
outreg2 using "$results/base_time_nocluster.xls", append addstat(N, e(N))

reghdfe cef_fwd $x if time >= 2011 & soe==1 , absorb(id time) cluster(id) //晚年，国企
outreg2 using "$results/base_time_nocluster.xls", append addstat(N, e(N))
reghdfe cef_fwd $x if time >= 2011 & soe==0 , absorb(id time) cluster(id) //晚年，非国企
outreg2 using "$results/base_time_nocluster.xls", append addstat(N, e(N))

**results/base_time_cluster.xls", append addstat(N, e(N))



*-------稳健性检验-------*

*-------WINSORIZE-------*
clear all
use "$financial/Yraw.dta"

//NO WISORIZE
reghdfe cef_fwd $x, absorb(id time)
outreg2 using "$results/base_winsor_nocluster.xls", replace addstat(N, e(N))

reghdfe cef_fwd $x, absorb(id time) cluster(id) // CLUSTER high-dimension fixed effect
outreg2 using "$results/base_winsor_cluster.xls", replace addstat(N, e(N))

//WISORIZE 99
clear all
use "$financial/Yraw.dta"

winsor2  cef_fwd ln_size roa lev beta bm, replace cuts(1 99) trim

reghdfe cef_fwd $x, absorb(id time)
outreg2 using "$results/base_winsor_nocluster.xls", append addstat(N, e(N))

reghdfe cef_fwd $x, absorb(id time) cluster(id) // CLUSTER high-dimension fixed effect
outreg2 using "$results/base_winsor_cluster.xls", append addstat(N, e(N))

//WISORIZE 97.5
clear all
use "$financial/Yraw.dta"

winsor2  cef_fwd ln_size roa lev beta bm, replace cuts(2.5 97.5) trim

reghdfe cef_fwd $x, absorb(id time)
outreg2 using "$results/base_winsor_nocluster.xls", append addstat(N, e(N))

reghdfe cef_fwd $x, absorb(id time) cluster(id) // CLUSTER high-dimension fixed effect
outreg2 using "$results/base_winsor_cluster.xls", append addstat(N, e(N))



*-------LAG-------*
clear all
use "$financial/Yraw.dta"

//winsor2  cef_fwd ln_size roa lev beta bm, replace cuts(1 99) trim

gen cef_fwd2 = f.cef_fwd

//NO LAG
reghdfe cef $x, absorb(id time)
outreg2 using "$results/base_lag_nocluster.xls", replace addstat(N, e(N))

reghdfe cef $x, absorb(id time) cluster(id) // CLUSTER high-dimension fixed effect
outreg2 using "$results/base_lag_cluster.xls", replace addstat(N, e(N))

//LAG 1
reghdfe cef_fwd $x, absorb(id time)
outreg2 using "$results/base_lag_nocluster.xls", append addstat(N, e(N))

reghdfe cef_fwd $x, absorb(id time) cluster(id) // CLUSTER high-dimension fixed effect
outreg2 using "$results/base_lag_cluster.xls", append addstat(N, e(N))

//LAG 2
reghdfe cef_fwd2 $x, absorb(id time)
outreg2 using "$results/base_lag_nocluster.xls", append addstat(N, e(N))

reghdfe cef_fwd2 $x, absorb(id time) cluster(id) // CLUSTER high-dimension fixed effect
outreg2 using "$results/base_lag_cluster.xls", append addstat(N, e(N))







*-------Moderating Effect-------*
*-------RND*-------*
clear all
use "$financial/Yraw.dta"
 
winsor2  cef_fwd ln_size roa lev beta bm, replace cuts(1 99) trim

gen typh_rnd = typh * rnd

global x_rnd "typh rnd typh_rnd ln_size roa lev beta bm"

reghdfe cef_fwd $x_rnd, absorb(id time)
outreg2 using "$results/base_mitigation.xls", replace addstat(N, e(N))
reghdfe cef_fwd $x_rnd, absorb(id time) cluster(id)
outreg2 using "$results/base_mitigation.xls", append addstat(N, e(N))


*-------CURRENT RATIO-------*

gen typh_current = typh * current_ratio

global x_current "typh current_ratio typh_current ln_size roa lev beta bm"

reghdfe cef_fwd $x_current, absorb(id time)
outreg2 using "$results/base_mitigation.xls", append addstat(N, e(N))
reghdfe cef_fwd $x_current, absorb(id time) cluster(id)
outreg2 using "$results/base_mitigation.xls", append addstat(N, e(N))


*-------PROFIT VOLABILITY-------*

gen typh_volability = typh * profit_volability

global x_volability "typh profit_volability typh_volability ln_size roa lev beta bm"

reghdfe cef_fwd $x_volability, absorb(id time)
outreg2 using "$results/base_mitigation.xls", append addstat(N, e(N))
reghdfe cef_fwd $x_volability, absorb(id time) cluster(id)
outreg2 using "$results/base_mitigation.xls", append addstat(N, e(N))


*-------INTANGIBLE ASSET*-------*

gen ntang_asset_ratio = 1-tang_asset_ratio

gen typh_ntang = typh * ntang_asset_ratio

global x_ntang "typh ntang_asset_ratio typh_ntang ln_size roa lev beta bm"

reghdfe cef_fwd $x_ntang, absorb(id time)
outreg2 using "$results/base_mitigation.xls", append addstat(N, e(N))
reghdfe cef_fwd $x_ntang, absorb(id time) cluster(id)
outreg2 using "$results/base_mitigation.xls", append addstat(N, e(N))


*-------CASH RATIO-------*

gen typh_cash = typh * cash_ratio

global x_cash "typh cash_ratio typh_cash ln_size roa lev beta bm"

reghdfe cef_fwd $x_cash, absorb(id time)
outreg2 using "$results/base_mitigation.xls", append addstat(N, e(N))
reghdfe cef_fwd $x_cash, absorb(id time) cluster(id)
outreg2 using "$results/base_mitigation.xls", append addstat(N, e(N))
