# Hara_et_al
ImageJ macros for counting RAD51 nuclear foci

The set of macros assumes that we have separate images for nuclei (DAPI) and RAD51 foci (Cy5).
Multiple images of the same channel are imported as an image sequence.

1. Run "BinarizationMacro.ijm" with appropriate modifications of paths where images are stored/saved (in lines 53 and 54).

Also, you might have to make "Bin" directory before running the macro (See line 53).
Other possible modifications are...
<ul>
  <li>threshold values for nuclear size and solidity (lines 11 and 12).</li>
  <li>radius for Mexican Hat Filter (line 16).</li>
</ul>

This macro generates a RoiSet.zip file that stores information about the position and the shape of the nuclei,
and a set of black/white binary images for the identified nuclei.

2. Run "FindMaximaProminenceTestMacro.ijm" with appropriate modifications of paths where images are stored/saved (in lines 9, 10, 11, 62, 70, 102).

This macro uses "Find Maxima" built-in function of ImageJ to identify RAD51 foci within nuclei. The Find Maxima function has a parameter called "prominence", whose value greatly affects the number of identified maxima (i.e. RAD51 foci). The macro systematically analyze the number of maxima for various values of the prominence parameter. In general, the number of maxima is a monotonically decreasing function of prominence. The graph of the function is fit by a power function. In each nucleus, a prominence value at which the curvature of the prominece-maxima curve shows the minimal value of its curvature is heuristically chosen as "the best prominence value". Note that the minimal curvature point can be mathematically derived and computed once the fitting parameters for the power function are determined (implemented in minimalCUrvature_power() function).
