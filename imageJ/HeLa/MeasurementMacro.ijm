root = "/Volumes/MPFM201207/230504_IFdata/";
run("ROI Manager...");
roiManager("Open", root+"RoiSet.zip");

// Measure EdU
run("Image Sequence...", "open="+root+"EdU sort");
run("Subtract Background...", "rolling=50 stack");
for(i=0; i<roiManager("count"); i++){
	roiManager("select", i);
	 List.setMeasurements();
	 area = List.getValue("Area");
	 mean = List.getValue("Mean");
	 setResult("ROI", i, i+1);
	 setResult("Area/um^2", i, area);
	 setResult("EdU_Mean", i, mean);
}
close();

// Measure DAPI
run("Image Sequence...", "open="+root+"DAPI sort");
run("Subtract Background...", "rolling=50 stack");
for(i=0; i<roiManager("count"); i++){
	roiManager("select", i);
	List.setMeasurements();
	mean = List.getValue("Mean");
	slice = List.getValue("Slice");
	setResult("DAPI_Mean", i, mean);
	setResult("Slice", i, slice);
}
close();



// Rad51 foci per nucleus
str = File.openAsString(root+"FociList.txt");
lines = split(str,'\n');

list_roi = newArray(lengthOf(lines));
list_value = newArray(lengthOf(lines));
list_count = newArray(lengthOf(lines));

for(i=0; i<lengthOf(lines); i++){
	tokens = split(lines[i],'\t');
	list_roi[i] = tokens[0];
	list_value[i] = tokens[4];
	list_count[i] = tokens[9];
}

for(i=0; i<nResults; i++){
	info = getROI_Info(getResult("ROI", i));
	setResult("MeanFocusIntensity", i, info[0]);
	setResult("FociCount", i, info[1]);
}


saveAs("Results", root+"MeasurementResults.txt");

function getROI_Info(roi){
	info = newArray(2);
	info[0] = 0; // pixel value
	info[1] = 0; // count
	for(i=0;i<lengthOf(lines); i++){
		if(list_roi[i]==roi){
			info[0] = info[0] + list_value[i];
			info[1] = list_count[i];
		}
	}
	if(info[1]==0){
		return info;
	}else {
		info[0] = info[0]/info[1];
		return info;
	}
	 	
}

