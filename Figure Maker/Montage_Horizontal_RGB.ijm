/*
 The aim is to make montages the way we like them.
 Horizontal - grayscale single channels with merge(s) on the right
 Vertical - grayscale single channels with merge(s) on the bottom
 
 If you have a 3 channel RGB TIFF (1 slice), you can make a 3 or 4 panel
 simple montage with "Montage Horizontal RGB". Specify the order of grayscale channels, merge is on right.
 Also specify grouting for the montage. There's no outside border, but there is an option to add a scale bar.
 There is a vertical version called "Montage Vertical RGB"
 
 For more flexible montages you can use "Montage Horizontal Flexible" (or the vertical version)
 It should work for all images (>1 chnnel or slice) including a single frame RGB.
 You can arange grayscale channel panels and up to two merges that you specify.
 As for the simple montage, you can specify the grout and scale bar.

 Batch processing of a directory TIFFs is possible for "Montage Horizontal RGB".
 In this case specify your first montage and the rest of the directory will be processed in the same way.
*/


macro "Montage Horizontal RGB" {
	if (nImages > 0) exit ("Please close all open images");
	filepath=File.openDialog("Select a File"); 
	open(filepath);
	if (bitDepth() != 24) exit ("RGB image required.");
		rgb2Montage("");
}