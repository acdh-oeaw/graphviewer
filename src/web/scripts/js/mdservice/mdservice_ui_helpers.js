/**
 * @fileOverview  The file contains UI concerned functions for building the pane structure from app settings 
 * and a lot of other UI functionality for example tooltips, notifymessges, ui-block handling
 *
 * @author 
 * @version 
 */
function createBlock(name, _parent){
	var ui_array;
	var layout;
	var _class;
	var len;
	var e, layout_elem;
	var _parent;
	var layout_div;
	
	// append UI
	if (_parent == ""){
		layout_initialisation[name].parent = $('body');
	} else {
		layout_initialisation[name].parent = _parent;
	}
 
	var settings;
	if (layout_initialisation[name].settings == ""){
		settings = new CloneObject(layout_initialisation[name].model_settings);
	} else {
		settings = layout_initialisation[name].settings;
	}
	 
	jQuery.each(block_positions, function(index,position){
		if (layout_initialisation[name][position] != undefined){
			ui_array = layout_initialisation[name][position];	
			len = ui_array.lenght;
			jQuery.each(ui_array, function(index,elem){
					var e = elem;
					
					
					if (layout_initialisation[elem] != undefined){
						layout_div = $('<div></div>').addClass(name + '-' + position).addClass("cmds-ui-block").attr("layoutname",name);
						e = createBlock(elem, layout_div);  // compode element
						$(layout_div).append($(e));
						layout_initialisation[name].parent.append($(layout_div));
					} else {
						$(e).addClass(name + '-' + position).attr("layoutname",name);
						if (blocks_settings[$(elem).attr("id")] != undefined) {
							//jQuery.each(blocks_settings[$(elem).attr("id")].sublayouts,function(index, ee){
							//	createBlock(ee, $('#' + ee));
							//});
							jQuery.each(blocks_settings[$(elem).attr("id")].commands.block,function(index, cmd){
								createCommand($(elem), cmd);
								bindCommand($(elem), cmd);
							});
						}
						layout_initialisation[name].parent.append($(e));
					}
					
					//layout_initialisation[name].parent.height(layout_initialisation[name].parent.height() + $(layout_div).height());
					settings[position + "__paneSelector"] = "." + name + "-" + position;
					//position + "__paneSelector" = "." + name + "-" + position
			});
		}
	});
	
	layout_initialisation[name].settings = settings;
	return $(layout_div);
}

function createLayouts(name){
	var ui_array;
	var layout;
	
	// append UI	
	layout = $(layout_initialisation[name].parent).layout(layout_initialisation[name].settings);

	layout_initialisation[name].layout = layout;
	jQuery.each(block_positions, function(index,position){
		if (layout_initialisation[name][position] != undefined){
			ui_array = layout_initialisation[name][position];	
			jQuery.each(ui_array, function(index,elem){
				if (layout_initialisation[elem] != undefined){
					createLayouts(elem);
				}
			});
		}
	});

}


//append blocks functionality
function createCommand(parent, cmd){
	$("<span class='cmd " + cmd+ "'></span>").appendTo($(parent).children('.header'));
	return  $(parent).children('.header').children('.' + cmd);
}

function bindCommand(parent, cmd){
	var command = $(parent).children('.header').children('.' + cmd);
	switch (cmd){
	case "cmd_close": 
		bindCloseCommand(command);
		break;
	case "cmd_advanced": 
		bindAdvancedCommand(command);
		break;
	default:
		break;
	}
}

function bindAdvancedCommand(cmd){
	$(cmd).click(function(){
		//var advanced = $(this).closest('.cmds-ui-block').attr("id") + '_advanced';
		$(this).closest('.cmds-ui-block').find('.ui-advanced').toggle();
		// TODO tag <table>  auto-resize dont work !!!!!  
		//if ($(this).closest('.cmds-ui-block').find('.ui-advanced').is(":visible") == false){
		//	var name = $(this).closest('.cmds-ui-block').attr("layoutname");
		//	layout_initialisation[name].layout.sizePane("north",$("#input-simplequery").height(),false, false);
		//}
	});
}

function bindCloseCommand(cmd){
	$(cmd).click(function(){
		$(this).closest('.cmds-ui-block').hide();
	});
}

////
function handleValueCaller(_this){

	$(_this).after('<div class="ui-context-dialog cmds-ui-closable cmd cmd_get" ></div>');					
	detail = $(_this).parent().children('.ui-context-dialog');				
				
	detail.load($(_this).attr('href'), function(event) {
				$(this).removeClass('cmd_get cmd');
				handleUIBlock($(this).children('.cmds-ui-block'));
				addPaging($(this).children('.cmds-ui-block'));
				$(this).show();
				
				$(this).find('.cmd_columns').click(function(event) {
					event.preventDefault();
					handleValueSelection($(this));
				});
				});
}
function handleIndexSelection(elem){
	var index = $(elem).closest('.treecol').children('.column-elem').text();
	searchclauseset.updatedata(index, false);
};
function handleValueSelection(elem){
	var index = undefined;
	if ($(elem).closest('.ui-context-dialog').parent().siblings('.treecol').length > 0){
		index = $(elem).closest('.ui-context-dialog').parent().siblings('.treecol').children('.column-elem').text();
	} 
	var value = $(elem).closest('td').text();
	searchclauseset.updatedata(index, false, undefined, value);
};
//
function handleUIBlock (elems) 
{
	
//	$('#left-menu').addClass('ui-accordion ui-widget ui-helper-reset ui-accordion-icons');	
	$(elems).addClass('ui-helper-reset ui-corner-all');
	$(elems).children('.header').addClass('ui-widget-header ui-state-default ui-corner-top');
	$(elems).children('.content').addClass('ui-widget-content ui-corner-bottom');
/*	$(elems).children('.header').click(function() {
		$(this).next().toggle('fast');
		return false;
	}).next().hide();
	*/
	
	$(elems).children('.header').prepend('<span class="cmd cmd-collapse cmd_down" > </span>');
	$(elems).find('.cmd-collapse').click(function(event) {
			$(this).closest('.header').next().toggle('fast');
			$(this).toggleClass('cmd_down cmd_up');
			return false;
		});
	
	$(elems).each(function(i) {
		// default is: hidden
		
		if ($(this).hasClass('init-show'))  {		
			$(this).children('.content').show();
			$(this).find('.cmd-collapse').toggleClass('cmd_down cmd_up');		
		} else {
			$(this).children('.content').hide();			
		}		
			
		if ($(this).parent().hasClass('cmds-ui-closable'))  {		
			$(this).children('.header').prepend('<span class="cmd cmd_close" > </span>');
			$(this).find('.cmd_close').click(function(event) {
					$(this).closest('.header').parent().parent('.cmds-ui-closable').remove();	
				});
		} 
	});
}


function addPaging (elem) 
{
	
	var header = $(elem).children('.header');
	var content = $(elem).children('.content');
	
	var pagingSize = 10;
	var startItem = $(header).attr('start-item');
	var countItems = $(header).attr('max-value'); //$(content).find('tr').size;
	var maximumItems = $(header).attr('maximum-items');
	
	if (maximumItems < countItems) {
		maximumItems = countItems;
	} 

	var paging = '<div class="cmds-navi-header ui-widget"><span class="label" >from:</span><span><input type="text" class="value start-item paging-input">' +
	'</input></span>' +
	'<span class="label" >max:</span><span><input type="text" class="value maximum-items paging-input" ></input></span>' +
  '<span class="cmd cmd_reload" />' +
	'<span class="cmd cmd_prev">'+
	//'<xsl:choose>' +
	//	'<xsl:when test="$startItem = '1'">' +
	//		'<xsl:attribute name="disabled">disabled</xsl:attribute>' +
	//	'</xsl:when>' +
	//'</xsl:choose>' +
	'</span>' +
	'<span class="cmd cmd_next">' +	
	//'<xsl:choose>' +
	//	'<xsl:when test="$maximumItems &gt; numberOfRecords or $maximumItems = numberOfRecords">' +
	//		'<xsl:attribute name="disabled">disabled</xsl:attribute>' +
	//	'</xsl:when>' +
	//	'</xsl:choose>' +
	'</span></div';
	
	$(header).append(paging);
	$(header).find('.start-item').attr("value",startItem);
	$(header).find('.maximum-items').attr("value",maximumItems);
	
	$(header).find('.cmd_reload').click(function(){
		reloadPage($(this).closest('.cmds-ui-block'));
		return false;
	});
	
	$(header).find('.cmd_next').click(function(){
		pageNext(this, 1);
		return false;
	});
	$(header).find('.cmd_prev').click(function(){
		pageNext(this, -1);
		return false;
	});	

}

function pageNext (cmd, pages) 
{
	//TODO
	var numItems = $(cmd).closest('.header').attr('max-value'); //$(cmd).closest('.cmds-ui-block').children('.content').find('tr').length;
	var startItem = $(cmd).closest('.header').attr('start-item');
	var maximumItems = $(cmd).closest('.header').attr('maximum-items');
	
	var page_record_count = 10;
	var start = 0;
	var num = 0;
	//var max_value = $('#' + qid ).find('.result-header').attr("max_value");

	if (maximumItems > page_record_count) {
		maximumItems = page_record_count;
	}
	if ((numItems >= maximumItems) && (pages > 0) ){
		start =	parseInt(startItem) + pages * page_record_count ;
	} 
	if ((pages < 0) && ((parseInt(startItem) + pages * parseInt(page_record_count) + parseInt(page_record_count) - 1) >= 1)) {
		start = parseInt(startItem) + pages * parseInt(page_record_count);
	}
	
	if (start > 0){
		num = maximumItems;
		
		if (num > 0){
			$(cmd).closest('.header').find('.start-item').attr('value',start);
			$(cmd).closest('.header').find('.maximum-items').attr('value',num);
			
			reloadPage($(cmd).closest('.cmds-ui-block'));
		}
	}

	/*
	if (parseInt(startItem) + pages * page_record_count >= 1){
		start =	parseInt(startItem) + pages * page_record_count ;
	} else  {
		if (parseInt(startItem) + pages * page_record_count + page_record_count - 1 >= 1){
			start =	1 ;
		} 
	}
	
	if (start > 0){
		if (start + page_record_count - 1 <= numItems) {
			num = page_record_count;
		} else if (start <= numItems){
			num = numItems - start;
		}
	
		if (num > 0){
			$(cmd).closest('.header').find('.start-item').attr('value',start);
			$(cmd).closest('.header').find('.maximum-items').attr('value',num);
			
			reloadPage($(cmd).closest('.cmds-ui-block'));
		}
	}
	*/
}

function reloadPage (detail) {
	
	var uri;
	
	if ($(detail).parent().get(0).localName == "body") {
		uri = document.URL;
	} else {
		uri = $(detail).parents('.number').children('a').attr('href');
	}

	
	var startItem;
	var maximumItems;
	
	//from paging attributes
	startItem = $(detail).find('.header').find('.start-item').val();
	maximumItems = $(detail).find('.header').find('.maximum-items').val();
	

	// create the uri params
	
	if (uri.indexOf("startItem=") > 0){
		 temp = uri.substring(uri.indexOf("startItem="));
		 len = temp.split("&")[0].length;
		 uri = uri.replace(uri.substr(uri.indexOf("&startItem="),len+1),'');
	}
	
	if (uri.indexOf("maximumItems=") > 0){
		 temp = uri.substring(uri.indexOf("maximumItems="));
		 len = temp.split("&")[0].length;
		 uri = uri.replace(uri.substr(uri.indexOf("&maximumItems="),len+1),'');
	} 
	
	uri = uri + "&startItem=" + startItem + "&maximumItems=" + maximumItems;

	if ($(detail).parent().get(0).localName == "body") {
		location.href = uri;
//		window.open(uri);
	} else {	
		//remove old content
		$(detail).children().remove();
		
		//load new content
		$(detail).load(uri, function(event) {
			handleUIBlock($(this).children('.cmds-ui-block'));
			addPaging($(this).children('.cmds-ui-block'));
		});
	}
}



//TOOLTIP
var tooltiptable = {};

/** 
 * Helper-object for displaying tooltips
 * @constructor
 */
var tooltip=function(){
	 var id = 'tt';
	 var top = 3;
	 var left = 3;
	 var maxw = 300;
	 var speed = 10;
	 var timer = 20;
	 var endalpha = 95;
	 var alpha = 0;
	 var tt,t,c,b,h;
	 var ie = document.all ? true : false;
	 return{

	show:function(v,w){
		 if(tt == null){
			 tt  = document.createElement('div');
			 tt.setAttribute('id',id);
			 document.body.appendChild(tt);
			 tt.style.opacity  = 0;
			 tt.style.filter  = 'alpha(opacity=0)';
			 document.onmousemove  = this.pos;
			}
		 tt.style.zIndex = "1000";
		tt.style.display  = 'block';
		tt.innerHTML = v; 
		tt.style.width  = w ? w + 'px' : 'auto';

			if(!w  && ie){
			 tt.style.width  = tt.offsetWidth;
			}

			if(tt.offsetWidth  > maxw){tt.style.width = maxw + 'px';}

			h =  parseInt(tt.offsetHeight) + top;
			clearInterval(tt.timer);
			tt.timer =  setInterval(function(){tooltip.fade(1);},timer);
		//$('body').find('.ac_results').css({'z-index' : '1000'});
	  },
	  
	  pos:function(e){
	   var u = ie ? event.clientY + document.documentElement.scrollTop : e.pageY;
	   var l = ie ? event.clientX + document.documentElement.scrollLeft : e.pageX;
	   tt.style.top = (u + h) + 'px'; //(u - h) + 'px';
	   tt.style.left = (l + left) + 'px';
	  },
	  
	  fade:function(d){
	   var a = alpha;
	   if((a != endalpha && d == 1) || (a != 0 && d == -1)){
	    var i = speed;
	   if(endalpha - a < speed && d == 1){
	    i = endalpha - a;
	   }else if(alpha < speed && d == -1){
	     i = a;
	   }
	   alpha = a + (i * d);
	   tt.style.opacity = alpha * .01;
	   tt.style.filter = 'alpha(opacity=' + alpha + ')';
	  }else{
	    clearInterval(tt.timer);
	     if(d == -1){tt.style.display = 'none';};
	  }
	 },
	
	 hide:function(){
		 if (tt != undefined) {
			 clearInterval(tt.timer);
			 tt.timer = setInterval(function(){tooltip.fade(-1);},timer);
		 }
	  }
	 };
	}();


	function notifyUser (msg) {
		var notifymessage = new NotifyMessage(new Date(),msg);	
		notifyset.add(notifymessage);
	}

	function notifyUser (msg, type) {	
		
			if (type=='debug' & !(typeof console == "undefined")) {
				console.log(msg);
			} else {
				var notifymessage = new NotifyMessage(new Date(),msg);	
				notifyset.add(notifymessage);
		  }
	}