/**
 * @fileOverview 
 *  This is the main file. Invokes app initialization on ready() 
 * @author vronk 
 * @version 
 */

var index_container_selector = "#index-container";
var graph_container_selector = '#infovis';
var navi_container_selector = '#navigate';
var detail_container_selector = "#detail-container";
var detail_info_holder_selector = '#detail-info-holder';
var graph_container = null;
var index_container = null;

$(function () {

    // check for jQuery 
    try {
        jQuery;
    } catch (e) {
        alert('You need to include jQuery!');
    }

    graph_container = $(graph_container_selector);

    // loading userdocs as welcome info
    $(graph_container).load(config.url.userdocs + " div.document");

    loadDetailInfo();

    addFunctionality();

    initGraph(opt("graph"));

    ////////////// CREATE  UI-LAYOUT
    createBlock('base', '');
    createLayouts('base');


});

/**
 * This function is called during the initialization sequence and binds event-handlers to events of ui-elements.
 * @function
 */
function addFunctionality() {

//	$("#input-filter-index").live('change', function(event) {
    $(document).on("change", '#input-filter-index', function (event) {
        filterIndex($(this).val());
    });

    $("#navigate").QueryInput({params: opts, onValueChanged: renderGraph});

    /*  $('#infovis-wrapper').resizable( {
     start: function(event, ui) {
     graph_container.hide();
     },
     stop: function(event, ui) {
     graph_container.show();
     renderGraph();
     }
     }
     );*/

    /*$('#input-link').live("mousedown", function(event) {
     console.log(this);
     $(this).attr("target", "_blank");
     $(this).attr("href", generateLink());
     });
     */

    //$('#input-download').live("mousedown", genDownload);
    $(document).on("mousedown", '#input-download', genDownload);

// $(".detail-caller").live("click", function(event) {
    $(document).on("click", '.detail-caller', function (event) {
        //console.log(this);
        event.preventDefault();
        $(this).parent().find('.detail').toggle();
    });

// $(".node-item .detail a").live("click", 
    $(document).on("click", '.node-item .detail a', function (event) {
        event.preventDefault();
        key = $(this).attr("data-key");
        console.log(key);
        selectNodeByKey([key]);
    });

//$("a.scan").live("click", function(event) {
    $(document).on("click", 'a.scan', function (event) {
        console.log(this);
        event.preventDefault();
        url = $(this).attr("href");
        $(this).parent().find('.node-detail').html("loading");
        $(this).parent().find('.node-detail').load(url + " div.content");
    });
}