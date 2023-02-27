# Hara_et_al
ImageJ macros for counting RAD51 nuclear foci

The set of macros assumes that we have separate images for nuclei (DAPI) and RAD51 foci (Cy5).
Multiple images of the same channel are imported as an image sequence.

1. Run "BinarizationMacro.ijm" with appropriate modifications of paths where images are stored/saved (in lines 53 and 54).
Other possible modifications are...
<ul>
  <li>threshold values for nuclear size and solidity (lines 11 and 12).</li>
  <li>radius for Mexican Hat Filter (line 16).</li>
</ul>

This macro generates a RoiSet.zip file that stores information about the position and the shape of the nuclei,
and alos a set of black/white binary images for the identified nuclei.
