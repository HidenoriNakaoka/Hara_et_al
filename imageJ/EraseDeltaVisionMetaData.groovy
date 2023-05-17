// This script converts an image stack with DeltaVision meta data
// into a simple pixel-value image stack

////////// How to use //////////

// 1. Open an image sequence.
// 2. Run the script.

////////////////////////////////
import ij.IJ;
import ij.ImagePlus;
import ij.process.ImageProcessor;
import ij.ImageStack;
import java.lang.reflect.Array

ImagePlus imp = IJ.getImage();
int[] dim = imp.getDimensions(); // Returns 5 elements in an array : width, height, nChannels, nSlices, nFrames
ImagePlus imp2 = IJ.createImage("Untitled", "16-bit black", dim[0], dim[1], dim[3]);

ImageStack stack = imp.getStack();
ImageStack stack2 = imp2.getStack();

// Declare a 2D array for pixel values
def pixelArray = Array.newInstance(float, dim[0], dim[1]);

for(i=0; i<dim[3]; i++){
	
	ImageProcessor ip = stack.getProcessor(i+1);
	ImageProcessor ip2 = stack2.getProcessor(i+1);
	
	for(int u=0; u<dim[0]; u++){
		for(int v=0; v<dim[1]; v++){
			pixelArray[u][v] = ip.getPixelValue(u,v);
		}
	}	
	ip2.setFloatArray(pixelArray);
}

imp2.show();