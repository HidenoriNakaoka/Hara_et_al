newImage("Point", "8-bit grayscale-mode", 1024, 1024, 1, 40, 1);
str = File.openAsString("/Users/nakaokahidenori/Desktop/ImageSeq/FociList.txt");
lines = split(str,'\n');
for(i=0; i<lengthOf(lines); i++){
	if(i>0){
		tokens = split(lines[i],' ');
		slice = tokens[1];
		x = tokens[2];
		y = tokens[3];
		isfocus = tokens[7];
		if(isfocus==1){
			setSlice(slice);
			setPixel(x, y, 255);
		}	
	}
}

run("Dilate", "stack");
run("Image Sequence... ", "format=TIFF save=/Users/nakaokahidenori/Desktop/ImageSeq/Point");

