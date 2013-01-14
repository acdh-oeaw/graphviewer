
/**
 * @fileOverview this is copy of mdservice/mdservice_ui_settings.js
    It includes all variables and possibilities of app settings concerning following areas:
 * data loading  - actions - possible to set details of data loading (uri)
 * pane structure 
 *	- layout_settings[pane_name], layoutBaseSettings - sets the properties of particular panes (ui-layout plugin settings )
 *	- layout_initialisation - structure of particular pane placement
 * app functionality - blocks_settings - the properties of particular ui blocks (type of detail-window display, commands-TODO)
 * @author 
 * @version 
 */

//VARIABLES
//var jsonw, json_admin;
var workspace;
var json_admin;
var url_params;
var local_collections = false;

var  element_autocomplete = new Array();
var  element_autocomplete_explain = new Array();
var  elements_hashtable =  {};

var outerLayout, middleLayout, innerLayout;
var block_positions = ["center","north","south","east","west"];


// LOAD DATA SEETTINGS
var actions = {
			base: {
			base_uri: "/MDService2/"
		},
		collections: {
			base_uri: "/MDService2/collections/",			
			current:'olac'},
		elements: {
				base_uri: "/MDService2/element/",			
				current:''},
		terms: {
			base_uri: "/MDService2/terms/",			
			current:'all',
			maxdepth: 8},
		terms_autocomplete: {
				base_uri: "/MDService2/terms/",	
				current:''},
		components: {
				base_uri: "/MDService2/comp/",				
				current:''},
				/* current:'cmdi-corpus-aac2'}, */		
		compprofiles: {
				base_uri: "/MDService2/compprofile/",				
					current:''},
					/* current:'cmdi-corpus-aac2'}, */		
				
		search: {
				base_uri: "/MDService2/search/"
				},

		isocat: {
				base_uri: "/MDService2/datcats/",
				current:5
				},
		sru: {
				base_uri: "/MDService2/sru/"
			 },
		pazpar: {
					base_uri: "/MDService2/pazpar2/"
				 },
		smc: {
					base_uri: "/MDService2/smc/"
				},
		fcs: {
					base_uri: "/MDService2/fcs"
				}	

	};



// LAYOUT SETTING
var layoutBaseSettings = { 
		
		//	center__paneSelector:	".base-center" 
		//,	west__paneSelector:		".base-west" 
		//,	east__paneSelector:		".base-east"
		//,	north__paneSelector:	".base-north" 
		    size:					"auto"
		  ,	west__size:				140 
		  ,	east__size:				280 
		//,	north__size:			200
		  ,	spacing_open:			4//8 // ALL panes
		//,	spacing_closed:			12//12 // ALL panes
		//,	north__spacing_open:	0
		//,	south__spacing_closed:	0
		//,	north__maxSize:			200
		//,	south__maxSize:			200
		  , contentSelector:		".content"
};

var layoutSettings_querysearch_advanced = { 
		north__size:			200
	,	north__spacing_open:	2
};
var layoutSettings_columns_collections = { 
		west__size:			300
	,	west__spacing_open:	2
};
var layoutSettings_coll_block = { 
		north__size:			60
	,	north__spacing_open:	2
};

/* layout sample
var layoutSettings_Outer = {
		name: "outerLayout" // NO FUNCTIONAL USE, but could be used by custom code to 'identify' a layout
		// options.defaults apply to ALL PANES - but overridden by pane-specific settings
	,	defaults: {
			size:					"auto"
		,	minSize:				50
		,	paneClass:				"pane" 		// default = 'ui-layout-pane'
		,	resizerClass:			"resizer"	// default = 'ui-layout-resizer'
		,	togglerClass:			"toggler"	// default = 'ui-layout-toggler'
		,	buttonClass:			"button"	// default = 'ui-layout-button'
		,	contentSelector:		".content"	// inner div to auto-size so only it scrolls, not the entire pane!
		,	contentIgnoreSelector:	"span"		// 'paneSelector' for content to 'ignore' when measuring room for content
		,	togglerLength_open:		35			// WIDTH of toggler on north/south edges - HEIGHT on east/west edges
		,	togglerLength_closed:	35			// "100%" OR -1 = full height
		,	hideTogglerOnSlide:		true		// hide the toggler when pane is 'slid open'
		,	togglerTip_open:		"Close This Pane"
		,	togglerTip_closed:		"Open This Pane"
		,	resizerTip:				"Resize This Pane"
		//	effect defaults - overridden on some panes
		,	fxName:					"slide"		// none, slide, drop, scale
		,	fxSpeed_open:			750
		,	fxSpeed_close:			1500
		,	fxSettings_open:		{ easing: "easeInQuint" }
		,	fxSettings_close:		{ easing: "easeOutQuint" }
	}
	,	north: {
			spacing_open:			1			// cosmetic spacing
		,	togglerLength_open:		0			// HIDE the toggler button
		,	togglerLength_closed:	-1			// "100%" OR -1 = full width of pane
		,	resizable: 				false
		,	slidable:				false
		//	override default effect
		,	fxName:					"none"
		}
	,	south: {
			maxSize:				200
		,	spacing_closed:			0			// HIDE resizer & toggler when 'closed'
		,	slidable:				false		// REFERENCE - cannot slide if spacing_closed = 0
		,	initClosed:				true
		//	CALLBACK TESTING...
		,	onhide_start:			function () { return confirm("START South pane hide \n\n onhide_start callback \n\n Allow pane to hide?"); }
		,	onhide_end:				function () { alert("END South pane hide \n\n onhide_end callback"); }
		,	onshow_start:			function () { return confirm("START South pane show \n\n onshow_start callback \n\n Allow pane to show?"); }
		,	onshow_end:				function () { alert("END South pane show \n\n onshow_end callback"); }
		,	onopen_start:			function () { return confirm("START South pane open \n\n onopen_start callback \n\n Allow pane to open?"); }
		,	onopen_end:				function () { alert("END South pane open \n\n onopen_end callback"); }
		,	onclose_start:			function () { return confirm("START South pane close \n\n onclose_start callback \n\n Allow pane to close?"); }
		,	onclose_end:			function () { alert("END South pane close \n\n onclose_end callback"); }
		//,	onresize_start:			function () { return confirm("START South pane resize \n\n onresize_start callback \n\n Allow pane to be resized?)"); }
		,	onresize_end:			function () { alert("END South pane resize \n\n onresize_end callback \n\n NOTE: onresize_start event was skipped."); }
		}
	,	west: {
			size:					250
		,	spacing_closed:			21			// wider space when closed
		,	togglerLength_closed:	21			// make toggler 'square' - 21x21
		,	togglerAlign_closed:	"top"		// align to top of resizer
		,	togglerLength_open:		0			// NONE - using custom togglers INSIDE west-pane
		,	togglerTip_open:		"Close West Pane"
		,	togglerTip_closed:		"Open West Pane"
		,	resizerTip_open:		"Resize West Pane"
		,	slideTrigger_open:		"click" 	// default
		,	initClosed:				true
		//	add 'bounce' option to default 'slide' effect
		,	fxSettings_open:		{ easing: "easeOutBounce" }
		}
	,	east: {
			size:					250
		,	spacing_closed:			21			// wider space when closed
		,	togglerLength_closed:	21			// make toggler 'square' - 21x21
		,	togglerAlign_closed:	"top"		// align to top of resizer
		,	togglerLength_open:		0 			// NONE - using custom togglers INSIDE east-pane
		,	togglerTip_open:		"Close East Pane"
		,	togglerTip_closed:		"Open East Pane"
		,	resizerTip_open:		"Resize East Pane"
		,	slideTrigger_open:		"mouseover"
		,	initClosed:				true
		//	override default effect, speed, and settings
		,	fxName:					"drop"
		,	fxSpeed:				"normal"
		,	fxSettings:				{ easing: "" } // nullify default easing
		}
	,	center: {
			paneSelector:			"#mainContent" 			// sample: use an ID to select pane instead of a class
		,	onresize:				"innerLayout.resizeAll"	// resize INNER LAYOUT when center pane resizes
		,	minWidth:				200
		,	minHeight:				200
		}
};
*/

//BLOCKS LAYOUT
var layout_initialisation = {
	base: {
		layout: "",
		parent: 'body',
		model_settings: layoutBaseSettings,
		settings: "",
		center: ['base_center_p'],
		west: ['#index-container'],
		east: ['#detail-container'],
		north: ['#header']
		 },
    base_center_p: {
			 layout: "",
			parent: "",
			model_settings: layoutBaseSettings,
			settings: "",
			center: ["#infovis-wrapper"],
			north: ["#navigate"]
		},
		
};


// type = [floating, pane, inline]
var blocks_settings = {
	querysearch:{
		id: "#querysearch",
		//sublayouts: ['querysearch_advanced'],
		commands: {
			block:['cmd_advanced']
		}
	},
	querylist:{
		id: "#querylistblock",
		//sublayouts: [],
		commands: {
			block:['cmd_close']
		}
	},
	collections:{
		id: "#collections",
		detail: {
			parent: "",
			type: "floating"
		}
	},
	terms:{
		id: "#terms",
		detail: {
			parent: "",
			type: "pane"
		}
	},
	index:{
		id: "",
		detail: {
			parent: "",
			type: "pane"
		}
	},
	values:{
		id: "#values",
		detail: {
			parent: "",
			type: "floating"
		}
	},
	query:{
		id: "#query",
		detail: {
			parent: "",
			type: "pane"
		}
	},
	record:{
		id: "#records",
		detail: {
			parent: "",
			type: "pane"
		}
	},
	info:{
		id: "#info",
		detail: {
			parent: "",
			type: "pane"
		}
	}
};