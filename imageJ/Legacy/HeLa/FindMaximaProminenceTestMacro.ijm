var p_min = 500; // minimum value of test prominece
var p_max = 5000; // maximum value of test prominence
var p_interval = 500; // increment in the prominence test
var size = (p_max-p_min)/p_interval + 1;
var ratio_threshold = 2.0;// Threshold value for [Focus fluorescence] / [Nucleus Mode fluorescence]


////////// How to use /////////

// 1. Open Cy5 Image sequence.
// 2. Run the macro.

///////////////////////////////

image_dir = getDirectory("image");
image_dir_parent = File.getParent(image_dir);

run("Subtract Background...", "rolling=50 stack");
//run("8-bit");
run("Image Sequence...", "open="+image_dir_parent+"/Bin sort");
roiManager("Open", image_dir_parent+"/RoiSet.zip");
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

/*
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


// Fitting to Power function
	Fit.doFit("y = a+b*x", x_array_ln, y_array_ln);
	prom = maxCurvature_power(Fit.p(0),Fit.p(1));
  	prominence_array[i] = prom;
  	a_array[i] = exp(Fit.p(0));
  	b_array[i] = Fit.p(1);
  	
	print("\n");
}
*/

// Perform FindMaxima with varying prominece values in every slice and sum up the results
x_array = newArray(size);
y_array = newArray(size);
x_array_ln = newArray(size);
y_array_ln = newArray(size);
print("## prominence\tm\tlog(prominece)\tlog(m)")
for(p=0; p<size; p++){
	
	prom = p_min+p_interval*p;
	x_array[p] = prom;
	x_array_ln[p] = log(prom);
	m = getMaximaNumber(prom);
	y_array[p] = m;
	y_array_ln[p] = log(m);
	
	print(prom+"\t"+m+"\t"+log(prom)+"\t"+log(m));	

}
selectWindow("Log");
saveAs("Text", image_dir_parent+"/ProminenceTestLog.txt");
print("\\Clear");


// Fitting
print("## a\tb\tprominece_determined");
//for(i=0; i<nSlices; i++){
//  	print(i+1, a_array[i], b_array[i], prominence_array[i]);
//}
Fit.doFit("y = a+b*x", x_array_ln, y_array_ln);
prom = maxCurvature_power(Fit.p(0),Fit.p(1));

a = exp(Fit.p(0));
//a = Fit.p(0);
b = Fit.p(1);
print(a+"\t"+b+"\t"+prom);
selectWindow("Log");
saveAs("Text", image_dir_parent+"/FittingParametersLog.txt");
print("\\Clear");


print("##ROI\tSlice\tX\tY\tpixelvalue\tmode\tratio\tprominence\tisFocus\tTotalFociPerNucleus");
for(i=0; i<roiManager("count"); i++){
	roiManager("select", i);
	Roi.getPosition(channel, slice, frame);
	List.setMeasurements();
	mode = List.getValue("Mode");
	run("Find Maxima...", "prominence="+prom+" output=List");

	// Count foci per nucleus that satisfy the threshold condition
	total_foci = nResults;
	for(j=0; j<nResults; j++){
		pixelvalue = getValue(getResult("X", j), getResult("Y", j));
		if(pixelvalue/mode < ratio_threshold) total_foci = total_foci-1;
	}
	// Output
	isFocus = 1; // 1: focus, 0; not a focus
	roi_id = i+1;
	for(j=0; j<nResults; j++){
		pixelvalue = getValue(getResult("X", j), getResult("Y", j));
		ratio = pixelvalue/mode;
		if(ratio < ratio_threshold){
			isFocus = 0;
		}else isFocus = 1;
		print(roi_id+"\t"+slice+"\t"+getResult("X", j)+"\t"+getResult("Y", j)+"\t"+pixelvalue+"\t"+mode+"\t"+ratio+"\t"+prom+"\t"+isFocus+"\t"+total_foci);
	}
	
}

setBatchMode("exit and display");
selectWindow("Log");
saveAs("Text", image_dir_parent+"/FociList.txt");

/*
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
*/
function getMaximaNumber(p){
	count = 0;
	for(i=0; i<roiManager("count"); i++){
		roiManager("select", i);
		run("Find Maxima...", "prominence="+p+" output=Count");
	}
	for(j=0; j<nResults; j++){
		count = count + getResult("Count", j);
	}
	run("Clear Results");
	return count;
}

function maxCurvature_power(a,b){
	// For Power function
	a_ = exp(a);
	b_ = b;
	return pow((b_-2)/a_/a_/b_/b_/(2*b_-1), 1.0/2.0/(b_-1));
	
}
