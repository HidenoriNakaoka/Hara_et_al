/*
 * This is to identify Rad51 foci.
 * Find Maxima function is used to identify the foci.
 * Appropriate "prominence" parameter is heuristically determined.
 */

////////// How to use //////////

// 0. Adjust global variables in lines.
// 1. Open Cy5 image sequence.
// 2. Run the script.

///////////////////////////////

import ij.IJ;
import ij.ImagePlus;
import ij.process.ImageProcessor;
import ij.ImageStack;
import ij.plugin.ImageCalculator;
import ij.WindowManager;
import ij.plugin.filter.MaximumFinder;
import ij.measure.ResultsTable;
import ij.measure.CurveFitter;
import java.io.BufferedWriter;
import java.io.FileWriter;

class Prominence{
	int min; int max; int interval; int size;
	Prominence(String cellType){
		if(cellType.contains("U2OS")){
			this.min = 50;
			this.max = 500;
			this.interval = 50;
		}else if(cellType.contains("HeLa")){
			this.min = 500;
			this.max = 5000;
			this.interval = 500;
		}
		this.size = (this.max-this.min)/this.interval + 1;
	}
}


def getMaxCurvature_PowerFunction(log_a, b){
	a = Math.exp(log_a);
	return Math.pow((b-2)/a/a/b/b/(2*b-1), 1.0/2.0/(b-1));
}


////////// Script starts here //////////

File file = new File(IJ.getDirectory("image"));
String parentPath = file.getAbsoluteFile().getParent();


// Check if Point directory exists.
bin_dir = new File(parentPath+"/Point");
if(!bin_dir.isDirectory()){
	File point = new File(parentPath+"/Point");
	point.mkdir();
}

Prominence p = new Prominence(parentPath);

// Open required images and ROI set.
ImagePlus imp = IJ.getImage(); // Cy5 image
dim = imp.getDimensions(); // Returns 5 elements in an array : width, height, nChannels, nSlices, nFrames
IJ.run(imp, "Subtract Background...", "rolling=50 stack");
IJ.run("Image Sequence...", "open="+parentPath+"/Bin sort");
imp2 = WindowManager.getImage("Bin");
IJ.openImage(parentPath+"/RoiSet.zip");

ImageStack stk2 = imp2.getImageStack();
for(int i=0; i<stk2.size(); i++){
	ImageProcessor ip2 = stk2.getProcessor(i+1);
	ip2.multiply(1/255);
	stk2.setProcessor(ip2, i+1);
}

ic = new ImageCalculator();
imp3 = ic.run("Multiply create 32-bit stack", imp, imp2);
imp2.close();
imp.changes = false;
imp.close();

// Perform FindMaxima with varying prominece values in every slice and sum up the results
MaximumFinder mf = new MaximumFinder();
ImageStack stk = imp3.getImageStack();

prom = p.min;
array_log_prom = [];
array_log_count = [];

def bufferedWriter = new BufferedWriter(new FileWriter(parentPath+"/Prominece_vs_maximaCount.txt"));
bufferedWriter.write("## prominence\tm\tlog(prominece)\tlog(m)\n");

index = 0;
while(prom<=p.max){
	int m = 0;
	for(int i=0; i<dim[3]; i++){
		ImageProcessor ip = stk.getProcessor(i+1);
		// COUNT of maxima is printed on ResultTable
		mf.findMaxima(ip, prom.asType(float), ImageProcessor.NO_THRESHOLD, MaximumFinder.COUNT, false, false);
	}
	// Reorganize ResultsTable
	ResultsTable rt = new ResultsTable();
	rt = ResultsTable.getResultsTable();
	array = rt.getColumn(0);// float array
	m = array.sum();
	rt.reset();
	if(index>0){// Do not use the first data point where the number of maxima points are too large
		array_log_prom.add(Math.log(prom));
		array_log_count.add(Math.log(m));
	}
	text = prom+"\t"+m+"\t"+Math.log(prom)+"\t"+Math.log(m)+"\n";
	bufferedWriter.write(text);
	prom = prom + p.interval;
	index = index + 1;
}
bufferedWriter.close();

x = array_log_prom.stream().mapToDouble(f -> f.doubleValue()).toArray(); // ArrayList to double[]
y = array_log_count.stream().mapToDouble(f -> f.doubleValue()).toArray(); // ArrayList to double[]
CurveFitter cf = new CurveFitter(x, y);
/*
 * Assuming count = a*(prominence)^b,
 * log(count) = log(a) + b * log(prominence)
 */
cf.doFit(CurveFitter.STRAIGHT_LINE); // Fitting with y = log(a) + b * x
fit = cf.getParams();
prom_determined = getMaxCurvature_PowerFunction(fit[0], fit[1]); // log(a) = fit[0], b = fit[1]
bufferedWriter = new BufferedWriter(new FileWriter(parentPath+"/FittingParametersLog.txt"));
bufferedWriter.write("log(a)\t"+fit[0]+"\n");
bufferedWriter.write("a\t"+Math.exp(fit[0])+"\n");
bufferedWriter.write("b\t"+fit[1]+"\n");
bufferedWriter.write("prom_determined\t"+prom_determined+"\n");
bufferedWriter.close();

// Apply the determined prominence to imp3 and save the output
ImagePlus imp4 = IJ.createImage("Point", "8-bit black", dim[0], dim[1], dim[3]); // Image sequence for maxima point images
ImageStack stk4 = imp4.getImageStack();

for(int i=0; i<dim[3]; i++){
	ImageProcessor ip = stk.getProcessor(i+1);
	point = mf.findMaxima(ip, prom_determined.asType(float), ImageProcessor.NO_THRESHOLD, MaximumFinder.SINGLE_POINTS, false, false);
	stk4.setProcessor(point, i+1);
}

IJ.run(imp4, "Image Sequence... ", "format=TIFF save="+parentPath+"/Point");

// Close all iamges
ids = WindowManager.getIDList();
ids.each{WindowManager.getImage(it).close();}

println "Finished";