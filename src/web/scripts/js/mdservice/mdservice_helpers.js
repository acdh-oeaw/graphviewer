/**
 * @fileOverview The file mainly should contain javascript assistance functions, which are not related directly to UI.
 * Actualy includes string additional functions,  Url decoding , datetime conversions
 * @author 
 * @version 
 */

// url params reading
var params;
function getUrlVars(url)
{
	if (url == undefined){
		url = window.location.href;
	}
    var vars = [], hash;
    var hashes = url.slice(url.indexOf('?') + 1).split('&');
    for(var i = 0; i < hashes.length; i++)
    {
        hash = hashes[i].split('=');
        vars.push(hash[0]);
        vars[hash[0]] = hash[1];
    }
    return vars;
    //return getUrlVars(window.location.href);
};



if(typeof String.prototype.trim !== 'function') {   String.prototype.trim = function() {     return this.replace(/^\s+|\s+$/g, '');    } }


String.prototype.beginsWith = function(t, i) { if (i==false) { return 
	 (t == this.substring(0, t.length)); } else { return (t.toLowerCase() 
	 == this.substring(0, t.length).toLowerCase()); } } ;


String.prototype.endsWith = function(t, i) { if (i==false) { return (t 
	 == this.substring(this.length - t.length)); } else { return 
	 (t.toLowerCase() == this.substring(this.length - 
	 t.length).toLowerCase()); } } ;


var Url = {
		 
			// public method for url encoding
		encode : function (string) {
			return escape(this._utf8_encode(string));
		},
	 
		// public method for url decoding
		decode : function (string) {
			return this._utf8_decode(unescape(string));
		},
	 
		// private method for UTF-8 encoding
		_utf8_encode : function (string) {
			string = string.replace(/\r\n/g,"\n");
			var utftext = "";
	 
			for (var n = 0; n < string.length; n++) {
	 
				var c = string.charCodeAt(n);
	 
				if (c < 128) {
					utftext += String.fromCharCode(c);
				}
				else if((c > 127) && (c < 2048)) {
					utftext += String.fromCharCode((c >> 6) | 192);
					utftext += String.fromCharCode((c & 63) | 128);
				}
				else {
					utftext += String.fromCharCode((c >> 12) | 224);
					utftext += String.fromCharCode(((c >> 6) & 63) | 128);
					utftext += String.fromCharCode((c & 63) | 128);
				}
	 
			}
	 
			return utftext;
		},
	 
		// private method for UTF-8 decoding
		_utf8_decode : function (utftext) {
			var string = "";
			var i = 0;
			var c = c1 = c2 = 0;
	 
			while ( i < utftext.length ) {
	 
				c = utftext.charCodeAt(i);
	 
				if (c < 128) {
					string += String.fromCharCode(c);
					i++;
				}
				else if((c > 191) && (c < 224)) {
					c2 = utftext.charCodeAt(i+1);
					string += String.fromCharCode(((c & 31) << 6) | (c2 & 63));
					i += 2;
				}
				else {
					c2 = utftext.charCodeAt(i+1);
					c3 = utftext.charCodeAt(i+2);
					string += String.fromCharCode(((c & 15) << 12) | ((c2 & 63) << 6) | (c3 & 63));
					i += 3;
				}
	 
			}
	 
			return string;
		}
	 
};

function dateFormat(dt){
	
	var str = "";
	var month = dt.getMonth() + 1;
	if (month < 10){
		month = "0" + month			
	}
	var day = dt.getDay();
	if (day < 10){
		day = "0" + day;
	}
	var hours = dt.getHours();
	if (hours < 10) {
		hours = "0" + hours;
	}
	var minute = dt.getMinutes();
	if (minute < 10) {
		minute = "0" + hours;
	}
	var second = dt.getSeconds();
	if (second < 10) {
		second = "0" + second;
	}
	str = dt.getFullYear() + "-" + month + "-" + day + " " + hours + ":" + minute + ":" + second;
	
	return str;
}

function link(action,format,params) {
	var l = actions[action].base_uri + format;

	// default param is q
	if (params){
		if ( ! $.isArray(params)) {
			//l += '/' + params;
			l += params;
		} else {
			l += '?' + $.param(params);
		}
	}
	notifyUser("l:"+ l,'debug');
	return l;
}

function CloneObject(inObj) {
	for (i in inObj) {
		this[i] = inObj[i];
	}
}// Usage:x = new CloneObject(obj);

function findPos(obj) {
	var curleft = obj.offsetLeft || 0;
	var curtop = obj.offsetTop || 0;
	while (obj = obj.offsetParent) {
		curleft += obj.offsetLeft;
		curtop += obj.offsetTop;
	}
	return {x:curleft,y:curtop};
}
