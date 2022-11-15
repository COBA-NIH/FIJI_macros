dirFiles=getDir("Get input directory");
outputdir=getDir("Get outputdirectory");
allFiles=getFileList(dirFiles);
print(allFiles.length);
setBatchMode(true);

for(f=0; f<allFiles.length; f++) {
	if (endsWith(allFiles[f], ".tif"))
	fileName=allFiles[f];
	print(fileName);
	run("Bio-Formats Macro Extensions");
	
	run("Bio-Formats Importer", "open=["+dirFiles+fileName+"] autoscale color_mode=Default view=Hyperstack stack_order=XYCZT");
	
	
	//open("+dirFiles+fileName+");
	//run("Bio-Formats Importer", "open=["+dirFiles+fileName+"] autoscale color_mode=Default rois_import=[ROI manager] split_timepoints view=Hyperstack stack_order=XYCZT");
	

}