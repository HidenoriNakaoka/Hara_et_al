/*
 * This script further analyze identifeid Rad51 foci.
 * FindRad51Foci.groovy must be run before running this script
 */

////////// How to use //////////

// 1. Open FITC image sequence.
// 2. Run the script.

///////////////////////////////

import ij.IJ;
import ij.ImagePlus;
import ij.process.ImageProcessor;
import ij.ImageStack;
import ij.gui.Roi;
import ij.plugin.frame.RoiManager;
import ij.WindowManager;
import ij.process.ImageStatistics;
import java.awt.Point;
import java.io.BufferedWriter;
import java.io.FileWriter;

def getWhitePixels(ip, polygon){
	points = [];
	java.awt.Rectangle rect = polygon.getBounds()
	bx = rect.x.asType(int); by = rect.y.asType(int); bw = rect.width.asType(int); bh = rect. height.asType(int);
	for(int i=bx; i<bx+bw; i++){
		for(int j=by; j<by+bh; j++){
			if(ip.get(i,j)==255) points.add(new Point(i,j));
		}
	}
	return points;
}

def addNoise(n){
	// This randomly generates -1, 0, 1
	rand = new Random().nextInt() % 2;
	return n + rand.asType(float)/2.0;
}

////////// Script starts here //////////

File file = new File(IJ.getDirectory("image"));
String parentPath = file.getAbsoluteFile().getParent();

// Read experimental conditions
String fileContents = new File(parentPath+"/conditions.txt").text;
conditions = fileContents.split('\n');

// Open required images and ROI set.
ImagePlus imp = IJ.getImage(); // Cy5 image
dim = imp.getDimensions(); // Returns 5 elements in an array : width, height, nChannels, nSlices, nFrames
IJ.run(imp, "Subtract Background...", "rolling=50 stack");

IJ.run("Image Sequence...", "open="+parentPath+"/Point sort");
imp2 = WindowManager.getImage("Point"); // Point image

IJ.run("Image Sequence...", "open="+parentPath+"/Cy5 sort");
imp3 = WindowManager.getImage("Cy5"); // Cy5(gH2AX) image
IJ.run(imp3, "Subtract Background...", "rolling=50 stack");
IJ.run(imp3, "Enhance Contrast", "saturated=0.35");
IJ.run(imp3, "Apply LUT", "stack");

IJ.openImage(parentPath+"/RoiSet.zip"); // ROI set
RoiManager rm = RoiManager.getInstance();
Roi[] rois = rm.getRoisAsArray();

// Identify maxima points in each ROI(cell)
def bufferedWriter = new BufferedWriter(new FileWriter(parentPath+"/FociList.txt"));
bufferedWriter.write("## ROI\tSlice\tCy5\tX\tY\tA488\tFociPerCell\tCondition\n");
def bufferedWriter2 = new BufferedWriter(new FileWriter(parentPath+"/SimpleFociList.txt"));
bufferedWriter2.write("## ROI\tSlice\tCy5\tFociPerCell\tFociPerCellNoise\tCondition\n");
for(int i=0; i<rois.size(); i++){
	imp2.setRoi(rois[i], false);
	slice = rois[i].getZPosition();
	imp2.setPosition(slice);
	ImageProcessor ip2 = imp2.getProcessor();
	points = getWhitePixels(ip2, rois[i].getPolygon());// Coordinates of maxima in a ROI

	// Measure gH2AX(Cy5) intensity for each ROI
	imp3.setPosition(slice);
	ImageProcessor ip3 = imp3.getProcessor();
	ip3.setRoi(rois[i]);
	cy5 = ip3.getStats().mean;
	bufferedWriter2.write((i+1)+"\t"+slice+"\t"+cy5+"\t"+points.size()+"\t"+addNoise(points.size())+"\t"+conditions[slice-1]+"\n");
	
	// For each maxima point, measure A488 focus intensity
	imp.setPosition(slice);
	ImageProcessor ip = imp.getProcessor();
	
	points.each{
		a488 = ip.getPixel(it.x.asType(int), it.y.asType(int));
		bufferedWriter.write((i+1)+"\t"+slice+"\t"+cy5+"\t"+it.x+"\t"+it.y+"\t"+a488+"\t"+points.size()+"\t"+conditions[slice-1]+"\n");
	}
}
bufferedWriter.close();
bufferedWriter2.close();

// Close all iamges
ids = WindowManager.getIDList();
ids.each{
	WindowManager.getImage(it).changes = false;
	WindowManager.getImage(it).close();	
}

println "Finished";