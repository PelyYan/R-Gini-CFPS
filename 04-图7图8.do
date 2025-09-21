 
 

************************************************************************
* 五 利率冲击对劳动收入差距的影响机制
*（一）劳动供给侧的证据  图7+图8
************************************************************************ 
    use $Data\cfps_LABOREco.dta,clear  
    xtset idind year  

  
    /*  2020-投入产出表 计算排序
    农业  0.000776231            农、林、牧、渔业
    社保  0.17309773             公共管理和社会组织 
    卫生  0.174935149            卫生、社会保障和社会福利业
    居民服务    0.188120119       居民服务和其他服务业
    商务服务    0.206481302       租赁和商务服务业
    教育    0.24549583           教育
    文娱  0.344029217            文化、体育和娱乐业
    建筑  0.34779887              建筑业
    科技  0.355106514             科学研究、技术服务和地质勘查业
    住宿餐饮    0.415428972       住宿和餐饮业 
    批发零售    0.454917532       批发和零售业 
    仓储运输邮政  0.495322735      交通运输、仓储和邮政业
    水环境管理   0.499025505       水利、环境和公共设施管理业
    信息软件    0.538019947       信息传播、计算机服务和软件业
    制造  0.643651031             制造业
    采矿  0.657121755             采矿业
    水电燃气供应  0.700934721      电力、燃气及水的生产和供应业
    金融  0.742538457             金融业
    房地产 0.749589125            房地产业   
    */

    cap drop alphaK 
    gen  alphaK = . 
    replace alphaK = 1 if  indusname =="农、林、牧、渔业" | indusname =="公共管理和社会组织" | indusname =="卫生、社会保障和社会福利业"| indusname =="居民服务和其他服务业"  
    replace alphaK = 2 if  indusname =="租赁和商务服务业" | indusname =="教育" | indusname =="文化、体育和娱乐业"| indusname =="建筑业"  
    replace alphaK = 3 if  indusname =="科学研究、技术服务和地质勘查业" | indusname =="住宿和餐饮业" | indusname =="批发和零售业"| indusname =="交通运输、仓储和邮政业"  
    replace alphaK = 4 if  indusname =="水利、环境和公共设施管理业" | indusname =="信息传播、计算机服务和软件业" | indusname =="制造业"| indusname =="采矿业"  
    replace alphaK = 5 if  indusname =="电力、燃气及水的生产和供应业" | indusname =="金融业" | indusname =="房地产业"  

     
    reghdfe g_inc_wag    i.alphaK#c.MP  ,  absorb( alphaK  )  
     

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
        local z = 2.54
        gen lower99 = beta + (-`z') * se  
        gen upper99 = beta + `z' * se  
        local z = 1.96
        gen lower95 = beta + (-`z') * se  
        gen upper95 = beta + `z' * se  

        gen qtile = _n  
        drop if qtile >5 
 
        replace qtile = 1.1 if qtile == 1
        replace qtile = 4.9 if qtile == 5
        twoway  (rcap upper99 lower99 qtile ,lc(black) lp("l") lw(*1))   ///   
                (rbar upper95 lower95 qtile ,barwidth(.1)  color(gs10) lw(*0.05))  ,     ///   
                yline(0, lw(*0.5) lp("l") lc(gray) )   ///  
                xlabel( 1 2 3 4 5 ,labsize(*1) nogrid tposition(inside) )  /// 
                ylabel(  -0.3 "-0.3" -0.15 "-0.15" 0 "0" 0.15 "0.15" 0.3 "0.3" ,labsize(*1) nogrid tposition(inside) )  /// 
                title(`"a.{fontface "宋体":利率对工资性收入增长率的影响}"',position(6))    ///  
                ytitle(`"{fontface "宋体":估}"' `"{fontface "宋体":计}"'  `"{fontface "宋体":系}"' /// 
                   `"{fontface "宋体":数}"' ,  orientation(  horizontal )  )  xtitle(`"{fontface "宋体":收入分位点}"')   ///      
                xtitle(`"{fontface "宋体":行业资本密集度}"')   ///
                legend(order(1 `"99%{fontface "宋体":置信区间}"' 2 `"95%{fontface "宋体":置信区间}"'  ) col(2) pos(11) ring(0) )  
        graph save    $Plot\图7左.gph ,replace   
 
    restore   
  

   *教育
    reghdfe g_inc_wag    i.edulevel#c.MP ,   absorb( edulevel  )  
     
  

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
        local z = 2.54
        gen lower99 = beta + (-`z') * se  
        gen upper99 = beta + `z' * se  
        local z = 1.96
        gen lower95 = beta + (-`z') * se  
        gen upper95 = beta + `z' * se  

        gen qtile = _n  
        drop if qtile >5 
 
        replace qtile = 1.1 if qtile == 1
        replace qtile = 4.9 if qtile == 5
        twoway  (rcap  upper99 lower99 qtile ,lc(black) lp("l") lw(*1))   ///   
                (rbar  upper95 lower95 qtile ,barwidth(.1) color(gray) lw(*0.05))  ,     ///   
                yline(0, lw(*0.5) lp("l") lc(gray) )   ///  
                xlabel( 1 2 3 4 5   ,labsize(*1)   nogrid tposition(inside)   )  /// 
                ylabel(  -0.3 "-0.3" -0.15 "-0.15" 0 "0" 0.15 "0.15" 0.3 "0.3"  ,labsize(*1) nogrid tposition(inside)  )  /// 
                title(`"b.{fontface "宋体":利率对工资性收入增长率的影响}"',position(6))    ///  
                ytitle(`"{fontface "宋体":估}"' `"{fontface "宋体":计}"'  `"{fontface "宋体":系}"' /// 
                   `"{fontface "宋体":数}"' ,  orientation(  horizontal )  )  xtitle(`"{fontface "宋体":受教育程度}"')   ///
                legend(order(1 `"99%{fontface "宋体":置信区间}"' 2 `"95%{fontface "宋体":置信区间}"'  ) col(2) pos(11) ring(0) )  
        graph save    $Plot\图7右.gph ,replace  
    restore  

    cd $Plot
    *grc1leg  图7左.gph 图7右.gph,col(2) legendfrom(图7左.gph)
    graph combine 图7左.gph 图7右.gph,col(2)  
    graph save    $Plot\图7.gph ,replace 
    graph export  $Plot\图7.png ,replace  width(1800) height(1080)
 
 
    ********************
    *    *交乘
    ********************
    gen eduLev2 = . 
    replace eduLev2 = 0 if edulevel >= 1 & edulevel<=3
    replace eduLev2 = 1 if edulevel >= 4 & edulevel<=5

    reghdfe g_inc_wag    i.eduLev2#i.alphaK#c.MP    ,  absorb( edulevel  )  
     



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
        local z = 2.54
        gen lower99 = beta + (-`z') * se  
        gen upper99 = beta + `z' * se  
        local z = 1.96
        gen lower95 = beta + (-`z') * se  
        gen upper95 = beta + `z' * se  

        gen qtile = _n  
        drop if qtile >10

        gen gr = 2 
        replace gr = 1 if _n <=5
        replace  qtile = qtile - 4.85 if gr ==2    //调整位置，保证美观，否则太挤
        replace  qtile = qtile - 0.15 if gr ==1    //调整位置，保证美观，否则太挤

        twoway  (rcap  upper99 lower99 qtile if gr == 1, lp("l") lc(black) lp("l") lw(*1))   ///   
                (rbar  upper95 lower95 qtile if gr == 1, lp("l") barwidth(.16) color(gs10) lw(*1) lc(black))  ///   
                (rcap  upper99 lower99 qtile if gr == 2, lp("l")  lc(gray) lp("l") lw(*1))   ///   
                (rbar  upper95 lower95 qtile if gr == 2, lp("l") barwidth(.16) color(white) lw(*1) lc(black))  ,     ///   
                yline(0, lw(*0.5) lp("l") lc(gray) )   ///  
                xlabel(1 2 3 4 5   ,labsize(*1)  nogrid tposition(inside)   )  /// 
                ylabel(  -0.2 "-0.2" -0.1 "-0.1" 0 "0" 0.1 "0.1" 0.2 "0.2"  ,labsize(*1)  nogrid tposition(inside)   )  /// 
                title("")    ///  
                 ytitle(`"{fontface "宋体":估}"' `"{fontface "宋体":计}"'  `"{fontface "宋体":系}"' /// 
                   `"{fontface "宋体":数}"' ,  orientation(  horizontal )  )  xtitle(`"{fontface "宋体":受教育程度}"')  ///
                    xtitle(`"{fontface "宋体":行业资本密集度}"')   ///
                legend(order(1 `"99%{fontface "宋体":置信区间}"' 2 `"{fontface "宋体":低技能劳动(95%置信区间)}"'  ///  
                             4 `"{fontface "宋体":高技能劳动(95%置信区间)}"' ) col(3) pos(11) ring(0)) 
        graph save    $Plot\图8.gph ,replace 
        graph export  $Plot\图8.png ,replace   
    restore  


    cd  $MainPath 







