/*
 * This is to identify cell nuclei.
 *  DAPI images are converted into binary (i.e. black and white) images.
 */

////////// How to use //////////

// 0. Adjust global variables in lines 25-27. Pay special attention to Mexican Hat Filter Radious.
// 1. Open DAPI image sequence.
// 2. Run the script.

///////////////////////////////

import ij.IJ;
import ij.ImagePlus;
import ij.process.ImageProcessor;
import ij.gui.Roi;
import ij.process.FloatPolygon;
import java.awt.Polygon;
import java.awt.Rectangle;
import ij.plugin.frame.RoiManager;

////////// Global Variables //////////
area_threshold = 5000; // Area in unit of pixels
solidity_threshold = 0.90; // Cells must be relatively round
radious = 10; // Mexican Hat Filter Radious


////////// Function definition //////////

def isCell(int a, float s, int bx, int by, int bw, int bh, int w, int h){
	if(bx==1) return false;
	if(by==1) return false;
	if(by+bh==h-1) return false;
	if(bx+bw==w-1) return false;
	if(a < area_threshold) return false;
	if(s < solidity_threshold) return false;
	return true;
}

def getPolygonArea(polygon){
	int area = 0;
	java.awt.Rectangle rect = polygon.getBounds()
	bx = rect.x.asType(int); by = rect.y.asType(int); bw = rect.width.asType(int); bh = rect. height.asType(int);
	for(int i=bx; i<bx+bw; i++){
		for(int j=by; j<by+bh; j++){
			if(polygon.contains(i,j)) area = area + 1;
		}
	}
	return area;
}

def getSolidity(roi){	
	FloatPolygon convexhull = roi.getFloatConvexHull();
	java.awt.Polygon polygon = roi.getPolygon();
	return getPolygonArea(polygon).asType(float)/getPolygonArea(convexhull).asType(float);
}

def binarization_U2OS(imp){
	radious = 15; // Image dependent parameter
	IJ.run(imp, "Enhance Contrast", "saturated=0.35");
	IJ.run(imp, "Apply LUT", "stack");
	IJ.run(imp, "8-bit", "stack");
	IJ.run(imp, "Subtract Background...", "rolling=50 stack");
	IJ.run(imp, "Mexican Hat Filter", "radius="+radious+" stack");
	IJ.run(imp, "Subtract...", "value=254 stack");
	IJ.run(imp, "Multiply...", "value=255 stack");
	IJ.run(imp, "Dilate", "stack");
	IJ.run(imp, "Dilate", "stack");
}

def binarization_HeLa(imp){
	radious = 10; // Image dependent parameter
	IJ.run(imp, "8-bit", "stack");
	IJ.run(imp, "Mexican Hat Filter", "radius="+radious+" stack");
	IJ.run(imp, "Subtract...", "value=254 stack");
	IJ.run(imp, "Multiply...", "value=255 stack");
}

////////// Script starts here //////////

File file = new File(IJ.getDirectory("image"));
String parentPath = file.getAbsoluteFile().getParent();

// Check if Bin directory exists.
bin_dir = new File(parentPath+"/Bin");
if(!bin_dir.isDirectory()){
	File bin = new File(parentPath+"/Bin");
	bin.mkdir();
}

// DAPI images are processed by Mexican Hat Filter to detect nuclear edges
ImagePlus imp = IJ.getImage();
imp.hide();
if(parentPath.contains("U2OS")){
	binarization_U2OS(imp);
}else if(parentPath.contains("HeLa")){
	binarization_HeLa(imp);
}
IJ.run(imp, "Analyze Particles...", "exclude add stack");
imp.show();

println "Checking cell integrity...";

int[] dim = imp.getDimensions(); // Returns 5 elements in an array : width, height, nChannels, nSlices, nFrames
ImagePlus imp2 = IJ.createImage("Bin", "8-bit black", dim[0], dim[1], dim[3]); // Image sequence for binarized images

RoiManager rm = RoiManager.getInstance();
Roi[] rois = rm.getRoisAsArray();
IJ.setForegroundColor(255, 255, 255);

for(int i=0; i<rois.size(); i++){
	imp.setRoi(rois[i], false);
	int a = getPolygonArea(rois[i].getPolygon());
	float s = getSolidity(rois[i]);
	java.awt.Rectangle rect = rois[i].getBounds()
	bx = rect.x.asType(int); by = rect.y.asType(int); bw = rect.width.asType(int); bh = rect. height.asType(int);

	// On finding a cell, paint the cell on imp2 (The black canvas).
	if(isCell(a, s, bx, by, bw, bh, imp.height, imp.width)){
		rm.select(i);
		rm.runCommand(imp2,"Fill");	
	}
	
}

// Close original images and RoiManager containing non-cells
rm.close();
imp.close();

// Finalize the results and save
imp2.show();
IJ.run(imp2, "Analyze Particles...", "exclude add stack");
rm = RoiManager.getInstance();
rm.runCommand("Save", parentPath+"/RoiSet.zip");
IJ.run(imp2, "Image Sequence... ", "format=TIFF save="+parentPath+"/Bin");

println "Finished";
