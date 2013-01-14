

/**
 * @fileOverview functions for handling options
 * @author 
 * @version 
 */

/**
gets an option, checking with the values in the navigation-UI
*/
function opt(key) {

    if ($('#' + input_prefix + key) && (opts[key].value != $('#' + input_prefix + key).val())) {
        opts[key].value = $('#' + input_prefix + key).val();    
     } else if (opts[key].value)  {
        return opts[key].value
     } else if (opts[key])  {
        return opts[key]
     } else {
        return ""
     }
}

function setOpt(input_object) {

    var id = $(input_object).attr("id");
    var val = $(input_object).val();
    key = id.substring(id.indexOf(input_prefix) + input_prefix.length)
    opts[key].value = val;
    return opts[key].value;
}


function fillOpts(trg_container) {

  for ( var key in opts ) {
    if ($('#' + input_prefix + key).length) {
        $('#' + input_prefix + key).value = opts[key].value;   
     } else if (trg_container)  {
        var new_input_label = "<label>" + key + "</label>";
        var new_input;
        
       if (opts[key].widget == "slider") {
            [new_input,new_widget] = genSlider(key, opts[key].values);
         } else if (opts[key].widget =="selectone") {
            [new_input,new_widget] = genCombo(key, opts[key].values);
            // set initial value
            $(new_input).val(opts[key].value);
            
        //     $(new_input).autocomplete({"source":opts[key].values});
         }
         
    /* hook changing  options + redrawing the graph, when values in navigation changed */
         new_input.change(function () {
               setOpt(this);
               var related_widget = $(this).data("related-widget");
           if ( $(related_widget).hasClass("widget-slider")) {$(related_widget).slider("option", "value", $(this).val()); }
               renderGraph(); 
            });
               
        $(trg_container).append(new_input_label, new_input, new_widget);
        
     }
   }
   
    
}

/** generating my own comboboxes, because very annoying trying to use some of existing jquery plugins (easyui.combo, combobox, jquery-ui.autocomplete) */ 
function genCombo (key, data) {
    
    var select = $("<select id='widget-" + key + "' />")
        select.attr("id", input_prefix + key)
    data.forEach(function(v) { $(select).append("<option value='" + v +"' >" + v + "</option>") });
    return [select, null];
}

function genSlider (key, data) {

    var new_input = $("<input />");
            new_input.attr("id", input_prefix + key)
                 .val(opts[key].value)
/*                 .attr("type", "text")*/
                 .attr("size", 3);
      
    var new_widget = $("<div class='widget-" + opts[key].widget + "'></div>");
        new_widget.attr("id", "widget-" + key);
        new_widget.slider( opts[key]);
            
        // set both-ways references between the input-field and its slider - necessary for updating 
        new_widget.data("related-input-field",new_input);
        new_input.data("related-widget",new_widget);
     
//           console.log("widget:" + opts[key].widget);
        
        new_widget.bind( "slidechange", function(event, ui) {
            //   console.log(ui.value);
               $(this).data("related-input-field").val(ui.value);
               // update the opts-object, but based on the (updated) value of the related input-field
                setOpt($(this).data("related-input-field"));
               renderGraph();
         });
         
   return [new_input,new_widget]; 
} 


function notify (msg) {
  $("#notify").append(msg);
}
