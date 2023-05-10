/*
 * This is to identify cell nuclei.
 *  DAPI images are converted into binary (i.e. black and white) images.
 */

/* 
 *  The folowing threshold variables are used to identify cell nuclei in 
 *  isCell(a, s, bx, by, bw, bh) function.
 */

var area_threshold=150;
var solidity_threshold=0.90;

// DAPI images are processed by Mexican Hat Filter to detect nuclear edges
run("8-bit");
run("Mexican Hat Filter", "radius=10 stack");
run("Subtract...", "value=254 stack");
run("Multiply...", "value=255 stack");

run("Analyze Particles...", "exclude add stack");

print("Checking cell integrity...");

for(i=0; i<roiManager("count"); i++){
	roiManager("select", i);
	 List.setMeasurements();
	 a = List.getValue("Area");
	 s = List.getValue("Solidity");
	 bx = List.getValue("BX");
	 by = List.getValue("BY");
	 bw = List.getValue("Width");
	 bh = List.getValue("Height");
	 if(isCell(a, s, bx, by, bw, bh)){	 	
		setForegroundColor(255,255,255);	
	 }else{
	 	setForegroundColor(0,0,0);
	 }
	 roiManager("Fill");
}

roiManager("deselect");
roiManager("delete");

run("Analyze Particles...", "exclude add stack");

// Make Binary images
newImage("Bin", "8-bit grayscale-mode", getHeight(), getWidth(), 1, nSlices, 1);
selectWindow("Bin");
setForegroundColor(255, 255, 255);
roiManager("Fill");

// Change the path names in the following two lines according to your settings.
run("Image Sequence... ", "format=TIFF save=/Users/nakaokahidenori/Desktop/ImageSeq/Bin");
roiManager("Save", "/Users/nakaokahidenori/Desktop/ImageSeq/RoiSet1.zip");

print("Finished");

function isCell(a, s, bx, by, bw, bh){
	if(bx==1) return false;
	if(by==1) return false;
	if(by+bh==getHeight()-1) return false;
	if(bx+bw==getWidth()-1) return false;
	if(a<area_threshold) return false;
	if(s<solidity_threshold) return false;
	return true;
}
