

	global MainPath "Z:\临时备份\Research\paper\货币政策"

	global Logout $MainPath\Logout
	global Plot   $MainPath\Plot
	global Data   $MainPath\Data 
	global Data_p   $MainPath\Data\Temp 

	cap mkdir $Logout
	cap mkdir $Data
	cap mkdir $Plot 
	cap mkdir $Data_p 
****************************************************************************************************

	cd $MainPath
****************************************************************************************************
*
*     构建外生利率冲击货币政策
*            基于Jarociński, Marek & Karadi, Peter(2020)  AEJ:Macro
*
****************************************************************************************************

*选择合适的利率预期指标：

*利率互换（IRS）： 选择3个月或6个月期限的利率互换合约，获取其价格或利率变化，来反映市场对未来利率的预期。
*短期国债收益率或国债期货： 使用3个月期的国债收益率（如果可得），或者2年期国债期货价格，作为利率变化的代理。
 
 *1.提取日期
	cd "$Data\中国政策文本\中国货币政策大事记"

	import excel using "中国货币政策大事记.xlsx" ,sheet("去重复") clear first case(preserve )
    drop if tg == 1 
    keep datest year month day 
    duplicates drop  year month day,force 
    save "$Data_p\中国货币政策大事记.dta",replace 

 *2.提取IRS变化 
	import excel using "$Data\DC利率互换固定利率7天回购定盘利率3个月.xlsx" ,sheet("我的数列") clear 
	drop if _n <= 29 
	rename A dd 
	rename B IRS 
	destring IRS,force replace 
	* 将字符串日期转换为Stata日期格式  
	generate date_new = date(dd, "DMY")   
	order date_new
	* 设置日期显示格式  
	format date_new %td  

	gen day =  day(date_new)
	gen mon =  month(date_new)
	gen year = year(date_new)
	order year mon day
	tostring year mon day,force replace 
	replace mon = "0" + mon if real(mon) < 10
	replace day = "0" + day if real(day) < 10
	gen datest = year + mon + day 
	order datest 
	destring datest,force replace  
	keep datest IRS 
	sort datest

	sum datest

	global minyIRS = r(min)
	global maxyIRS = r(max)
	gen dIRS =  IRS[_n+1]-IRS[_n]
	label var dIRS  "下一期减去当期"  

	preserve  
		generate date_monthly = ym(int(datest/10000), real(substr(string(datest,"%12.0f"),5,2)))    
		format date_monthly %tm    
		*tsset date_monthly, monthly   
		generate date_quarterly = qofd(dofm(date_monthly)) 
		format date_quarterly %tq   
		order date_quarterly 
		collapse ( mean ) IRS, by(date_quarterly)   
	    tsset date_quarterly
	    save "$Data_p\IRS_季度水平值.dta",replace  
	restore  
 
    save "$Data_p\IRS.dta",replace 
 *3.提取上证变化	
	import excel using "$Data\上证指数日线行情.xlsx" ,sheet("000001.SH") clear first case(preserve )
    gen datest = 交易日期 
    destring datest,force replace 
    order datest 
    sort datest
    save "$Data_p\上证指数日线行情.dta",replace 
 *3.合并   
 	merge 1:1 datest using "$Data_p\IRS.dta"
 	order _merge 
 	sort datest  
 	drop if datest < ${minyIRS} | datest > ${maxyIRS}  
 	rename _merge 上证匹IRS 
 	label var 上证匹IRS "1 SH 2 IRS 3 match"



 	merge 1:1 datest using "$Data_p\中国货币政策大事记.dta" 
 	order _merge
 	sort datest  
 	drop if datest < ${minyIRS} | datest > ${maxyIRS} 
 	rename _merge 与大事记匹
 	label var 与大事记匹 "1 SH 2 IRS 3 match"

 	gen ISPOLICY = (与大事记匹 == 2| 与大事记匹 == 3)

 	order 上证匹IRS 与大事记匹  datest ISPOLICY IRS 收盘价 开盘价 涨跌额 涨跌幅

    *生成差值
    gen dP = ISPOLICY[_n]-ISPOLICY[_n-1]
 	order 上证匹IRS 与大事记匹  datest ISPOLICY dP IRS 收盘价 开盘价 涨跌额 涨跌幅

    codebook 开盘价 if ISPOLICY == 1
    codebook IRS if ISPOLICY == 1

    replace 涨跌幅 = 涨跌幅[_n-1] if 涨跌幅 == . 

    forvalue  i = 1(1)100 {
    	replace dIRS = dIRS[_n+1] if dIRS == . 
    } 

    order datest ISPOLICY dIRS 涨跌幅


    preserve 
        keep if ISPOLICY == 1
	    keep  datest   dIRS 涨跌幅 
	    gen date = substr(string(datest,"%12.0f"),1,4) + "-" +substr(string(datest,"%12.0f"),5,2) + "-" + substr(string(datest,"%12.0f"),-2,2)
	    order date dIRS 涨跌幅
	    keep  date   dIRS 涨跌幅
	    rename 涨跌幅 SH
	    outsheet using "$Data\CN_MP_use.csv" , replace comma  
    restore
 

 *4.套用matlab
	*使用CN_MP文件夹中的main.m，对CN_MP_use.csv的数据进行分解，得到外生的货币政策冲击

   
   *-----------------------------------------------------------------------*
   *-----------------------------------------------------------------------*
   *-----------------------------------------------------------------------*


	*将分解的利率冲击加总到年份 
    cd $Data
    insheet using "shocks_CN_t_A.csv",clear
    gen year = real(substr(date,1,4)) 
    bys year :egen MPs_CN = total(mp_median)  
    duplicates drop year,force 
    keep year MPs_CN  
    save CN_MPshocks_year.dta ,replace 


    insheet using "shocks_CN_m_A.csv",clear 
    keep year month mp_median
    rename   mp_median  MPs_CN
    save CN_MPshocks_month.dta ,replace 


    insheet using "$Data\shocks_CN_m_A.csv",clear 

    keep year month mp_pm
    rename   mp_pm  MPs_CN 
	generate date_monthly = ym(year, month)    
	format date_monthly %tm    
	tsset date_monthly, monthly   
	generate date_quarterly = qofd(dofm(date_monthly)) 
	format date_quarterly %tq   
	collapse (mean) MPs_CN, by(date_quarterly) 
	tsset date_quarterly, quarterly  


