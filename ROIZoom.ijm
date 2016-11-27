/* 
 * This macro picks an ROI and makes an expanded version in the corner 
 * The ROI and the expansion have a white border
 * User can select the size of the ROI, the expansion, the corner and the border size
 * It is meant to be used for montages (made with MultiMotageMacro.ijm)
 * but will work on single square images.
 * Open 1 image. Run Macro. Pick settings.
 * Click in the centre of where you want your ROI to be (any panel will work).
 */

macro "Add ROI Zoom"	{
	if (nImages > 1)	{
		print("ROIZoom only works on a single montage or image");
		return;
	}
	if (nImages == 0)	{
		print("No image open");
		return;
	}
		
	imageID = getImageID();
	title = getTitle();
	dir1 = getDirectory("image");
	newName = "zooms_" + title;
	run("Select None");
	getDimensions(w, h, c, nFrames, dummy);

	// assume 1 row
	if (w == h) {
		nCol = 1;
		grout = 0;
	}
	else	{
		nCol = floor(w/h);
		grout = (w - (nCol * h)) / (nCol - 1);
	}

	// ask what size ROI and expansion and corner
	cornerArray = newArray("LT", "RT", "LB", "RB");
	// Make dialog box
	Dialog.create("Specify ROI Zoom"); 
	Dialog.addMessage("Select corner for zoom");
	Dialog.addChoice("Corner", cornerArray);
	Dialog.addMessage("What size box for expansion?");
	Dialog.addNumber("Box size (px)", 50);
	Dialog.addNumber("Expansion e.g. 2X", 2);
	Dialog.addNumber("Border for boxes (px)", 2);
	// need to add something here so that the user can define where boxes go
	Dialog.show();
	
	corner = Dialog.getChoice();
	bSize = Dialog.getNumber();
	expand = Dialog.getNumber();
	bStroke = Dialog.getNumber();
	// decisions collected

	// sanity check
	if ((bSize * expand) + bStroke > h)	{
		print("The zoomed box won't fit!");
		return;
	}

	// User defines the centre of the box for expansion
	setTool(7); // not sure how to force single point vs multi-point
	waitForUser("Define box", "Click on image to centre of box for expansion");
	if (selectionType == 10)	{
		getBoundingRect(xp, yp, width, height);
		// print("x="+xp+" y="+yp+" "+width+" "+height);
		makeRectangle(xp-(bSize/2),yp-(bSize/2),bSize,bSize);
		// need to do something where user clicks too close to the edge
		selectImage(imageID);
	}
	else	{
		print("Works with point selection only");
	}
	setBatchMode(true);
	// figure out which column the selction is in
	// each panel is h x h pixels separated by grout
	sp = floor(xp / h);	// sp is the panel where selection is 0-based
	// this is risky but box should not be less than grout away from panel edge
	
	// x and y coords relative to the panel
	xp1 = xp - (sp * (h + grout));
	yp1 = yp - 0; // --for future dev
	dSize = bSize * expand;
	// --include sanity check here in case user has clicked too close to the edge
	
	// border will be white
	setForegroundColor(255,255,255);
	// T dStarty = 0; B dStarty = h - dSize
	if (corner == "LB" || corner == "RB")	{
		dStarty = h - dSize; // B	
	}
	else if (corner == "LT" || corner == "RT")	{
		dStarty = 0; // T
	}
	// do the copy/pasting
	for (i=0; i<nCol; i++)	{
		run("Select None");
		xq = xp1 + (i * (h + grout));
		yq = yp1 + 0; // --for future dev
		makeRectangle(xq-(bSize/2),yq-(bSize/2),bSize,bSize);
		run("Copy");
		// make border
		makeRectangle(xq-((bSize + bStroke)/2),yq-((bSize + bStroke)/2),bSize+bStroke,bSize+bStroke);
		run("Fill");
		makeRectangle(xq-(bSize/2),yq-(bSize/2),bSize,bSize);
		run("Paste");
		run("Internal Clipboard");
		selectWindow("Clipboard");
		cmd = "width="+dSize+" height="+dSize+" constrain average interpolation=Bilinear";
		run("Size...", cmd);
		run("Select All");
		run("Copy");
		close("Clipboard");
		selectWindow(title);
		// L dStartx is left side of panel; R dStartX is right side of panel - dSize
		if (corner == "LB" || corner == "LT")	{
			dStartx = (i * (h + grout)); // L	
		}
		else if (corner == "RB" || corner == "RT")	{
			dStartx = h + (i * (h + grout)) - dSize; // R
		}
		// dStarty calculated outside the loop

		// make border for zoom
		if (corner == "LB")	{
			makeRectangle(dStartx,dStarty-bStroke,dSize+bStroke,dSize+bStroke);
		}
		else if (corner == "LT")	{
			makeRectangle(dStartx,dStarty,dSize+bStroke,dSize+bStroke);
		}
		else if (corner == "RB")	{
			makeRectangle(dStartx-bStroke,dStarty-bStroke,dSize+bStroke,dSize+bStroke);
		}
		else if (corner == "RT")	{
			makeRectangle(dStartx-bStroke,dStarty,dSize+bStroke,dSize+bStroke);
		}
		run("Fill");
		// now paste zoom
		makeRectangle(dStartx,dStarty,dSize,dSize);
		run("Paste");
	}	
	selectWindow(title);
	run("Select None");
	saveAs("TIFF", dir1+newName);
	setBatchMode(false);
}
