
// This macro open a .czi file and save as a color TIFF file.
// Wrote by: Mario Cruz  
// Last update: 07/29/2022
// @ Cimini's Lab (The Broad Institute of MIT and Harvard)

dirFiles=getDir("Get input directory");
//outputdir=getDir("Get outputdirectory");
outputdir=getDir("Get outputdirectory");
//S = parseInt(Dialog.getNumber());
allFiles=getFileList(dirFiles);
print(allFiles.length);
setBatchMode(true);
fs=File.separator;
//count the .czi files, open the bioformats and count the series
for(f=0; f<allFiles.length; f++) {
if (endsWith(allFiles[f], ".czi"))
   fileName=allFiles[f];
   savePath=outputdir + fileName + fs;
   run("Bio-Formats Macro Extensions");
   Ext.setId(dirFiles+fileName);
   Ext.getSeriesCount(seriesCount);
   sCount=seriesCount;
   
//open the .czi file and pick up the chose series
for(l=1;l<=sCount;l++){
	series = "_series_"+l;
	run("Bio-Formats Importer", "open=["+dirFiles+fileName+"] autoscale color_mode=Default view=Hyperstack stack_order=XYCZT series_"+(l));
   //Get the file name without the extension
    nameStoreNoExtension= File.nameWithoutExtension;
    Ext.getMetadataValue("Information|Image|S|Scene|Name #"+(l),val);
	

//Convert the 8Bit composite image to a RGB image
//run("RGB Color");

saveAs("TIFF", outputdir+nameStoreNoExtension+"_"+val);

}
}
print("Finished!");
