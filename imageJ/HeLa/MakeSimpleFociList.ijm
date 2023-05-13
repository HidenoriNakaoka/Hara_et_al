////////// How to use //////////

// 1. Open FociList.txt as a result table.
// 2. Run the macro.

////////////////////////////////


roi_prev = -1;
foci_prev = -1;

print("slice\troi\tfoci");

for (i=0; i<nResults; i++) {

	roi = getResult("##ROI", i);
	foci = getResult("TotalFociPerNucleus", i);
	slice = getResult("Slice", i);

	if(roi!=roi_prev || foci!=foci_prev) print(slice+"\t"+roi+"\t"+foci);

	roi_prev = roi;
	foci_prev = foci;
	
}

