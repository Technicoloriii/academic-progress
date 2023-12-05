*********结果呈现包**********
*ssc install estout,replace


*导入数据
cd "D:\PhD PSU\Dissertation\Stata project\c-adjusted"
import excel "D:\PhD PSU\Dissertation\Stata project\data.xlsx", firstrow clear

*************数据整理和清洗*********************
*把各个州的c组合与其1年 2年 3年后的igt状况组合， 需要对源数据做一些调整形成新数据。
sort states year


*删除缺失值
 sum lgigt c p population lgpl wapw mhi ur lggdp lgml if missing(lgigt, c, p, population, lgpl, wapw, mhi, ur, lggdp, lgml) == 0

 summarize p_d


**********定义dummy variables*************
*首先是党派的dummy variables
*将全部party部分变成1（默认的共和党全部是0）

gen democratic=0 if !missing(p_d)
gen swing=0 if !missing(p_d)

// 将democratic和swing变成1，republican作为基准量
replace democratic=1 if !missing(p_d) & p_d == 1
replace swing=1 if !missing(p_d) & p_d==2

*现在定义combination的dummy variables
tab c, gen(comb_)

*ols回归
// eststo m1: reg lgigt comb_2 comb_3 comb_4 comb_5 comb_6 comb_7 comb_8 comb_9 comb_10 comb_11 comb_12 comb_13 comb_14 comb_15 comb_16 democratic swing lgpl wapw lgmhi ur lggdp lgml

eststo m1: reg proportion comb_2 comb_3 comb_4 comb_5 comb_6 comb_7 comb_8 comb_9 comb_10 comb_11 comb_12 comb_13 comb_14 comb_15 comb_16 democratic swing lgpl wapw lgmhi ur lggdp lgml

*fixed effect 回归
egen state_group = group(states)
*时间固定效应已经搞定了，源数据里面year 就是时间固定效应，首先用year固定一下，然后再固定一下个体也就是state。
xtset year
*eststo m2: xtreg lgigt comb_2 comb_3 comb_4 comb_5 comb_6 comb_7 comb_8 comb_9 comb_10 comb_11 comb_12 comb_13 comb_14 comb_15 comb_16 democratic swing lgpl wapw lgmhi ur lggdp lgml,fe

eststo m2: xtreg proportion comb_2 comb_3 comb_4 comb_5 comb_6 comb_7 comb_8 comb_9 comb_10 comb_11 comb_12 comb_13 comb_14 comb_15 comb_16 democratic swing lgpl wapw lgmhi ur lggdp lgml,fe

*时间效用和个体效应双重固定
// xtset state_group
*eststo m3: xtreg lgigt comb_2 comb_3 comb_4 comb_5 comb_6 comb_7 comb_8 comb_9 comb_10 comb_11 comb_12 comb_13 comb_14 comb_15 comb_16 democratic swing lgpl wapw lgmhi ur lggdp lgml,fe
xtset p_d
eststo m3: xtreg proportion comb_2 comb_3 comb_4 comb_5 comb_6 comb_7 comb_8 comb_9 comb_10 comb_11 comb_12 comb_13 comb_14 comb_15 comb_16 democratic swing lgpl wapw lgmhi ur lggdp lgml,fe


*加标签方便结果展示
label var lgmhi "Log(median household income)"
label var lgigt "Log(intergovernmental transfer)"
label var lgpl "Log(population)"
label var wapw "working age population weight"
label var lggdp "Log(GDP)"
label var lgml "Log(mileage)"
label var democratic "Democratic States"
label var swing "Swing States"
label var ur "unemployment rate"
****部分图片展示*****
tabulate states 
encode states, gen(states_n)
encode p, gen(p_n)
xtset states_n year
xtline lgigt
xtline lgigt, overlay

******************************结果导出***************************
*esttab m1 m2 m3 using res.xls,ar2 label
esttab m1 m2 m3 using regression-party_fixed.rtf,ar2 label
// esttab m1 m2 m3 using res.tex,ar2 label