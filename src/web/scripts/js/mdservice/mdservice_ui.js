/**
 * @fileOverview  This is the main file, contains main app function (jquery-initialization). 
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

$(function(){
		// turn on debugging (see jquery.xslTransform.js)
		var DEBUG = false;
	
		// check for jQuery 
		try{
			jQuery;
		}catch(e){
			alert('You need to include jQuery!');
		}
		
		/////// INIT VARIABLE SETTINGS
		url_params = getUrlVars();
		workspace = new Workspace();
		
		// create widgets
		columns_widget = new ListWidget($('#columns-widget'), "columns");
		collections_widget = new ListWidget($('#collections-widget'), "collections");
		listwidgetset.add(columns_widget);
		listwidgetset.add(collections_widget);
		
		//////////// LOAD DATA
		// loadData();
		
		initGraph();
		
		////////////// CREATE  UI-LAYOUT
		createBlock('base','');
		createLayouts('base');

        addFunctionality();
    
		// ??autocomplete correction
		/*initDetailFloat();
		searchclauseset.addsearchclause(new SearchClause("","",""),"",0,0);
		createInfos();
		detailcaller.calldetail(undefined, "info");*/
	
});

function createInfos(){
	var info = "<span class='cmd cmd_info'></span>";
	$('.cmds-ui-block').children('.header').append(info);
	createTooltip($('.cmds-ui-block').children('.header'));
	
	$('.cmds-ui-block').children('.header').children('.cmd_info').click(function(){
		//var a = $(this).parent().next().attr('id');
		//var uri = window.location.pathname + "static/info.xml";
		//$.get(uri,{"id":a}, showDetail,'html');
		detailcaller.calldetail($(this));
		return false;
	});	
}


function getSelectedRepository(){
	return $('select[name="x-context"]').find("option:selected").val();
}

function getInputMode(){
	if ($('#searchclauselist').is(":visible")){
		return 'complex';
	}
	return 'simple';
}

/**
 * This function is called during the initialization sequence and binds event-handlers to events of ui-elements.
 * @function
 */
function addFunctionality(){
	
	$("#input-filter-index").live('change', function(event) {	
	       filterIndex ($(this).val());
	});
	//change context_selects
	$('select[name=x-context]').live('change',function(event){
		event.preventDefault();
		//delete the autocomplete arrays, reset the index input values
		//element_autocomplete.splice(0, element_autocomplete.length);
		//element_autocomplete_explain.splice(0, element_autocomplete_explain.length );
		
		//searchclauseset.clear();
		//load new
		loadTermsAutocompleteExplain();
		searchclauseset.initAutocomplete(false);
	});
	
	//switch the input simple query vs complex query
	$('#switch-input').live('click',function(){
		$('#searchclauselist').toggle();
		$('#input-simplequery').toggle();
		if (getInputMode() == 'complex'){
			searchclauseset.sctext = $('#input-simplequery').attr("value");
			searchclauseset.buildfromquerystring();
		} else {
			$('#input-simplequery').attr("value",searchclauseset.buildsctext());
		}
	});
	
	// DEL COMMAND
	/*
	$('.ui-dialog-titlebar .cmd_del').live('click',function(){
		var did;
		if ($(this).closest('.ui-dialog').length > 0){
			did = $(this).closest('.ui-dialog').find('.detail-wrapper').attr('id');
		}
		if (did != undefined){
			detail = detailcaller.getdetail(did);
			detail.close();
		}
		$(this).closest('.ui-dialog').hide();
	})
*/
	/**
	 * Remove a query from queryset
	 * FIXME: shouldn't this primarily delete the query-object from the queryset? 
	 * @event 
	 * @name clickQueryremove
	 */
	$('.query_header .cmd_del').live('click', function(){
		$(this).closest('.query_wrapper').remove();
	});

	//TODO dialog
	$('.detail-header .cmd_del').live('click', function(){
		var did, detail;
		
		if ($(this).parent().hasClass('detail-header')){
			var dw = $(this).closest('.detail-wrapper');
			did = dw.attr('id');
			dw.hide();
		}
		else {
			if ($(this).parent().siblings('.ui-dialog-content').length > 0){
				did = $(this).parent().siblings('.ui-dialog-content').find('.detail-wrapper').attr('id');
			}
		}	
		if (did != undefined){
			detail = detailcaller.getdetail(did);
			detail.close();
		}
	});
	
	// DETAIL-CALLER
	$('.detail-caller a').live('click',  function(event) {		
		event.preventDefault();
	});
	// open detail (from result-set, but also already within detail-view (ResourceRef, IsPartOf)	
	$('.result a.internal, .mdrecord-detail a.internal').live('click',  function(event) {
		event.preventDefault();		
		
		var uri = $(this).attr('href');
		detailcaller.calldetail(undefined, "record", uri);
	});

	$('.detail-content a').live('click',  function(event) {
		
		if ($(this).attr("target") == "_blank"){
			return true;
		} else {
			event.preventDefault();		
			var uri = $(this).attr('href'); // + " body";
			if ($(this).attr("class") == "query"){
				var urlparams = getUrlVars(uri);
				loadQueryFromUriParams(urlparams);
			} else {
				var type;
				if ($(this).attr("class") == "bookmark"){
					type = "record";
				} else {
					type = $(this).parents('.detail-wrapper').attr("id");
					type = type.substring(7,type.length);
				}
			//	$.get(uri, showDetail,'html'); */
				detailcaller.calldetail(undefined, type, uri);
			}
		}
	});
	$('.result a.external, .mdrecord-detail a.external').live('click',  function(event) {
		
		//event.preventDefault();		
		var uri = $(this).attr('href'); // + " body";
		notifyUser('resource-link: ' + uri,'debug' );
	//	$.get(uri, showDetail,'html'); */
	});
	/*
	$('.result .cmd_detail').live('click',  function(event) {	
		//var qid = $(this).closest('.query_wrapper').attr('id');
		//var query = queryset.getQuery(qid);
		
		var uri = $(this).parent().find("a").attr('href'); // + " body";
		$.get(uri, showDetail,'html');
	});
	*/
	$(".detail-caller, .cmd_detail").live('click',function(event) {
		event.preventDefault();	
		detailcaller.calldetail($(this));
			
	});		
	$(".detail-caller-inline").live('click',function(event) {
		event.preventDefault();
		$(this).parent().children('.detail').toggle();
		$(this).children('.cmd_down, .cmd_up').toggleClass('cmd_down cmd_up');
			
	});	
	
	
	
	$('.cmd_sc_autocomplete').live('click',  function(event) {
		var i = $(this).closest('.sc-i').attr('id');
		var j = $(this).closest('.sc-j').attr('id');
		searchclauseset.searchclauses[i][j].initAutocomplete($(this).hasClass('cmd_sca_explain'));
		$(this).toggleClass('cmd_sca_explain cmd_sca_smc');					
	});
	
	// cmd_up cmd_down
	$('.cmd_up').live('click',  function(event) {
		if ($(this).closest('.detail-wrapper').length >  0 ) {
			$(this).closest('.detail-wrapper').find('.detail-content').hide();
		} else {
			$(this).closest('.query_wrapper').find('.result').hide();
		}
		$(this).toggleClass('cmd_down cmd_up');					
	});
	$('.cmd_down').live('click',  function(event) {
		if ($(this).closest('.detail-wrapper').length >  0 ) {
			$(this).closest('.detail-wrapper').find('.detail-content').show();
		} else {
			$(this).closest('.query_wrapper').find('.result').show();
		}
		$(this).toggleClass('cmd_down cmd_up');				
	});
	
	$('.cmd_publish').live('click', function(event){
		var query = $(this).parent().data('query');
		if (query != undefined){ // query
			query.publish();
		} else { // bookmarksets
			var json = workspace.getTypedElement('user','bookmarkset');
			var id = parseInt($('#bts_select').find("option:selected").val());
			var bsjson = json[id];
			$.get("/MDService2/virtualcollection/USER/" + bsjson.id,"", function(data){
				if (bsjson.vcrid == 0){
					var id = parseInt($(data).children().children('virtualcollectionid').text());
					bsjson.vcrid = id;
					workspace.savequeryset(bsjson, 1);
				}
			});
		}

	});
	
	//////////////////////////////////////////////
	$('#searchretrieve').submit( function(event) {
		event.preventDefault();
		//hideWelcomeMessage();
		var query;
		if (getInputMode() == 'complex'){
			query = searchclauseset.buildsctext();
		} else {
			query = $('#input-simplequery').attr("value");
		}
		// TODO we dont use columns-widget
		var columns = "";//columns_widget.getColumnsListText();
		var collections = collections_widget.widgets; //searchclauseset.sctext;
		//var ws  = $('#input-withsummary').attr("checked");
		
		notifyUser("processing query");
		
		if (jQuery.trim(query).length == 0){
			query = null;
		}
		var q = new Query(collections, columns, query); //actions.collections.current, query );
		q.repository = getSelectedRepository();
		//if (ws) {
		//	q.options = "withSummary";
		//}
		notifyUser("submit_query:" + q.query_uri(),'debug');
		queryset.addquery(q);
	});
	
	$('.autocomplete-select-caller').live('click',  function(event) {
		
		$(this).closest(".index-context").prev().parent().find(".autocomplete-input").val($(this).text()).change();		
		$(this).closest(".index-context").hide();
	});
	$('.autocomplete-select-caller a').live('click',  function(event) {		
		event.preventDefault();
	});
	
	
	$('.comp_detail input').live('keyup',  function(event) {			
		$('#srquery').val(
				$(this).parent().children('span.cmdelem_name').text()
				+ "=" + $(this).val() );
	});
	
	
	 $('a.open-in-context').live('click', function(event) {
			event.preventDefault();
			var uri = $(this).attr('href');
			/* notifyUser("open_incontext:" + uri);
			$(this).after("<div class='ui-context-dialog cmds-ui-block' ></div>");
			var trg = $(this).next(".ui-context-dialog");
			trg.show();						
			$(trg).load(uri); //function(event) {	} */
			var contextual_uri = uri.replace('htmlpage','htmldetail'); 		
			
			$.get(contextual_uri, showDetail,'html');
	});
	
// RECORDSET searchRetrieve
	 /*
	$('#searchretrieve').submit( function(event) {
			event.preventDefault();
			//hideWelcomeMessage();
			searchclauseset.buildsctext();
			notifyUser(searchclauseset.sctext,'debug');
			//submit_query ($('#columns_list').attr("value"),searchclauseset.sctext, $('#input-simplequery').attr("value"));			
			submit_query (columns_widget.getColumnsListText(),searchclauseset.sctext, $('#input-simplequery').attr("value"), $('#input-withsummary').attr("checked"));
	});
*/
	$('#columns-widget .cmd_save').click(function(event) {
		var terms = [{}];	
			
		var id = $("#ts_select option").size();
		var name = "termset_" + id;
		
		columns_widget.getListWidget().find('.list-item').each(function(i,elem){
			terms[i] = $(elem).text();
		});
		
		var dt = new Date();
		var str_time = dateFormat(dt);//dt.toString("dd/mm/yyyy HH:mm:ss");
		var jsont = {"name":name, "time" : str_time, "Terms" :terms};
		if (jsonw["WorkspaceProfile"]["CustomTermsets"] == undefined) {
			jsonw["WorkspaceProfile"]["CustomTermsets"] = [{}];
		}
		jsonw["WorkspaceProfile"]["CustomTermsets"][id] = jsont;
		
		//saveWorkspace("USER");
		Workspace.save("USER");
		loadTermsets(jsonw["WorkspaceProfile"]["CustomTermsets"]);
		//createTermsUI(jsonw["WorkspaceProfile"]["CustomTermsets"][id],$('#userterms'));
		$("#ts_select option").removeAttr("selected");
		$("#ts_select option").last().attr("selected","selected");
		$('#ts_input').attr("value",name);
		createTermsUI(jsonw["WorkspaceProfile"]["CustomTermsets"][id],$('#userterms'));
	});
	
	/*
	$('#querylist .query_header').find('.cmd_del').live('click',  function(event) {
		//showTermDetail($(this).parent().text());
		
		queryset.removequery($(this).closest('.query_wrapper').attr('id'));
					
	});
*/
	/*
	$('#querylist .cmd_up').live('click',  function(event) {
		$(this).closest('.query_wrapper').find('.result').hide();
		$(this).toggleClass('cmd_down cmd_up');					
	});

*/
	
	$('#detail_query .cmds .cmd_save').live('click',  function(event) {
		//qid = $(this).data('query').listid;
		qid = $(this).data('qid');
		notifyUser("here I would save query: " + qid, "debug");
		var q = queryset.getQuery(qid);
		q.save();
		//Workspace.saveQuery($(this).data('query'));
	});
	$('#detail_query .cmds .cmd_savenew').live('click',  function(event) {
		//qid = $(this).data('query').listid;
		qid = $(this).data('qid');
		notifyUser("here I would savenew query: " + qid, "debug");
		var q = queryset.getQuery(qid);
		q.id = 0;
		q.save();
		//Workspace.saveQuery($(this).data('query'));
	});

	/**
	 * FIXME: this should only invoke appropriate query-function storing the query to workspaceprofile
	 */
	$('#querylist .cmd_save').live('click',  function(event) {
		// bookmark
		if ($(this).parents('.result').length > 0){
			qstring = $(this).parent().find("a").attr('href');
			qstring = qstring.substring(18,qstring.length);
			
			var q = new Query([],"",qstring);
			q.bookmark = 1;
			q.save();
			
		}
	});
	
	/**
	 * FIXME: this looks like a typo: #queryslist -> #querylist  
	 */
	$('#queryslist .cmd_reload').live('click',  function(event) {
		var qid = $(this).closest('.query_wrapper').attr("id");

		queryset.resubmit(qid);
		
	});
	
	
	
	$('.cmd_sc_delete').live('click',  function(event) {
		var i = $(this).closest('.sc-i').attr('id');
		var j = $(this).closest('.sc-j').attr('id');
		//notifyUser(i + j,'debug');
		searchclauseset.removesearchclause(i,j);
					
	});
	$('.cmd_add_and').live('click',  function(event) {
		//showTermDetail($(this).parent().text());
		//$(this).next().hide();
		$(this).attr("value","AND");
		var searchclause = new SearchClause("","","");
		var i = $(this).closest('.sc-i').attr('id');
		var j = $(this).closest('.sc-j').attr('id');
		//notifyUser(i + j,'debug');
		searchclauseset.addsearchclause(searchclause,"and",i,j);
					
	});
	$('.cmd_add_or').live('click',  function(event) {
		//showTermDetail($(this).parent().text());
		//$(this).next().hide();
		var i,j;
		$(this).attr("value","OR");
		var searchclause = new SearchClause("","","");
		searchclauseset.addsearchclause(searchclause,"or",$(this).closest('.sc-i').attr('id'),$(this).closest('.sc-j').attr('id'));
					
	});

	///// QUERYSETS
	$('#qts_save').click(function(){
		var id = $("#qts_select option:selected").val();
		//notifyUser($('#qts_input').val() + $('#qts_input').text(),'debug');
		workspace.user_json["WorkspaceProfile"]["Querysets"][id]["name"] = $('#qts_input').val();
		//workspace.save("USER");
		workspace.savequeryset(workspace.user_json["WorkspaceProfile"]["Querysets"][id],0);
		
		$("#qts_select option:selected").text( $('#qts_input').val());
		
	});
	$('#qts_add').click(function(){
		//var new_name = "new_queryset";
		
		//workspace.addqueryset(new_name);
		//var id = workspace.user_json["WorkspaceProfile"]["Querysets"].length-1;
		//workspace.savequeryset(workspace.user_json["WorkspaceProfile"]["Querysets"][id],0);
		//workspace.save("USER");
		var q = workspace.addelement('queryset');
		workspace.savequeryset(q, 0);
		//todo
		var id = $('#qts_select option').size();
		$("#qts_select").append(new Option(q["name"], id));
		$("#qts_select").find('option').attr("selected","false");
		$("#qts_select").find('option').last().attr("selected","true");
		$('#qts_input').val(q["name"]);
	});
	$('#qts_delete').click(function(){
		var qsid = parseInt($("#qts_select option:selected").val());
		workspace.removeelement("queryset", qsid);
		workspace.save("USER");
		//update
		loadQuerysets("user");
	});

	//BOOKMARKSETS
	$('#bts_save').click(function(){
		var id = $("#bts_select option:selected").val();
		workspace.user_json["WorkspaceProfile"]["Bookmarksets"][id]["name"] = $('#bts_input').val();
		workspace.savequeryset(workspace.user_json["WorkspaceProfile"]["Bookmarksets"][id],1);
		
		$("#bts_select option:selected").text( $('#bts_input').val());
	});
	$('#bts_add').click(function(){
		var b = workspace.addelement('bookmarkset');
		//var id = workspace.user_json["WorkspaceProfile"]["Bookmarksets"].length-1;
		//workspace.savequeryset(workspace.user_json["WorkspaceProfile"]["Bookmarksets"][id],1);
		workspace.savequeryset(b,1);
		
		var id = $('#bts_select option').size();
		$("#bts_select").append(new Option(b["name"], id));
		$("#bts_select").find('option').attr("selected","false");
		$("#bts_select").find('option').last().attr("selected","true");
		$('#bts_input').val(b["name"]);
	});
	$('#bts_delete').click(function(){
		var bsid = parseInt($("#bts_select option:selected").val());
		
		workspace.removeelement("bookmarkset", bsid);
		workspace.save("USER");
		//update
		loadBookmarksets("user");
	});

	////////////////////////////////////////////////
	$('#ts_save').click(function(){
		var id = $("#ts_select option:selected").val();
		//notifyUser($('#qts_input').val() + $('#qts_input').text(),'debug');
		jsonw["WorkspaceProfile"]["CustomTermsets"][id]["name"] = $('#ts_input').val();
			
		$("#ts_select option:selected").text( $('#ts_input').val());
		//saveWorkspace("USER");
		Workspace.save("USER");
	});
	$('#ts_add').click(function(){
		var new_name = "new_termset";
		
		var id = $('#ts_select option').size();
		var dt = new Date();
		var str_time = dateFormat(dt);//dt.toString("yyyy-MM-dd HH:mm:ss");
		
		if (id == 0){
			jsonw["WorkspaceProfile"]["CustomTermsets"] = [{}];
		}
	
		jsonw["WorkspaceProfile"]["CustomTermsets"][id] = {"name":new_name,"created":str_time , "Terms" : "null"};
		
		//saveWorkspace("USER");
		Workspace.save("USER");
		//todo
		
		//loadWorkspace(jsonw["WorkspaceProfile"]["Querysets"]);
		$("#ts_select").append(new Option(new_name, id));
		$("#ts_select").find('option').attr("selected","false");
		$("#ts_select").find('option').last().attr("selected","true");
		$('#ts_input').val(new_name);
		createTermsUI(jsonw["WorkspaceProfile"]["CustomTermsets"][id],$('#userterms'));
	});
	$('#ts_delete').click(function(){
		var count = $("#ts_select option").size();
		
		//if (count > 1){
			var id = parseInt($("#ts_select option:selected").val());
			var size = jsonw["WorkspaceProfile"].CustomTermsets.length;
		
			for (var i=id;i<size-1;i++){
				jsonw["WorkspaceProfile"].CustomTermsets[i] = jsonw["WorkspaceProfile"].CustomTermsets[i+1];
			}
		
			delete jsonw["WorkspaceProfile"].CustomTermsets[size-1];
			jsonw["WorkspaceProfile"]["CustomTermsets"].length = size-1;
			// set null string , if 0 termsets
			if (count == 1) {
				jsonw["WorkspaceProfile"]["CustomTermsets"] = "null";
			}
			//saveWorkspace("USER");
			Workspace.save("USER");
			loadTermsets(jsonw["WorkspaceProfile"]["CustomTermsets"]);
	});
	
	$('#userterms .cmd_load').live('click',function(event){
		var term = String.trim($(this).parent().find('a').text());
		columns_widget.add(new ListItem(term));
		
	});
	$('#userterms .cmd_del').live('click', function(event){
		var id = parseInt($("#ts_select option:selected").val());
		var str = $(this).parent().find('a').attr("href");
		var iq = parseInt(str.substring(10));
		var size = jsonw["WorkspaceProfile"]["CustomTermsets"][id]["Terms"].length;
		
		for (var i=iq;i<size-1;i++){
			jsonw["WorkspaceProfile"]["CustomTermsets"][id]["Terms"][i] = jsonw["WorkspaceProfile"]["CustomTermsets"][id]["Terms"][i+1];
		}
	
		delete jsonw["WorkspaceProfile"]["CustomTermsets"][id]["Terms"][size-1];
		jsonw["WorkspaceProfile"]["CustomTermsets"][id]["Terms"].length = size-1;
		
		if (size == 1){
			jsonw["WorkspaceProfile"]["CustomTermsets"][id]["Terms"] = "null";
		}
		
		//saveWorkspace("USER");
		Workspace.save("USER");
		loadTermsets(jsonw["WorkspaceProfile"]["CustomTermsets"]);
		//$("#ts_select option").remove();
		//$("#ts_select option").first().attr("selected","true");
	});

	
	$('#collections .cmd_load').live('click',function(event){
		//hideWelcomeMessage();
		var collection_text = "";
		var coll = $(this).parent();
		var collections = [];
		//collections.splice(0, collections.length);
		collections[0] = new Collection($(coll).attr("handle"), String.trim($(coll).children('a').text()));
		var columns = columns_widget.getListText();//$('#columns_list').attr("value");
		//var collections = collections_widget.getListText();
		var query = new Query(collections,columns,"");
		query.repository = getSelectedRepository();
	
		//searchclauseset.clear();
		queryset.addquery(query);
		//$('#collection_list').attr("value",query.getcollectiontext("name"));
		collections_widget.load(query.collection);
	
	});
	$('#serverqueries .cmd_load').live('click',function(event){
		
		//var id = parseInt( $("#serverqts_select option:selected").val());
		//var str = $(this).parent().find('a').attr("href");
		//var iq = parseInt(str.substring(9));
		//var json = jQuery.parseJSON($("#serverqs").attr("data"));
		//var q = json["WorkspaceProfile"]["Querysets"][id]["Queries"][iq];
		
		var q = $(this).closest('.cmds-elem-plus').data("query");//json");
		loadQuery(q);
	});
	$('#userqueries .cmd_load').live('click',function(event){
		var q = $(this).closest('.cmds-elem-plus').data("query");//json");
		loadQuery(q);
	});
	$('#userqueries .cmd_del').live('click', function(event){
		//var count = $("#userqueries li").size();
		/*
		var id = parseInt($("#qts_select option:selected").val());
		var str = $(this).parent().find('a').attr("href");
		var iq = parseInt(str.substring(7));
		var size = workspace.user_json["WorkspaceProfile"]["Querysets"][id]["Queries"].length;
		
		for (var i=iq;i<size-1;i++){
			workspace.user_json["WorkspaceProfile"]["Querysets"][id]["Queries"][i] = workspace.user_json["WorkspaceProfile"]["Querysets"][id]["Queries"][i+1];
		}
	
		delete workspace.user_json["WorkspaceProfile"]["Querysets"][id]["Queries"][size-1];
		workspace.user_json["WorkspaceProfile"]["Querysets"][id]["Queries"].length = size-1;
		
		if (size == 1){
			workspace.user_json["WorkspaceProfile"]["Querysets"][id]["Queries"] = "null";
		}
		*/
		//saveWorkspace("USER");
		var id2 = parseInt($("#qts_select option:selected").val());
		var id1 = parseInt( $(this).parent().find('a').attr("href").substring(7));
		workspace.removeelement("query", id1, id2);
		workspace.save("user");
		loadQuerysets("user");
		//$("#qs_select option").remove();
		//$("#qs_select option").first().attr("selected","true");
	});

	$('.detail-wrapper .cmd_withsummary').live('click',function(event){
		var detail = $(this).closest('.detail-wrapper').data('detail');
		var query = detail.query;
		// aaaload new query
		query.summaryinfo();
		// copy summary data
		//detailcaller.calldetail($(query.container).find('.result-header').find('.cmd_detail'));
	});
	
	$('#bookmarks .cmd_load').live('click',function(event){
		var q = $(this).closest('.cmds-elem-plus').data("query");//json");
		var uri = "/MDService2/record/htmldetail/" + q.query;
		detailcaller.calldetail(undefined, "record", uri);
	});
	$('#bookmarks .cmd_del').live('click', function(event){
		var id2 = parseInt($("#bts_select option:selected").val());
		var id1 = parseInt( $(this).parent().find('a').attr("href").substring(7));
		workspace.removeelement("bookmark", id1, id2);
		workspace.save("user");
		loadBookmarksets();
	});

	
	$('.ui-dialog-titlebar-del').live('click', function(event){
		//$('#detail-float').dialog('close');
		var t = $(this).parents('.ui-widget').children('.ui-dialog-content');
		$(t).dialog('close');
	});

	$('.ui-dialog-titlebar-up').live('click', function(event){
		var t = $(this).parents('.ui-widget').children('.ui-dialog-content');
		
		$(this).parents('.ui-widget').attr("tempheight",$(this).parents('.ui-widget').height());
		//notifyUser("up(height):" + $(this).parents('.ui-widget').height(),'debug');
		$(this).parents('.ui-widget').height(30);
		//notifyUser("up(tempheight):" + $(this).parents('.ui-widget').attr("tempheight"),'debug');
		
		
		//$(t).find(".ui-dialog-buttonpane:first, .ui-dialog-content").stop({clearQueue:true}).fadeOut(300);
		//$(t).stop({clearQueue:true}).animate({height:'0px'},300);
		
		$(this).removeClass('cmd_up ui-dialog-titlebar-up');
		$(this).addClass('cmd_down ui-dialog-titlebar-down');	
	});
	$('.ui-dialog-titlebar-down').live('click', function(event){
		var t = $(this).parents('.ui-widget').children('.ui-dialog-content');
		
		var h = $(this).parents('.ui-widget').attr("tempheight");
		//notifyUser("down(tempheight):" + h,'debug');
		$(this).parents('.ui-widget').height(parseInt(h));
		//notifyUser("down(height):" + $(this).parents('.ui-widget').height(),'debug');
		
		
		//$(this).parents('.ui-widget').attr("tempheight",$(this).parents('.ui-widget').height());
		//$(t).find(".ui-dialog-content, .ui-dialog-buttonpane:first").stop({clearQueue:true}).fadeIn(800)
		//.end().stop({clearQueue:true}).animate({height:'100%'},300);

		$(this).removeClass('cmd_down ui-dialog-titlebar-down');
		$(this).addClass('cmd_up ui-dialog-titlebar-up');	
	});

}

function initDetailFloat(){
	$("#detail-float").dialog({ autoOpen: false});
	$("#detail-float").dialog();
	$("#detail-float").tabs();
};

function submit_query (columns, query,  ws) {
	notifyUser("processing query");
	
	if (jQuery.trim(query).length == 0){
		query = null;
	}
	
	var q = new Query(collections, columns, query); //actions.collections.current, query );
	q.repository = getSelectedRepository();
	if (ws) {
		q.options = "withSummary";
	}
	notifyUser("submit_query:" + q.query_uri(),'debug');
	queryset.addquery(q);
	//notifyUser("container" + q.container.attr('id'));
	//$("#querylist").append("sdfdsf");	
}

/**
 * allows to add ui-containers into the detail-pane.
 * 
 * Most of it is just to ensure a defined ordering:
 * 1. info, 2. index, 3. query, 4. record
 */
function addToDetailList(elem, did){
	var exists = false;
	var index_elem = undefined;
	var query_elem = undefined;
	var record_elem = undefined;
	var info_elem = undefined;
	
	$('#detailblock').children('.content').children().each(function(){
		if ($(this).attr("id") == did){
			exists = true;
		}
		if ($(this).attr("id") == "detail_index"){
			index_elem = this;
		}
		if ($(this).attr("id") == "detail_query"){
			query_elem = this;
		}
		if ($(this).attr("id") == "detail_record"){
			record_elem = this;
		}
		if ($(this).attr("id") == "detail_info"){
			info_elem = this;
		}
	});
	if (!exists) {
		if (did == "detail_record") {
			$('#detailblock').children('.content').append(elem);
		} else {
			if (did == "detail_info") {
				$('#detailblock').children('.content').prepend(elem);
			} else {
				if (did == "detail_index") {
					if (info_elem != undefined) {
						$(info_elem).after(elem);
					} else {
						if (record_elem != undefined) {
							$(record_elem).before(elem);
						} else {
							$('#detailblock').children('.content').prepend(elem);
						}
					}
				} else {
					if (did == "detail_query") {
						if (index_elem != undefined) {
							$(index_elem).after(elem);
						} else {
							if (record_elem != undefined) {
								$(record_elem).before(elem);
							} else {
								$('#detailblock').children('.content').append(elem);
							}
						}
					} else {
						$('#detailblock').children('.content').append(elem);
					}
				}
			}
		}

	} else {
		$('#detailblock').children('.content').children().each(function(){
			if ($(this).attr("id") == did){
				$(this).show();
			}
		});
	}
}

function addToSClist (div, i, j, rel) {	
	
	var x;
	
	//notifyUser(i + "," + j + "," + rel);
	if (rel == ""){
		x = $('<div />').addClass("sc-i").addClass("and_level");
		$(div).appendTo($(x).appendTo($('#searchclauselist')));
		$(x).attr("id",i);
	} else {
		if (rel == "and") {
			x = $('<div />').addClass("sc-i").addClass("and_level");
			$(x).attr("id",i);
			$(div).appendTo($(x).appendTo($('#searchclauselist')));
		} else {
			$(div).appendTo($('#searchclauselist').children()[i]);
		}
	}
	
	//$('#searchclauselist').append($(li));
	
}

function addToQuerylist (x) {	
	$("#querylist").prepend(x);	
}

function addToNotifylist (x) {	
	$("#notifylist").prepend(x);	
}

function createTooltip(parentwidget) {
	
	 var ccmd;
	 if (parentwidget == null) {
		 ccmd = $('.cmd');
	 } else {
		 ccmd = $(parentwidget).find('.cmd');
	 }
	 $(ccmd).mouseover(function(){
		 // command name
		 var cmd = $(this).attr("class");
		 cmd = cmd.substring(cmd.indexOf("cmd_"));
		 cmd = cmd.split(" ")[0];
		 
		 // command place
		 var place = "";
		 if ($(this).parents('.content').length > 0) {
			 place = $(this).parents('.content').attr("id") + ".";
		 }
		 if ($(this).parents('.block').length > 0) {
			 place = $(this).parents('.block').attr("id") + ".";
		 }
		 

		 // find tho tooltiptext
		 var a = place + cmd;
		
		 if (tooltiptable[a] != null) {
		 	s = tooltiptable[a];
		 } else { 
		 	if (tooltiptable[cmd] != null) {
		 		s = tooltiptable[cmd];
		 	} else {
		 		s = a;
		 	}
		 }
		 tooltip.show(s);
	 });
	 $(ccmd).mouseout(function(){
		 tooltip.hide();
	 });

};
function loadQuery(query){
	query.repository = getSelectedRepository();
	queryset.addquery(query);
	
	searchclauseset.sctext = query.query;
	notifyUser(searchclauseset.sctext,'debug');
	searchclauseset.buildfromquerystring();

	//collections = query.collection;
	collections_widget.load(query.collection);
	columns_widget.load(query.columns.split(','));
	$('#input-simplequery').attr("value",query.query);
	$('#input-withsummary').attr("checked",(query.options != null));
	updateCollectionTree();

};
/*
function loadQuery(q){
	if (q["bookmark"] == "1") {
		var uri = "/MDService2/record/htmldetail/" + q["querystring"];
		detailcaller.calldetail(undefined, "record", uri);
		//var uri = "/MDService2/record/htmldetail/" + q["querystring"];
		//showDetail(null,'html');
		//$.get(uri, showDetail,'html');
	} else {
		//hideWelcomeMessage();
		var query = new Query([],"","","");
		query.load(q);
		query.repository = getSelectedRepository();
		queryset.addquery(query);
		
		searchclauseset.sctext = query.query;
		notifyUser(searchclauseset.sctext,'debug');
		searchclauseset.buildfromquerystring();

		//collections = query.collection;
		collections_widget.load(query.collection);
		columns_widget.load(query.columns.split(','));
		$('#input-simplequery').attr("value",query.query);
		$('#input-withsummary').attr("checked",(query.options != null));
		updateCollectionTree();
	} 

}
*/
function loadQueryFromUriParams(local_uri){
	var url;
	
	if (local_uri == undefined){
		url = url_params;
	} else {
		url = local_uri;
	}
	//TODO new params
	var q = url["q"];
	if (url["query"] == undefined){
		q = url["q"];
	}
	else {
		q = url["query"];
	}

	var collection = url["collection"];
	var startItem = url["startRecord"];
	var maximumItems = url["maximumRecords"];
	var repository = url["repository"];
	var columns = url["columns"];
	if ((q != undefined) || (collection != undefined)) {
		if (q == undefined) {
			q = "";
		} else {
			q = Url.decode(q);
		}
		if (columns == undefined) {
			columns = "";
		}
		if (startItem == undefined) {
			startItem = 1;
		}
		if (maximumItems == undefined) {
			maximumItems = 10;
		}
		if (repository == undefined) {
			repository = getSelectedRepository();
		}
		if (collection == undefined){
			collection = "";
		}
		var collections = [];
		if (collection.length > 0 ){
			var coll = collection.split(",");
			$.each(coll,function(i,item){
					var n;
					n = $('#collections').find(".folder:[handle='"+item+"']").text();
					var simple_collection = new Collection(item, n);
					collections[i] = simple_collection;
			});
		}
		
		var query = new Query(collections, columns, q);
		query.startItem = startItem;
		query.maximumItems = maximumItems;
		query.repository = repository;
		
		
		queryset.addquery(query);
		
		searchclauseset.sctext = query.query;
		notifyUser(searchclauseset.sctext,'debug');
		searchclauseset.buildfromquerystring();

		//collections = query.collection;
		collections_widget.load(query.collection);
		columns_widget.load(query.columns.split(','));
		$('#input-simplequery').attr("value",query.query);
		$('#input-withsummary').attr("checked",(query.options != null));
		updateCollectionTree();
		
	}
	
}

