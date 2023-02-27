// Measure EdU
run("Image Sequence...", "open=/Users/nakaokahidenori/Desktop/ImageSeq/EdU sort");
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
run("Image Sequence...", "open=/Users/nakaokahidenori/Desktop/ImageSeq/DAPI sort");
for(i=0; i<roiManager("count"); i++){
	roiManager("select", i);
	List.setMeasurements();
	mean = List.getValue("Mean");
	setResult("DAPI_Mean", i, mean);
}
close();

// Rad51 foci per nucleus
str = File.openAsString("/Users/nakaokahidenori/Desktop/ImageSeq/FociList.txt");
lines = split(str,'\n');
roi = 0;
roi_previous = 1;
intensity = 0;
slice = 1;
for(i=0; i<lengthOf(lines); i++){
	if(i>0){
		tokens = split(lines[i],' ');
		roi = tokens[0];
		if(roi!=roi_previous){
			setResult("FociCount", roi_previous-1, count);
			if(count==0){
				setResult("MeanFocusIntensity", roi_previous-1, 0);
			}else setResult("MeanFocusIntensity", roi_previous-1, intensity/count);
			setResult("Slice", roi_previous-1, slice);
			setResult("Condition", roi_previous-1, getExperimentalCondition(getResult("Slice", roi_previous-1)));
			setResult("Experiment", roi_previous-1, getExperimentalID(getResult("Slice", roi_previous-1)));
			roi_previous = roi;
			intensity = 0;
		}
		slice = tokens[1];
		count = tokens[8];
		intensity = intensity + tokens[4];
	}
}
setResult("FociCount", roi-1, count);
if(count==0){
	setResult("MeanFocusIntensity", roi-1, 0);
}else setResult("MeanFocusIntensity", roi-1, intensity/count);
setResult("Slice", roi-1, slice);
setResult("Condition", roi-1, getExperimentalCondition(getResult("Slice", roi-1)));
setResult("Experiment", roi-1, getExperimentalID(getResult("Slice", roi-1)));

saveAs("Results", "/Users/nakaokahidenori/Desktop/ImageSeq/MeasurementResults.txt");

function getExperimentalCondition(s){
	// 0: Ctrl H2O2
	// 1: Ctrl No damage
	// 2: STN1 H2O2
	// 3: STN1 No damage
	if(s>=1 && s<=4 || s>=17 && s<=22){
		return 0;
	}else if(s>=5 && s<=8 || s>=23 && s<=28){
		return 1;
	}else if(s>=9 && s<=12 || s>=29 && s<=34){
		return 2;
	}else if(s>=13 && s<=16 || s>=35 && s<=41){
		return 3;
	}else return -1;
}

function getExperimentalID(s){
	if(s>=1 && s<=16){
		return 1;
	}else return 3;
}
