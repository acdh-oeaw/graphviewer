***********
SMC Browser
***********

Explore the `Component Metadata Framework`

.. _Component Metadata Framework: http://clarin.eu/cmdi

In *CMD*, metadata schemas are defined by profiles, that are constructed out of reusable components  - collections
of metadata fields. The components can contain other components, and they can be reused in multiple profiles.
Furthermore, every CMD element (metadata field) refers via a PID to a data category to indicate unambiguously how the content of the field in a metadata description should
be interpreted (Broeder et al., 2010).

Thus, every profile can be expressed as a tree, with the profile component as the root node, the used components as intermediate nodes
and elements or data categories as leaf nodes, parent-child relationship being defined by the inclusion (``componentA -includes-> componentB``) or referencing (``elementA -refersTo-> datcat1``).The reuse of components in multiple profiles and especially also the referencing of the same data categories in multiple CMD elements leads to a blending of the individual profile trees into a graph (acyclic directed, but not necessarily connected).

SMC Browser visualizes this graph structure in an interactive fashion. You can have a look at the `examples`_ for inspiration.

It is implemented on top of wonderful js-library d3_, the code checked in `clarin-svn`_ (and needs refactoring). More technical documentation follows soon.

.. _d3: https://github.com/mbostock/d3
.. _clarin-svn: https://svn.clarin.eu/SMC/trunk/SMC
.. _examples: examples.html


Data
====
The graph is constructed from all profiles defined in the `Component Registry`_.
To resolve name and description of data categories referenced in the CMD elements
definitions of all (public) data categories from `DublinCore`_ and `ISOcat`_ (from the `Metadata Profile`_ [RDF] - retrieving takes some time!) are fetched. However only data categories used in CMD will get part of the graph. Here is a `quantitative summary`_ of the dataset. 

When inspecting the numbers, it is important to be aware of the occurrence expansion resulting from the reusability of the components. 
So in an example, a component C has 2 subcomponents and is reused within one profile by two other components A and B, the resulting profile
will consist of (at least) 8 components (``[A, B, A/C, B/C, A/C/C1, A/C/C2, B/C/C1, B/C/C2]``), although only 5 distinct components are used.
The same goes for elements in reused components. In most cases it is indicated in the label, if the number reflect distinct items, or all (expanded) occurrences.

(Some of the) numbers in the statistics lead to a list of corresponding terms. 
E.g. in the summary for a profile, clicking on the components-number lists all the components of given profile alphabetically.
Currently there are such lists for:

  * ``profile -> components`` 
  * ``profile -> elements``
  * ``profile -> data categories``
  * ``data category -> profiles``

.. _Component Registry: http://catalog.clarin.eu/ds/ComponentRegistry/#
.. _ISOcat: http://www.isocat.org
.. _Metadata Profile: http://www.isocat.org/rest/profile/5.rdf
.. _DublinCore: http://dublincore.org
.. _quantitative summary: smc_stats.html

User Interface
==============

The User interface is divided into 4 main parts:

Index
   Lists all available Profiles, Components, Elements and used Data Categories
   The lists can be filtered (enter search pattern in the input box at the top of the index-pane)
   By clicking on individual items, they are added to the `selected nodes` and get rendered in the graph pane
   
Main (Graph)
   Pane for rendering the graph.
   
Navigation
   This is the control panel governing the rendering of the graph. See below for available `Options`_.
   
Detail
   In this pane, overall summary of the data is displayed by default,
   but mainly the detail information about the selected nodes is listed here.
   
   
Interaction
-----------

Following data sets are distinguished wrt user interaction:

all data 
   the full graph with all profiles, components, elements and data categories and links between them.
   
   Currently this amounts to roughly 2.000 nodes and 3.000 links

selected nodes
   nodes explicitely selected by the user (see below how to `select nodes`_) 

data to show
   the subset of data that shall be displayed. 
   
   Starting from the selected nodes, connected nodes (and connecting edges) 
   are determined  based on the options (``depth-before``, ``depth-after``).

The nodes are colour-coded by type:

.. image:: graph_legend.svg
	 :alt: the legend to the graph
	 :height: 80px

.. _select nodes:

There are multiple ways to select/unselect nodes:

select from index
	by clicking individual items in the index list, the item will be **added** to the selected nodes
	
	clicking on an already selected item unselects it

select in graph
  by clicking on a visible node in the graph, the node will be **added** to the selected nodes
  
  clicking on an already selected node unselects it
  
select area in graph
  by dragging (hold mouse button down and pull) a rectangle in the graph pane, all nodes within that rectangle get selected
  all other nodes will be unselected

unselect in detail pane
  clicking on an item in the detail pane unselects it

select in statistics 
	as mentioned in `Data`_ (some) numbers in the statistics reveal a list of corresponding terms.
	Clicking on these terms in the statistics page leads to the browser, with given term as selected node (and default settings)
	
select in statistics in the detail pane
  the numbers from statistics page are shown also in the detail pane for selected nodes.
  Here, clicking on a term from these lists adds it to the graph, as a selected node.
  
mouseover 
  on mouse over a node, all connected nodes to given node (and connecting links) within the visible sub-graph are highlighted 
  and all other nodes and links are faded 

drag a node
  click and hold on a node, one can move the node around, however usually the layout is stronger 
  and puts the node back to its original position. Not so with the freeze-layout, that freezes all the nodes and lets you move them around freely

Options
-------
The navigation pane provides following option to control the rendering of the graph:


depth-before
  how many levels of connected ancestor nodes shall be displayed  
depth-after
	how many levels of connected descendant nodes shall be displayed  

link-distance
	approximate distance between individual nodes 
	(not exact, because it is just one of multiple factor for the layouting of the graph)
	
charge
	the higher the charge, the more the nodes tend to drift apart
	
friction
  factor for "cooling down" the layout, lower numbers (50-70) stabilize the graph more quickly, 
  but it may be too early, with higher numbers (95-100) the layout has more time/freedom to arrange,
  but may get jittery
  
node-size
  N = all nodes have given diameter N;
  
  usage = node is scaled based on how often the node appears in the complete dataset
  i.e. often reused elements (like description or language) will be bigger
  
labels
  show/hide all labels
  hiding the labels accelerates the rendering significantly, which may be an issue if more nodes are displayed.
  irrespective of this option, on mouseover labels for all and only the highlighted nodes are displayed

curve
  straight or arc (better visibility)
  
layout
  There are a few layouting algorithms provided. They are all not optimal in any way, but most of the time, they deliver quite good results.
  For different data displayed other algorithm may be more appropriate:
  
  force
    undirected layout, trying to spread the nodes in the pane optimally, equally in all directions
    This is the underlying `layouting algorithm`_. All the other layouts build on top of it, by just adding further constraints.
  vertical-tree
    top-down layout respect the direction of the edges, children are always below the parents
  horizontal-tree
    left-right layout respect the direction of the edges, children are always right to the parents 
    (at least they should be, currently, in certain configurations, the layout does not get the orientation for some links right)
  weak-tree
    a layout that "tends" towards left to right arrangement, but not strictly so (experimental)	  	   
  dot
    strict left to right reusing the x-positioning as determined by dot_
    Arranges the nodes in strict ranks (typical for dot layout)
    This is done in a separate preprocessing step for the whole graph, so the positioning may be suboptimal
    for a given subgraph. The y-coordinate is approximated on the fly by the base algorithm.
  freeze 
    this is actually a "no-layout" - the nodes just stay fixed in their last position,
    However, individual nodes still can be dragged around, so this can be used to adjust a few nodes for better legibility (or aesthetics),
    but only when you start moving around inividual nodes, you will learn to appreciate the great (and tedious) work of the layouting algorithms, 
    so generally you want to try to play around with the other settings to achieve a satisfying result.

.. _layouting algorithm: https://github.com/mbostock/d3/wiki/Force-Layout
.. _dot: http://www.graphviz.org/
  


Linking, Export
---------------
 
The navigation pane exposes a **link**, that captures the exact current state of the interface 
(just the options and the selection, not the positioning of the elements),
so that it can be bookmarked, emailed etc.

Furthermore, there is the **download**, that allows to export the current graph as SVG.
This is accomplished without a round trip to the server, with a `javascript trick`_ 
serializing the svg as base64-data into the url (so you don't want to save (or see) the exported url).
But you can both, right click the link and [Save link as...], or click on the link, which opens the SVG in a new tab
where you can view, resize, print and save it.
Employing this simple method also means, that there is no possibility to export the graph in PNG, PDF or any other format, 
because this would require `server-side processing`_. (However this is a planned future enhancement.)

.. _javascript trick: https://groups.google.com/forum/?fromgroups=#!topic/d3-js/aQSWnEDFxIc
.. _server-side processing: http://d3export.cancan.cshl.edu/
  
 
Issues
======

Performance
	Chrome is by far the fastest, followed by IE(9). 
	A serious performance degradation was observed for graphs above 200 nodes on Firefox.
	Showing labels also significantly affects performance.

Bounds
  When the graph gets to big, it does not fit in the viewing pane.
  This will be tackled soon (either scrollbars or applying boundaries). Meanwhile,
  you can reduce the link-distance and charge parameters or change the layout.

Plans and ToDos
===============

Substantial issues:

* Add information from **RelationRegistry** (relations between DatCats)
* Blend in instance data from **MDRepository** (allow search on MDRepository)
* graph operations (intersect, difference of subrgraphs)

Smaller enhancements of the user interface:

* select nodes by querying the names (e.g. show me all nodes with "Access" in their name)
* option to show only selected types of nodes (e.g. only profiles and datcats)
* detail-info on hover
* full HTML-rendering of a node (Profile, Component)
* backlinking from detail (e.g. view all the profiles a data category is used in by clicking on the number ('used in profiles')
* store/export SVG/PDF/PNG-renderings of the graphs
* add edge-weight: scale based on usage, i.e. how often appears the relation in the complete dataset
  i.e. often reused combinations of components/elements will be nearer
* allow to blend in further (private) CMD-profiles dynamically