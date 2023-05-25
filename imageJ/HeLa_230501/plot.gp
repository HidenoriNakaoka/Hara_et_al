load "~/Documents/Programming/GNUplot/MyDefaultSettings.gp"
load "~/Documents/Programming/GNUplot/MyColors.gp"

########## HeLa 230501 ##########
ROOT = "/Users/nakaokahidenori/Documents/Publications/2023_Hara_CST/RAD51/HeLa_230501/"


## Fitting: Prominence vs Foci count
DATA = ROOT."FittingParametersLog.txt"
stats DATA using 2 nooutput ## Read Column 2
N = STATS_records
array A[N]
stats DATA using (A[$0+1]=$2, 0) ## A[1]=log(a), A[2]=a, A[3]=b, A[4]=prom_determined
DATA = ROOT."Prominece_vs_maximaCount.txt"
set output ROOT."Fitting_log.eps"
set xlabel "ln[Prominence]"
set ylabel "ln[Foci count]"
plot A[1]+A[3]*x lc rgb JINZAMOMI, DATA using 3:4 with points pt 31 lc rgb GINNEZUMI
set output ROOT."Fitting_linear.eps"
set xlabel "Prominence"
set ylabel "Foci count"
plot A[2]*x**A[3] lc rgb JINZAMOMI, DATA using 1:2 with points pt 31 lc rgb GINNEZUMI


## EdU distribution and Correlation between EdU and foci count
DATA = ROOT."SimpleFociList.txt"

set output ROOT."EdU.eps"

set logscale y
set xlabel "ROI"
set ylabel "EdU fluorescence / a.u."
plot DATA using 1:3 with points pt 6 lc rgb GINNEZUMI

set output ROOT."EdU_vs_FociCount.eps"

unset logscale y
set logscale x
set xlabel "EdU fluorescence / a.u."
set ylabel "Rad51 foci per cell"
plot DATA using 3:4 with points pt 6 lc rgb GINNEZUMI

## Rad51 foci distribution per experimental condition
set jitter overlap 1.0 spread 0.3
unset logscale x
set output ROOT."FociCount_EdU_Negative.eps"
set xrange [0:5]
set xtics ("Ctrl" 1, "Ctrl_ H2O2" 2, "shSTN1" 3, "shSTN1_ H2O2" 4)
set xtics rotate by -90
plot DATA using ($3<1000 && strcol(6) eq "Ctrl" ? (1) : 1/0):5 with points pt 6 ps 2 lc rgb GINNEZUMI,\
"" using ($3<1000 && strcol(6) eq "Ctrl_H2O2" ? (2) : 1/0):5 with points pt 6 ps 2 lc rgb ASAGI,\
"" using ($3<1000 && strcol(6) eq "shSTN1" ? (3) : 1/0):5 with points pt 6 ps 2 lc rgb GINNEZUMI,\
"" using ($3<1000 && strcol(6) eq "shSTN1_H2O2" ? (4) : 1/0):5 with points pt 6 ps 2 lc rgb ASAGI

set output ROOT."FociCount_EdU_Positive.eps"
plot DATA using ($3>2000 && strcol(6) eq "Ctrl" ? (1) : 1/0):5 with points pt 6 ps 2 lc rgb GINNEZUMI,\
"" using ($3>1000 && strcol(6) eq "Ctrl_H2O2" ? (2) : 1/0):5 with points pt 6 ps 2 lc rgb ASAGI,\
"" using ($3>1000 && strcol(6) eq "shSTN1" ? (3) : 1/0):5 with points pt 6 ps 2 lc rgb GINNEZUMI,\
"" using ($3>1000 && strcol(6) eq "shSTN1_H2O2" ? (4) : 1/0):5 with points pt 6 ps 2 lc rgb ASAGI

DATA = ROOT."FociList.txt"
set output ROOT."FociFluorescenceDist.eps"
set ylabel "Rad51 foci fluorescence / a.u."
set jitter overlap 1.0 spread 0.5
plot DATA using (strcol(8) eq "Ctrl" ? (1) : 1/0):4 with points pt 6 ps 1 lc rgb GINNEZUMI,\
"" using (strcol(8) eq "Ctrl_H2O2" ? (2) : 1/0):4 with points pt 6 ps 1 lc rgb ASAGI,\
"" using (strcol(8) eq "shSTN1" ? (3) : 1/0):4 with points pt 6 ps 1 lc rgb GINNEZUMI,\
"" using (strcol(8) eq "shSTN1_H2O2" ? (4) : 1/0):4 with points pt 6 ps 1 lc rgb ASAGI