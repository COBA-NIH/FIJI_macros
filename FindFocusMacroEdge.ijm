// This macro can transform an image sequence into a Stack, then a Hyperstack, find the in-focus plane using the normalized variance algorithm (mean or mode methods) with the option of cropping, FindEdge filter and z-plane offset along a time-frame and save the in-focus time series as a new image.
// Wrote by: Mario Cruz  
// Last update: 07/18/2022
// @ Cimini's Lab (The Broad Institute of MIT and Harvard)
// ATTENTION: Please cite this macro if you use it to generate data for publications. 
//Based on algorithm F-11 "Normalized Variance"
// In: Sun et al., 2004. MICROSCOPY RESEARCH AND TECHNIQUE 65, 139–149. //Richard Mort 27/09/2018


dir=getDir("Get input directory");
outputdir=getDir("Get outputdirectory");
list=getFileList(dir)
Dialog.create("Parameters Configuration");
	 Dialog.addCheckbox("Apply a edge filter before calculating the in-focus plane? This option duplicates your image and requires more memory.", false);
     Dialog.addNumber("Please input the number of z planes. (ex. 26):", "26");
     Dialog.addNumber("Please input the number of time-lapse frames (ex. 400):", "8");
     Dialog.addNumber("Please input the time frame in seconds. (ex. 90):", "90");
     Dialog.addChoice("Please choose the method to find the in focus plane:", newArray("mean", "mode"));
     Dialog.addMessage("Improve processing time with crop function (Center square crop).");
     Dialog.addNumber("Choose 0 for no crop or input the crop size value in pixels(ex.350):", "");
     Dialog.addNumber("Z-plane Offset. (ex. -2, select the second plane below the focal plane)", "0");
     Dialog.show();
     edge = parseInt(Dialog.getCheckbox());
     zplanes = parseInt(Dialog.getNumber());
	 tframes = parseInt(Dialog.getNumber());
	 ttime = parseInt(Dialog.getNumber());
	 mmethod = Dialog.getChoice();
	 cropsize = parseInt(Dialog.getNumber());
	 offset = Dialog.getNumber();
	 print("Method: ", mmethod);
	 print("Crop size:", cropsize);
setBatchMode("true");
start = getTime(); 

//loop through the groups and make the image stack
for (i = 1; i < lengthOf(list); i+=zplanes) {
	print(i);
	print("Wait we're loading your files");
	//read images and make stacks
	run("Image Sequence...", "open=dir"); 
	//extract metadata label for first slice
	fileName = getMetadata("Label");
	//convert to hyperstack
	run("Stack to Hyperstack...", "order=xyczt(default) channels=1 slices="+zplanes+" frames="+tframes+" display=Grayscale");
	newhyperstack = getTitle();
	close("\\Others");
	width = getWidth();
	//make a center copy of the image// if the crop size is bigger than the original image no crop will be make
	if (edge == 1) {
		print("Wait we're resizing your image, this can take a while.");
		run("Duplicate...", "title=resized duplicate");
		run("Find Edges", "stack");
		//make square selection on the center of a image
		if ((cropsize < width) && (cropsize > 0)) {
		xc = parseInt(getWidth()/2);
		yc = parseInt(getHeight()/2);
		makeRectangle(xc-(cropsize/2), yc-(cropsize/2), cropsize, cropsize);
		run("Crop");} else {rename("resized");}
	}
	print("Start processing your files");
	//Get image type
	type = bitDepth();
	xc = parseInt(getWidth()/2);
	yc = parseInt(getHeight()/2);
	ic = parseInt(xc-(cropsize/2));
	jc = parseInt(yc-(cropsize/2));
	if (type==8) {type="8-bit";} else {if(type==16) {type="16-bit";} else{if(type==32) {type="32-bit";} else {if(type==24) {type="RGB";}}}}
	StackID=newhyperstack;
	//Loop to run the calculation on each time frame
	Stack.getDimensions(width, height, channels, slices, frames);
	width = getWidth();
	for (k=1; k<=frames; k++) { Stack.setFrame(k);
	m=0;
	normVar = 0; // Set to 0 which is out of focus
	//Loop to run the normalized variance analysis in each z-plane
	for (l=1; l<=slices; l++){ 
		if (edge == 1) {
			selectWindow("resized");} else {selectWindow(StackID);}
		Stack.setSlice(l);

	getRawStatistics(nPixels, mean, median, mode, stdDev);
	if ((cropsize < width) && (cropsize > 0)) { 
		W = cropsize;
		H = cropsize;} 
		else {W = getWidth();
			H = getHeight();}
			
	b = 0;

	for (j=0; j<H; j++) {
  	 for (i=0; i<W; i++) {
      if ((cropsize < width) && (cropsize > 0)) {
      p = getPixel(i+ic,j+jc);} else {p = getPixel(i,j);}
     //condition to choose the method for the normalazied variance calculation
     if (mmethod == "mean") {t = (p-mean)*(p-mean);} else {t = (p-mode)*(p-mode);}
     b += t;
     }
   }

	if ((b/(H*W*mean))>normVar) {normVar = (b/(H*W*mean)); m++;} else {normVar=normVar;}

	}
	//make a copy of the in plane on the original image (not cropped) for each time frame
	selectWindow(StackID);
	wait(100);
	Stack.getDimensions(width, height, channels, slices, frames);
	Stack.setFrame(k);
	Stack.setSlice(m + offset);
	wait(100);
	run("Select All");
	run("Copy");
	//Make a new image file to save the in focus planes along the time-frame
	if (isOpen("Output")){
                selectWindow("Output");
                run("Add Slice");
            }
            else{
                newImage("Output", type, width, height, 1);
            }
run("Paste");
if (edge == 1) {
	selectWindow("resized");} else {selectWindow(StackID);}
Stack.setSlice(l);
print("Processing files: "+((k)/tframes)*100+"%");
}

selectWindow("Output");
close("\\Others");
run("Select None");
//Set the proprieties for the output file
run("Properties...", "channels=1 slices=1 frames="+tframes+" pixel_width=1.0000 pixel_height=1.0000 voxel_depth=1.0000 frame=["+ttime+" sec]");
saveAs("TIFF", outputdir+StackID);

print("Macro finished. Please check for results within output folder.");
print ("Macro execution time: " + (((getTime()-start)/1000)/60) + " minutes");
run("Select None");
close("\\Others");