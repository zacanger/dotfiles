//     This file is part of the Animated GIF Maker project
//     by Philip J. Guo (Created April 2005)
//     http://alum.mit.edu/www/pgbovine/
//     Copyright 2005 Philip J. Guo
//
//     This program is free software; you can redistribute it and/or modify
//     it under the terms of the GNU General Public License as published by
//     the Free Software Foundation; either version 2 of the License, or
//     (at your option) any later version.

//     This program is distributed in the hope that it will be useful,
//     but WITHOUT ANY WARRANTY; without even the implied warranty of
//     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//     GNU General Public License for more details.

/* TODO:
Funky-ass things happen when you try to do clear()'s so avoid if possible
*/

var imageFilename;

var ready = false;
var isMouseDown = false;

var positionLock = false;
var xOverflow = false;
var yOverflow = false;

//var centerX = -1;
//var centerY = -1;
//var halfCurrentSize = -1;

var myImage;
var layerOnTopOfImage;

var currentID = 1;

// Holds all Selection objects created by the user
var selectionArray;

var activeSelection;

var centerLeeway = 4;
/*********************************
 Classes
 *********************************/

// Returns true if x and y are within the selection's bounds
function Selection_intersect(x, y) {
  return (((this.centerX - this.radius) <= x) &&
	  (x <= (this.centerX + this.radius)) &&
	  ((this.centerY - this.radius) <= y) &&
	  (y <= (this.centerY + this.radius)));
}

// Returns true if x and y are within a reasonable range
// of the center of this selection
function Selection_intersectCenter(x, y) {
  return (((this.centerX - centerLeeway) <= x) &&
	  (x <= (this.centerX + centerLeeway)) &&
	  ((this.centerY - centerLeeway) <= y) &&
	  (y <= (this.centerY + centerLeeway)));
}

function Selection_draw() {
    this.painter.clear();
    this.painter.drawRect(this.centerX - this.radius, 
			  this.centerY - this.radius, 
			  this.radius * 2, 
			  this.radius * 2);
    this.painter.paint();
}

function Selection_drawID(num) {
  this.painter.setFont("arial","16px");
  this.painter.setColor("#a90000");
  this.painter.drawString(num, 
			  this.centerX + this.radius - 18, 
			  this.centerY + this.radius - 20);
  this.painter.paint();
}

function Selection_drawCenterDot() {
  var dotRadius = centerLeeway - 2;
  this.painter.fillRect(this.centerX - dotRadius, 
			this.centerY - dotRadius,
			(2 * dotRadius) + 1, 
			(2 * dotRadius) + 1);
  this.painter.paint();
}

// Constructor for Selection object
// If faux, then don't bother to create a real thing
function Selection(centerX, centerY, faux) {
  this.centerX = centerX;
  this.centerY = centerY;
  // 'radius' is half the width/height
  this.radius = 0;

  // only set this if we're creating a real selection
  if (!faux) {
    this.painter = new jsGraphics("layerOnTopOfImage");
    this.painter.setColor("#d90000");
    this.painter.setStroke(2);
  }
}

// Forces prototype object to be created:
new Selection(0, 0, 1);

// Define methods of Selection class via an object prototype:
Selection.prototype.intersect = Selection_intersect;
Selection.prototype.intersectCenter = Selection_intersectCenter;
Selection.prototype.draw = Selection_draw;
Selection.prototype.drawID = Selection_drawID;
Selection.prototype.drawCenterDot = Selection_drawCenterDot;

/*********************************
 Managing Selections
 *********************************/

// Returns a selection from selectionArray
// where (x, y) is within its boundaries
function getSelection(x, y) {
  for (i in selectionArray) {
    var curSelection = selectionArray[i];
    if (curSelection.intersect(x, y)) {
      //      alert('intersect: ' + i);
      return curSelection;
    }
  }
  return 0;
}

// Returns a selection from selectionArray
// where (x, y) is near its center
function getSelectionCenter(x, y) {
  for (i in selectionArray) {
    var curSelection = selectionArray[i];
    if (curSelection.intersectCenter(x, y)) {
      return curSelection;
    }
  }
  return 0;
}

/*********************************
 Time for Action!
 *********************************/

function InitPage() {
  imageFilename = location.search.substring(1);

  myImage = document.getElementById ? 
    document.getElementById("myImage") : 
    document.all.myImage;

  layerOnTopOfImage = document.getElementById ? 
    document.getElementById("layerOnTopOfImage") : 
    document.all.layerOnTopOfImage;

  myImage.src = imageFilename;

  selectionArray = new Array();
}

// Do this so that the width and height of the image can be initialized
function ImageLoaded() {
  // Remember to set these to strings!
  layerOnTopOfImage.style.width = myImage.width + "px";
  layerOnTopOfImage.style.height = myImage.height + "px";
  ready = true;
}

// These calculations depend on where the image is placed 
// on the page in animated-gif-maker.html
function getRealX(pageX) {
  return pageX - 10;
}

function getRealY(pageY) {
  return pageY - 100;
}

function MouseDown(pageX, pageY) {
  if (ready && !isMouseDown) {
    isMouseDown = true;
    var centerX = getRealX(pageX);
    var centerY = getRealY(pageY);
    positionLock = false;
    xOverflow = false;
    yOverflow = false;
    layerOnTopOfImage.style.cursor = "move";

    // This is to ensure that when you try to create a new
    // selection with the same center as an existing one, 
    // their centerX and centerY values match up EXACTLY
    // in order to get the greatest benefits from zooming
    var tempSelection = getSelectionCenter(centerX, centerY);
    if (tempSelection) {
      centerX = tempSelection.centerX;
      centerY = tempSelection.centerY;
    }

    activeSelection = new Selection(centerX, centerY);
    selectionArray.push(activeSelection);
  }
}

function MouseUp() {
  //  alert("MouseUp!");
  if (ready && isMouseDown) {
    // Reject if it's too small
    if (activeSelection.radius < 10) {
      selectionArray.pop();
      activeSelection.painter.clear();
    }
    else {
      activeSelection.drawCenterDot();
      activeSelection.drawID(currentID);
      activeSelection = 0;
      currentID++;
    }

    isMouseDown = false;
    positionLock = false;
    xOverflow = false;
    yOverflow = false;
    layerOnTopOfImage.style.cursor = "crosshair";
  }
}

// function MouseClick(pageX, pageY) {
//   if (isMouseDown) {
//     isMouseDown = false;
//     centerX = -1;
//     centerY = -1;
//     halfCurrentSize = -1;
//     positionLock = false;
//     xOverflow = false;
//     yOverflow = false;
//   }
//   else {
//     isMouseDown = true;
//     centerX = getRealX(pageX);
//     centerY = getRealY(pageY);
//     halfCurrentSize = 0;
//     positionLock = false;
//     xOverflow = false;
//     yOverflow = false;
//   }
// }

function MouseMove(pageX, pageY) {
  if (isMouseDown) {
    var realX = getRealX(pageX);
    var realY = getRealY(pageY);

    var xRadius = Math.abs(realX - activeSelection.centerX);
    var yRadius = Math.abs(realY - activeSelection.centerY);


    // Keep it square-shaped by taking the maximum
    if (!positionLock) {
      activeSelection.radius = Math.max(xRadius, yRadius);
    }

    // Border check

    if (!xOverflow) {
      if ((activeSelection.centerX - activeSelection.radius) < 0) {
	activeSelection.radius = activeSelection.centerX;
	positionLock = true;
	xOverflow = true;
      }
      else if ((activeSelection.centerX + activeSelection.radius) > myImage.width) {
	activeSelection.radius = myImage.width - activeSelection.centerX;
	positionLock = true;
	xOverflow = true;
      }
    }
    else {
      if (((activeSelection.centerX - activeSelection.radius) >= 0) && 
	  ((activeSelection.centerX + activeSelection.radius) <= myImage.width)) {
	xOverflow = false;
      }
    }
    
    if (!yOverflow) {
      if ((activeSelection.centerY - activeSelection.radius) < 0) {
	activeSelection.radius = activeSelection.centerY;
	positionLock = true;
	yOverflow = true;
      }
      else if ((activeSelection.centerY + activeSelection.radius) > myImage.height) {
	activeSelection.radius = myImage.height - activeSelection.centerY;
	positionLock = true;
	yOverflow = true;
      }
    }
    else {
      if (((activeSelection.centerY - activeSelection.radius) >= 0) && 
	  ((activeSelection.centerY + activeSelection.radius) <= myImage.height)) {
	yOverflow = false;
      }
    }

    if (positionLock && !xOverflow && !yOverflow) {
      positionLock = false;
    }

    activeSelection.draw();
  }
}

/*********************************
 Generating Output
 *********************************/

function GenerateCoordinates() {
  var handle = window.open('', 'outputWin', 'width=400,height=600,menubar=yes');
  if (window.focus) handle.focus();

  var body = handle.document.body;
  var textArray = new Array();
  // Write the actual content:
  for (var i = 0; i < selectionArray.length; i++) {
    var sel = selectionArray[i];
    textArray.push(new String(sel.centerX + ' ' + sel.centerY + ' ' + (2 * sel.radius) + ' num-frames'));
  }

  body.innerHTML = textArray.join('<br>');
}
