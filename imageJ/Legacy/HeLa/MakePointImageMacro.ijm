newImage("Point", "8-bit grayscale-mode", 960, 960, 1, 30, 1);
root = "/Volumes/MPFM201207/230504_IFdata/"
if(File.exists(root+"Point")==0){
	File.makeDirectory(root+"Point");
}
str = File.openAsString(root+"FociList.txt");
lines = split(str,'\n');
for(i=0; i<lengthOf(lines); i++){
	if(i>0){
		tokens = split(lines[i],'\t');
		slice = tokens[1];
		x = tokens[2];
		y = tokens[3];
		isfocus = tokens[8];
		if(isfocus==1){
			setSlice(slice);
			setPixel(x, y, 255);
		}	
	}
}

run("Dilate", "stack");
run("Image Sequence... ", "format=TIFF save="+root+"Point");

