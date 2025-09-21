 

************************************************************************
* 五 利率冲击对劳动收入差距的影响机制
*（二）劳动需求侧的证据  表6
************************************************************************ 
*表6 

    use $Data\上市公司.dta ,clear   

    reghdfe wagg_Ledu mp_down asinh_asset asinh_age asinh_emp asinh_人均gdp_city 第二产业增加值占GDP比重_city   , absorb(Lfid) cluster(indus) 
 
    use $Data\税调.dta ,clear    

    reghdfe wagg   mp_down   lnasset_begin  lnemp_begin lnage lngdpa 第二产业增加值占GDP比重   , absorb(firmID)  clu(indus_4d2#city)  




    cd  $MainPath 








































 
