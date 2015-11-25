

var item_li = null;

var svg = null; // main svg-element
var css;
var data_all = null; // global holder for all (input) data
var nodes_sel = []; // global holder for selected data (selected nodes)
var data_show = null; // global holder for data to show  closure over nodes_sel 
var nest = {};
var detail_data = null; // global holder for detail-data (in html)
var mode = "static";   // dynamic or static (default)  static=load detail data all at once on init; 


var input_prefix = "input-";
var select_rect_min_size = config.select_rect_min_size;
var first_level_margin = config.first_level_margin;
var base_font_size = config.base_font_size;
var min_circle = config.min_circle;
var max_circle = config.max_circle;

var show_count = config.show_count;


//var detail_url = "http://localhost:8580/exist/apps/smc-browser/get.xql"; obsoleted by config
var comp_reg_url = "http://catalog.clarin.eu/ds/ComponentRegistry/?item=";
var wiki_url = "http://en.wikipedia.org/wiki/";
var mdrepo_url_search = "http://localhost:8680/exist/apps/cr-xq/mdrepo/index.html?operation=searchRetrieve&x-context=&query=";
/*http://localhost:8680/exist/apps/cr-xq/mdrepo/fcs?operation=scan&scanClause=cmd:CountryName&x-context=&x-format=htmlpage*/
var mdrepo_url_scan = "http://localhost:8680/exist/apps/cr-xq/mdrepo/fcs?operation=scan&x-context=&x-format=htmlpage&sort=size&scanClause=";
/*var source_file = "../scripts/cmd-dep-graph-d3_all_svg.json"*/
/*var source_file = "file:/C:/Users/m/3/clarin/_repo/SMC/output/cmd-dep-graph.d3.js"
 var detail_file = "file:/C:/Users/m/3/clarin/_repo/SMC/output/smc_stats_detail.html"
 */
/*
 var source_file = "/smc/_structure-graph.json";
 var source_file = "cmd-dep-graph.d3.js";
 var detail_file = "smc_stats_detail.html";
 var userdocs_file = "userdocs.html";
 */
//now graph-param is used
//var source_file = "/smc/smc-graph.d3";
/*var source_file = "/smc/cmd-dep-graph.d3.js";*/
//var data_prefix = "data/";
//var detail_file = "/smc/data/smc_stats_detail.html"; obsoleted by config
//var userdocs_file = "/smc/docs/userdocs.html"; obsoleted by config



/** temporary helper function
 to easily get the param-data
 */
function opt(key) {
    var val = $("#navigate").data("qi").getParamValue(key);
    return typeof val == 'undefined' ? "" : val;
}

function currentOpts() {
    return $("#navigate").data("qi");
}

/**  gets the data for the graph and calls rendering of the lists 
 * @name initGraph
 * @function
 */
function initGraph(graph_source) {

    // load data
    d3.json(config.url.data_prefix + graph_source,
            function (json) {
                // return if data missing
                if (json == null) {
                    notifyUser("source data missing: " + graph_source);
                    return null
                }
                data_all = json;
                data_all.nodes_index = {};
                data_all.nodes.forEach(function (d) {
                    data_all.nodes_index[d.key] = d;
                });

                data_all.links.forEach(function (d) {
                    // try to interpret node references as nodes ids
                    // if it fail, try to interpret them as indexes
                    if(data_all.nodes_index.hasOwnProperty(d.source)){
                        d.source = data_all.nodes_index[d.source];
                    }else{
                        d.source = data_all.nodes[d.source];
                    }
                    
                    if(data_all.nodes_index.hasOwnProperty(d.target)){
                        d.target = data_all.nodes_index[d.target];
                    }else{
                        d.target = data_all.nodes[d.target];
                    }
                                        
                    if (d.target === null || d.source === null) {
                        notifyUser("nodes for link missing: " + src_ix + " - " + trg_ix);
                    }

                });
                // remove links for which nodes are missing!
                data_all.links = data_all.links.filter(function (d) {
                    return (d.source != null & d.target != null)
                })

                // generate lookup hashes for neighbours;                                             
                add_lookups(data_all);

                // get min/max on some properties
                var init_x_arr = [];
                data_all.nodes.forEach(function (d, i) {
                    init_x_arr.push(d.init_x);
                })
                data_all.init_x_min = d3.min(init_x_arr);
                data_all.init_x_max = d3.max(init_x_arr);

                var init_level = [];
                data_all.nodes.forEach(function (d, i) {
                    init_level.push(+d.level);
                })
                data_all.level_min = (d3.min(init_level) == d3.max(init_level)) ? (d3.min(init_level) - 1) : d3.min(init_level);

                var init_count = [];
                data_all.nodes.forEach(function (d, i) {
                    init_count.push(+d.count);
                })

                data_all.count_max = d3.max(init_count);
                data_all.node_size_ratio = Math.sqrt(data_all.count_max) / max_circle;

                var init_weight = [];
                data_all.links.forEach(function (d, i) {
                    init_weight.push(+d.weight);
                })

                data_all.weight_min = d3.min(init_weight);
                curr_params = $("#navigate").data("qi").params;
                /* if weight is not used (all weight==1 deactivate the weight widget */
                if (data_all.weight_min == 1) {

                    delete curr_params.weight;
                    /*                           $("#navigate").init(curr_opts );*/
                    $("#navigate").QueryInput({params: curr_params,
                        onValueChanged: renderGraph
                    });
                } else {
                    curr_params.weight = {"value": 70, "min": 1, "max": 100, "widget": "slider"};
                    $("#navigate").QueryInput({params: curr_params,
                        onValueChanged: renderGraph
                    });
                }


                notifyUser("count max: " + data_all.count_max + "; "
                        + "node_size_ratio: " + data_all.node_size_ratio);

                // should be delivered by the data directly
                data_all.nodes.forEach(function (d, i) {
                    d.x = d.init_x;
                    d.y = d.init_y;
                });

                // get selected nodes (if any) from param
                selected_ids = opt("selected").split(",");
                selectNodeByKey(selected_ids);
                /*var selected_match = 0;
                 for (var i = 0; i < selected_ids.length; i++)
                 {  if (data_all.nodes_index[selected_ids[i]]) {
                 data_all.nodes_index[selected_ids[i]].selected = 1;
                 selected_match ++;
                 }
                 }    
                 // if something was selected, update and render Graph and Detail
                 if (selected_match) { updateSelected();}
                 */
                renderIndex();


            });
}

/** put grouped list of nodes into the target container*/
function renderIndex(data, target_container_selector) {
    data = typeof data !== 'undefined' ? data : data_all.nodes;
    target_container_selector = typeof target_container_selector !== 'undefined' ? target_container_selector : index_container_selector;
    renderNodeList(data, target_container_selector);
}


/** generate the detail lists
 @param nodes
 */
function renderDetail(nodes) {
    renderNodeList(nodes, detail_container_selector);
}



/** generate a grouped (by type) list of nodes
 @param nodes - accepts an array of nodes (like in data.nodes)
 */
function renderNodeList(nodes, target_container_selector) {

    nest = d3.nest()
            .key(function (d) {
                return d.type;
            })
            .sortValues(function (a, b) {
                return d3.ascending(a.name, b.name);
            })
            .entries(nodes);

    target_container = d3.select(target_container_selector);
    target_container.selectAll("div.node-detail").remove();

    var group_divs = target_container.selectAll("div.node-detail").data(nest)
            .enter().append("div")
            .attr("id", function (d) {
                return "detail-" + d.key
            })
            .classed("node-detail cmds-ui-block init-show", 1)
    // collapse groups in index, but expand right away in detail view
    //.classed("init-show", (target_container_selector != index_container_selector)); 

    var group_headers = group_divs.append("div").classed("header", 1)
            .text(function (d) {
                return d.key + " |" + d.values.length + "|"
            });

    var list = group_divs.append("div").classed("content", 1)
            .append("ul");
    var item_li = list.selectAll(".node-item")
            .data(function (d) {
                return d.values;
            })
            .enter().append("li")
            .attr("class", "node-item");
    item_li.append("span")
            /*                     .text(function (d) { return d.name})*/
            .text(renderItemText)
            .on("click", function (d) {
                d.selected = d.selected ? 0 : 1;
                updateSelected()
            });


    /* slightly different behaviour for the main-index and rendering of the selected nodes in the detail-view */
    //  console.log("target_container:" + target_container_selector);
    if (target_container_selector == index_container_selector) {
        index_container = target_container;
        item_li.attr("id", function (d) {
            return "n-" + d.name
        })
                .attr("title", function (d) {
                    return  d.id
                });
        item_li.classed("highlight", function (d) {
            return d.selected
        });
        /*                item_li.classed("highlight", liveSelected);*/


    } else {
        var item_detail = item_li.append("div");
        /*  .classed("node-detail", 1);*/

        item_detail.append("a")
                .attr("href", function (d) {
                    if (d.type.toLowerCase() == 'datcat')
                        return d.id
                    else if (d.type.toLowerCase() == 'philosopher')
                        return wiki_url + d.id;
                    else
                        return comp_reg_url + d.id
                })
                .text(function (d) {
                    return d.id
                });

        profile_item_detail = item_detail.filter(function (d, i) {
            return d.type.toLowerCase() == 'profile'
        });
        profile_item_detail.append("a")
                .attr("target", '_blank')
                .attr("href", function (d) {
                    return 'profiles/' + d.key + '.html'
                })
                .text(' html-view ');

        /*                profile_item_detail.append("a")*/
        /*                item_detail.append("a")
         .classed("scan", function (d) {  return !(d.type=='Profile') } )
         .attr("target",'_blank')
         .attr("href",function (d) { if (d.type=='Profile') { return mdrepo_url_search +  'cmd.profile=%22' + d.id + '%22'; }
         else { return mdrepo_url_scan +  'cmd:' +  d.name; }   }  )
         .text(' mdrepo-view ');*/

        item_detail_detail = item_detail.append("div").html(
                function (d) {
                    var detail_info_div = getDetailInfo(d.type.toLowerCase(), d.key, this);
                    if (detail_info_div) {
                        return detail_info_div
                    } else {
                        return  "<div>No detail</div>";
                    }
                });

        item_detail_detail.classed("node-detail", 1);

    }

    handleUIBlock($(target_container_selector).find(".node-detail.cmds-ui-block"));

}

function renderItemText(d) {
    if (show_count) {
        return d.name + ' |' + d.count + '|';
    } else {
        return d.name;
    }
}

function filterIndex(search_string) {
    var filtered_index_nodes = data_all.nodes.filter(function (d, i) {
        //   console.log(d.name.indexOf(search_string));
        return d.name.toLowerCase().indexOf(search_string.toLowerCase()) > -1;
    });

    renderIndex(filtered_index_nodes, index_container_selector);
}


/** render data (data_show) as graph  into target-container (graph_container) */
function renderGraph(data, target_container) {
// setting defaults 
// for now, ignore the params, as they are always the same

    //data = typeof data !== 'undefined' ? data : dataToShow(nodes_sel);

    try {
        if ($(this).is('#input-graph')) {
            console.log("graph-source changed! reinitializing graph");
            initGraph(data);
        }
    } catch (e) {
    }

    data = dataToShow(nodes_sel);

    target_container = graph_container;

    if (data == null) {
        $(target_container).text("no data to show");
        return;
    } else {
        $(target_container).text("");
    }

    // compute the maximum number, but only if it will be needed (i.e. node-size=count)
    if (opt("node-size") == "count") {
        var init_count = [];
        data.nodes.forEach(function (d, i) {
            init_count.push(+d.count);
        })
        data.count_max = d3.max(init_count);
        data.node_size_ratio = Math.sqrt(data.count_max) / max_circle;
    }

    // information about the displayed data 
    notifyUser("show nodes: " + data_show.nodes.length + "; "
            + "show links: " + data_show.links.length + "; "
            + "max count:" + data.count_max + "; "
            + "node_size_ration:" + data.node_size_ratio);




    var w = $(target_container).width(),
            h = $(target_container).height();

    var ratio = w / (data_all.init_x_max - data_all.init_x_min);
    var node_size_int = parseInt(opt("node-size"));
    var font_size_int = base_font_size + (node_size_int / 2);
    var link_distance = parseInt(opt("link-distance"))

    // console.log (w + '-' + h);
    var force = d3.layout.force()
            .nodes(data.nodes)
            .links(data.links)
            .size([w, h])

            .friction(parseInt(opt("friction")) / 100)

            .gravity(parseInt(opt("gravity")) / 100)

            .linkDistance(parseInt(opt("link-distance")))

    /*            .linkDistance(function(d){return link_distance / (d.weight * d.value) })*/
    /* Profiles:           
     .linkStrength(function(d){return d.value})
     
     */
    //.charge(parseInt(opt("charge")) * -1)

    if (parseInt(opt("charge")) == 0) {
        force.charge(0);
    } else {
        force.charge(function (d) {
            if (opt("node-size") == "count")
            {
                var node_charge = (Math.sqrt(d.count) <= min_circle) ? min_circle : Math.sqrt(d.count) / data.node_size_ratio;
                //console.log (node_charge + ':' + d.count);
                return node_charge * -1 * parseInt(opt("charge"));
            }
            //{ return -d.count * parseInt(opt("charge"));  }
            else {
                return parseInt(opt("charge")) * -1
            }
        })
    }

    force.on("tick", tick)
            .start();

    if (opt("layout") == 'freeze') {
        data.nodes.forEach(function (d) {
            d.fixed = true
        });
    } else {
        data.nodes.forEach(function (d) {
            d.fixed = false
        });
    }


//    console.log ("gravity: " + force.gravity() );              

    // remove old render:
    d3.select(graph_container_selector).selectAll("svg").remove();

    svg = d3.select(graph_container_selector).append("svg:svg")
            .attr("width", w).attr("height", h);

    // Per-type markers, as they don't inherit styles.

    if (opt("curve").indexOf("arrow") > -1) {
        svg.append("svg:defs").selectAll("marker")
                .data(["uses"])
                .enter().append("svg:marker")
                .attr("id", String)
                .attr("markerUnits", "userSpaceOnUse")
                .attr("viewBox", "0 -5 10 10")
                .attr("refX", 10)
                /*.attr("refY", -1.5)*/
                .attr("markerWidth", 10)
                .attr("markerHeight", 10)
                .attr("orient", "auto")
                .append("svg:path")
                .attr("d", "M0,-3L10,0L0,3");
    }

    var path = svg.append("svg:g").selectAll("path")
            .data(force.links())
            .enter().append("svg:path")
            /*            .attr("class", function(d) { return "link uses"; })*/
            .classed("link", 1)
            .classed("uses", 1)
            .classed("highlight", function (d) {
                d.highlight
            })
            .attr("marker-end", function (d) {
                return "url(#uses)";
            });

    if (opt("link-width") == "value") {
        path.style("stroke-width", function (d) {
            return Math.sqrt(d.value);
        });
        /*             .style("stroke-width", function(d) { return d.value });*/
    }

    path.append("title").text(function (d) {
        return d.value
    });

    var gnodes = svg.append("svg:g")
            .selectAll("g.node")
            .data(force.nodes())
            .enter().append("g")
            .attr("class", function (d) {
                return "node type-" + d.type.toLowerCase()
            })
            .classed("selected", function (d) {
                return d.selected;
            })
            .call(force.drag);

    // dragging of all selected nodes on freeze layout
    // this does not work yet
    /*if (opt("layout")=="freeze") {
     gnodes.on("mousedown", function() {
     var m0 = d3.mouse(this);
     
     gnodes.on("mousemove", function() {
     var m1 = d3.mouse(this),
     x0 = Math.min(w, m0[0], m1[0]),
     y0 = Math.min(w, m0[1], m1[1]),
     x1 = Math.max(0, m0[0], m1[0]),
     y1 = Math.max(0, m0[1], m1[1]);
     // console.log("DEBUG: mousedown: " + (x1-x0) + ( y1-y0));
     x_d = (x1 - x0);
     y_d = (y1 - y0);
     // y_d = d.y - d.py;
     // x_d = d.x - d.px;
     
     nodes_sel.forEach(function (d) {
     d.x += x_d;
     d.y += y_d;
     });
     
     });
     
     gnodes.on("mouseup", function() {
     gnodes.on("mousemove", null).on("mouseup", null);
     });
     
     d3.event.preventDefault();
     });     
     }          
     */
    gnodes.append("svg:circle")
            /*            .attr("r", 6)*/
            .on("click", function (d) {
                d.selected = d.selected ? 0 : 1;
                console.log("click:" + d.key);
                updateSelected();
            })
            .on("mouseover", highlight()).on("mouseout", unhighlight())
            .attr("r", function (d) {
                if (opt("node-size") == "count")
                {
                    return (Math.sqrt(d.count) <= min_circle) ? min_circle : Math.sqrt(d.count) / data.node_size_ratio;
                } else {
                    return node_size_int;
                }
            })

    gnodes.append("title")
            /*                .text(function (d) { return d.name + ' |' + d.count + '|' })*/
            .text(renderItemText);




    /*
     svg.selectAll("circle")
     .attr("class", function(d) { return "type-" + d.type.toLowerCase()})
     .classed("selected", function(d) { return d.selected; })
     .on("click", function(d) {d.selected= d.selected ? 0 : 1; updateSelected() })
     .on("mouseover", highlight("in")).on("mouseout", highlight("out"));
     */

    // A copy of the text with a thick white stroke for legibility.
    //if (opt("labels") =='show') {
    gnodes.append("svg:text")
            .attr("x", 8)
            .attr("y", ".31em")
            .style("font-size", function (d) {
                var fontsize = '';
                if (opt("node-size") == "count")
                {
                    fontsize = (Math.sqrt(d.count) <= min_circle) ? base_font_size : Math.sqrt(d.count) / data.node_size_ratio;
                } else {
                    fontsize = font_size_int;
                }
                return fontsize + 'px';
            })
            .attr("class", "shadow")
            .classed("hide", opt("labels") == 'hide')
            .text(function (d) {
                return d.name;
            });
    gnodes.append("svg:text")
            .attr("x", 8)
            .attr("y", ".31em")
            .style("font-size", function (d) {
                var fontsize = '';
                if (opt("node-size") == "count")
                {
                    fontsize = (Math.sqrt(d.count) <= min_circle) ? base_font_size : Math.sqrt(d.count) / data.node_size_ratio;
                } else {
                    fontsize = font_size_int;
                }
                return fontsize + 'px';
            })
            .classed("hide", function (d) {
                return !d.selected && opt("labels") == 'hide'
            })
            .text(function (d) {
                return d.name;
            });
    //}


    var tick_counter = 0;
    function tick(e) {
        var link_distance_int = parseInt(opt("link-distance"));
        var k = 10 * e.alpha;
        if (opt("layout") == 'dot') {
            var offset = data_all.init_x_min;
            /*data.links.forEach(function(d, i) {
             d.source.x = (d.source.init_x / 150 * link_distance_int) ;
             d.target.x = (d.target.init_x / 150 * link_distance_int);
             
             });*/

            data.nodes.forEach(function (d, i) {
                d.x = d.init_x * ratio - link_distance_int;
            });

        } else if (opt("layout") == 'weak-tree') {
            data.links.forEach(function (d, i) {
                d.source.x -= k;
                d.target.x += k;
            });
        } else if (opt("layout") == 'vertical-tree') {
            var ky = 1.4 * e.alpha, kx = .4 * e.alpha;
            data.links.forEach(function (d, i) {
                if (d.source.level == data_all.level_min) {
                    d.source.y = first_level_margin
                }
                ;
                //  d.target.x += (d.source.x - d.target.x)  * kx;
                d.target.y += (d.source.y - d.target.y + link_distance_int) * ky;
            });
        } else if (opt("layout") == 'horizontal-tree') {
            var kx = 1.4 * e.alpha, ky = .4 * e.alpha;
            data.links.forEach(function (d, i) {
                //if (d.source.level==data_all.level_min) { d.source.x = first_level_margin };
                if (data_show.roots.indexOf(d.source.key) > -1) {
                    d.source.x = first_level_margin
                }
                ;
                //d.target.y += (d.source.y - d.target.y)  * ky;
                d.target.x += (d.source.x - d.target.x + link_distance_int) * kx;
                //d.target.x += (d.source.x - d.target.x ) * kx;
            });
        }
        /*  parent foci 
         var kx = 1.2 * e.alpha;
         data.links.forEach(function(d, i) {
         d.target.x += (d.target.level * link_distance  - d.target.x) * kx;
         });*/

        tick_counter++;
        if (tick_counter % 2 == 0) {
            transform();
        }
    } // end  tick()


    function transform() {

        path.attr("d", function (d) {
            // links as elliptical arc path segments
            if (opt("curve").indexOf("arc") > -1)
            {
                var dx = d.target.x - d.source.x,
                        dy = d.target.y - d.source.y,
                        dr = Math.sqrt(dx * dx + dy * dy);
                return "M" + d.source.x + "," + d.source.y + "A" + dr + "," + dr + " 0 0,1 " + d.target.x + "," + d.target.y;
            } else {
                // or straight
                return "M" + d.source.x + "," + d.source.y + "L" + d.target.x + "," + d.target.y;
            }
        });

        /*circle.attr("cx", function(d) {return d.x;})
         .attr("cy", function(d) {return d.y;});*/
        gnodes.attr("transform", function (d) {
            return "translate(" + d.x + "," + d.y + ")";
        });

        /*     textgroup.attr("transform", function(d) {
         return "translate(" + d.x + "," + d.y + ")";
         });*/
    }

    // Highlight selected nodes using the quadtree.
    svg.on("mousedown", function () {
        var m0 = d3.mouse(this);

        var rect = d3.select(this).append("rect")
                .style("fill", "#999")
                .style("fill-opacity", .5);

        d3.select(window).on("mousemove", function () {
            var m1 = d3.mouse(rect.node()),
                    x0 = Math.min(w, m0[0], m1[0]),
                    y0 = Math.min(w, m0[1], m1[1]),
                    x1 = Math.max(0, m0[0], m1[0]),
                    y1 = Math.max(0, m0[1], m1[1]);
            // console.log("DEBUG: mousedown: " + (x1-x0) + ( y1-y0));       
            selectNodes(data.nodes, x0, y0, x1, y1);
            rect.attr("x", x0).attr("y", y0).attr("width", x1 - x0).attr("height", y1 - y0);

        });

        d3.select(window).on("mouseup", function () {
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


/** loads detail info about individual nodes (in html) from separate file  
 later used in renderDetail() 
 invoked during the (jquery-)initalization */
function loadDetailInfo() {
    if (mode == 'static') {
        $(detail_info_holder_selector).load(config.url.detail, function (data) {
            $(detail_container_selector).find("h3").after(
                    '<div id="detail-summary-overall" class="cmds-ui-block init-show" ><div class="header">Overview</div><div class="content">' +
                    getDetailInfo("summary", "overall") +
                    '</div></div>'
                    );

            handleUIBlock($(detail_container_selector).find(".cmds-ui-block"));

            // only render detail for initially selected nodes, after the detail info has been loaded 
            if (nodes_sel) {
                renderDetail(nodes_sel)
            }
            ;

        });
    } else {
        var target_container = $(detail_container_selector).append(
                '<div id="detail-summary-overall" class="cmds-ui-block init-show" ><div class="header">Overview</div></div>'
                );
        $(detail_container_selector).find('#detail-summary-overall').append('<div class="content"></div>');
        target = $(detail_container_selector).find("#detail-summary-overall .content")
        getDetailInfo("summary", "overall", target, function () {
            handleUIBlock($(detail_container_selector).find(".cmds-ui-block"));
        });
    }

    // loading css to store in extra variable, for later use = injecting into exported SVG 
    $.get("scripts/style/smc-graph.css", function (data) {
        //  console.log(data)
        css = data
    });
}

function getDetailInfo(type, id, target, load_callback) {
    //notify("getDetailInfo: #" + type + "-" + id );

    if (type == 'philosopher') {
        url = "get.php?link=" + wiki_url + id;
        $(target).load(url + " .infobox");
    } else if (mode == 'static') {
        var d = $(detail_info_holder_selector).find("#" + type + "-" + id);
        return d.html();
    } else {
        var url = config.url.detail + "?type=" + type + "&key=" + id;
        console.log("get-detail:" + url);
        $(target).toggleClass("loading");
        $(target).load(url, load_callback);
    }
    // notify(d);

}

/** generates a base64-data encoded url out of the current svg
 does some preprocessing: injects the css and sets the @viewBox, @width and @height attributes to ensure, 
 that everything is visible in the exported svg.
 later perhaps even exporting to server, for rendering to PNG, PDF
 http://d3export.cancan.cshl.edu/
 called on mousedown of the download-link, so assumes the <a>-element as this
 */
function genDownload(event) {
//console.log("genDownload:" + this);

    var svg_w = svg.attr("width");
    var svg_h = svg.attr("height");
    var bounds = graphBounds();
    var margin = 30;
    var link_dist = parseInt(opt("link-distance"));

    var x, y, w, h;
    x = Math.floor(bounds["x-min"]) - margin
    y = Math.floor(bounds["y-min"]) - margin
    // add extra space to the right, because of the possible labels 
    w = (bounds["width"] > svg_w) ? bounds["width"] + 2 * margin + link_dist : svg_w + link_dist;
    h = (bounds["height"] > svg_h) ? bounds["height"] + 2 * margin : svg_h;

    var viewBox = x + " " + y + " " + w + " " + h;

    svg.attr("title", "SMC Browser - export")
            .attr("version", 1.1)
            .attr("viewBox", viewBox)
            .attr("width", w)
            .attr("height", h)
            .attr("xmlns", "http://www.w3.org/2000/svg");
    var style = svg.append("style");
    style.attr("type", 'text/css');
    style.text(css);

    var html = svg.node().parentNode.innerHTML;

    /*    $(html).append("<style type='text/css'><![CDATA[" + css + "]]> </style>" );*/


    //console.log(html);

    $(this).attr("title", "smc-browser-export.svg")
            .attr("target", "_blank")
            .attr("href-lang", "image/svg+xml")
            .attr("href", "data:image/svg+xml;base64,\n" + btoa(html));

}


/**  select the nodes within the specified rectangle. */
function selectNodes(nodes, x0, y0, x3, y3) {

    var points = [];
    nodes.forEach(function (n) {
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

function selectNodeByKey(nodes_keys) {

    // get selected nodes (if any) from param
    var selected_match = 0;
    for (var i = 0; i < nodes_keys.length; i++)
    {
        if (data_all.nodes_index[nodes_keys[i]]) {
            data_all.nodes_index[nodes_keys[i]].selected = 1;
            selected_match++;
        }
    }
    // if something was selected, update and render Graph and Detail
    if (selected_match) {
        updateSelected();
    }
}

function updateSelected() {

    // don't change the selected nodes on freeze-layout
    if (opt("layout") != 'freeze') {
        nodes_sel = data_all.nodes.filter(function (d) {
            return d.selected
        });
        console.log("updateSelected:");
        console.log(nodes_sel);
        // update param
        var selected = [];
        nodes_sel.forEach(function (d) {
            selected.push(d.key)
        });
        $("#navigate").data("qi").setParamValue("selected", selected.join());
        renderDetail(nodes_sel);

    }

    renderGraph();

    // just need to highlight the selected nodes
    d3.select(index_container_selector).selectAll("li").classed("highlight", function (d) {
        return d.selected
    });
    //   renderIndex(); - this would be unnecessary and too expensive   
}


/** Returns an event handler for highlighting the path of selected (mouseover) node.
 */
function highlight() {
    max_depth = parseInt(opt("depth-before")) + parseInt(opt("depth-after"));
    console.log("max_depth:" + max_depth);
    return function (d, i) {
        // console.log ("fade:" + d.key);
        //var connected_subgraph_in = neighboursWithLinks(data_show, d,'in', -1);
        //var connected_subgraph_out = neighboursWithLinks(data_show, d,'out', -1);

        var connected_subgraph_in = neighboursWithLinks(data_show, d, 'in', max_depth);
        var connected_subgraph_out = neighboursWithLinks(data_show, d, 'out', max_depth);
        var connected_subgraph = {"nodes": [], "links": []};
        connected_subgraph.nodes = connected_subgraph.nodes.concat(connected_subgraph_in.nodes).concat(connected_subgraph_out.nodes);
        connected_subgraph.links = connected_subgraph.links.concat(connected_subgraph_in.links).concat(connected_subgraph_out.links);
        add_lookups(connected_subgraph);
        svg.selectAll("path.link")
                /*        .filter( d.source.index != i && d.target.index != i; })*/
                /*      .transition()*/
                .classed("highlight", function (p) {
                    return connected_subgraph.links_index[p.source.key + ',' + p.target.key]
                })
                .classed("fade", function (p) {
                    return !(connected_subgraph.links_index[p.source.key + ',' + p.target.key])
                });

        connected = svg.selectAll("g.node").filter(function (d) {
            return  connected_subgraph.nodes_in[d.key] || connected_subgraph.nodes_out[d.key]
        })
                .classed("highlight", 1)
                .classed("fade", 0);

        connected.selectAll("text").classed("hide", 0);
        not_connected = svg.selectAll("g.node").filter(function (d) {
            return  !(connected_subgraph.nodes_in[d.key] || connected_subgraph.nodes_out[d.key])
        })
                .classed("highlight", 0)
                .classed("fade", 1);
        not_connected.selectAll("text").classed("hide", 1);

        /*svg.selectAll("circle")
         /\*        .filter( d.source.index != i && d.target.index != i; })*\/
         /\*      .transition()*\/
         .classed("highlight", function(d) { return connected_subgraph.nodes_in[d.key]  || connected_subgraph.nodes_out[d.key]  })
         .classed("fade", function(d) { return !(connected_subgraph.nodes_in[d.key] || connected_subgraph.nodes_out[d.key])   });*/
        /*
         if (opt("labels") =='show') {
         gnodes.append("svg:text")
         .attr("x", 8)
         .attr("y", ".31em")
         .attr("class", "shadow")
         .text(function(d) { return d.name; });
         gnodes.append("svg:text")
         .attr("x", 8)
         .attr("y", ".31em")
         .text(function(d) { return d.name; });
         }
         */
    };
}

function unhighlight() {
    return function (d, i) {

        svg.selectAll("path.link")
                .classed("highlight", 0)
                .classed("fade", 0);

        var gnodes = svg.selectAll("g.node")
                .classed("highlight", 0)
                .classed("fade", 0);

        gnodes.selectAll("text").classed("hide", function (d) {
            return !d.selected && opt("labels") == 'hide'
        });

    };
}


/**  generates the subset of data to display (based on selected nodes + options) 
 fills global variable: data_show ! 
 */
function dataToShow(nodes) {
    data_show = {};
    data_show.nodes = nodes;
    var data_show_collect = {nodes: [], links: []};

    nodes.forEach(function (n) {
        var data_add_in = neighboursWithLinks(data_all, n, 'in', opt("depth-before"));
        var data_add_out = neighboursWithLinks(data_all, n, 'out', opt("depth-after"));
        data_show_collect.nodes = data_show_collect.nodes.concat(data_add_in.nodes).concat(data_add_out.nodes);
        data_show_collect.links = data_show_collect.links.concat(data_add_in.links).concat(data_add_out.links);
    });

    /*         deduplicate nodes and edges */
    data_show.nodes = unique_nodes(nodes.concat(data_show_collect.nodes));
    data_show.links = unique_links(data_show_collect.links);

    // extend the object, with some lookup hashes on neighbourhood
    add_lookups(data_show);

    return data_show;
}

/** generate lookup hashes for neighbours;
 for faster/simpler neighborhood lookup
 from: http://stackoverflow.com/questions/8739072/highlight-selected-node-its-links-and-its-children-in-a-d3-js-force-directed-g
 */
function add_lookups(data) {

    var links = data.links;
    var neighbours = {"links_index": {}, "nodes_index": {},
        "nodes_in": {}, "nodes_out": {},
        "links_in": {}, "links_out": {},
        "roots": []};

    data.nodes.forEach(function (d) {
        neighbours.nodes_index[d.key] = d;
    });

    var targets = [];

    links.forEach(function (d) {
        src_key = d.source.key;
        trg_key = d.target.key;

        // generate lookup hashes for neighbours;
        neighbours.links_index[src_key + "," + trg_key] = d;
        if (d.source) {
            if (!neighbours.nodes_in[trg_key]) {
                neighbours.nodes_in[trg_key] = [d.source];
                neighbours.links_in[trg_key] = [d];
            } else {
                neighbours.nodes_in[trg_key].push(d.source);
                neighbours.links_in[trg_key].push(d);
            }
        }
        if (d.target) {
            if (targets.indexOf(d.target.key) == -1) {
                targets.push(d.target.key);
            }

            if (!neighbours.nodes_out[src_key]) {
                neighbours.nodes_out[src_key] = [d.target];
                neighbours.links_out[src_key] = [d];
            } else {
                neighbours.nodes_out[src_key].push(d.target);
                neighbours.links_out[src_key].push(d);
            }
        }
    });

    data.nodes.forEach(function (d) {
        if (targets.indexOf(d.key) == -1)
        {
            neighbours.roots.push(d.key);
        }
    });


    //if it is target, it is no root



    data = $.extend(data, neighbours);
    return data;
}



/*                        item_detail.text(function (d) { return "links_in: " +  dataShowCount(d.key, "links_in") +  "; links_out: " +  dataShowCount(d.key, "links_out") ;
 })*/
function dataShowCount(n_key, info_type) {

    if (data_show[info_type][n_key]) {
        return data_show[info_type][n_key].length;
    } else {
        return 0
    }
}

/** determines the min/max x/y position of the visible nodes
 ! neglects the labels!
 
 @returns array of [x_min, y_min, x_max, y_max, (x_max - x_min), (y_max - y_min)]
 */
function graphBounds() {

    var x_arr = [], y_arr = [];

    data_show.nodes.forEach(function (d, i) {
        x_arr.push(d.x);
        y_arr.push(d.y)
    })

    x_min = d3.min(x_arr);
    x_max = d3.max(x_arr);
    y_min = d3.min(y_arr);
    y_max = d3.max(y_arr);

    return {"x-min": x_min, "y-min": y_min, "x-max": x_max, "x-max": y_max, "width": (x_max - x_min), "height": (y_max - y_min)}
}

/** returns appropriate link
 */
function neighbouring(a, b) {
//console.log("neighbouring: " +a.key + "," + b.key ); 
    return data_all.links_index[a.key + "," + b.key];
}


/** access function to retrieve the neighbours from the hashes
 @param data base data to search for links (default: data_all)
 @param dir in|out|any  - but "any" branches in unexpected ways (because it goes in and out on every level = it takes all the children of the parent) 
 @param depth 0-n - go depth-levels; negative depth := no depth restriction = go to the end of the paths;
 @returns a sub-graph
 */
function neighboursWithLinks(data, n, dir, depth) {
// setting defaults
    depth = typeof depth !== 'undefined' ? depth : 1;
    data = typeof data !== 'undefined' ? data : data_all;
    weight_threshold = parseInt(opt("weight")) / 100;
//console.log("weight_threshold:" + weight_threshold + "; depth:" + depth + "; key: " + n.key); 
    if (depth == 0) {
        return {nodes: [], links: []};
    }

    /* don't filter at all */
    if (weight_threshold == 1 | opt("weight") == "") {
        var n_in = data.nodes_in[n.key] ? data.nodes_in[n.key] : [];
        var n_out = data.nodes_out[n.key] ? data.nodes_out[n.key] : [];
        var l_in = data.links_in[n.key] ? data.links_in[n.key] : [];
        var l_out = data.links_out[n.key] ? data.links_out[n.key] : [];
    } else {
        var l_in = data.links_in[n.key] ? data.links_in[n.key].filter(function (d, i) {
            return d.weight >= weight_threshold
        }) : [];
        var l_out = data.links_out[n.key] ? data.links_out[n.key].filter(function (d, i) {
            return d.weight >= weight_threshold
        }) : [];
        var n_in = data.nodes_in[n.key] ? data.nodes_in[n.key].filter(function (d, i) {
            return neighbouring(d, n).weight >= weight_threshold
        }) : [];
        var n_out = data.nodes_out[n.key] ? data.nodes_out[n.key].filter(function (d, i) {
            return neighbouring(n, d).weight >= weight_threshold
        }) : [];
    }

    var result_n = {nodes: [], links: []};
    if (dir == 'in') {
        result_n.nodes = n_in;
        result_n.links = l_in;
    } else if (dir == 'out') {
        result_n.nodes = n_out;
        result_n.links = l_out;
    } else {
        result_n.nodes = n_out.concat(n_in);
        result_n.links = l_out.concat(l_in);
    }
    var n_nextlevel = {nodes: [], links: []};
    if (depth > 0 || depth < 0) {
        result_n.nodes.forEach(function (n)
        {
            var n_neighbours = neighboursWithLinks(data, n, dir, depth - 1);
            n_nextlevel.nodes = n_nextlevel.nodes.concat(n_neighbours.nodes);
            n_nextlevel.links = n_nextlevel.links.concat(n_neighbours.links);
        })
    }
    result_n.nodes = result_n.nodes.concat(n_nextlevel.nodes);
    result_n.links = result_n.links.concat(n_nextlevel.links);

    return result_n;

}

/** deduplicates based on index-property */
function unique_nodes(nodes)
{
    var hash = {}, result = [];
    for (var i = 0, l = nodes.length; i < l; ++i) {
        n_key = nodes[i].key;
        if (!hash[n_key]) { //it works with objects! in FF, at least
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
    for (var i = 0, l = links.length; i < l; ++i) {
        src_key = links[i].source.key;
        trg_key = links[i].target.key;
        key = src_key + "," + trg_key;
        if (!hash[key]) {
            hash[ key] = true;
            result.push(links[i]);
        }
    }
    return result;
}

function notifyUser(msg) {
    $("#notifylist").append(msg);
}
