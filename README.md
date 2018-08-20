
****************
  Graph Viewer 
****************

Graph Viewer is an JavaScript web application for interactive visualization/exploration of graph data.
It is based on the d3 JavaScript library.

The application was originally developed in the context of the SMC [2] - Semantic Mapping Component - a module within the CMDI framework [3] of the CLARIN infrastructure.


[1] http://d3js.org/
[2] https://clarin.oeaw.ac.at/smc
[3] http://clarin.eu/cmdi

Overview
--------

The code consists of 3 main parts:
- XSL-stylesheets [src/scripts/*.xsl]
- client-side JS application [src/web/*]
- a minimal Java "application" (meant mainly to invoke the initialization steps specific to SMC incarnation of graphviewer)
[src/eu/clarin/cmdi/smc/SMC.java]


Installation
-------------

- Graph Viewer is a client side JS application, so it doesn't have any 
  server-side requirements. You can simply open it in a browser and it should 
  work.
- You can find Graph Viewer client application in src/web directory. The directory structure is as 
  follows:
  - index.html - HTML template
  - get.php - very simple HTTP proxy script (it returns content of a given URL 
    making it possible to bypass AJAX cross-domain restrictions).
    Currently used only for gathering details about philosopers (see "handling
    details" below).
  - scripts - all js libraries and css stylesheets Graph Viewer depends on
  - docs - static HTML content
  - data - sample data consistent with the Graph Viewer configuration commited to 
    the repo
- Available data sources
  To adjust a list of available data sources edit opts.graph variable in 
  scripts/js/config.js:
  - value property should be one of the values[].value and denotes data set
    selected after the page is loaded
  - values array describes all available datasets
- Static pages
  Static page templates are in the /docs directory.
  You can use rst2html (part of docutils package) to convert them into HTML.
  HTML files should be then moved to docs/
- Handling details
  - The right column of the Graph Viewer displays node details. 
    Details can come from different sources:
    - If the node is of type "philosopher" they are simply read from Wikipedia.
      To bypass AJAX cross-domain restrictions and assure proper encoding a 
      very simple PHP proxy script is used (get.php). You can adjust get.php
      location in the getDetailInfo() function in the scripts/js/smc-graph.js
    - In other case there are two possibilities:
      - Data can be loaded from a prepared static HTML file.
        Such file has to be generated before (probably using scripts in the /src
        drectory other then /src/web).
        Path to the file is set up in config.url.detail variable in 
        scripts/js/config.js. By default it points to an empty HTML file (so no
        details will be provided but there will be also no error).
      - Data can be loaded dinamically by reading data from a given URL
        providing details in the HTML format. URL is constructed as:
          config.url.detail + "?type=" + type + "&key=" + id
        where type and id comes from the node and config.url.detail is defined
        in scripts/js/config.js
        The predecessor of Graph Viewer, the SMC Browser running at https://clarin.oeaw.ac.at/smc-browser/
        is using xql query run in eXist to generate details.
      
