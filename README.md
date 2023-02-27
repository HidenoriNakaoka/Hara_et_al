# Hara_et_al
## ImageJ macros for counting RAD51 nuclear foci

The set of macros assumes that we have separate images for nuclei (DAPI) and RAD51 foci (Cy5).
Multiple images of the same channel are imported as an image sequence.

### 1. "BinarizationMacro.ijm"

This is the first macro to be run with appropriate modifications of paths where images are stored/saved (in lines 53 and 54).
Also, you might have to make "Bin" directory before running the macro (See line 53).
Other possible modifications are...
<ul>
  <li>threshold values for nuclear size and solidity (lines 11 and 12).</li>
  <li>radius for Mexican Hat Filter (line 16).</li>
</ul>

This macro generates a RoiSet.zip file that stores information about the position and the shape of the nuclei,
and a set of black/white binary images for the identified nuclei.

### 2. "FindMaximaProminenceTestMacro.ijm"

This is the main macro that implements the algorithms for detecting RAD51 foci. Must be run with appropriate modifications of paths where images are stored/saved (in lines 9, 10, 11, 62, 70, 102).
This macro uses "Find Maxima" built-in function of ImageJ to identify RAD51 foci within nuclei. The Find Maxima function has a parameter called "prominence", whose value greatly affects the number of identified maxima (i.e. RAD51 foci). The macro systematically analyze the number of maxima for various values of the prominence parameter. In general, the number of maxima is a monotonically decreasing function of prominence that can be nicely fit by a power function\*\*\*. In each nucleus, a prominence value at which the curvature of the prominece-maxima curve shows the minimal value of its curvature is heuristically chosen as "the best prominence value". Note that the minimal curvature point can be mathematically derived and computed once the fitting parameters for the power function are determined (implemented in minimalCUrvature_power() function).

The main output of the macor is "FociList.txt", where the following information is stored.
<ul>
  <li>#ROI : ROI ID</li>
  <li>Slice : Slice numbe in an image sequence</li>
  <li>X : x-coordinate of a RAD51 focus</li>
  <li>Y : y-coordinate of a RAD51 focus</li>
  <li>pixelvalue : max fluorescence intensity (a.u.) of a RAD51 focus</li>
  <li>mode : mode Cy5 (RAD51) fluorescence value within a nucleus analyzed</li>
  <li>prominence : the best prominence parameter value for a nucleus</li>
  <li>isFocus : 1:considered to be a RAD51 focus. 0: neglected </li>
  <li>TotalFociPerNucleus : the numbe of total RAD51 foci within a nucleus</li>
</ul>

\*\*\* Strictly speking, a log-log plot is used for curve fitting.


$$ 
\ln{y} = \ln a + b\ln{x}
$$

, where $y$ is the number of RAD51 foci in a nucleus, and $x$ is prominence.

Curvature $k$ of a curve ( $y=f(x)$ ) is defined as follows.


$$
k=\frac{d^2 y/dx^2}{\sqrt{1+(dy/dx)^2}^3}
$$

By taking derivative of $k$ and setting it to $0$, we obtain


$$
 x=(\frac{b-2}{a^2b^2(2b-1)})^{1/(2b-2)}
$$

, where the curvature takes the maximum value. In the macro, maxCurvature_power(a,b) function computes the value of $x$.

### 3. (Optional) "MakePointImageMacro.ijm" 
This macro creates a set of black/white binary images, where RAD51 foci are white and the background are black. This is to visualize all the identified RAD51 foci, and totally optional. The images generated in this macro were not used for data analyses.

The new image size specified in line 1 might be modifeid depending on your image size. Also, paths must be appropriately re-written in lines 2 and 19.


### 4. (Optional) "MeasurementMacro.ijm" 
This macro measures fluorescence intensity of each channel (EdU, DAPI, and Cy5) and output the results as MeasurementResults.txt. The procedures are highly experiment-specific, and thus might not be appropriate for general analysis purposes. We made it public just for reference.
