load "~/Documents/Programming/GNUplot/MyDefaultSettings.gp"
load "~/Documents/Programming/GNUplot/MyColors.gp"

########## U2OS B02 ##########
ROOT = "/Users/nakaokahidenori/Documents/Publications/2023_Hara_CST/RAD51/HeLa_B02/"

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


## gH2A distribution and Correlation between EdU and foci count
DATA = ROOT."SimpleFociList.txt"

set output ROOT."gH2AX.eps"

set logscale y
set xlabel "ROI"
set ylabel "gH2AX fluorescence / a.u."
plot DATA using 1:3 with points pt 6 lc rgb GINNEZUMI

set output ROOT."gH2AX_vs_FociCount.eps"

unset logscale y
set logscale x
set xlabel "gH2AX fluorescence / a.u."
set ylabel "Rad51 foci per cell"
plot DATA using 3:4 with points pt 6 lc rgb GINNEZUMI

## Rad51 foci distribution per experimental condition
set jitter overlap 1.0 spread 0.3
unset logscale x
set output ROOT."FociCount.eps"
set xrange [0:5]
set xtics ("Ctrl" 1, "Ctrl_ B02" 2, "Etoposide" 3, "Etoposide_ B02" 4)
set xtics rotate by -90
plot DATA using (strcol(6) eq "Ctrl" ? (1) : 1/0):4 with points pt 6 ps 2 lc rgb GINNEZUMI,\
"" using (strcol(6) eq "Ctrl_B02" ? (2) : 1/0):4 with points pt 6 ps 2 lc rgb ASAGI,\
"" using (strcol(6) eq "Etoposide" ? (3) : 1/0):4 with points pt 6 ps 2 lc rgb GINNEZUMI,\
"" using (strcol(6) eq "Etoposide_B02" ? (4) : 1/0):4 with points pt 6 ps 2 lc rgb ASAGI

## Rad51 foci distribution per experimental condition
unset logscale x
set xrange [0:5]
set xtics ("Ctrl" 1, "Ctrl_ B02" 2, "Etoposide" 3, "Etoposide_ B02" 4)
set xtics rotate by -90
DATA = ROOT."FociList.txt"
set output ROOT."FociFluorescenceDist.eps"
set ylabel "Rad51 foci fluorescence / a.u."
set jitter overlap 1.0 spread 0.5
plot DATA using (strcol(8) eq "Ctrl" ? (1) : 1/0):6 with points pt 6 ps 1 lc rgb GINNEZUMI,\
"" using (strcol(8) eq "Ctrl_B02" ? (2) : 1/0):6 with points pt 6 ps 1 lc rgb ASAGI,\
"" using (strcol(8) eq "Etoposide" ? (3) : 1/0):6 with points pt 6 ps 1 lc rgb GINNEZUMI,\
"" using (strcol(8) eq "Etoposide_B02" ? (4) : 1/0):6 with points pt 6 ps 1 lc rgb ASAGI