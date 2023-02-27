var p_min = 50; // minimum value of test prominece
var p_max = 1000; // maximum value of test prominence
var p_interval = 50; // increment in the prominence test
var size = (p_max-p_min)/p_interval + 1;
var ratio_threshold = 2.0;// Threshold value for [Focus fluorescence] / [Nucleus Mode fluorescence]

// Use Cy5 MaxProjection Image sequence
// First Open Bin images to eliminate non-ROI regions
run("Image Sequence...", "open=/Users/nakaokahidenori/Desktop/ImageSeq/Cy5 sort");
run("Image Sequence...", "open=/Users/nakaokahidenori/Desktop/ImageSeq/Bin sort");
roiManager("Open", "/Users/nakaokahidenori/Desktop/ImageSeq/RoiSet1.zip");
selectWindow("Bin");
run("Divide...", "value=255.000 stack");
imageCalculator("Multiply create 32-bit stack", "Cy5","Bin");
selectWindow("Cy5");
close();
selectWindow("Bin");
close();
selectWindow("Result of Cy5");

prominence_array = newArray(nSlices);

a_array = newArray(nSlices);
b_array = newArray(nSlices);

setBatchMode("hide");

for(i=0; i<nSlices; i++){
	setSlice(i+1);
	x_array = newArray(size);
	y_array = newArray(size);
	x_array_ln = newArray(size);
	y_array_ln = newArray(size);
	for(p=0; p<size; p++){
		prom = p_min+p_interval*p;
		m = getMaximaNumber(i+1,prom);
		if(m==0) m = 1;
		print(i+1, prom, m, log(prom), log(m));
		x_array[p] = prom;
		y_array[p] = m;
		x_array_ln[p] = log(prom);
		y_array_ln[p] = log(m);
	}

// Fitting to Exponential function
//	Fit.doFit("y = a*exp(b*x)", x_array, y_array); // Prominence v.s. Maxima count can be empirically fit by an exponential function.   	
//  	prom = minimalCurvature(Fit.p(0),Fit.p(1));
//  	prominence_array[i] = prom;
//  	a_array[i] = Fit.p(0);
//  	b_array[i] = Fit.p(1);

// Fitting to Power function
	Fit.doFit("y = a+b*x", x_array_ln, y_array_ln);
	prom = minimalCurvature_power(Fit.p(0),Fit.p(1));
  	prominence_array[i] = prom;
  	a_array[i] = exp(Fit.p(0));
  	b_array[i] = Fit.p(1);
  	
	print("\n");
}

saveAs("Text", "/Users/nakaokahidenori/Desktop/ImageSeq/ProminenceTestLog.txt");
print("\\Clear");

print("## Exponential fit : maxima_count = a*exp(b*prominence)");
print("## Slice\ta\tb\tprominece_determined");
for(i=0; i<nSlices; i++){
  	print(i+1, a_array[i], b_array[i], prominence_array[i]);
}
saveAs("Text", "/Users/nakaokahidenori/Desktop/ImageSeq/FittingParametersLog.txt");
print("\\Clear");


print("##ROI\tSlice\tX\tY\tpixelvalue\tmode\tprominence\tisFocus\tTotalFociPerNucleus");
for(i=0; i<roiManager("count"); i++){
	roiManager("select", i);
	Roi.getPosition(channel, slice, frame);
	List.setMeasurements();
	mode = List.getValue("Mode");
	run("Find Maxima...", "prominence="+prominence_array[slice-1]+" output=List");

	// Count foci per nucleus that satisfy the threshold condition
	total_foci = nResults;
	for(j=0; j<nResults; j++){
		pixelvalue = getValue(getResult("X", j), getResult("Y", j));
		if(pixelvalue/mode < ratio_threshold) total_foci = total_foci-1;
	}
	// Output
	isFocus = 1; // 1: focus, 0; not a focus
	for(j=0; j<nResults; j++){
		pixelvalue = getValue(getResult("X", j), getResult("Y", j));
		if(pixelvalue/mode < ratio_threshold){
			isFocus = 0;
		}else isFocus = 1;
		print(i+1, slice, getResult("X", j), getResult("Y", j), pixelvalue, mode, prominence_array[slice-1],isFocus,total_foci);
	}
	
}

setBatchMode("exit and display");

saveAs("Text", "/Users/nakaokahidenori/Desktop/ImageSeq/FociList.txt");

function getMaximaNumber(s, p){
	count = 0;
	for(i=0; i<roiManager("count"); i++){
		roiManager("select", i);
		Roi.getPosition(channel, slice, frame);
		if(slice==s){
			run("Find Maxima...", "prominence="+p+" output=Count");
		}
	}
	for(j=0; j<nResults; j++){
		count = count + getResult("Count", j);
	}
	run("Clear Results");

	return count;
}

function minimalCurvature(a,b){
	// For Exponential function
	return (log(2/a/a/b/b))/(2*b);
}

function minimalCurvature_power(a,b){
	// For Power function
	a_ = exp(a);
	b_ = b;
	return pow((b_-2)/a_/a_/b_/b_/(2*b_-1), 1.0/2.0/(b_-1));
	
}
