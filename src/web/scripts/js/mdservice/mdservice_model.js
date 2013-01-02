 /**
 * @fileOverview  This file provides basic client-side model of the Query-object. <code>Query</code> construction, 
 * manipulating and <code>queryset</code> model functionality. 
 *
 * @author 
 * @version 
 */

var page_record_count = 10;
var formatquerystring_len = 25;
//var workspace;

// json for user and server data
function Workspace(){
	user_json = undefined;
	server_json = undefined;
};

Workspace.prototype.getTypedElement = function(type, elementtype, id){
	var json; 
	if (type == 'server'){
		json = this.server_json;
	} else {
		json = this.user_json;
	}
	switch(elementtype){
	case 'queryset':
		return json["WorkspaceProfile"].Querysets;
	case 'bookmarkset':
		return json["WorkspaceProfile"].Bookmarksets;
	case 'query':
		return  json["WorkspaceProfile"]["Querysets"][id]["Queries"];
	case 'bookmark':
		return json["WorkspaceProfile"]["Bookmarksets"][id]["Bookmarks"];
	case 'customtermset':
		return json["WorkspaceProfile"].CustomTermsets;
	}

};

Workspace.prototype.setTypedElement = function(type, id,data){
	switch(type){
	case 'queryset':
		if (data == "[{}]"){
			this.user_json["WorkspaceProfile"].Querysets = [{}];
		} else {
			this.user_json["WorkspaceProfile"].Querysets = data;
		}
		break;
	case 'bookmarkset':
		if (data == "[{}]"){
			this.user_json["WorkspaceProfile"].Bookmarksets = [{}];
		} else {
			this.user_json["WorkspaceProfile"].Bookmarksets = data;
		}
		break;
	case 'query':
		if (data == "[{}]"){
			workspace.user_json["WorkspaceProfile"]["Querysets"][id]["Queries"] = [{}];
		} else {
			workspace.user_json["WorkspaceProfile"]["Querysets"][id]["Queries"] = data;
		}
		break;
	case 'bookmark':
		if (data == "[{}]"){
			workspace.user_json["WorkspaceProfile"]["Bookmarksets"][id]["Bookmarks"] = [{}];
		} else {
			workspace.user_json["WorkspaceProfile"]["Bookmarksets"][id]["Bookmarks"] = data;
		}
		break;
	case 'customtermset':
		if (data == "[{}]"){
			this.user_json["WorkspaceProfile"].CustomTermsets = [{}];
		} else {
			this.user_json["WorkspaceProfile"].CustomTermsets = data;
		}
		break;
	}

};

Workspace.prototype.addelement = function(type, json, id){
	var elems = this.getTypedElement('user', type, id);
	var iq = 0;
	
	if (elems == "null"){
		this.setTypedElement(type,id, "[{}]");
		elems = this.getTypedElement('user', type, id);
	} else {
		iq = elems.length;
	}
	if (json == undefined){
		var str_time = dateFormat(new Date());//dt.toString("yyyy-MM-dd HH:mm:ss");
		var name;
		if (type == "bookmarkset"){
			name = "new_bookmarkset";
			json  = {"name":name, "id":0, "vcrid":0, "created":str_time , "Bookmarks" : "null"};
		} 
		if (type == "queryset"){
			name = "new_queryset";
			json  = {"name":name, "id":0, "vcrid":0, "created":str_time , "Queries" : "null"};
		}
	}
	elems[iq] = json;

	return json;
	//this.user_json["WorkspaceProfile"]["Querysets"][id] = {"name":name, "id":0, "created":str_time , "Queries" : "null"};
	
};
Workspace.prototype.getRepositoryType = function(repository){
	var reptype = "";
	$.each(workspace.server_json["WorkspaceProfile"]["Repositories"], function(i,item){
		if (item.name==repository){
			reptype=item.type;
		}
	});
	return reptype;
};

Workspace.prototype.getOption = function(opt_key){
	var value = "";
	
	value = workspace.server_json["WorkspaceProfile"]["Options"][opt_key];
	
	return value;
}

Workspace.prototype.removeelement = function(type, id1, id2){
	var set = this.getTypedElement('user', type,id2);
	var size = set.length;
	for (var i=id1;i<size-1;i++){
		set[i] = set[i+1];
	}
	delete set[size-1];
	set.length = size-1;
	// set null string , if 0 querysets
	if (size == 1) {
		this.setTypedElement(type,id2,"null");
	}
};

Workspace.prototype.getCustomTermsets = function(){
	var json;
	json = this.user_json["WorkspaceProfile"]["CustomTermsets"];
	return json;
};
Workspace.prototype.save = function(type){
	var JSONText;

	JSONText = JSON.stringify(this.user_json["WorkspaceProfile"]);
	$.post("/MDService2/workspaceprofilesave/" + type + "/",{"data":JSONText},  function(data) {
	});

};
Workspace.prototype.savequery = function(json, qsid, query){
	var JSONText;
	var type = "user";
	var qdata = "/";// + querysetid;
	JSONText = JSON.stringify(json);
	if (query.bookmark == 0){
		qdata = qdata + this.getTypedElement(type, 'queryset')[qsid]["id"];
	} else {
		qdata = qdata + this.getTypedElement(type, 'bookmarkset')[qsid]["id"];
	}

	$.post("/MDService2/workspaceprofilesave/" + type + qdata,{"data":JSONText},  function(data) {
		if (json.id == 0){
			json.id = $(data).text();
			query.id = $(data).text();
			if (query.bookmark == 0){
				workspace.addelement("query", json, qsid);
				appendQueryUI(json,qsid, $('#userqueries'));
			} else {
				workspace.addelement("bookmark", json, qsid);
				appendBookmarkUI(json,qsid, $('#bookmarks'));
			}
		} 
	});
};
Workspace.prototype.savequeryset = function(json, bookmark){
	var JSONText;
	var type = "user";
	JSONText = JSON.stringify(json);
	
	$.post("/MDService2/workspaceprofilesave/" + type,{"data":JSONText},  function(data) {
		if (json.id == 0){
			json.id = $(data).text();
			// todo appendQueryset
			if (bookmark == 0){
				loadQuerysets(type);
			} else {
				loadBookmarksets();
			}
		} 
	});
};

function Collection(index, name){
	this.index = index;
	this.name = name;
};
//var collections  = [];

/**
Creates a new Query
@class Represents a Query. 
*/ 
function Query(collection, columns, query) {
	this.id = 0;
	this.collection = collection;   // []
	this.columns = columns;         // string
	this.query = query;	         //sctext
	this.listid = "";
	this.container = {};
	this.bookmark = 0;
	// page
	this.startItem = 1;
	this.maximumItems = parseInt(this.startItem) + page_record_count - 1;
	
	// repository
	this.repository = 1;
	//this.reptype = 
	this.options = null;
	this.time_created = null;
	
	this.format = 'htmltable';
	this.columns_widget = null;
	
	//vcr
	this.vcrid = 0;
	
	//pazpar
	
	this.pz2 = new md_pz2( { "onshow": this.pazpar2show,
        "showtime": 500,            //each timer (show, stat, term, bytarget) can be specified this way
        "queryobject": this
        //"repository": q.repository
        //"pazpar2path": pazpar2path,
        //"oninit": my_oninit,
        //"onstat": my_onstat,
        //"onterm": my_onterm,
        //"termlist": "xtargets,subject,author",
        //"onbytarget": my_onbytarget,
        //"onrecord": my_onrecord 
        } );
        
};
Query.prototype.pazpar2show = function(data, activeClients){
	//this.container.find('.result').html(data);
	
	
	var res = $(this.queryobject.container).find('.result').html("");
	$(res).append(data);
	//res.append('<ul></ul>');
	/*
	$.each(data.hits,function(){
		//$(res.children('ul')[res.length]).append('<li>'+this+'</li>');
		res.append(this);
	});
	*/	
	
	var result_header = $(res).children('.result-header');
	
	var q_header;
	q_header = $(res).parent().find('.query_header');
	q_header.children('.result-header').remove();
	
	q_header.append(result_header);				
 	addDetailFunctionality(q_header, this);
 	
 	
	//if (Number( $(data).find(".activeclients").text() ) == 0) {
	if (activeClients == 0){
		// update link-hrefs
		var qid = $(res).closest('.query_wrapper').attr("id");
		//notifyUser("result-loaded ID:" + qid,'debug');
		
		var q = queryset.getQuery(qid);
		$('#' + qid ).find(".cmd_link").attr("href", q.link("fullpage"));
		notifyUser("result-loaded",'debug');
		
		var get = $(res).parent().find('.cmd_get');				

		get.removeClass('cmd_get');
		get.addClass('cmd_up');
	}
};
Query.prototype.load  = function(json) {
	
	var columns_text = "";
	if (json.columns != "null"){
		$.each(json.columns,function(i,item){
			columns_text = columns_text + "," + item;
		});
		if (columns_text.length > 1) {
			columns_text = columns_text.substring(1);	
		}
	}
	this.columns = columns_text;
	
	var collection = [];
	if (json.collections != "null"){
		$.each(json.collections,function(i,item){
			var coll = new Collection(item.index, item.name);
			collection[i] = coll;
		});
	}
	this.collection = collection;
	if (json["querystring"] == "[NULL]"){
		this.query = null;
	} else {
		this.query = json["querystring"];	
	}

	this.columns = columns_text;
	
	var options_text = "";
	if (json.options == undefined) {
		this.options = null;
	} else {
		if (json.options != "null"){
			var opts = json.options.split(',');
			$.each(opts,function(i,item){
				options_text = options_text + "," + item;
			});
			if (options_text.length > 1) {
				options_text = options_text.substring(1);	
			}
			this.options = options_text;
		} else {
			this.options = null;
		}
	}
	
	if (json.time == undefined){
		this.time_created = null;
	} else {
		this.time_created = json.time;
	}
	this.id = json.id;
	this.vcrid = json.vcrid;
};
Query.prototype.save = function(){
	var qsid;
	var jsonq = this.toJSON();

	if (this.bookmark == 0){
		qsid = parseInt($("#qts_select option:selected").val());
	} else {
		qsid = parseInt($("#bts_select option:selected").val());
	}
	workspace.savequery(jsonq, qsid, this);
	
	/*
	if (this.bookmark == 0){
		qsid = parseInt($("#qts_select option:selected").val());
		//qsjson = workspace.getQuerysets("user")[qsid];
		if (this.id == 0){
			workspace.addelement("query",jsonq, qsid);//qsjson);
			workspace.savequery(jsonq, qsid, this);
		} else {
			workspace.savequery(jsonq, qsid, this);
		}
	} else {
		qsid = parseInt($("#bts_select option:selected").val());
		//qsjson = workspace.getBookmarksets()[qsid];
		if (this.id == 0){
			workspace.addelement("bookmark", jsonq, qsid);//qsjson);
			workspace.savequery(jsonq, qsid,this);
		} else {
			workspace.savequery(jsonq, qsid, this);
		}
	}
	
	*/
	
};
/*
Query.prototype.save = function(){
	//queryset id
	var qsid = parseInt($("#qts_select option:selected").val());
	var iq = 0;
	var queries = jsonw["WorkspaceProfile"]["Querysets"][qsid]["Queries"];
	
	//var iq = $('#userqueries').children().size();
	var jsonq = this.toJSON();
	if (this.id == 0){
		if (queries == "null"){
			jsonw["WorkspaceProfile"]["Querysets"][qsid]["Queries"] = [{}];
		} else {
			iq = queries.length;
		}
		jsonw["WorkspaceProfile"]["Querysets"][qsid]["Queries"][iq] = jsonq;
		Workspace.save("USER", this, qsid, iq);
	} else {
		$.each(jsonw["WorkspaceProfile"]["Querysets"][qsid]["Queries"], function(index,value){
			if (value.id == jsonq.id){
				iq = index;
			}
		});
		jsonw["WorkspaceProfile"]["Querysets"][qsid]["Queries"][iq] = jsonq;
		Workspace.save("USER", this, qsid, iq);
	}
	
	
	//appendQueryUI(jsonw["WorkspaceProfile"]["Querysets"][id]["Queries"][iq],iq, $('#userqueries'));
	
};
*/

Query.prototype.getcolumnstext = function (){
	
	if (this.columns_widget == null ) {
		return this.columns;
	}
	return this.columns_widget.getListText();
};

Query.prototype.updatecolumnstext = function (list) {
	var columns_text = "";
	
	$(list).each(function(index){
		if (index > 0) {
			columns_text = columns_text + ",";
		}
		columns_text = columns_text + $(this).text();
	});
	this.columns = columns_text;
};

/** special handling for special characters: double escaping (escape the %-sign)
 * to survive the %-encoding through the request (and parsing) down to the transformation in XCQL2XPath.xsl
 * it's: whitespace, and single and double-quotes (unified to double quotes %22)
*/  

Query.prototype.query_uri = function () {
	var params = "?";
	if (this.query != null) {
		params = params + "query=" + escapequerystring(this.query) + "&";
	}
	/*
	if (this.squery != null) {
		escaped_sq =escape(this.squery).replace(/%20/g,"%2520").replace(/\%2[27]/g,"%2522") ;
		escaped_sq = escaped_sq.replace(/%7C/g,"%257C").replace(/\+/g,"%2B"); 
		//params = params + "squery=" + escaped_sq + "&";
		params = params + "query=" + escaped_sq + "&";
	}
	*/
	params = params + "collection=" + this.getcollectiontext("index") + "&columns=" + this.getcolumnstext() + "&startRecord=" + this.startItem + "&maximumRecords=" + this.maximumItems + "&repository=" + this.repository;
	if  (this.options != null) {
		params = params + "&options=withSummary";
	}
	
	return params;

	//return $.param(this.query);
};

Query.prototype.sruquery_uri = function () {
	var params = "?operation=searchRetrieve&version=1.2&";
	var q = "";
	/*
	if (this.query != null) {
		q = "( "  + escape(this.query) + " )";
	}
	*/
	if (this.query != null) {
		escaped_sq =escape(this.query).replace(/%20/g,"%2520").replace(/\%2[27]/g,"%2522") ;
		escaped_sq = escaped_sq.replace(/%7C/g,"%257C").replace(/\+/g,"%2B"); 
		/*if (q.length > 0){
			q = q + " and ";
		}*/
		q =  escaped_sq;
	}
	params = params + "query=" + q + "&x-cmd-collections=" + this.getcollectiontext("index") + 
	"&startRecord=" + this.startItem + "&maximumRecords=" + this.maximumItems + "&x-cmd-repository=" + this.repository;
	
	return params;
};

Query.prototype.toString = function(){
	var str = "";
	var coll = (this.getcollectiontext("name") != "" ) ? " in " + this.getcollectiontext("name") : "";
	str = Query.simplequerystring(this.query) + coll + " @" + this.repository.toString();
	return str;
};

Query.prototype.publish = function() {
	//$.data("query",this);
	var q = this;
	//if (q.vcrid == 0){
		$.get("/MDService2/virtualcollection/USER/" + this.id,"", function(data){
			if (q.vcrid == 0){
				var id = parseInt($(data).children().children('virtualcollectionid').text());
				q.vcrid = id;
				q.save();
			}
		});
	//} 
};

Query.prototype.toJSON = function () {
//Query.prototype.query_json = function () {	
	var dt = new Date();
	var str_time = dateFormat(dt);//dt.toString("dd/mm/yyyy HH:mm:ss");
	//var jsonq = { "options" : json_options, "bookmark" : bookmark, "time" : str_time};
	var json_options = this.options; 
	if (this.options != null) {
		json_opts = [{}];
		json_opts[0] = this.options;
	}

	// collections
	var json_coll;
		
	if (this.collection.length == 0) {
		json_coll = {};
		json_coll = "null";
	} else { 
		json_coll = [{}];
		for (var i = 0; i < this.collection.length; i++) {
			json_coll[i] = {"index" : this.collection[i].index, "name" :this.collection[i].name};
		}
	}
	//columns
	var json_cols;
	var cols = this.columns;
	if (cols == "") {
		//json_cols = {};
		json_cols = "null";
	} else {  
		var pos = this.columns.indexOf(",", 0);
		var i = 0;
		
		json_cols = [{}];
		while (pos > -1){
			if (pos > -1){
				json_cols[i] = cols.substring(0,pos);
			} else {
				json_cols[i] = cols;
			}
			cols = cols.substring(pos+1);
			pos = cols.indexOf(",", 0);
			i = i+1;
		}
		
		json_cols[i] = cols;
	}

	var jsonq = {"id":this.id,
				 "name":"",
			     "querystring":this.query,	
				 "searchclauses":"null" ,
				 "collections" : json_coll, 
				 "columns" : json_cols,
				 "startItem" : this.startItem,
				 "maximumItems" : this.maximumItems,
				 "options" : json_options, 
				 "bookmark" : this.bookmark,
				 "time" : str_time,
				 "vcrid": this.vcrid};
	
	if (this.bookmark == "1") {
		qstring = Url.decode(qstring);
		var s = qstring.split(':');
		jsonq.name = s[s.length - 2] + ":" + s[s.length - 1];
	} else {
		jsonq.name = Query.fullformatstring(jsonq);
	}
	
	return jsonq;//JSON.stringify(jsonq);
};

Query.prototype.getcollectiontext = function(what) {
	var collection_text = "";
	for (var i = 0; i < this.collection.length; i++) {
		if (what == "index") {
			collection_text = collection_text + "," + this.collection[i].index;
		} else {
			collection_text = collection_text + "," + this.collection[i].name;	
		}
	}
	if (collection_text.length > 1) {
		collection_text = collection_text.substring(1);	
	}
	return collection_text;
};
Query.prototype.getcollectionindextext = function() {
	var collection_text = "";
	for (var i = 0; i < this.collection.length; i++) {
		collection_text = collection_text + "," + this.collection[i].index;
	}
	if (collection_text.length > 1) {
		collection_text = collection_text.substring(1);	
	}
	return collection_text;
};

Query.collectiontext = function(json) {
	var collection_text = "";
	if (json.collections != "null"){
		$.each(json.collections,function(i,item){
			collection_text = collection_text + "," + item.name;
		});
		if (collection_text.length > 1) {
			collection_text = collection_text.substring(1);	
		}
	}
	return collection_text;
};

Query.columnstext = function(json) {
	var columns_text = "";
	if (json.columns != "null"){
		$.each(json.columns,function(i,item){
			columns_text = columns_text + "," + item;
		});
		if (columns_text.length > 1) {
			columns_text = columns_text.substring(1);	
		}
	}
	return columns_text;
};

Query.optionstext = function(json) {
	var options_text = "";
	if (json.options == undefined){
		return "";
	}
	if (json.options != "null"){
		$.each(json.options,function(i,item){
			options_text = options_text + "," + item;
		});
		if (options_text.length > 1) {
			options_text = options_text.substring(1);	
		}
	}
	return options_text;
};

Query.fullformatstring = function (json) {
	var qs = json.querystring;
	
	if (qs == "[NULL]") {
		qs = null;
	}
	
	
	var collection_text = Query.collectiontext(json);
	
	var full_str = "";
	var len = formatquerystring_len;
	
	if (qs != null) {
		qs = Query.simplequerystring(qs);
		if (qs.length > len){
			full_str = full_str + qs.substring(0,len) + "..| ";
		} else {
			qs = qs + "                                     ";
			full_str = full_str + qs.substring(0,len) + "  | ";
		}
	}
	if (collection_text.length > (len - 6)) {
		full_str = full_str + collection_text.substring(0,len);
	} else {
		full_str = full_str + collection_text;
	}
	
	return full_str;
};

Query.simplequerystring = function (querystring) {

	if (querystring == null){
		return "";
	}
	querystring = Url.decode(querystring);
	
	var arr_and = querystring.split(" and ");
	var simple_form = "";
	var simple_form_all = "";
	var rel = "";
	
	for( var i=0;i<arr_and.length;i++){
		arr_and[i] = $.trim(arr_and[i]);
		var arr_or = arr_and[i].split(" or ");
		simple_form = "";
		for( var j=0;j<arr_or.length;j++){
			arr_or[j] = $.trim(arr_or[j]);
			while (arr_or[j].substring(0,1) == "(" ) {
				arr_or[j] = arr_or[j].substring(1,arr_or[j].length);
				arr_or[j] = $.trim(arr_or[j]);
			}
			while ( arr_or[j].substring(arr_or[j].length-1) == ")"){
				arr_or[j] = arr_or[j].substring(0,arr_or[j].length-1);
				arr_or[j] = $.trim(arr_or[j]);
			}
			if (j > 0) { 
				rel = " or ";
			} else {
				rel = "";
			}
			simple_form = simple_form + rel + arr_or[j];
		}
		if (arr_or.length > 1){
			simple_form = "(" + simple_form + ") ";
		}
		if (i > 0) { 
			rel = " and  ";
		} else {
			rel = "";
		}
		simple_form_all = simple_form_all + rel + simple_form;
		
	}
	
	
	//notifyUser("querystring:" + querystring, 'debug');
	//notifyUser("simplequerystring:" + simple_form_all, 'debug');
	return simple_form_all;
};

Query.prototype.render = function () {

	// FIXME: this is not nice, there should be a function providing the formatted string of the query.
	//var coll = (this.getcollectiontext("name") != "" ) ? " in " + this.getcollectiontext("name") : "";  
	var x = "<div id='" + this.listid + "' class='query_wrapper ui-widget' name='query' ><div class='query_header ui-widget-header ui-state-default ui-corner-top'>" +
	"<span class='cmd cmd_get'></span><span class='cmd cmd_del'> </span>" +
	"<span class='query_id'>" + this.listid + "</span>: <span class='query'>" +
	this.toString() + 
	"</span>" + 
			"</div>" +
			"<div class='result ui-widget-content ui-corner-bottom'></div>";
	addToQuerylist(x);	
	
	this.container = $('#' + this.listid );
	$(this.container).data('query',this);
	
	notifyUser("DEBUG: setting up removing query:" + $(this).closest('.query_wrapper').attr('id'));
	$(this.container).children('.query_header').find('.cmd_del').click(function(event) {
		notifyUser("DEBUG: removing query:" + $(this).closest('.query_wrapper').attr('id'));
		queryset.removequery($(this).closest('.query_wrapper').attr('id'));
	});
	
	createTooltip(this.container);
 };
 
 Query.prototype.open = function (type) {
	 if (type != null)
	    window.open(this.link(type));
	 else
		window.open(this.link());
};
 
 Query.prototype.link = function (type) {
	 var uri="";
	 if (type=="fullpage")  {
		 uri = link('base',this.query_uri());
	 } else {
		 //if (type == "xml"){
		 //	 uri = link('sru',this.sruquery_uri());
		 //} else {
			 uri = link('search', type, this.query_uri());
		// }		
	 }
	return uri;
 };
  
 Query.prototype.link_obsoleted = function () {
	 
		// JSON conversion
    	 var jsonq = { "querystring":this.query, "searchclauses":"null" , "collections" : this.json_coll, "columns" : this.json_cols};

		var uri = "?query=" + JSON.stringify(jsonq) + "&startItem=" + this.startItem + "&maximumItems=" + this.maximumItems;
		return uri;
};
 Query.prototype.submit = function () {
	 	
	 	var uri;
	 	
	 	var reptype = workspace.getRepositoryType(this.repository);
	 	
	 	// USE CLIENT PAZPAR
	 	/*
	 	if (reptype=="pazpar"){
	 		//pazpar handling this
	 		pazparsubmit(this);
	 		return;
	 	}
	 */
	 	// ALL types  = query uri, 
	 	// pazpar server usage
	 	uri = link('search',this.format, this.query_uri());
	 	
	 	/*
	 	if (reptype=="md" ){
			uri = link('recordset',this.format, this.query_uri());
	 	} else {
	 		if (reptype=="sru"){
	 			uri = link('sru', this.format, this.sruquery_uri());
	 		} else {
	 			// USE SERVER PAZPAR 
	 			//if (reptype=="pazpar"){
		 		//	uri = link('pazpar', this.format, this.query_uri());
		 		//} else {
		 		
		 			return;
		 		//}
	 		}
	 	}
	 	*/

	 	
		var query = this;
		notifyUser("submitting query:" +  uri);
		this.container.find('.result').load( uri, function() {
					notifyUser("result-loaded",'debug');
					
					var get = $(this).parent().find('.cmd_get');				

					get.removeClass('cmd_get');
					get.addClass('cmd_up');
					// get.show();
					
					var result_header = $(this).find('.result-header');
					
					var q_header;
					q_header = $(this).parent().find('.query_header');					
					q_header.append(result_header);
					
				 	addDetailFunctionality(q_header, query);
				 	$(q_header).find('.result-header').height($(q_header).height());
				 	
					createTooltip($(this));
				});

	};
	
Query.prototype.resubmit = function () {
	
	var uri;// = link('recordset',this.format, this.query_uri());
	var reptype = workspace.getRepositoryType(this.repository);
 	if (reptype=="pazpar"){
 		//pazpar handling this
 		return;
 	}
 	if (reptype=="md" ){
		uri = link('search',this.format, this.query_uri());
 	} else {
 		if (reptype=="sru"){
 			uri = link('sru', this.format, this.sruquery_uri());
 		} else {
 			return;
 		}
 	}
	var qid = this.listid;
	//var q_uri = this.query_uri();
	var query = this;
	
	notifyUser("resubmitting query:" +  uri);
	
	var get = $('#' + qid ).find('.cmd_up');
	if (get.length == 0) {
		get = $('#' + qid ).find('.cmd_down');
	}
	get.addClass('cmd_get');
	get.removeClass('cmd_up');
	get.removeClass('cmd_down');
	// get.show();	

	$('#' + qid ).children('.result').children().remove();
	$('#' + qid ).find('.result').load( uri, function() {
				// update link-hrefs
				var qid = $(this).closest('.query_wrapper').attr("id");
				notifyUser("result-loaded ID:" + qid,'debug');
				
				var q = queryset.getQuery(qid);
				$('#' + qid ).find(".cmd_link").attr("href", q.link("fullpage"));
				
				var get = $(this).parent().find('.cmd_get');				
				get.removeClass('cmd_get');
				get.addClass('cmd_up');
				// get.show();	
				
				var result_header = $(this).find('.result-header');
				
				var q_header;
				q_header = $(this).parent().find('.query_header');
				q_header.children('.result-header').remove();
				
				q_header.append(result_header);				
			 	addDetailFunctionality(q_header, query);
			});

};

Query.prototype.summaryinfo = function () {
	
	var uri = link('recordset',this.format, this.query_uri());
	//columns-wrapper
	var temp = $('<div />');
	$(temp).data('qcontainer',$(this.container));
	$(temp).load(uri, function(response, status, xhr) { 
		//detailcaller.getdetail("detail_query").close();
		/*
		var profiles = $(this).find('.used-profiles');
		var parent = $(this).data('qcontainer').find('.used-profiles').parent();
		$(parent).remove('.used-profiles').append(profiles);
		
		var summary = $(this).find('.result-summary');
		parent = $(this).data('qcontainer').find('.result-summary').parent();
		$(parent).remove('.result-summary').append(summary);
		*/
		//detailcaller.calldetail($(this).data('qcontainer').find('.result-header').find('.cmd_detail'));

		// direct replace detail data
		var detailcontent = detailcaller.getdetail("detail_query").content;
		
		var profiles = $(this).find('.used-profiles');
		var parent = detailcontent.find('.used-profiles').parent();
		$(parent).find('.used-profiles').remove();
		$(parent).append(profiles);
		
		var summary = $(this).find('.result-summary');
		$(summary).find('.terms-tree').treeTable({initialState:"collapsed"});
		var parent = detailcontent.find('.result-summary').parent();
		$(parent).find('.result-summary').remove();
		$(parent).append(summary);
		$(parent).find('.cmd_columns').click(function(){
			query_wrapper_add_column($(this));
		});
	}); 


};

Query.prototype.updateColumns = function(selectionlist){
	if (selectionlist != undefined){
		if (selectionlist.autoSelected()){
			this.columns = "";
		} else
		{
			this.columns = selectionlist.listwidget.getListText();
		}
	}
};

Query.prototype.next = function(pages){
	var start = 0;
	var num = 0;
	var max_value = $('#' + this.listid ).find('.result-header').attr("max_value");
	
	if (parseInt(this.startItem) + pages * page_record_count >= 1){
		start =	parseInt(this.startItem) + pages * page_record_count ;
	} else if (parseInt(this.startItem) + pages * page_record_count + page_record_count - 1 >= 1){
		start =	1 ;
	}
	if (start > 0){
		if (start + page_record_count - 1 <= max_value) {
			num = page_record_count;
		} else if (start <= max_value){
			num = max_value - start;
		}
	
		if (num > 0){
			this.startItem = start;
			this.maximumItems = num;
			this.resubmit();
			updateQueryDetailPane(this);
		}
	}
};

var queryset_container = $("#querylist"); 

/**
 * A singleton-object holding all queries.
 * @constructor
*/ 
var queryset = { queries: [],
	container: '#querylist',
	recordrowselected: undefined,
	
	addquery: function (query){
			
		this.queries[this.queries.length] = query;
		query.listid = "q" + this.queries.length;
		query.render();				
		query.submit();		
	},

	removequery: function (qid) {
		notifyUser("removing query:"  + qid);
		
		 for (var i = 0; i < this.queries.length; i++) {
			if (this.queries[i].listid == qid) {
				this.queries.splice(i, 1);
			} 
		}	
		$('#' + qid).remove();
		notifyUser("query removed, new queries.length:"  + this.queries.length);
		
	},
	getquerystring: function(qid) {
		var qstring = "";
		
		for (var i = 0; i < this.queries.length; i++) {
			if (this.queries[i].listid == qid) {
				qstring = this.queries[i].query;
			} 
		}
		if (qstring == null){
			qstring = "";
		}

		return qstring;
	},
	getcollections: function(qid) {
		var coll = "";
		var json_coll, json_temp;
		
		for (var i = 0; i < this.queries.length; i++) {
			if (this.queries[i].listid == qid) {
				coll = this.queries[i].collection;
			} 
		}		
		if (coll.length == 0) {
			json_coll = {};
			json_coll = "null";
		} else { 
			json_coll = [{}];
			for (var i = 0; i < coll.length; i++) {
				json_coll[i] = {"index" : coll[i].index, "name" :coll[i].name};
			}
		}
		return json_coll;
	},
	
	getcolumns: function(qid) {
		var cols = "";
		var json_cols, json_temp;
		
		for (var i = 0; i < this.queries.length; i++) {
			if (this.queries[i].listid == qid) {
				cols = this.queries[i].columns;
			} 
		}
		
		if (cols == "") {
			json_cols = {};
			json_cols = "null";
		} else {  
			var pos = cols.indexOf(",", 0);
			var i = 0;
			
			json_cols = [{}];
			while (pos > -1){
				if (pos > -1){
					json_cols[i] = cols.substring(0,pos);
				} else {
					json_cols[i] = cols;
				}
				cols = cols.substring(pos+1);
				pos = cols.indexOf(",", 0);
				i = i+1;
			}
			
			json_cols[i] = cols;

			
		}
		return json_cols;
	},
	getoptions: function(qid) {
		var opts = null;
		var json_opts;
		
		for (var i = 0; i < this.queries.length; i++) {
			if (this.queries[i].listid == qid) {
				opts = this.queries[i].options;
			} 
		}

		if (opts != null) {
			json_opts = [{}];
			json_opts[0] = opts;
		}
		return json_opts;
	},
	resubmit: function(qid){
		var query = queryset.queries[qid.substring(1)-1];
		
		query.repository = getSelectedRepository();
		query.startItem = $('#' + qid ).find('.start_record').val();
		query.maximumItems = $('#' + qid ).find('.maximum_records').val();
		query.resubmit();

	},
	
	getQuery: function(qid){
		var query = queryset.queries[qid.substring(1)-1];
		return query;
	},
	recorddetailselection: function(recordrow){
		if (this.recordrowselected != undefined){
			$(this.recordrowselected).removeClass('detailselection');
		}
		this.recordrowselected = recordrow;
		$(this.recordrowselected).addClass('detailselection');
	}
	
	
};

$('#querylist .cmd_columns').live('click',function(){
	notifyUser("DEBUG: #querylist.cmd_columns");
	$(this).closest('.query_wrapper').find('.columns-wrapper').toggle();
});

function query_wrapper_add_column(elem){
	var slid = $(elem).closest('.query-columns').find('.widget-wrapper').attr('id');
	var sl = selectionlistset.getselectionlist(slid);
	if (sl.autoSelected()){
		sl.select(0);
	}
	sl.listwidget.add(new ListItem($(elem).closest('.treecol').children('.column-elem').text()));
	
	//$(elem).data('query').updateColumns(slid);

};

function addDetailFunctionality(q_header, query){
	
	$(q_header).data('query',query);
	q_header.find('.cmd_reload').data('query',query);
	q_header.find('.cmds .cmd_save').data('qid',query.listid);
	q_header.find('.cmds .cmd_savenew').data('qid',query.listid);
 	q_header.find('.cmd_reload').click(function(event) {
 		event.preventDefault();	
 		$(this).data('query').updateColumns($(this).data('selectionlist'));
 		$(this).data('query').resubmit();
	});
	q_header.find('a.internal').click(function(event) {
		event.preventDefault();	
		if ($(this).hasClass('prev')){
			$(this).closest('.query_header').data('query').next(-1);
		}
		if ($(this).hasClass('next')){
			$(this).closest('.query_header').data('query').next(1);
		}
		
	});
	
	q_header.find('.value-format').data('query',query);
	q_header.find('.value-format').change(function(){
		$(this).data('query').format = $(this).find('option:selected').val();
		$(this).data('query').resubmit();
	});
	//q_header.find('.cmd_add').click(function(){
	//q_header.find('.cmd_columns').data('query', query);
	q_header.find('.cmd_columns').click( function(){
		query_wrapper_add_column($(this));
		//$(this).data('query').resubmit();
	});
	q_header.find('.columns-wrapper').hide();
	q_header.find('.terms-tree').treeTable({initialState:"collapsed"});

};
