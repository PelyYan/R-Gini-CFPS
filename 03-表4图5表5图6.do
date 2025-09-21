 
    use $Data\cfps_LABOREco.dta,clear  
    xtset idind year  
 
************************************************************************
* 四 利率冲击对劳动收入的异质性影响
*（二）稳健性分析 表4 
************************************************************************ 
 
    *平均效应-增速 
    reghdfe g_inc_wag   MP age eduy gender  , absorb( pctile  )  cluster( prov ) 
    est store a1 
    reghdfe g_inc_wag   MP  i.year  , absorb( pctile  )  cluster( prov ) 
    est store a2  
    *最低40%-增速
    gen is_b40 = (pctile >=0 & pctile<= 4)  
    reghdfe g_inc_wag i.is_b40#c.MP  age eduy gender ,absorb(pctile) cluster( prov ) 
    est store b1 
    reghdfe g_inc_wag i.is_b40#c.MP i.year  , absorb(pctile) cluster( prov ) 
    est store b2 
    *最高20%-增速
    gen is_u20 = (pctile >=8 & pctile<= 10)  
    reghdfe g_inc_wag i.is_u20#c.MP   age eduy gender  ,  absorb(pctile) cluster( prov)  
    est store c1 
    reghdfe g_inc_wag i.is_u20#c.MP  i.year  ,  absorb(pctile) cluster( prov)  
    est store c2 
 
  esttab  a1 a2   b1 b2   c1 c2    ,   ///  
      mtitle(  mg_ctrl mg_yfe   lowg_ctrl lowg_yfe   upg_ctrl upg_yfe  )    ///  
       b(%9.3f) se(%9.3f)  r2 ar2 star(* 0.1 ** 0.05 *** 0.01) replace  

  cd "$Logout"
  esttab   a1 a2   b1 b2  c1 c2   using "表4.csv"  ,   ///  
      mtitle(  mg_ctrl mg_yfe   lowg_ctrl lowg_yfe   upg_ctrl upg_yfe )    ///  
       b(%9.3f) se(%9.3f)  r2 ar2 star(* 0.1 ** 0.05 *** 0.01) replace 
   
 
************************************************************************
* 四 利率冲击对劳动收入的异质性影响
*（二）稳健性分析 图5
************************************************************************ 


    *稳健检验1：时间固定效应
    xtset idind year
    reghdfe g_inc_wag i.pctile#c.MP ,  absorb(pctile year)  
 
     // 提取估计系数  
    qui matrix b = e(b)   
    // 提取协方差矩阵  
    qui matrix V = e(V)   
    qui matrix se = V  
    qui matrix se = vecdiag(se)  
    qui matrix se = diag(se)  
    mat se[10,10] = 1 
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


    twoway (line  lower qtile if qtile < 100 ,lc(gray) lp("-") lw(*0.8))  ///   
           (line  beta qtile  if qtile < 100,lc(blcak) lp("l") lw(*1.5))  ///   
           (line  upper qtile if qtile < 100,lc(gray) lp("-") lw(*0.8))  , ///   
            yline(0, lw(*0.5) lp("l") lc(gray) )   ///  
           xlabel( 10(20)90   ,labsize(*1) nogrid tposition(inside) )  /// 
           ylabel( -0.5 "-0.5" -0.25 "-0.25" 0 0.25 "0.25" 0.5 "0.5"    ,labsize(*1) nogrid tposition(inside) )  /// 
            title(`"a.{fontface "宋体":稳健检验1：时间固定效应}"',position(6))    ///   
                ytitle(`"{fontface "宋体":估}"' `"{fontface "宋体":计}"'  `"{fontface "宋体":系}"' /// 
                   `"{fontface "宋体":数}"' ,  orientation(  horizontal )  )  xtitle(`"{fontface "宋体":收入分位点}"')     legend(off)    
    graph save    $Plot\图5左.gph ,replace  
    restore  
 
    *稳健检验2：个人特征
    xtset idind year
    reghdfe g_inc_wag i.pctile#c.MP  age eduy gender  ,absorb(pctile  ) cluster(prov )   
 
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
           xlabel( 10(20)100   ,labsize(*1) nogrid tposition(inside) )  /// 
           ylabel(-0.5 "-0.5" -0.25 "-0.25" 0 0.25 "0.25" 0.5 "0.5"   ,labsize(*1) nogrid tposition(inside) )  ///  
            title(`"b.{fontface "宋体":稳健检验2：控制个人特征}"',position(6))    ///   
                ytitle(`"{fontface "宋体":估}"' `"{fontface "宋体":计}"'  `"{fontface "宋体":系}"' /// 
                   `"{fontface "宋体":数}"' ,  orientation(  horizontal )  )  xtitle(`"{fontface "宋体":收入分位点}"')     legend(off)    
    graph save    $Plot\图5右.gph ,replace  
    restore  
  




    cd  $Plot   
    graph combine  图5左.gph 图5右.gph
    
    graph save    $Plot\图5.gph ,replace 
    graph export  $Plot\图5.png ,replace width(1800) height(1000)

 


 
************************************************************************
* 四 利率冲击对劳动收入的异质性影响
*（二）稳健性分析 表5
************************************************************************ 

    rifhdreg inc_wag       MP age eduy gender        , rif(gini) abs(idind) 
    rifhdreg ln_inc_wag    MP age eduy gender        , rif(gini) abs(idind)

 
************************************************************************
* 四 利率冲击对劳动收入的异质性影响
*（二）稳健性分析 图6
************************************************************************ 


    mat A = J(9,3,0)
    local i = 1 

    foreach num of numlist   10(10)90  {
        qui rifhdreg ln_inc_wag       MP age eduy gender        , rif(q(`num')) abs(idind)
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
        mat A[`i',1] = b[1,1]
        mat A[`i',2] = se[1,1]
        mat A[`i',3] = `num'
        local i = `i' + 1
    }
    mat list A  

    preserve 
        clear 
        svmat A 

        rename A1 beta
        rename A2 se
        rename A3 qtile

        local z = 2.56
        gen lower = beta + (-`z') * se  
        gen upper = beta + `z' * se  


  
        twoway (line  lower qtile ,lc(gray) lp("-") lw(*0.8))  ///   
               (line  beta  qtile ,lc(blcak) lp("l") lw(*1.5))  ///   
               (line  upper qtile ,lc(gray) lp("-") lw(*0.8))  , ///   
                yline(0, lw(*0.5) lp("l") lc(gray) )   ///  
               xlabel( 10(20)100              ,labsize(*1) nogrid tposition(inside) )  /// 
               ylabel(-2 "-2" -1.5 "-1.5" -1 "-1" -0.5 "-0.5" 0  0.5 "0.5"  ,labsize(*1) nogrid tposition(inside) )  /// 
                title("")    ///   
                ytitle(`"{fontface "宋体":估}"' `"{fontface "宋体":计}"'  `"{fontface "宋体":系}"' /// 
                   `"{fontface "宋体":数}"' ,  orientation(  horizontal )  )  xtitle(`"{fontface "宋体":收入分位点}"')     legend(off)  
 
        graph save    $Plot\图6.gph ,replace 
        graph export  $Plot\图6.png ,replace  width(1800) height(1200)     


    restore  
 
    cd  $MainPath 
