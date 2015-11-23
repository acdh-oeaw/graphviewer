
// Module QueryInput
// provides a jQuery plugin with the same name.
!function ($, console) {
    // could expose the defaults: $.fn.QueryInput.defaults =
    //{q:{label:"Query", widget:"text"}, submit:{value:"Search", widget:"submit"}}
    var defaults = {
        params: {},
        input_prefix: "input-",
        slider_style: {width: "80px", display: "inline-block", "font-size": "70%", margin: "6px 12px 0 2px"},
        onValueChanged: function () {},
        fcs_source: "http://193.170.82.207:8680/exist/apps/sade/amc/fcs?operation=scan&x-format=json&scanClause="
    };
    
    var module = {};

    /**
     * @class QueryInput
 * generate a customizable query_input UI, a input form with fields/widgets based on settings
 * options: multiple params/fields, 
 * indexes, different widgets
 *
 * dependencies: jQuery, jquery-ui: slider, autocomplete
 
 * @author vronk, Andy Basch
 * @version 2013-01-17
 */
/* we could make it a class (instead of jQuery plugin)
       function QueryInput(elem,s) */
    module.QueryInput = function (options)
{
   /** the dom-element to generate the query input in */
   var elem=this;
    
    /** main variable holding all the settings for qi, especially also all params and their allowed values, and their current value
      * it is constructed here by merging the default and the user options passed as parameter to .QueryInput()
      */
   var settings = $.extend(true, {}, defaults, options);
        
        /** gets the current value for a parameter
         * accepting settings as reliable source of current value
         * i.e. changes in input have to change the .value in settings.
         * This is assured by calling setParamValue upon input-change.
         * public by calling: $(elem).data("qi").getParamValue(param_key);
         * @public 
         */
        settings.getParamValue = function (key) {
            if (this.params[key]) {
                return this.params[key].value;
            } else {
                return "";
            }
        };

        /** allow to update the current value in settings from outside */
        settings.setParamValue = function (key, value) {

            if (settings.params[key]) {
                settings.params[key].value = value;
            }
            // callback:
            settings.onValueChanged.call(settings, value);
            return value;
        };
      
    blendInParams();  

        // makes the settings publicly available as .data("qi")
   elem.data("qi",settings); 
   init(settings);   

  function init(s) {
    //empty the target element - TODO:optional
    elem.html('');
    generateWidgets(s.params, elem);
  }
    
  /** run through the params and generate the widget for every param */
  function generateWidgets (params, trg_container) {
        
        $(trg_container).append("<form />");
        var form = $(trg_container).find("form");
        
      for ( var key in params ) {
         var param = params[key];
         console.log("creating widget: " + param.widget + " for: " + key);
        // if input already exists - fill it with the default value
        if ($('#' + settings.input_prefix + key).length) {
            $('#' + settings.input_prefix + key).value = param.value;   
         } else if (trg_container)  {
            var label= param.label ? param.label : key;
            var new_input_label = param.label === '' ? $('') : $(
                            "<label for='" + settings.input_prefix + key + "'>" + label+ "</label>"
                            );
                    var new_input=null, new_widget=null;
            
            switch (param.widget) {
                case "text":
                  new_input = genText(key, param);    
                  break;
                case "checkbox":
                  new_input = genCheckBox(key, param);
                  break;
                case "hidden":
                  new_input = genHidden(key, param);
                  break;
                case "submit":
                  new_input = genSubmit (key, param);    
                  break;
                case "selectone":
                  new_input = genCombo(key, param);    
                  break;
                case "multiselect":
                            var elems = genMultiselect(key, param);
                            new_input = elems[0];
                            new_widget = elems[1];
                            break;
                        case "autocomplete":
                  new_input = genAutocomplete (key, param);    
                  break;
               case "cql":
                  var cql_elems = QueryInput_CQL.genCQLInput(key, param);
                  new_input = cql_elems[0];
                  new_widget = cql_elems[1]; 
                  break;
                case "vkb-cql":                       
                            var cql_elems = QueryInput_CQL.genCQLInput(key, param);
                            new_input = genVKBCombo(key, param, cql_elems[0]);
                            new_widget = cql_elems[1];
                            break;
                        case "link":
                  new_input = genLink (key, param);    
                  break;
                case "slider":
                  var slider_elems = genSlider(key, param);
                  new_input = slider_elems[0];
                  new_widget = slider_elems[1]; 
                  break;
                default:
                  console.log("no such widget: " + param.widget + " for: " + key); 
              }    
        
          if (new_input) {
                        var new_input = $(new_input);
                        new_input.data("key", key)
                        .addClass("type-" + param.widget + (param.additional_classes === undefined ? '' :  ' ' + param.additional_classes))
                                .attr("id", settings.input_prefix + key)
                             .data("param-object", param);
                     
            if (param.data !== undefined) {
                            for (var k in param.data) {
                                new_input.attr("data-" + k, param.data[k]);
                            }
                        }
                        
                        if (param.widget !== "link") {
                 // set initial valuelink
                 $(new_input).val(param.value);
                     
                /* update settings and widgets upon value-change */
                new_input.change(function () {
                           setParamValue(this);
                            });
                        }
                        
                        if (new_input_label !== undefined) {
                            new_input_label.attr('for', settings.input_prefix + key);
                            if (param.additional_label_classes !== undefined) {
                                new_input_label.addClass(param.additional_label_classes);
                            }
                        }
                        if (settings.params[key].label_after_input === true) {
                            $(form).append(new_input, new_input_label, new_widget);
                        } else {
                            $(form).append(new_input_label, new_input, new_widget);
                        }
                    }
                }
            } // end for
       
       
    }
/*
    function formatForm(inputs) {
      for ( var key in inputs ) {
    
      }
        <table>
        </table>
    }
*/
    function genText(key, param_settings) {
         
        var input = $("<input />");
         $(input).attr("name",key);
         
        if (param_settings.size)
                $(input).attr("size", param_settings.size);

            return input;
    }
    
    function genCheckBox(key, param_settings) {
         
        var input = $("<input type='checkbox'/>");
            $(input).attr("name", key);
            if (param_settings.checked !== undefined)
                $(input).attr("checked", param_settings.checked);

            return input;
        }
        
        function genVKBCombo(key, param_settings, preconfigured_input) {
            preconfigured_input.attr("data-context", param_settings.cql_config.settings.context);
            preconfigured_input.addClass("virtual-keyboard-input");
            var input = $('<span class="virtual-keyboard-input-combo virtual-keyboard-input-above">' +
                        $('<div>').append(preconfigured_input).html() +
                        '<input type="checkbox" value="unused" class="virtual-keyboard-toggle" id="vkbt' + key + '"/>' +
                        '<label for="vkbt' + key + '" class="virtual-keyboard-first-three">äöü</label>');
            
            return input;
        }

        function genHidden(key, unused) {

            var input = $("<input type='hidden'  />");
            $(input).attr("name", key);

            return input;
        }

        function genLink(key, unused) {

            var a = $("<a>" + key + "</a>");
        a.attr("href", generateLink());
       
            $(a).mousedown(function(e) {
                $(this).attr("target", "_blank");
                $(this).attr("href", generateLink());
         });
        return a;
    }
    
    function genSubmit(key, param_settings) {
         
        var input = $("<input type='submit'/>");
         $(input).attr("name",key);
         $(input).attr("value",param_settings.label);
        return input;
    }
        
    /** generating our own comboboxes, because very annoying trying to use some of existing jquery plugins (easyui.combo, combobox, jquery-ui.autocomplete) */ 
    function genCombo (key, param_settings) {
    
        var select = $("<select id='widget-" + key + "' />");
            //select.attr("id", settings.input_prefix + key)
            
       if (param_settings.static_source) {
              //var scanURL = settings.fcs_source +  param_settings.index
              var source_url = param_settings.static_source.replace(/&amp;/g, '&');
                // if static source - try to retrieve the data 
              $.getJSON(source_url, function(data) {
                    param_settings.values = data.terms;
                    param_settings.values.forEach(function(v) { $(select).append("<option value='" + v.value + "' >" + v.label + "</option>") });
                    //console.log($(input).autocomplete().source);
              });
        
             //param_settings.source = fcsScan;
        } else if (param_settings.values) {
            //    $(input).autocomplete(param_settings);
            if (typeof  param_settings.values[0] ==='object') {// accept format with value and label
                  param_settings.values.forEach(function(v) { $(select).append("<option value='" + v.value +"' >" + v.label + "</option>") });
               } else { 
                   param_settings.values.forEach(function(v) { $(select).append("<option value='" + v +"' >" + v + "</option>") });
             }
        } else { /* if no values,  rather make a textbox out of it? */ 
          //select = 
        }
        
        select.attr("id", settings.input_prefix + key)
        return select;
    }

    /** generate autocomplete */ 
    function genAutocomplete (key, param_settings) {
        
        var input = $("<input />");
         $(input).attr("name",key)
   //     console.log(key, param_settings.static_source);
        if (param_settings.static_source) {
              //var scanURL = settings.fcs_source +  param_settings.index
              var source_url = param_settings.static_source.replace(/&amp;/g, '&');
                // if static source - try to retrieve the data 
              $.getJSON(source_url, function(data) {
                    param_settings.source = data.terms
                    $(input).autocomplete(param_settings);
                    //console.log($(input).autocomplete().source);
              });
        
             //param_settings.source = fcsScan;
        } else {
        $(input).autocomplete(param_settings);
        }
         
        return input;
        }

        /** generate a multiselect*/
        function genMultiselect(key, param_settings) {

            var parent = $("<div/>");
            var select = $("<select multiple='multiple' id='widget-" + key + "' />");
            select.attr("name", key);
            //select.attr("id", settings.input_prefix + key)
            parent.append(select);

            if (param_settings.static_source) {
                //var scanURL = settings.fcs_source +  param_settings.index
                var source_url = param_settings.static_source.replace(/&amp;/g, '&');
                // if static source - try to retrieve the data 
                $.getJSON(source_url, function (data) {
                    param_settings.values = data.terms
                    param_settings.values.forEach(function (v) {
                        $(select).append("<option value='" + v.value + "' >" + v.label + "</option>")
                    });
                    //console.log($(input).autocomplete().source);
                });

                //param_settings.source = fcsScan;
    }

    
    else if (param_settings.values) {
                //    $(input).autocomplete(param_settings);
                param_settings.values.forEach(function (v) {
                    $(select).append("<option value='" + v + "' >" + v + "</option>")
                });
            } else { /* if no values,  rather make a textbox out of it? */
                //select = 
            }

            select.attr("id", settings.input_prefix + key)
            select.chosen(param_settings);
            return [select, parent.find("#input_context_chosen")];
        }


        function fcsScan(request, response) {
        response($.ui.autocomplete.filter(
                          scan.terms, request.term));
            // extractLast( request.term )
    }
         
    /** generate a slider based on settings
        @returns an array of two elements: actual input-element with value and a div-container for the slider widget
    */
    function genSlider (key, param_settings) {

        var new_input = $("<input />");
            new_input.attr("id", settings.input_prefix + key)
                 .val(param_settings.value)
                 .attr("size", 3);
      
        var new_widget = $("<div class='widget-" + param_settings.widget + "'></div>");
            new_widget.attr("id", "widget-" + key)
                      .css(settings.slider_style)
                      .slider( param_settings)
                
                        // set both-ways references between the input-field and its slider - necessary for updating 
                        .data("related-input-field",new_input)
                        .data("related-widget",new_widget);
                     
            new_widget.bind("slidechange", function(event, ui) {
                $(this).data("related-input-field").val(ui.value);
                // update the settings-object, but with the (updated) value of the related input-field
                setParamValue($(this).data("related-input-field"));
            });
            
            /* update the widget upon input value-change (updating the settings-value is handled in the general part */
            new_input.bind("change", function () {
                   var related_widget = $(this).data("related-widget");
                   if ($(related_widget).hasClass("widget-slider")) {
                    $(related_widget).slider("option", "value", $(this).val()); }
             });
             
           return [new_input,new_widget]; 
    } 
    
    
    /** update the current value in settings */
    function setParamValue(input_object) {
        var param_object = $(input_object).data("param-object");
        param_object.value= $(input_object).val();
        var key = $(input_object).data("key");
        var value = settings.params[key].value;
       
        // callback:
        settings.onValueChanged.call( input_object,value );
        return value;
        }

        /** generate a query-link out of the current values of the params */
    function generateLink()
    {
      var url = "?";

            for ( var key in settings.params) {
           if (settings.params[key].value) {
                 url += key + "=" + settings.params[key].value + "&"; 
             }      
            }
            
           return url;
       }

    /** overwrite settings with param-values from the URL-search string if available
       not using $.extend(), because we still want only known/defined params overriden, not adding new params that might be in the url (?) */
       function blendInParams() {
           var params= getUrlParams();
             for ( var key in settings.params ) {
                if (params[key]) {settings.params[key].value=params[key]; }
             }
       }
  
         /** get params from the uri */
        function getUrlParams() {
            var currentURI = new URI();
            var params = currentURI.search(true);
            return params;
        }



  };     // end $.fn.QueryInput


    /* TODO: add defaults for widgets, like:
     widgets: {slider: {style:{width:"80px", display:"inline-block", "font-size": "70%",  margin: "6px 12px 0 2px"}}},
     */
    
    // publish;
    // this.QueryInput = module;
    $.fn.QueryInput = module.QueryInput;

}(jQuery, console);

