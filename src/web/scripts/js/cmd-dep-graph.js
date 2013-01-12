

var item_li = null;

var svg  = null; // main svg-element
var data_all = null; // global holder for all (input) data
var nodes_sel = null; // global holder for selected data (selected nodes)
var data_show = null; // global holder for data to show  closure over data_sel 
var nest = {}; 
var detail_data = null; // global holder for detail-data (in html)  
 

var index_container_selector = "#index-container";
var graph_container_selector = '#infovis';
var navi_container_selector = '#navigate';
var detail_container_selector = "#detail-container";
var detail_info_holder_selector =  '#detail-info-holder';

var graph_container = null;
var index_container = null; 

var input_prefix = "input-";
var select_rect_min_size = 5;
var min_circle = 4;
var comp_reg_url = "http://catalog.clarin.eu/ds/ComponentRegistry/?item=";     
/*var source_file = "../scripts/cmd-dep-graph-d3_all_svg.json"*/
var source_file = "file:/C:/Users/m/3/clarin/_repo/SMC/output/cmd-dep-graph.d3.js"
var detail_file = "file:/C:/Users/m/3/clarin/_repo/SMC/output/smc_stats_detail.html"

var opts = {"depth-before": {"value":2, "min":0, "max":10, "widget":"slider"}, 
            "depth-after":{"value":2, "min":0, "max":10, "widget":"slider"}, 
            "link-distance": {"value":30, "min":10, "max":200, "widget":"slider" }, 
            "charge":{"value":400, "min":10, "max":1000, "widget":"slider" },
            "node-weight": {"value":"1", "values":["1","usage"], "widget":"selectone" },
            "curve": {"value":"straight", "values":["straight","arc"], "widget":"selectone" },
            "layout": {"value":"horizontal-tree", "values":["vertical-tree", "horizontal-tree", "weak-tree","force","dot"], "widget":"selectone" },
            
            };

/** for faster/simpler neighborhood lookup
from: http://stackoverflow.com/questions/8739072/highlight-selected-node-its-links-and-its-children-in-a-d3-js-force-directed-g
*/
var linkedByIndex = {};
var neighbours_in = {};
var links_in = {};
var neighbours_out = {};
var links_out = {};

/** loads from separate file detail info about individual nodes (in html) 
later used in renderDetail() 
invoked during the (jquery-)initalization */

function loadDetailInfo () {
     
  $(detail_info_holder_selector).load(detail_file,function(data) {
     $(detail_container_selector).html(getDetailInfo("summary", "overall"));
  });
  
  
  /* $.get(detail_file, function(data) {
    detail_data = data;  
    notify('Detail data loaded');
  
}); */
}

function getDetailInfo(type, id) {
    notify("getDetailInfo: #" + type + "-" + id );
    var d = $(detail_info_holder_selector).find("#" + type + "-" + id );
    // notify(d);
    return d.html();
}


/**  gets the data for the graph and calls rendering of the lists 
 * @name initGraph
 * @function
 */
 function initGraph ()
    {
    graph_container = $(graph_container_selector);
    
    fillOpts(navi_container_selector);
    
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

    
    $("#navigate .slider").slider();
    
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

                    renderIndex_default();
                    //renderGraph(data_all, graph_container);
                });        
}

/* there was a strange problem with overloading */
function renderIndex_default () {
    renderIndex (data_all.nodes, index_container_selector) 
}

/** generate the index lists
    @param nodes - accepts an array of nodes (like in data.nodes)
*/  
function renderIndex (nodes, target_container_selector) {

    nest = d3.nest()
    .key(function(d) { return d.type; })
    .sortValues(function(a, b) { return d3.ascending(a.name, b.name); })
    .entries(nodes);
  
    target_container = d3.select(target_container_selector);
        target_container.selectAll("div").remove();
        
        // rendering extra-information about the displayed data only in detail-index
        if (target_container_selector != index_container_selector) {
           target_container.append("span")
                .text("show nodes: " + data_show.nodes.length + "; "
                        + "show links: " + data_show.links.length);
           }
           
        var group_divs = target_container.selectAll("div").data(nest)
                        .enter().append("div")
                        .attr("id", function (d) { return "detail-" + d.key })
                        .classed("cmds-ui-block init-show", 1);
                        
      var group_headers = group_divs.append("div").classed("header", 1)
                        .text(function (d) { return d.key + " |" + d.values.length + "|"});
                        
      var list =  group_divs.append("div").classed("content",1)
                    .append("ul");
      var item_li = list.selectAll(".node-item")        
                    .data(function(d) { return d.values; })
                    .enter().append("li")
                    .attr("class", "node-item")
                    .text(function (d) { return d.name})
                    .on("click", function(d) { d.selected= d.selected ? 0 : 1 ; updateSelected() });
          
                    
            /* slightly different behaviour for the main-index and rendering of the selected nodes in the detail-view */
          //  console.log("target_container:" + target_container_selector);
            if (target_container_selector == index_container_selector) {
                index_container = target_container;
                item_li.attr("id", function (d) { return "n-" + d.name });
                item_li.classed("highlight", function (d) { return d.selected });
                
              } else {
                 var item_detail = item_li.append("div")
                            .classed("node-detail", 1);
                            
                        item_detail.text(function (d) { return "links_in: " +  dataShowCount(d.key, "links_in") +  "; links_out: " +  dataShowCount(d.key, "links_out") ;
                                                       })
                                .append("a")
                      .attr("href",function (d) { if (d.type.toLowerCase()=='datcat') return d.id 
                                                        else return comp_reg_url + d.id })
                      .text(function (d) { return d.id });
            item_detail.append("div").html(
                          function (d) { var detail_info_div = getDetailInfo(d.type.toLowerCase(), d.key);
                                            if (detail_info_div) {return detail_info_div } else
                                                { return  "<div>No detail</div>"; }
                          });
                            
         
                        
              }
                        //.classed("detail", 1);
                        //console.log($(target_container_selector).find(".cmds-ui-block"));
   handleUIBlock($(target_container_selector).find(".cmds-ui-block"));
  
}

function filterIndex (search_string){
    var filtered_index_nodes = data_all.nodes.filter(function(d, i) { 
     //   console.log(d.name.indexOf(search_string));
        return d.name.toLowerCase().indexOf(search_string) > -1; 
    });
    console.log(filtered_index_nodes);
    renderIndex(filtered_index_nodes, index_container_selector);
}


function renderGraph () {
    renderGraph(data_show, graph_container);
}

/** render the data as graph  into target-container */
function renderGraph (data, target_container=graph_container) {

    data = dataToShow(nodes_sel);

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
        //   .gravity(0)
            .linkDistance(opt("link-distance"))
            .charge(opt("charge") * -1)
            .on("tick", tick) 
            .start();
    console.log ("gravity: " + force.gravity() );              
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
            .attr("d", "M0,-3L10,0L0,3");
        
        var path = svg.append("svg:g").selectAll("path")
            .data(force.links())
            .enter().append("svg:path")
            .attr("class", function(d) { return "link uses"; })
            .attr("marker-end", function(d) { return "url(#uses)"; });
/*            .style("stroke-width", function(d) { return Math.sqrt(d.value); });*/

            
            
        var circle = svg.append("svg:g")
             .selectAll("circle")
            .data(force.nodes())
            .enter().append("svg:circle")
/*            .attr("r", 6)*/
            .attr("r", function(d) { if (opt("node-weight")=="1"){ return min_circle }
                                        else {return (Math.sqrt(d.count)>min_circle ? Math.sqrt(d.count) * 2 : min_circle); } })
          /*  .attr("x", function(d) {return d.x;})
            .attr("y", function(d) {return d.y;})*/
            .call(force.drag); 
       
         circle.append("title")
            .text(function(d) { return d.name; });
        
       svg.selectAll("circle")
            .attr("class", function(d) { return "type-" + d.type.toLowerCase()})
            .classed("selected", function(d) { return d.selected; })
          .on("click", function(d) {d.selected= d.selected ? 0 : 1; updateSelected() });
          .on("mouseover", function(d) {console.log(this)});
        
          
        var textgroup = svg.append("svg:g").selectAll("g")
            .data(data.nodes)
          .enter().append("svg:g")
          .attr("class", function(d) { return "type-" + d.type.toLowerCase()})
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



  /*
  force.start();
        force.tick();
        force.stop();
        
        force.on("tick",tick);
       force.start();    
           var n = 100;
           console.log("start ticking");
for (var i = 0; i < n; ++i) force.tick();
force.stop();
*/
        /*    
          data.links.forEach(function(d, i) {
            d.source.x -= d.source.init_x;
            d.target.x += d.target.init_x;
          });
*/

   function statick(e) {
      
      data.nodes.forEach(function(d,i) {
        d.x = d.init_x;
        d.y = d.init_y;
      });
      
      transform();
   }

   function tick(e) {
    var link_distance = parseInt(opt("link-distance"));      
   var k =  10 * e.alpha;
          if (opt("layout")=='dot') {
            var link_distance_int = parseInt(opt("link-distance"));
            data.links.forEach(function(d, i) {
              d.source.x = (d.source.init_x / 150 * link_distance_int) ;
              d.target.x = (d.target.init_x / 150 * link_distance_int);
              //d.target.y  += (d.target.init_y / 300 ) * k;
  /*            d.source.x = (d.source.level * link_distance_int) + link_distance_int;
              d.target.x = (d.target.level * link_distance_int) + link_distance_int;*/
              /*d.source.x = d.source.level * 2 * opt("link-distance") + 50;
              d.target.x = d.target.level * 2 * opt("link-distance") + 50;*/
            });
          } else if (opt("layout")=='weak-tree') {
              data.links.forEach(function(d, i) {
              d.source.x -= k;
                d.target.x += k;
                
                //d.source.x -= k * d.source.level / (dataShowCount(d.source.key, "links_out") + 0.1);  // 0.1 to prevent div/0
                //d.target.x += k * d.target.level / (dataShowCount(d.target.key, "links_in") + 0.1);
                });
          } else if (opt("layout")=='vertical-tree') {
                   var ky= 1.4 * e.alpha, kx = .4 * e.alpha;
                   data.links.forEach(function(d, i) {
                     if (d.source.level==0) { d.source.y = 20 };
                     d.target.x += (d.source.x - d.target.x)  * kx;
                     d.target.y += (d.source.y - d.target.y + link_distance) * ky;
                    });
           } else if (opt("layout")=='horizontal-tree') {
                   var kx= 1.4 * e.alpha, ky = .4 * e.alpha;
                   data.links.forEach(function(d, i) {
                       if (d.source.level==0) { d.source.x = 20 };
                       d.target.y += (d.source.y - d.target.y)  * ky;
                       d.target.x += (d.source.x - d.target.x + link_distance  ) * kx;
                  });
            }
      
           /*  parent foci 
                  var kx = 1.2 * e.alpha;
    data.links.forEach(function(d, i) {
      d.target.x += (d.target.level * link_distance  - d.target.x) * kx;
      });*/
      
      /*  obsoleted:
      /*data.links.forEach(function(d, i) {
                d.source.x -= (k * d.source.init_x  / (200 * Math.sqrt(d.source.count)) );
                d.target.x += (k * d.target.init_x / (50 * Math.sqrt(d.target.count)) );
                });*/
          
         /*d.source.y = d.source.init_y - d.source.y * k;
           d.target.y = d.target.init_y + d.target.y * k;*/
              /*d.source.x -= k * d.target.sum_level ;
             d.target.x += k *  d.source.sum_level ;*/
             /* d.source.y = d.source.init_y ;
             d.target.y = d.target.init_y;*/
              //d.source.x -= d.source.level * 0.2 ;
              //d.target.x += d.target.level * 0.2;
         
       transform();
   } // end  tick()


    function transform () { 
         
       path.attr("d", function(d) {
             // links as elliptical arc path segments
            if (opt("curve")=="arc") 
            {   var dx = d.target.x - d.source.x,
                    dy = d.target.y - d.source.y,
                    dr = Math.sqrt(dx * dx + dy * dy);
                return "M" + d.source.x + "," + d.source.y + "A" + dr + "," + dr + " 0 0,1 " + d.target.x + "," + d.target.y;
            } else { 
            // or straight
                return "M" + d.source.x + "," + d.source.y + "L" + d.target.x + "," + d.target.y;
            }  
       });
         
         circle.attr("cx", function(d) {return d.x;})
                .attr("cy", function(d) {return d.y;});
      /* circle.attr("transform", function(d) {
            return "translate(" + d.x + "," + d.y + ")";
       });*/
        
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
                // console.log("DEBUG: mousedown: " + (x1-x0) + ( y1-y0));       
                    selectNodes(data.nodes, x0, y0, x1, y1);                    
                    rect.attr("x", x0).attr("y", y0).attr("width", x1 - x0).attr("height", y1 - y0);
                    
          });
        
          d3.select(window).on("mouseup", function() {
            // only change selection, if the rectangle was big enough 
            // (mainly to prevent clearing of the graph on clicks that look like mousemoves to the system)
            if (rect.attr("width") > select_rect_min_size && rect.attr("height") > select_rect_min_size) {
                updateSelected();
            }
            rect.remove();
            d3.select(window).on("mousemove", null).on("mouseup", null);
          });
        
          d3.event.preventDefault();
        });
}  // end renderGraph


/** generate the detail lists
    @param nodes
*/  
function renderDetail (nodes) {
    
    renderIndex (nodes, detail_container_selector); 
}

function renderDetail_old (nodes) {
    /*
    nest = d3.nest()
    .key(function(d) { return d.group; })
    .sortValues(function(a, b) { return d3.ascending(a.name, b.name); })
    .entries(nodes);
  */
    detail_container = d3.select("#detail-container");
      detail_container.selectAll("div").remove();
      /*
      var group_divs = detail_container.selectAll("div").data(nest)
                        .enter().append("div")
                        .attr("id", function (d) { return "detail-" + d.key })
                        .classed("cmds-ui-block init-show", 1);
                        
      var group_headers = group_divs.append("div").classed("header", 1)
                        .text(function (d) { return d.key});
        */                
      var item_li = detail_container.append("div")
                    .append("ul").selectAll(".node-item")        
                    .data(nodes)
                    .enter().append("li")
                    .attr("class", "node-item")
                    .attr("id", function (d) { return "n-" + d.name });
               item_li.append("span")
                      .text(function (d) { return d.type + ": " + d.name})
                      .on("click", function(d) { d.selected= d.selected ? 0 : 1 ; updateSelected() });
         var item_detail = item_li.append("div")
                            .classed("node-detail", 1);
         
             item_detail.append("a")
                      .attr("href",function (d) { if (d.type.toLowerCase()=='datcat') return d.id 
                                                        else return comp_reg_url + d.id })
                      .text(function (d) { return d.id });
            item_detail.append("div").html(
                          function (d) { var detail_info_div = getDetailInfo(d.type.toLowerCase(), d.key);
                                            if (detail_info_div) {return detail_info_div } else
                                                { return  "<div>No detail</div>"; }
                          });
                            
                         
  // handleUIBlock($(".cmds-ui-block"));    
}

        
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
    
    renderGraph();
    renderDetail(nodes_sel);
    
 //   index_container.selectAll("li").classed("highlight", function (d) { return d.selected });    
}



/**  generates the subset of data to display (based on selected nodes + options) 
fills global variable: data_show ! 
*/
function dataToShow (nodes) {
     data_show = {};
     data_show.nodes = nodes;
        var data_show_collect = {nodes:[],links:[]};
        
        nodes.forEach(function(n) {
                        var data_add_in = neighboursWithLinks(n,'in', opt("depth-before"));
                        var data_add_out = neighboursWithLinks(n,'out', opt("depth-after"));
                        data_show_collect.nodes = data_show_collect.nodes.concat(data_add_in.nodes).concat(data_add_out.nodes);
                        data_show_collect.links = data_show_collect.links.concat(data_add_in.links).concat(data_add_out.links);
                    });
            
/*         deduplicate nodes and edges */
     data_show.nodes = unique_nodes(nodes.concat(data_show_collect.nodes));
     data_show.links = unique_links(data_show_collect.links);
     
     // extend the object, with some lookup hashes on neighbourhood 
     hashes = gen_neighbours(data_show.links);
     data_show = $.extend(data_show, hashes); 
/* data_show.nodes.forEach; data_all.links;
.filter(function(e) {*/
/*                console.log ("DEBUG: links.filter::" + (nodes_sel.indexOf(e.target) > -1 ) )*/
/*               return (data_show.nodes.indexOf(data_all.nodes[e.target]) > -1 || data_show.nodes.indexOf(data_all.nodes[e.source]) > -1)    */
/*            return (data_show.nodes.indexOf(data_all.nodes[e.s]) > -1 || data_show.nodes.indexOf(e.target) > -1)
         });*/
      
     return data_show;
    }

/** generate lookup hashes for neighbours;
*/
function gen_neighbours(links) {

    var neighbours = {"links_index": {}, 
                      "nodes_in": {}, "nodes_out": {},
                      "links_in": {}, "links_out": {}};
    
        links.forEach(function(d) { 
                            src_key = d.source.key;
                            trg_key = d.target.key;
                         // generate lookup hashes for neighbours;
                            neighbours.links_index[src_key + "," + trg_key] = d;
                            if (d.source) { 
                                    if (! neighbours.nodes_in[trg_key]) { 
                                        neighbours.nodes_in[trg_key] = [d.source];
                                        neighbours.links_in[trg_key] = [d];
                                     }  else {
                                        neighbours.nodes_in[trg_key].push(d.source);
                                        neighbours.links_in[trg_key].push(d);
                                     }
                             }
                            if (d.target) { 
                                    if (! neighbours.nodes_out[src_key]) { 
                                        neighbours.nodes_out[src_key] = [d.target];
                                        neighbours.links_out[src_key] = [d];
                                    } else { 
                                        neighbours.nodes_out[src_key].push(d.target);
                                        neighbours.links_out[src_key].push(d) ;
                                    }
                             }
                       });
                       
return neighbours;

}

function dataShowCount(n_key, info_type) { 

    if (data_show[info_type][n_key]) {
        return data_show[info_type][n_key].length;
       } else {
        return 0
       }
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
function neighbours (n, dir, depth=1) {
        var n_in = neighbours_in[n.key] ? neighbours_in[n.key] : [] ;
        var n_out = neighbours_out[n.key] ? neighbours_out[n.key] : [] ;
        var result_n;
        if (dir == 'in' ) { result_n = n_in; }
                   else if (dir == 'out' ) { result_n = n_out; }
                   else { result_n = n_out.concat(n_in); }
        var n_nextlevel = [];
        if (depth > 1) { 
         result_n.forEach (function(n) 
                     { var n_neighbours = neighbours(n, dir, depth - 1);
                     n_nextlevel = n_nextlevel.concat(n_neighbours); }
                            )
         }
        return result_n.concat(n_nextlevel);
        
}

function neighboursWithLinks (n, dir, depth=1) {
        var n_in = neighbours_in[n.key] ? neighbours_in[n.key] : [] ;
        var n_out = neighbours_out[n.key] ? neighbours_out[n.key] : [] ;
        var l_in = links_in[n.key] ? links_in[n.key] : [] ;
        var l_out = links_out[n.key] ? links_out[n.key] : [] ;
        
        var result_n = {nodes:[], links:[]};
        if (dir == 'in' ) { result_n.nodes = n_in; result_n.links = l_in; }
                   else if (dir == 'out' ) { result_n.nodes = n_out; result_n.links = l_out; }
                   else { result_n.nodes = n_out.concat(n_in); result_n.links = l_out.concat(l_in);  }
        var n_nextlevel = {nodes:[], links:[]};
        if (depth > 1) { 
         result_n.nodes.forEach (function(n) 
                     { var n_neighbours = neighboursWithLinks(n, dir, depth - 1);
                     n_nextlevel.nodes = n_nextlevel.nodes.concat(n_neighbours.nodes); 
                     n_nextlevel.links = n_nextlevel.links.concat(n_neighbours.links);
                     })
         }
         result_n.nodes = result_n.nodes.concat(n_nextlevel.nodes);
         result_n.links = result_n.links.concat(n_nextlevel.links);
        
        return result_n;
        
}

function neighbour_links (nodes, dir) {
    var l_result = []
    
        nodes.forEach (function(n) { 
               var l_in = links_in[n.key] ? links_in[n.key] : [] ;
               var l_out = links_out[n.key] ? links_out[n.key] : [] ;
               if (dir == 'in' ) { l_result = l_result.concat(l_in); }
               else if (dir == 'out' ) { l_result = l_result.concat(l_out); }
               else { l_result = l_result.concat(l_out.concat(l_in)); } 
            } );       
 
    return l_result;
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
   
   
  /*   
     d3.select(trg_container).selectAll("input").data(opts[)
            .enter().append("input")
            .attr("id", "k")
            .attr("type", "text")
            .attr("value", "val")
//            .attr("value", function (d) { return d } )
         ;
        
*/     
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
