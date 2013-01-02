
/**
 * @fileOverview The file builds important widgets used in app.
 * Following widqets are defined:
 * <dl>
 * <dt>notifyMessage</dt><dd>model and bulding of set of notifyMessages</dd>
 * <dt>listWidget</dt><dd>the compact widget for creation list of elements, possible add, remove elements, addition through html - input 
 *	possible to use autocomplete</dd>
 * </dl>
 * @author 
 * @version 
 */
 
/**
 * 
 * @constructor 
 */
function NotifyMessage(dt, msg){
	this.dt = dt;
	this.msg = msg;
};

NotifyMessage.prototype.getText = function(){

	var month = this.dt.getMonth() + 1;
	var day = this.dt.getDate();
	var year = this.dt.getFullYear();
	var h = this.dt.getHours();
	var m = this.dt.getMinutes();
	var s = this.dt.getSeconds();
	var m =  year + "-" +  month + "-" + day + " "  + h + ":" + m + ":" + s + "  :" + this.msg;
	return m;
};


NotifyMessage.prototype.render = function () {
	var x = "<div id='" + this.listid + "' class='notify_wrapper ui-widget' >" +
			//"<span class='notifymessage_id'>" + this.listid + "</span>: " +
			"<span class='notifymessage'>" + this.getText() + "</span></div>";
	addToNotifylist(x);	
	
	this.container = $('#' + this.listid );
	$(this.container).find('.notifymessage').dblclick(function(){
		showNotifyMessages();
	});
 };
var notify_container = $("#notifylist"); 

/**
 * Maintains the notify messages
 * @constructor 
 */
var notifyset = { notifymessages: [],
	container: '#notifylist',
		
	add: function (notifymessage){
			
		this.notifymessages[this.notifymessages.length] = notifymessage;
		notifymessage.listid = "nm" + this.notifymessages.length;
		notifymessage.render();				
	},

	remove: function (mid) {		
		 for (var i = 0; i < this.notifymessages.length; i++) {
			if (this.notifymessages[i].listid == mid) {
				this.notifymessages.splice(i, 1);
			} 
		}	
		$('#' + mid).remove();
	}	
};
////////////////////////////////////////////////////////////////////////

/**
 * @field 
 * @memberOf ListWidget
 */
var collections_widget = null;

/**
 * @field 
 * @memberOf ListWidget
 */
var columns_widget = null;

/**
 * @field 
 * @memberOf ListWidget
 */
var active_widget = null;

/**
 * A generic widget allowing manipulating lists
 * @constructor 
 */
function ListWidget(_parent_div, type) {
	this.parent_div = $(_parent_div);//$('#columns-widget');	
	this.listwidget_container = {};
	this.widgets = [];
	this.lvid = "";
	this.type = type;
	
	//this.query = undefined;
	//this.init();
	
};
/*
ListWidget.prototype.getType = function(){
	if (this.type == "collections") {
		return "cls";
	}
	return "col";
};
*/
ListWidget.prototype.getTypePrefix = function(){
	var typeprefix = "";
	if (this.type == "columns") {
		typeprefix =  "col_";
	} 
	if (this.type == "collections") {
		typeprefix =  "cls_";
	} 
	typeprefix = typeprefix + this.lvid + "_";
	//var qid = $(this).closest('.query_wrapper').attr("id");
	return typeprefix;//"col_" + qid + "_";
	
};

ListWidget.prototype.add = function(list_item){
	this.widgets[this.widgets.length] = list_item;
	list_item.parent_container = this.getListWidget();
	list_item.listid = this.getTypePrefix() + this.widgets.length;
	list_item.render();
};

ListWidget.prototype.clear = function() {
	$.each(this.widgets,function(i,list_item){
		$('#' + this.listid).remove();
	});
	this.widgets.splice(0, this.widgets.length);
};

ListWidget.prototype.remove = function(id){
	for (var i = 0; i < this.widgets.length; i++) {
		if (this.widgets[i].listid == id) {
			//if (this.type == "collections"){
			//	var n = this.widgets[i].index;
			//	//$('#collections').find("[href=" + n + "]");
			//	$('#collections').find('.jstree-checked').each(function(){
			//		var jstreename = $(this).find('a').attr("href").split('?')[1].split('&')[0].split('=')[1];
			//		if (jstreename == n){
			//			$(this).removeClass("jstree-checked").addClass("jstree-unchecked");
			//			//$('#collections').plugins.checkbox.uncheck($(this));
			//		}
			//	});
			//}
			this.widgets.splice(i, 1);
			
		} 
	}	
	$('#' + id).remove();
};

ListWidget.prototype.render = function () {
	var x_save = "";
	var x_detail = "";
	var name = "";
	var x_input = "";
	
	//x_input = "<input type='text' class='input-widget autocomplete-input' />";
	if ($(this.parent_div).attr("id") == 'columns-widget') {
		x_save =  "<span class='cmd cmd_save' />";
	}
	if ($(this.parent_div).attr("id") == 'collections-widget') {
		x_save = "<span class='cmd cmd_detail' />";
		name = "Collections";
	}
	var x = "<div id='"+ this.lvid + "' class='widget-wrapper ui-widget' >" + 
	"<div class='widget-header'>"  + // ui-widget-header ui-state-default ui-corner-top'>" +
	"<label>" + name + "</label>" + //"<span>" + name + "</span>" + 
	x_save + x_detail + "</div>" +
	"<div class='widget-content'>" + x_input + 
	"<div class='index-context'><table></table></div><div class='list-widget'></div></div></div>";
	$(this.parent_div).append(x);

	listwidget_container = $(this.parent_div).find('.list-widget');//$('#columns-list'); 

	$('#' + this.lvid + ' .cmd_del').live('click',  function(event) {
	//$(this.parent_div).find('.cmd_del').live('click',  function(event) {
		var colid = $(this).closest('.list-item').attr("id");
		var lvid = $(this).closest('.widget-wrapper').attr('id');
		var lv;
		var sl;
		//var q;
		if (lvid.beginsWith("sl")){
			sl = $(this).closest('.selectionlist-widget').data('selectionlist');//selectionlistset.getselectionlist($(this).closest('.selectionlist-widget').attr("id"));
			if (sl.autoSelected()){
				sl.select(0);
			}
			lv = sl.listwidget;
			//q = $(this).closest('.detail-wrapper').find('.cmd_reload').data();
		} else {
			lv = listwidgetset.getlistwidget(lvid);
		}
		lv.remove(colid);
		//resubmit query
		/*
		if (lvid.beginsWith("sl")){
			q.query.updateColumns(sl);
			q.query.resubmit();
		}
		*/
		/*
		if ($(this).parent().parent().parent().attr('class') == 'query-columns'){
			var qid = $(this).closest('.query_wrapper').attr("id");
			var q = queryset.getQuery(qid);
			q.columns_widget.remove(colid);
		}else {
		if ($(this).parent().parent().parent().attr('id') == "columns-widget"){	
			columns_widget.remove(colid);
		} else {
			collections_widget.remove(colid);
		}
		*/
	});


	var input = $(this.parent_div).find('.input-widget');
	
	input.focusin(function(){
		var colid = $(this).closest('.list-item').attr("id");
		var lvid = $(this).closest('.widget-wrapper').attr('id');
		var lv = listwidgetset.getlistwidget(lvid);
		active_widget = lv;
/*		if ($(this).parent().attr('class') == 'query-columns'){
			var qid = $(this).closest('.query_wrapper').attr("id");
			var q = queryset.getQuery(qid);
			active_widget = q.columns_widget;
		}else{
			active_widget = columns_widget;
		}
		*/
	});
	input.bind('change', function(){
		
	});
	
	input.keydown(function(ev){
		var evStop = function(){ 
			ev.stopPropagation(); 
			ev.preventDefault(); 
		};
		if (ev.which === 13) {
			var colid = $(this).closest('.list-item').attr("id");
			var lvid = $(this).closest('.widget-wrapper').attr('id');
			var lv = listwidgetset.getlistwidget(lvid);
			lv.add(new ListItem($(this).val()));
/*			if ($(this).parent().attr('class') == 'query-columns'){
				var qid = $(this).closest('.query_wrapper').attr("id");
				var q = queryset.getQuery(qid);
				q.columns_widget.add(new ListItem($(this).val()));
			}else{
				columns_widget.add(new  ListItem($(this).val()));
			}
			evStop();
			*/
		}
	});
	
	if ($(this.parent_div).attr('id') == "collections-widget") {
		$(input).hide();
	}
 };

 ListWidget.prototype.getListWidget = function() {
	 return $(this.parent_div).find('.list-widget');
 };
ListWidget.prototype.initAutocomplete = function(autocomplete_array) {
 	
 	if (autocomplete_array.size == 0) return;
 	 
 	 //autocomplete
 	function handleSelectionWidget(elem, widget){
 		var input = $(widget.parent_div).find('.input-widget');
		var context = $(input).next('.index-context');
	
		// fill context
		$(context).html(elements_hashtable[elem]);
		$(context).show();
		$(input).blur(function(){
 				$(context).hide();
 			});
		$(input).focusin(function(){
 				$(context).hide();
 			});
 						
 		};
 		
 		//autocomplete
 		function findValueWidget(e) {
 			var sValue = e.selectValue;
 			handleSelectionWidget(sValue, active_widget);			
 		}
 		 
 		function selectItemWidget(li) {
 			findValueWidget(li);
 		}		

 	 		var ac = $(this.parent_div).find('.input-widget').autocompleteArray(autocomplete_array,{
 	 			autoFill:true,
 	 			width:150,
 	 			onFindValue:findValueWidget,
 	 			onItemSelect:selectItemWidget
 	 			//extraParams: {oo, '75'}
 	 		});

 	 		//ac.setExtraParams({aaa:3});
 	 
};
ListWidget.prototype.load = function(items) {
	this.clear();
		
	if (items != undefined){
		if (this.type == "collections"){
			for(var i=0; i<items.length; ++i) {
				this.add(new ListItem(items[i].name, items[i].index));
			 }   
		} else
		{
			for(var i=0; i<items.length; ++i) {
				if (items[i].length > 0){
					this.add(new ListItem(items[i]));
				}
			 }   
		}	
	}
};

ListWidget.prototype.getListText = function() {
	var column_text = "";
	if (this.type == "collections"){
		$.each(this.widgets,function(i,column){
			column_text = column_text  + "," + jQuery.trim(column.index);
		});
	} else {
		$.each(this.widgets,function(i,column){
			column_text = column_text  + "," + jQuery.trim(column.name);
		});
	}
	
	
	if (column_text.length > 1) {
		column_text = column_text.substring(1);	
	}
	return column_text;
};




function ListItem(_name, _index ) {
	this.name = _name;
	this.index = _index;
	this.listid = "";
	this.parent_container = {};
}

ListItem.prototype.render = function () {
	
	var x_save = "";
	
	//if ($(this.parent_container).parent().attr("id") == 'columns-widget') {
	//	x_save = "<span class='cmd cmd_save' />";
	//}
	
	var x = "<div id='" + this.listid + "'class='list-item'><span>" + this.name + "</span><span class='cmd cmd_del'> </span>" + x_save + "</div>";

	$(this.parent_container).prepend(x);
	//$('#columns-list').prepend(x);
	//addToColumnslist(x);	
	this.container = $('#' + this.listid );
}; 

/**
 * FIXME: What is this for?
 * @constructor
 */
	
var listwidgetset = { listwidgets: [],
		container: '#listwidgetlist',
			
		add: function (listwidget){
				
			this.listwidgets[this.listwidgets.length] = listwidget;
			listwidget.lvid = "lv" + this.listwidgets.length;
			listwidget.render();				
		},

		remove: function (lvid) {		
			 for (var i = 0; i < this.listwidgets.length; i++) {
				if (this.listwidgets[i].listid == mid) {
					this.listwidgets.splice(i, 1);
				} 
			}	
			$('#' + lvid).remove();
		},
		getlistwidget: function(lvid) {
			var listwidget;
			$.each(this.listwidgets,function(){
				if (this.lvid == lvid) {
					listwidget = this;
				}
			});
			return listwidget;
		}
	};
	////////////////////////////////////////////////////////////////////////


//////  SELECTION LIST - COMBOBOX
/**
 * Selection List implemented as Combobox
 * @constructor 
 */

function SelectionList(_parent_div) {
	this.parent_div = $(_parent_div);	
	//this.container = "";
	
	//this.listwidget_container = {};
	this.items = [];
	this.items[0] = new ListItem("<new>");
	this.items[1] = new ListItem("<auto>");
	this.autolist = [];
	
	this.slid = "";
	
	this.listwidget = new ListWidget();
	//this.type = type;
	
};
SelectionList.prototype.getSelect = function(){
	var select;
	select = $(this.parent_div).find('select');
	return $(select);
};
SelectionList.prototype.createSelect = function(){
	var items = this.items;
	var slid = this.slid;
	var $select = this.getSelect();
	$select.children().remove();
	
	$.each(this.items,function(i, item){
		items[i].lvid = slid + "_" + i;
		$select.append(new Option(item.name, i));
	});
	
	$select.change(function(data){
		if ($(this).find("option").size() > 0) {
			// find id of selected
			var id = parseInt($select.find("option:selected").val());
			var slid = $(this).closest('.selectionlist-widget').attr("id");
			var sl = selectionlistset.getselectionlist(slid);
			if (id < 2) {
				if (id == 1){
					sl.listwidget.load(sl.autolist.split(','));
				}else{
					sl.listwidget.clear();
				}
				$(this).closest('.selectionlist-select').find('.cmd_del').attr("disabled","disabled");
				$(this).closest('.selectionlist-select').find('.cmd_save').attr("disabled","disabled");
			} else {
				sl.listwidget.load(jsonw["WorkspaceProfile"]["CustomTermsets"][id - 2]["Terms"]);
				$(this).closest('.selectionlist-select').find('.cmd_del').removeAttr("disabled");
				$(this).closest('.selectionlist-select').find('.cmd_save').removeAttr("disabled");
			}
		}
     });
};
SelectionList.prototype.load = function(json){
	var items = this.items;
	//var $select = this.getSelect();
	//$select.children().remove();

	//<auto>,<new>
	//$select.append(new Option(this.items[0], 0));
	//$select.append(new Option(this.items[1], 1));
	if (json != "null") {
		$.each(json, function(i,item) {
			items[items.length] = new ListItem(item.name);
			//$select.append(new Option(item.name, i+2));
		});
	}
	/*
	// find id of selected
	if ($select.find("option").size() > 0) {
		$select.find("option").first().attr("selected","true");
		var id = parseInt($select.find("option:selected").val());
		this.listwidget.load(json[id]["Terms"]);
	}
	*/
	this.createSelect();
};
SelectionList.prototype.add = function(item){
	this.items[this.items.length] = item;
	//list_item.parent_container = this.getListWidget();
	item.listid = this.slid + "_" + this.items.length;
	this.getSelect().append(new Option(this.items[this.items.length-1].name, this.items.length-1));
	//list_item.render();
};

SelectionList.prototype.clear = function() {
	if (this.items.length > 0){
		this.items.splice(i, this.items.length);	
	}
	this.listwidget.clear();
};

SelectionList.prototype.remove = function(id){
	this.items.splice(id, 1);
	var select = $(this.parent_div).find('.selectionlist-select').children('select');
	$($(select).find('option')[id]).remove();
	$(select).find('option').each(function(i, item){
		$(this).val(i);
	});
};
SelectionList.prototype.autoSelected = function(){
	if (this.getSelected() == 1){
		return true;
	}
	return false;
};
SelectionList.prototype.getSelected = function(){
	return $(this.getSelect()).find('option:selected').val();
};
SelectionList.prototype.select = function(id){
	$(this.getSelect().find('option')[id]).attr("selected","selected");//get(id).selectedIndex = id; 
	//var sl = this;//selectionlistset.getselectionlist(this.slid);
	if (id > 1){
		this.listwidget.load(jsonw["WorkspaceProfile"]["CustomTermsets"][id - 2]["Terms"]);
	} else {
		if (id == 1){
			this.listwidget.load(this.autolist.split(',') );
		}
	}	
};
SelectionList.prototype.render = function () {
	var x = "<div id='"+ this.slid +"' class='widget-wrapper ui-widget selectionlist-widget' >" +
	"<div class='widget-content'><div class='selectionlist-select'><select></select>"+
	"<span class='cmd cmd_save' /><span class='cmd cmd_saveas' /><span class='cmd cmd_del' /></div>"+
	"<div><input type='text' class='saveas-input' /></div>"+
	"<div class='selectionlist-listwidget'></div></div>";
	$(this.parent_div).append(x);

	$(this.parent_div).find('.selectionlist-select').find('.cmd_save').click(function(){
		var select = $(this).closest('.selectionlist-select').children('select');
		var id = parseInt($(select).find("option:selected").val());
		if (id < 2) {return;}
		var name = $(select).find("option:selected").text();
		
		var slid = $(this).closest('.widget-wrapper').attr("id");
		var selectionlist = selectionlistset.getselectionlist(slid);
		
		saveTermset(id - 2, name, selectionlist.listwidget);
	});
	$(this.parent_div).find('.selectionlist-select').find('.cmd_saveas').click(function(){
		var saveas = $(this).closest('.selectionlist-widget').find('.saveas-input');
		$(saveas).show();
		$(saveas).focus();
		
		/*
		var name = $(this).closest('.selectionlist-select').find('.saveas-input').text();
		var slid = $(this).closest('widget-wrapper').attr("id");
		var selectionlist = selectionlistset.getselectionlist(slid);
		
		selectionlist.add(name);
		*/
	});
	$(this.parent_div).find('.selectionlist-select').find('.cmd_del').click(function(){
		//find selected
		var select = $(this).closest('.selectionlist-select').children('select');
		var id = parseInt($(select).find("option:selected").val());
		if (id < 2) {return;}
		
		var slid = $(this).closest('.selectionlist-widget').attr("id");
		var selectionlist = selectionlistset.getselectionlist(slid);
		
		removeTermset(id -2);
		
		selectionlist.remove(id);
		if (id > 0 ){
			id = id - 1;
		}
		selectionlist.select(id);
		
	});
	
	$(this.parent_div).find('.saveas-input').focusout(function(){
		$(this).attr("value","");
		$(this).hide();
	});
	$(this.parent_div).find('.saveas-input').keydown(function(ev){
		var evStop = function(){ ev.stopPropagation(); ev.preventDefault(); };
		if (ev.which === 23) {
			$(this).attr("value","");
			$(this).hide();
			evStop();
		}
		var evSaveAs = function(name, select, slid){
			ev.preventDefault();
			
			//var slid = $(this).closest('.widget-wrapper').attr("id");
			var selectionlist = selectionlistset.getselectionlist(slid);
			
			saveTermset(-1, name, selectionlist.listwidget);
			selectionlist.add(new ListItem(name));
			selectionlist.select($(select).children().length-1);
		};
		if ($(this).attr("value").length > 0 &&  ev.which === 13) evSaveAs($(this).attr("value"),
				$(this).closest('.selectionlist-widget').find('select'),
				$(this).closest('.widget-wrapper').attr("id")); 
	});
	
	$(this.parent_div).find('.saveas-input').hide();
	$(this.parent_div).find('.selectionlist-select').find('.cmd_del').attr("disabled","disabled");
	$(this.parent_div).find('.selectionlist-select').find('.cmd_save').attr("disabled","disabled");
	this.listwidget = new ListWidget( $(this.parent_div).find('.selectionlist-listwidget'));
	this.listwidget.lvid = this.slid + "_lv";
	this.listwidget.render();
	
	//$(this.parent_div).find
	$(this.parent_div).find('.selectionlist-widget').data('selectionlist',this);
 };

 /*
SelectionList.prototype.load = function(items) {
	this.clear();
		
	for(var i=0; i<items.length; ++i) {
			this.add(new ListItem(items[i]));
	}   
};
*/

 //TODO what is this for?
var selectionlistset = { selectionlists: [],
			
		add: function (selectionlist){
				
			this.selectionlists[this.selectionlists.length] = selectionlist;
			selectionlist.slid = "sl" + this.selectionlists.length;
			selectionlist.render();				
		},

		remove: function (slid) {		
			 for (var i = 0; i < this.selectionlists.length; i++) {
				if (this.selectionlists[i].slid == slid) {
					this.selectionlists.splice(i, 1);
				} 
			}	
			$('#' + slid).remove();
		},
		getselectionlist: function(slid) {
			var selectionlist;
			$.each(this.selectionlists,function(){
				if (this.slid == slid) {
					selectionlist = this;
				}
			});
			return selectionlist;
		}
	};
