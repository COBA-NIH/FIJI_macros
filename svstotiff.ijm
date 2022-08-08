
// This macro open a .svs file and sabe as a color TIFF file.
// Wrote by: Mario Cruz  
// Last update: 07/29/2022
// @ Cimini's Lab (The Broad Institute of MIT and Harvard)

dirFiles=getDir("Get input directory");
//outputdir=getDir("Get outputdirectory");
Dialog.create("Parameters Configuration");
Dialog.addNumber("Choose which Series?", "4");
Dialog.show();
outputdir=getDir("Get outputdirectory");
S = parseInt(Dialog.getNumber());
allFiles=getFileList(dirFiles);
print(allFiles.length);
setBatchMode(true);
fs=File.separator;
//count the .svs files, open the bioformats and count the series
for(f=0; f<allFiles.length; f++) {
if (endsWith(allFiles[f], ".svs"))
   fileName=allFiles[f];
   series = "_series_" + S;
   savePath=outputdir + fileName + fs;
   run("Bio-Formats Macro Extensions");
   Ext.setId(dirFiles+fileName);
   Ext.getSeriesCount(seriesCount);
   sCount=seriesCount;
   
//open the .svs file and pick up the chose series
for(l=1;l<=sCount;l++){
	
	run("Bio-Formats Importer", "open=["+dirFiles+fileName+"] autoscale color_mode=Default view=Hyperstack stack_order=XYCZT series_"+(S));
	
   //Get the file name without the extension
   nameStoreNoExtension= File.nameWithoutExtension;

//Convert the 8Bit composite image to a RGB image
run("RGB Color");

saveAs("TIFF", outputdir+nameStoreNoExtension+series);

}
}
print("Finished!");
