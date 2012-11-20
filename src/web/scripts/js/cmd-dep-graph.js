


var svg  = null; // main svg-element
var data_all = null; // global holder for all (input) data
var nodes_sel = null; // global holder for selected data (selected nodes)
var data_show = null; // global holder for data to show  closure over data_sel 
var nest = {}; 
 
var graph_container_selector = '#infovis';
var graph_container = null;
var index_container = null; 
var comp_reg_url = "http://catalog.clarin.eu/ds/ComponentRegistry/";     
var source_file = "scripts/cmd-dep-graph-d3.json"

/** for faster/simpler neighborhood lookup
from: http://stackoverflow.com/questions/8739072/highlight-selected-node-its-links-and-its-children-in-a-d3-js-force-directed-g
*/
var linkedByIndex = {};
var neighbours_in = {};
var links_in = {};
var neighbours_out = {};
var links_out = {};

/**  the jquery initialization construct, ensures waiting until all html is loaded, so that it can be safely referenced 
 * @name init
 * @function
 */
 $(function()
    {
    graph_container = $(graph_container_selector);
    
    $('#infovis-wrapper').resizable( {
                   start: function(event, ui) {
                            graph_container.hide();
                        },
                   stop: function(event, ui) {
                            graph_container.show();
                            renderGraph(data_show, graph_container);
                       }
                }
                );

     // load data
     d3.json(source_file , 
                function(json) {        
                    // return if data missing
                    if (json==null) { notify("source data missing: " + source_file ); return null}            
                    data_all = json;
                    data_all.links.forEach(function(d) { 
                                        //resolve numeric index to node references
                                                src_ix = d.source;
                                                d.source = data_all.nodes[src_ix];
                                                d.source.index = src_ix;
                                                trg_ix = d.target;
                                                d.target = data_all.nodes[trg_ix];
                                                d.target.index = trg_ix;
                                                src_key = d.source.key;
                                                trg_key = d.target.key;
                                             // generate lookup hashes for neighbours;
                                                linkedByIndex[src_key + "," + trg_key] = d;
                                                if (d.source) { 
                                                        if (! neighbours_in[trg_key]) { 
                                                            neighbours_in[trg_key] = [d.source];
                                                            links_in[trg_key] = [d];
                                                         }  else {
                                                            neighbours_in[trg_key].push(d.source);
                                                            links_in[trg_key].push(d);
                                                         }
                                                 }
                                                if (d.target) { 
                                                        if (! neighbours_out[src_key]) { 
                                                            neighbours_out[src_key] = [d.target];
                                                            links_out[src_key] = [d];
                                                        } else { 
                                                            neighbours_out[src_key].push(d.target);
                                                            links_out[src_key].push(d) ;
                                                        }
                                                 }
                                           });

                    renderLists(data_all);
                    //renderGraph(data_all, graph_container);
                });        
});


/** generate the index lists  */  
function renderLists (data) {
    nest = d3.nest()
    .key(function(d) { return d.group; })    
    .entries(data.nodes);

    index_container = d3.select("#index-container");
//      detail_wrapper.selectAll("div").remove();
      var group_divs = index_container.selectAll("div").data(nest)
                        .enter().append("div")
                        .attr("id", function (d) { return "detail-" + d.key })
                        .text(function (d) { return d.key});
                        
      var item_li = group_divs.append("ul").selectAll(".node-item")        
                    .data(function(d) { return d.values; })
                    .enter().append("li")
                    .attr("class", "node-item")
                        .attr("id", function (d) { return "n-" + d.name })
                        .text(function (d) { return d.name})
                        .classed("highlight", function (d) { return d.selected })
                        .on("click", function(d) { d.selected= d.selected ? 0 : 1 ; updateSelected() });
                        //.classed("detail", 1);         
}

/** render the data as graph  into target-container */
function renderGraph (data, target_container) {

    if (data == null) { 
       $(target_container).text("no data to show"); 
       return;
     } else {
       $(target_container).text("");
     }
    var w = $(target_container).width(),
        h = $(target_container).height();
        // console.log (w + '-' + h);
     var force = d3.layout.force()
            .nodes(data.nodes)
            .links(data.links)
            .size([w, h])
            .linkDistance(60)
            .charge(-300)
            .on("tick", tick)
           .start();
                  
         // remove old render:
          d3.select(graph_container_selector).selectAll("svg").remove();
      // console.log(force.size())               
        svg = d3.select(graph_container_selector).append("svg:svg")
            .attr("width", w)        .attr("height", h);
        
        // Per-type markers, as they don't inherit styles.
        svg.append("svg:defs").selectAll("marker")
          .data(["uses"])
          .enter().append("svg:marker")
            .attr("id", String)
            .attr("viewBox", "0 -5 10 10")
            .attr("refX", 15)
            .attr("refY", -1.5)
            .attr("markerWidth", 6)
            .attr("markerHeight", 6)
            .attr("orient", "auto")
          .append("svg:path")
            .attr("d", "M0,-5L10,0L0,5");
        
        var path = svg.append("svg:g").selectAll("path")
            .data(force.links())
            
          .enter().append("svg:path")
            .attr("class", function(d) { return "link uses"; })
            .attr("marker-end", function(d) { return "url(#uses)"; });
        
        var circle = svg.append("svg:g").selectAll("circle")
            .data(force.nodes())

          .enter().append("svg:circle")
            .attr("class", function(d) { return (d.group==1) ? 'profile' : 'component' ; })
            .attr("r", 6)
            .call(force.drag); 
        
        var textgroup = svg.append("svg:g").selectAll("g")
            .data(data.nodes)
          .enter().append("svg:g")     
          .on("click", function(d) {d.selected= d.selected ? 0 : 1; updateSelected() });
        
         textgroup.attr("data-key", function (d) { return d.name } );
         
        // A copy of the text with a thick white stroke for legibility.
        textgroup.append("svg:text")
            .attr("x", 8)
            .attr("y", ".31em")
            .attr("class", "shadow")
            .text(function(d) { return d.name; });
        
        textgroup.append("svg:text")
            .attr("x", 8)
            .attr("y", ".31em")
            .text(function(d) { return d.name; });
           
        // Use elliptical arc path segments to doubly-encode directionality.
        
        function tick(e) {
          var k = 6 * e.alpha;
          path.attr("d", function(d) {
              d.source.x -= k ;
              d.target.x += k ;
            var dx = d.target.x - d.source.x,
                dy = d.target.y - d.source.y,
                dr = Math.sqrt(dx * dx + dy * dy);
    //            console.log ("M" + d.source.x + "," + d.source.y + "A" + dr + "," + dr + " 0 0,1 " + d.target.x + "," + d.target.y);
            return "M" + d.source.x + "," + d.source.y + "A" + dr + "," + dr + " 0 0,1 " + d.target.x + "," + d.target.y;
          });
        
          circle.attr("transform", function(d) {
            return "translate(" + d.x + "," + d.y + ")";
          });
        
          textgroup.attr("transform", function(d) {
            return "translate(" + d.x + "," + d.y + ")";
          });
        }

        
        // Highlight selected nodes using the quadtree.
        svg.on("mousedown", function() {
          var m0 = d3.mouse(this);
        
          var rect = d3.select(this).append("rect")
              .style("fill", "#999")
              .style("fill-opacity", .5);
        
          d3.select(window).on("mousemove", function() {
            var m1 = d3.mouse(rect.node()),
                x0 = Math.min(w, m0[0], m1[0]),
                y0 = Math.min(w, m0[1], m1[1]),
                x1 = Math.max(0, m0[0], m1[0]),
                y1 = Math.max(0, m0[1], m1[1]);
        
                    selectNodes(data.nodes, x0, y0, x1, y1);                    
                    rect.attr("x", x0).attr("y", y0).attr("width", x1 - x0).attr("height", y1 - y0);
                    updateSelected();
          });
        
          d3.select(window).on("mouseup", function() {
            rect.remove();
            d3.select(window).on("mousemove", null).on("mouseup", null);
          });
        
          d3.event.preventDefault();
        });
}  // end renderGraph

        
/**  select the nodes within the specified rectangle. */
function selectNodes(nodes, x0, y0, x3, y3) {
    
  var points = [];
  nodes.forEach(function(n) {    
    if (n && (n.x >= x0) && (n.x < x3) && (n.y >= y0) && (n.y < y3)) {
            points.push(n);
            n.selected = 1;
        } else {
            n.selected = 0;
        }
/*    return x1 >= x3 || y1 >= y3 || x2 < x0 || y2 < y0;*/
  });
  return points;
}


function updateSelected () {
    nodes_sel = data_all.nodes.filter(function (d) { return d.selected });
    renderGraph(dataToShow(nodes_sel), graph_container);
    if (svg!=null) svg.selectAll("circle").style("fill", function(d) { return d.selected ? "red" : null; });
    index_container.selectAll("li").classed("highlight", function (d) { return d.selected });    
}



/**  generates the subset of data to display (based on selected nodes + options) */
function dataToShow (nodes) {
     data_show = {};
     data_show.nodes = nodes;
        var nodes_add = [], links_add = [];
        nodes.forEach(function(n) {
                        nodes_add = nodes_add.concat(neighbours(n,'all'));
                        links_add = links_add.concat(neighbour_links(n,'all'));
/*                        nodes_add = nodes_add.concat(neighbours_out[n.index]);*/
                    });
           /*         
            links_add = data_all.links.forEach(function(e,n){ console.log(e.source) });
            nodes_add = data_all.nodes.filterlinks
            if (n.source==group) {
                 data_show.nodes.push(n)*/
            
       data_show.nodes = unique_nodes(nodes.concat(nodes_add));
       
/*         filter edges */
             data_show.links = unique_links(links_add);
             
/* data_show.nodes.forEach; data_all.links;
.filter(function(e) {*/
/*                console.log ("DEBUG: links.filter::" + (nodes_sel.indexOf(e.target) > -1 ) )*/
/*               return (data_show.nodes.indexOf(data_all.nodes[e.target]) > -1 || data_show.nodes.indexOf(data_all.nodes[e.source]) > -1)    */
/*            return (data_show.nodes.indexOf(data_all.nodes[e.s]) > -1 || data_show.nodes.indexOf(e.target) > -1)
         });*/
      
     return data_show;
    }


/** returns appropriate link
*/
function neighboring(a, b) {
  return linkedByIndex[a.index + "," + b.index];
}

/** access function to retrieve the neigbours from the hashes
especially handles the (necessarily?) empty elements (undefined),
as not every position is filled 
(perhaps other key, than index would be less confusing)
*/
function neighbours (n, dir) {
        var n_in = neighbours_in[n.key] ? neighbours_in[n.key] : [] ;
        var n_out = neighbours_out[n.key] ? neighbours_out[n.key] : [] ;
        if (dir == 'in' ) { return n_in; }
        else if (dir == 'out' ) { return n_out; }
        else { return  n_out.concat(n_in); } 
 
}


function neighbour_links (n, dir) {
        var l_in = links_in[n.key] ? links_in[n.key] : [] ;
        var l_out = links_out[n.key] ? links_out[n.key] : [] ;
        if (dir == 'in' ) { return l_in; }
        else if (dir == 'out' ) { return l_out; }
        else { return  l_out.concat(l_in); } 
 
}

/** deduplicates based on index-property */
function unique_nodes(nodes) 
{
    var hash = {}, result = [];
    for ( var i = 0, l = nodes.length; i < l; ++i ) {
           n_key = nodes[i].key;
        if ( !hash[n_key] ) { //it works with objects! in FF, at least
            hash[ n_key ] = true;
            result.push(nodes[i]);
        }
    }
    return result;
}


/** deduplicates links (based on source-target-index
based on: http://stackoverflow.com/questions/1890203/unique-for-arrays-in-javascript
*/
function unique_links(links) 
{
    var hash = {}, result = [];
    for ( var i = 0, l = links.length; i < l; ++i ) {
            src_key = links[i].source.key;
            trg_key = links[i].target.key;
            key = src_key + "," + trg_key;
        if ( !hash[key] ) {
            hash[ key] = true;
            result.push(links[i]);
        }
    }
    return result;
}


function notify (msg) {
  d3.select("#notify").html(msg);
}
