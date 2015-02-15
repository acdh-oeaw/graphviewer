
var config ={
       "url": {"data_prefix":"data/",
                "detail":"get.xql" ,
             //  "detail":"http://localhost:8580/exist/apps/smc-browser/get.xql" ,
            // "detail":"data/smc_stats_detail.html",
               "userdocs":"docs/userdocs.html"
              },
        "mode":"dynamic",  // "static | dynamic"
        "min_circle":4,
        "max_circle":80,
        "base_font_size":10,
        "select_rect_min_size":5,
        "first_level_margin":20,
        "show_count":1
        
};

// configuration of the navigation widgets 
var opts = {"graph": {"value":"smc-graph-basic.js", 
                    "values":[{value: "smc-graph-basic.js", label:"SMC graph basic"},
                              {value: "smc-graph-all.js", label:"SMC graph all"},                              
                              {value: "smc-graph-profiles-datcats.js", label:"only profiles + datcats"},
                              {value: "smc-graph-groups-profiles-datcats-rr.js", label:"profiles+datcats+groups+rr"},
                              {value: "smc-graph-profiles-similarity.js", label:"profiles similarity"}                              
                              /*{value: "dbpedia_philosophers_influence_years_graph.json", label:"Philosophers"},
                              {value: "SC_Persons_120201_cAll_graph.json", label:"Schnitzler Cooccurrences"},*/
                              /*,
                              {value: "smc-graph-mdrepo-stats.js", label:"instance data"}*/
                              
                             ], "widget":"selectone" },
            "depth-before": {"value":2, "min":0, "max":10, "widget":"slider"}, 
            "depth-after":{"value":2, "min":0, "max":10, "widget":"slider"}, 
            "link-distance": {"value":120, "min":10, "max":300, "widget":"slider" }, 
            "charge":{"value":250, "min":10, "max":1000, "widget":"slider" },
            "friction":{"value":75, "min":1, "max":100, "widget":"slider" },
            "gravity":{"value":10, "min":1, "max":100, "widget":"slider" },
            "node-size": {"value":"4", "values":["1","4","8","16","count"], "widget":"selectone" },
            "link-width": {"value":"1", "values":["1","value"], "widget":"selectone" },
            "weight":{"value":100, "min":1, "max":100, "widget":"slider" },
            "labels": {"value":"show", "values":["show","hide"], "widget":"selectone" },                         
            "curve": {"value":"straight-arrow", "values":["straight-line","arc-line","straight-arrow","arc-arrow"], "widget":"selectone" },
           "layout": {"value":"horizontal-tree", "values":["vertical-tree", "horizontal-tree", "weak-tree","force","dot", "freeze"], "widget":"selectone" },
            "selected": {"widget":"hidden" },
            "link": {"widget":"link", "label":""},
            "download": {"widget":"link", "label":""},
            "add_profile": {"widget":"link", "label":"Add profile", "widget":""}
            };
