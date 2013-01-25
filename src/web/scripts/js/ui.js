
/**
 * @fileOverview This is based on mdservice/mdservice_ui.js, but removed all unused code. 
 *  This is the main file, contains main app function (jquery-initialization). 
 * The app main function runs setup functionality, which covers this domains:
 * <dl>
 * <dt>the variable initialization<dt>
 * 	<dd>functions from mdservice_searchclause.js, mdservice_widget.js, mdservice_ui_helpers.js</dd>
 * <dt>loadData()</dt> 
 * 	<dd>loading data from repository and creating particular client-side representations  - functions from <a>mdservice_ui_load.js</a></dd>
 * <dt>creating of ui-layout</dt>
 * 	<dd>i.e. split UI to individual panes  - functions from mdservice_ui_layout.js</dd>
 * <dt>addFunctionality()</dt>
 * 	<dd>bind handlers to events of ui-elements (function directly in mdservice_ui.js)</dd>
 * </dl>
 * @author 
 * @version 
 */


var index_container_selector = "#index-container";
var graph_container_selector = '#infovis';
var navi_container_selector = '#navigate';
var detail_container_selector = "#detail-container";
var detail_info_holder_selector =  '#detail-info-holder';

var graph_container = null;
var index_container = null; 


$(function(){
		// turn on debugging (see jquery.xslTransform.js)
		var DEBUG = false;
	
		// check for jQuery 
		try{
			jQuery;
		}catch(e){
			alert('You need to include jQuery!');
		}
	
        graph_container = $(graph_container_selector);
    
		/////// INIT VARIABLE SETTINGS
		url_params = getUrlVars();
//		workspace = new Workspace();
		
		// create widgets
	/*	columns_widget = new ListWidget($('#columns-widget'), "columns");
		collections_widget = new ListWidget($('#collections-widget'), "collections");
		listwidgetset.add(columns_widget);
		listwidgetset.add(collections_widget);
		*/
		//////////// LOAD DATA
		// loadData();
		
		initGraph();
		loadDetailInfo ();
	
        addFunctionality();
   
		////////////// CREATE  UI-LAYOUT
		createBlock('base','');
		createLayouts('base');

     
	
});


/**
 * This function is called during the initialization sequence and binds event-handlers to events of ui-elements.
 * @function
 */
function addFunctionality(){
	
	$("#input-filter-index").live('change', function(event) {	
	       filterIndex ($(this).val());
	});
	
    fillOpts(navi_container_selector);
    
    $("#navigate .slider").slider();
    
    $('#infovis-wrapper').resizable( {
                   start: function(event, ui) {
                            graph_container.hide();
                        },
                   stop: function(event, ui) {
                            graph_container.show();
                            renderGraph();
                       }
                }
                );

    

	
}