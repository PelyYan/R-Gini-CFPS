
 

************************************************************************
* 四 利率冲击对劳动收入的异质性影响
*（一）基准回归结果 表3 
************************************************************************ 
    use $Data\cfps_LABOREco.dta,clear  
    xtset idind year  
    *平均效应-增速
    reghdfe g_inc_wag MP , absorb(pctile)  cluster(prov) 
    est store a1 
    *最低40%-增速
    gen is_b40 = (pctile >=0 & pctile<= 4) 
    reghdfe g_inc_wag i.is_b40#c.MP , absorb(pctile) cluster(prov) 
    est store a2 
    *最高20%-增速
    gen is_u20 = (pctile >=8 & pctile<= 10) 
    reghdfe g_inc_wag i.is_u20#c.MP , absorb(pctile) cluster(prov)  
    est store a3  
    *平均效应-%标准化增长 
    reghdfe g_inc_wag_sd   MP , absorb( pctile)  cluster( prov ) 
    est store b1 
    *最低40%-%标准化增长 
    reghdfe g_inc_wag_sd i.is_b40#c.MP , absorb(pctile) cluster( prov ) 
    est store b2 
    *最高20%-%标准化增长 
    reghdfe g_inc_wag_sd i.is_u20#c.MP , absorb(pctile) cluster( prov)    
    est store b3 
  

  esttab a1 b1 a2 b2 a3 b3   ,   ///  
      mtitle( all_g all_gst  low40_g low40_gst up20_g up20_gst )    ///  
       b(%9.3f) se(%9.3f)  r2 ar2 star(* 0.1 ** 0.05 *** 0.01) replace 
  

  cd "$Logout"
  esttab a1 b1 a2 b2 a3 b3   using "表3.csv"  ,   ///  
      mtitle(all_g all_gst  low40_g low40_gst up20_g up20_gst )    ///  
       b(%9.3f) se(%9.3f)  r2 ar2 star(* 0.1 ** 0.05 *** 0.01) replace 
 

************************************************************************
* 四 利率冲击对劳动收入的异质性影响
*（一）基准回归结果 图4 
************************************************************************ 
    xtset idind year
    reghdfe g_inc_wag i.pctile#c.MP , absorb(pctile) cluster(prov )   
 
     // 提取估计系数  
    qui matrix b = e(b)   
    // 提取协方差矩阵  
    qui matrix V = e(V)   
    qui matrix se = V  
    qui matrix se = vecdiag(se)  
    qui matrix se = diag(se)  
    qui matrix se = cholesky(se)  
    qui matrix se = vecdiag(se)  
 

    qui matrix se = se' 
    mat list se
    qui matrix b = b' 
    mat list b
    mat A = (b,se)
    preserve 
        clear 
        svmat A 
        rename A1 beta
        rename A2 se

        local z = 2.56
        gen lower = beta + (-`z') * se  
        gen upper = beta + `z' * se  
        gen qtile = _n * 10
        drop if qtile >100
  
        twoway (line  lower qtile ,lc(gray) lp("-") lw(*0.8))  ///   
               (line  beta qtile ,lc(blcak) lp("l") lw(*1.5))  ///   
               (line  upper qtile ,lc(gray) lp("-") lw(*0.8))  , ///   
                yline(0, lw(*0.5) lp("l") lc(gray) )   ///  
               xlabel( 10(20)100 ,labsize(*1) nogrid tposition(inside) )  /// 
               ylabel( -0.5 "-0.5" -0.25 "-0.25" 0 "0" 0.25 "0.25" 0.5 "0.5" ,labsize(*1) nogrid tposition(inside) )  /// 
                title(`"a.{fontface "宋体":降低利率对工资性收入增速的影响}"',position(6))    ///  
                ytitle(`"{fontface "宋体":估}"' `"{fontface "宋体":计}"'  `"{fontface "宋体":系}"' /// 
                   `"{fontface "宋体":数}"' ,  orientation(  horizontal )  )  xtitle(`"{fontface "宋体":收入分位点}"')     legend(off)   
        graph save    $Plot\图4左上.gph ,replace 
        *graph export  $Plot\plot1_wag.png ,replace  
    restore  
 
    * 财产收入
    reghdfe g_inc_wealth_p i.pctile#c.MP , absorb(pctile) cluster(prov)   
    // 提取估计系数  
    qui matrix b = e(b)   
    // 提取协方差矩阵  
    qui matrix V = e(V)   
    qui matrix se = V  
    qui matrix se = vecdiag(se)  
    qui matrix se = diag(se)  
    qui matrix se = cholesky(se)  
    qui matrix se = vecdiag(se)  
 

    qui matrix se = se' 
    mat list se
    qui matrix b = b' 
    mat list b
    mat A = (b,se)
    preserve 
        clear 
        svmat A 
        rename A1 beta
        rename A2 se

        local z = 2.56
        gen lower = beta + (-`z') * se  
        gen upper = beta + `z' * se  
        gen qtile = _n * 10
        drop if qtile >100

        twoway (line  lower qtile ,lc(gray) lp("-") lw(*0.8))  ///   
               (line  beta qtile ,lc(blcak) lp("l") lw(*1.5))  ///   
               (line  upper qtile ,lc(gray) lp("-") lw(*0.8))  , ///   
                yline(0, lw(*0.5) lp("l") lc(gray) )   ///  
               xlabel( 10(20)100   ,labsize(*1) nogrid tposition(inside)   )  /// 
               ylabel(     ,labsize(*1) nogrid tposition(inside)  )  /// 
                title(`"b.{fontface "宋体":降低利率对财产收入增速的影响}"',position(6))    ///   
                ytitle(`"{fontface "宋体":估}"' `"{fontface "宋体":计}"'  `"{fontface "宋体":系}"' /// 
                   `"{fontface "宋体":数}"' ,  orientation(  horizontal )  )  xtitle(`"{fontface "宋体":收入分位点}"')     legend(off)    
        graph save    $Plot\图4右上.gph ,replace 
        *graph export  $Plot\plot2_hincwealth.png ,replace 
    restore  
  
    * 经营收入   
    reghdfe g_inc_oper_p i.pctile#c.MP , absorb(pctile)     
    // 提取估计系数  
    qui matrix b = e(b)   
    // 提取协方差矩阵  
    qui matrix V = e(V)   
    qui matrix se = V  
    qui matrix se = vecdiag(se)  
    qui matrix se = diag(se)  
    qui matrix se = cholesky(se)  
    qui matrix se = vecdiag(se)  

    qui matrix se = se' 
    mat list se
    qui matrix b = b' 
    mat list b
    mat A = (b,se)
    preserve 
        clear 
        svmat A 
        rename A1 beta
        rename A2 se

        local z = 2.56
        gen lower = beta + (-`z') * se  
        gen upper = beta + `z' * se  
        gen qtile = _n * 10
        drop if qtile >100 

        twoway (line  lower qtile ,lc(gray) lp("-") lw(*0.8))  ///   
               (line  beta qtile ,lc(blcak) lp("l") lw(*1.5))  ///   
               (line  upper qtile ,lc(gray) lp("-") lw(*0.8))  , ///   
                yline(0, lw(*0.5) lp("l") lc(gray) )   ///  
               xlabel( 10(20)100   ,labsize(*1) nogrid tposition(inside)  )  /// 
               ylabel(           ,labsize(*1)  nogrid tposition(inside) )  /// 
                title(`"c.{fontface "宋体":降低利率对经营收入增速的影响}"',position(6))    ///    
                ytitle(`"{fontface "宋体":估}"' `"{fontface "宋体":计}"'  `"{fontface "宋体":系}"' /// 
                   `"{fontface "宋体":数}"' ,  orientation(  horizontal )  )  xtitle(`"{fontface "宋体":收入分位点}"')     legend(off)   


        graph save    $Plot\图4左下.gph ,replace 
        *graph export  $Plot\plot3_hincoper.png ,replace  
    restore  
 
   
    *5. 转移收入   
    reghdfe g_inc_trans_p i.pctile#c.MP , absorb(pctile)  
  
    // 提取估计系数  
    qui matrix b = e(b)   
    // 提取协方差矩阵  
    qui matrix V = e(V)   
    qui matrix se = V  
    qui matrix se = vecdiag(se)  
    qui matrix se = diag(se)  
    qui matrix se = cholesky(se)  
    qui matrix se = vecdiag(se)  
 
    qui matrix se = se' 
    mat list se
    qui matrix b = b' 
    mat list b
    mat A = (b,se)
    preserve 
        clear 
        svmat A 
        rename A1 beta
        rename A2 se

        local z = 2.56
        gen lower = beta + (-`z') * se  
        gen upper = beta + `z' * se  
        gen qtile = _n * 10
        drop if qtile >100

        replace lower = -lower
        replace upper = -upper
        replace beta = -beta

        twoway (line  lower qtile ,lc(gray) lp("-") lw(*0.8))  ///   
               (line  beta qtile ,lc(blcak) lp("l") lw(*1.5))  ///   
               (line  upper qtile ,lc(gray) lp("-") lw(*0.8))  , ///   
                yline(0, lw(*0.5) lp("l") lc(gray) )   ///  
               xlabel( 10(20)100   ,labsize(*1) nogrid tposition(inside)   )  /// 
               ylabel(   ,labsize(*1) nogrid tposition(inside)  )  /// 
                title(`"d.{fontface "宋体":降低利率对转移收入增速的影响}"',position(6))    ///     
                ytitle(`"{fontface "宋体":估}"' `"{fontface "宋体":计}"'  `"{fontface "宋体":系}"' /// 
                   `"{fontface "宋体":数}"' ,  orientation(  horizontal )  )  xtitle(`"{fontface "宋体":收入分位点}"')     legend(off)   
 
        graph save    $Plot\图4右下.gph ,replace 
        *graph export  $Plot\plot4_hintrans.png ,replace  

    restore    
    
    cd  ${Plot} 

    graph combine   图4左上.gph       图4右上.gph ///  
                    图4左下.gph  图4右下.gph  ,col(2)  
    graph save     图4.gph ,replace 
    graph export   图4.png ,replace  width(1800) height(1200)

    *erase   plot1_wag.gph
    *erase   plot2_hincwealth.gph
    *erase   plot3_hincoper.gph
    *erase   plot4_hintrans.gph
********************************************************************************************************************************************* 
    cd  $MainPath 

 


















