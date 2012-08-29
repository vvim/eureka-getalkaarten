/*

Based on: http://www.dhtmlgoodies.com/index.html?whichScript=drag-drop-nodes-quiz

Javascript variables:
	boxSizeArray
	 = An array indicating max number of items("students") in the small boxes on the right side.

	arrow_offsetX
	 = Horizontal offset of small arrow - You may have to adjust this value to get the small arrow positioned correctly

	arrow_offsetY
	 = Vertical offset of small arrow

	arrow_offsetX_firefox and arrow_offsetY_firefox
	 = Same as above, but for Firefox.

	initOrderItems
	 = Was called "initShuffleItems" in the original script: The left side items will be shuffled when the script loads.
	   Adapted it so it would put all the 'getalkaarten' in order, renamed

	indicateDestionationByUseOfArrow
	 = Indicate where objects will be dropped with an arrow. If you set this variable to false, it will use a rectangle instead.

*/
/************************************************************************************************************
Copyright (C) December 2005  DTHMLGoodies.com, Alf Magne Kalleland

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

Dhtmlgoodies.com., hereby disclaims all copyright interest in this script
written by Alf Magne Kalleland.

Alf Magne Kalleland, 2010
Owner of DHTMLgoodies.com

************************************************************************************************************/
	
/* VARIABLES YOU COULD MODIFY */
var boxSizeArray = [3,3,3,3,3,3,3];	// Array indicating how many items there is rooom for in the right column ULs

var arrow_offsetX = -5;	// Offset X - position of small arrow
var arrow_offsetY = 0;	// Offset Y - position of small arrow

var arrow_offsetX_firefox = -6;	// Firefox - offset X small arrow
var arrow_offsetY_firefox = -13; // Firefox - offset Y small arrow

var verticalSpaceBetweenListItems = 3;	// Pixels space between one <li> and next	
										// Same value or higher as margin bottom in CSS for #dhtmlgoodies_dragDropContainer ul li,#dragContent li

var indicateDestionationByUseOfArrow = true;	// Display arrow to indicate where object will be dropped(false = use rectangle)

/* END VARIABLES YOU COULD MODIFY */

var dragDropTopContainer = false;
var dragTimer = -1;
var dragContentObj = false;
var contentToBeDragged = false;	// Reference to dragged <li>
var contentToBeDragged_src = false;	// Reference to parent of <li> before drag started
var contentToBeDragged_next = false; 	// Reference to next sibling of <li> to be dragged
var destinationObj = false;	// Reference to <UL> or <LI> where element is dropped.
var dragDropIndicator = false;	// Reference to small arrow indicating where items will be dropped
var ulPositionArray = new Array();
var mouseoverObj = false;	// Reference to highlighted DIV

var MSIE = navigator.userAgent.indexOf('MSIE')>=0?true:false;
var navigatorVersion = navigator.appVersion.replace(/.*?MSIE (\d\.\d).*/g,'$1')/1;
var destinationBoxes = new Array();
var indicateDestinationBox = false;
	
function getTopPos(inputObj)
{		
  var returnValue = inputObj.offsetTop;
  while((inputObj = inputObj.offsetParent) != null){
  	if(inputObj.tagName!='HTML')returnValue += inputObj.offsetTop;
  }
  return returnValue;
}

function getLeftPos(inputObj)
{
  var returnValue = inputObj.offsetLeft;
  while((inputObj = inputObj.offsetParent) != null){
  	if(inputObj.tagName!='HTML')returnValue += inputObj.offsetLeft;
  }
  return returnValue;
}
	
function cancelEvent()
{
	return false;
}

function initOrderItems()
{
	/* WIM: deze functie gebruiken om de getalkaarten telkens op volgorde te houden??? */
	// <vvim>
			// 1. get the <UL>-element from the BODY
			var nList = document.getElementById("allItems");
			// 2. extract all the <LI>-elements from that <UL> and put it in a NodeList
			var nEntry = nList.getElementsByTagName('li');

			// 3. we can't sort a NodeList, so first make it an Array
			var nEntryArray = Array.prototype.slice.call(nEntry, 0);

			// 4. sort the array, the normal sort()-function won't do because it is an alphabetical sort
			// to sort() numeric values, see http://www.w3schools.com/jsref/jsref_sort.asp example, as "Default sort order is alphabetic and ascending. When numbers are sorted alphabetically, "40" comes before "5".  To perform a numeric sort, you must pass a function as an argument when calling the sort method."
			// the numeric value of the <LI> nodes can be located in nEntryArray[i].firstChild.nodeValue , so compare those

			nEntryArray.sort(function(a,b){
				return a.firstChild.nodeValue - b.firstChild.nodeValue
			})

			// 5. empty the nList and refill it with those in the correct order at the nEntryArray
			while (nList.lastChild)
			{
				nList.removeChild(nList.lastChild);
			}

			for (i=0; i<nEntryArray.length; i++)
			{
				nList.appendChild(nEntryArray[i]);
			}

			// 6. Tadaaaah, shit is tight!

	// </vvim>
}


function initDrag(e)	// Mouse button is pressed down on a LI
{
	if(document.all)e = event;
	
	var st = Math.max(document.body.scrollTop,document.documentElement.scrollTop);
	var sl = Math.max(document.body.scrollLeft,document.documentElement.scrollLeft);
	
	dragTimer = 0;
	dragContentObj.style.left = e.clientX + sl + 'px';
	dragContentObj.style.top = e.clientY + st + 'px';
	contentToBeDragged = this;
	contentToBeDragged_src = this.parentNode;
	contentToBeDragged_next = false;
	if(this.nextSibling){
		contentToBeDragged_next = this.nextSibling;
		if(!this.tagName && contentToBeDragged_next.nextSibling)contentToBeDragged_next = contentToBeDragged_next.nextSibling;
	}
	timerDrag();
	return false;
}

function timerDrag()
{
	if(dragTimer>=0 && dragTimer<10){
		dragTimer++;
		setTimeout('timerDrag()',10);
		return;
	}
	if(dragTimer==10){
		dragContentObj.style.display='block';
		dragContentObj.appendChild(contentToBeDragged);
	}
}

function moveDragContent(e)
{
	if(dragTimer<10){
		if(contentToBeDragged){
			if(contentToBeDragged_next){
				contentToBeDragged_src.insertBefore(contentToBeDragged,contentToBeDragged_next);
			}else{
				contentToBeDragged_src.appendChild(contentToBeDragged);
			}	
		}
		return;
	}
	if(document.all)e = event;
	var st = Math.max(document.body.scrollTop,document.documentElement.scrollTop);
	var sl = Math.max(document.body.scrollLeft,document.documentElement.scrollLeft);
	
	
	dragContentObj.style.left = e.clientX + sl + 'px';
	dragContentObj.style.top = e.clientY + st + 'px';
	
	if(mouseoverObj)mouseoverObj.className='';
	destinationObj = false;
	dragDropIndicator.style.display='none';
	if(indicateDestinationBox)indicateDestinationBox.style.display='none';
	var x = e.clientX + sl;
	var y = e.clientY + st;
	var width = dragContentObj.offsetWidth;
	var height = dragContentObj.offsetHeight;
	
	var tmpOffsetX = arrow_offsetX;
	var tmpOffsetY = arrow_offsetY;
	if(!document.all){
		tmpOffsetX = arrow_offsetX_firefox;
		tmpOffsetY = arrow_offsetY_firefox;
	}

	for(var no=0;no<ulPositionArray.length;no++){
		var ul_leftPos = ulPositionArray[no]['left'];	
		var ul_topPos = ulPositionArray[no]['top'];	
		var ul_height = ulPositionArray[no]['height'];
		var ul_width = ulPositionArray[no]['width'];
		
		if((x+width) > ul_leftPos && x<(ul_leftPos + ul_width) && (y+height)> ul_topPos && y<(ul_topPos + ul_height)){
			var noExisting = ulPositionArray[no]['obj'].getElementsByTagName('LI').length;
			if(indicateDestinationBox && indicateDestinationBox.parentNode==ulPositionArray[no]['obj'])noExisting--;
			if(noExisting<boxSizeArray[no-1] || no==0){
				dragDropIndicator.style.left = ul_leftPos + tmpOffsetX + 'px';
				var subLi = ulPositionArray[no]['obj'].getElementsByTagName('LI');
				for(var liIndex=0;liIndex<subLi.length;liIndex++){
					var tmpTop = getTopPos(subLi[liIndex]);
					if(!indicateDestionationByUseOfArrow){
						if(y<tmpTop){
							destinationObj = subLi[liIndex];
							indicateDestinationBox.style.display='block';
							subLi[liIndex].parentNode.insertBefore(indicateDestinationBox,subLi[liIndex]);
							break;
						}
					}else{							
						if(y<tmpTop){
							destinationObj = subLi[liIndex];
							dragDropIndicator.style.top = tmpTop + tmpOffsetY - Math.round(dragDropIndicator.clientHeight/2) + 'px';
							dragDropIndicator.style.display='block';
							break;
						}	
					}					
				}
				
				if(!indicateDestionationByUseOfArrow){
					if(indicateDestinationBox.style.display=='none'){
						indicateDestinationBox.style.display='block';
						ulPositionArray[no]['obj'].appendChild(indicateDestinationBox);
					}
					
				}else{
					if(subLi.length>0 && dragDropIndicator.style.display=='none'){
						dragDropIndicator.style.top = getTopPos(subLi[subLi.length-1]) + subLi[subLi.length-1].offsetHeight + tmpOffsetY + 'px';
						dragDropIndicator.style.display='block';
					}
					if(subLi.length==0){
						dragDropIndicator.style.top = ul_topPos + arrow_offsetY + 'px'
						dragDropIndicator.style.display='block';
					}
				}
				
				if(!destinationObj)destinationObj = ulPositionArray[no]['obj'];
				mouseoverObj = ulPositionArray[no]['obj'].parentNode;
				mouseoverObj.className='mouseover';
				return;
			}
		}
	}
}

/* End dragging 
Put <LI> into a destination or back to where it came from.
*/	
function dragDropEnd(e)
{
	if(dragTimer==-1)return;
	if(dragTimer<10){
		dragTimer = -1;
		return;
	}
	dragTimer = -1;
	if(document.all)e = event;		
	if(destinationObj){
		if(destinationObj.id=='allItems' || destinationObj.parentNode.id=='allItems')contentToBeDragged.className='';
		
		
		if(destinationObj.tagName=='UL'){
			destinationObj.appendChild(contentToBeDragged);
		}else{
			destinationObj.parentNode.insertBefore(contentToBeDragged,destinationObj);
		}
		mouseoverObj.className='';
		destinationObj = false;
		dragDropIndicator.style.display='none';
		if(indicateDestinationBox){
			indicateDestinationBox.style.display='none';
			document.body.appendChild(indicateDestinationBox);
		}
					
		contentToBeDragged = false;
		
		saveDragDropNodes();

		//<vvim>
		initOrderItems();
		//</vvim>

		return;
	}	
	if(contentToBeDragged_next){
		contentToBeDragged_src.insertBefore(contentToBeDragged,contentToBeDragged_next);
	}else{
		contentToBeDragged_src.appendChild(contentToBeDragged);
	}
	contentToBeDragged = false;
	dragDropIndicator.style.display='none';
	if(indicateDestinationBox){
		indicateDestinationBox.style.display='none';
		document.body.appendChild(indicateDestinationBox);
		
	}		
	mouseoverObj = false;
}

/* 
Preparing data to be saved 
*/
function saveDragDropNodes()
{
	// <vvim> to put information in hidden <input> from <form> so that it can be submitted.
	// dit zou eleganter moeten kunnen, vooral het optellen met lis[i].firstChild.nodeValue is nogal bizar
	var saveString = 0;
	var uls = document.getElementById('kaartendropping');
	var lis = uls.getElementsByTagName('LI');
	for(var i=0;i<lis.length;i++){
		saveString = saveString + Number(lis[i].firstChild.nodeValue);
	}		
	
	console.log(saveString)
	document.getElementById('uitkomst').value = saveString;
	//</vvim>
}

function initDragDropScript()
{
	dragContentObj = document.getElementById('dragContent');
	dragDropIndicator = document.getElementById('dragDropIndicator');
	dragDropTopContainer = document.getElementById('dhtmlgoodies_dragDropContainer');
	document.documentElement.onselectstart = cancelEvent;;
	var listItems = dragDropTopContainer.getElementsByTagName('LI');	// Get array containing all <LI>
	var itemHeight = false;
	for(var no=0;no<listItems.length;no++){
		listItems[no].onmousedown = initDrag;
		listItems[no].onselectstart = cancelEvent;
		if(!itemHeight)itemHeight = listItems[no].offsetHeight;
		if(MSIE && navigatorVersion/1<6){
			listItems[no].style.cursor='hand';
		}			
	}
	
	var mainContainer = document.getElementById('dhtmlgoodies_mainContainer');
	var uls = mainContainer.getElementsByTagName('UL');
	itemHeight = itemHeight + verticalSpaceBetweenListItems;
	for(var no=0;no<uls.length;no++){
		uls[no].style.height = itemHeight * boxSizeArray[no]  + 'px';
		destinationBoxes[destinationBoxes.length] = uls[no];
	}
	
	var leftContainer = document.getElementById('dhtmlgoodies_listOfItems');
	var itemBox = leftContainer.getElementsByTagName('UL')[0];
	
	document.documentElement.onmousemove = moveDragContent;	// Mouse move event - moving draggable div
	document.documentElement.onmouseup = dragDropEnd;	// Mouse move event - moving draggable div
	
	var ulArray = dragDropTopContainer.getElementsByTagName('UL');
	for(var no=0;no<ulArray.length;no++){
		ulPositionArray[no] = new Array();
		ulPositionArray[no]['left'] = getLeftPos(ulArray[no]);	
		ulPositionArray[no]['top'] = getTopPos(ulArray[no]);	
		ulPositionArray[no]['width'] = ulArray[no].offsetWidth;
		ulPositionArray[no]['height'] = ulArray[no].clientHeight;
		ulPositionArray[no]['obj'] = ulArray[no];
	}

	initOrderItems();

	if(!indicateDestionationByUseOfArrow){
		indicateDestinationBox = document.createElement('LI');
		indicateDestinationBox.id = 'indicateDestination';
		indicateDestinationBox.style.display='none';
		document.body.appendChild(indicateDestinationBox);
	}		
	
}

window.onload = initDragDropScript;