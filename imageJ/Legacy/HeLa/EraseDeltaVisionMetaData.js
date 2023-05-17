// This script converts an image stack with DeltaVision meta data
// into a simple pixel-value image stack

////////// How to use //////////

// 1. Open an image sequence.
// 2. Run the script.

////////////////////////////////


importClass(Packages.ij.IJ);

imp = IJ.getImage();
dim = imp.getDimensions(); // Returns 5 elements in an array : width, height, nChannels, nSlices, nFrames
imp2 = IJ.createImage("Untitled", "16-bit black", dim[0], dim[1], dim[3]);

stack = imp.getStack();
stack2 = imp2.getStack();

for(i=0; i<dim[3]; i++){
	ip = stack.getProcessor(i+1);
	stack2.setProcessor(ip, i+1);
}

imp2.show();
