
SMC Browser Examples
====================

Following are a few examples of graphs generated in the SMC browser. The links point either to a static exported ``[SVG]`` graph, to a rasterized ``[PNG]`` version of it, or **live** to the ``[SMC]`` browser. (With live links, sometimes, the graph does not get rendered right away. In such case just change any of the options to refresh the graph pane.)Links pointing to the definition of given term either in `Component Registry`_ or ISOcat_ are marked with ``[DEF]``.

.. _Component Registry: http://catalog.clarin.eu/ds/ComponentRegistry/
.. _ISOcat: http://isocat.org

Description
-----------

By far the most often used data category is `description [DEF]`_ (used in 44 profiles on 550 elements).
Following image depicts the surroundings of this `description` data category:

.. figure:: examples/description-datcat-smaller.png
   :width: 800px
   
   In this graph, the node size is set relative to the usage of given term within the whole CMD (option_ ``node-size=usage``).
   
   View `description-datcat [PNG]`_, `description-datcat [SVG]`_ or `description data category [SMC]`_ in SMC browser.
   
If we dig `higher up the trees [SVG]`_  (option ``depth-before=6``) we get up to all the profiles using this data category (and all the paths), which becomes somewhat unreadable.
Alternatively, we can inspect the related `description component [DEF]`_ in `dot-layout [SMC]`_ (`dot-layout [SVG]`_) or as `horizontal-tree [SMC]`_.

.. _description [DEF]: http://www.isocat.org/datcat/DC-2520
.. _description component [DEF]: http://catalog.clarin.eu/ds/ComponentRegistry/?item=clarin.eu:cr1:c_1271859438118
.. _dot-layout [SMC]: .?depth-before=2&depth-after=2&link-distance=95&charge=360&friction=86&node-size=usage&labels=show&curve=straight&layout=dot&selected=clarin_eucr1c_1271859438118,clarin_eucr1c_1271859438177&
.. _horizontal-tree [SMC]: .?depth-before=2&depth-after=2&link-distance=95&charge=360&friction=86&node-size=usage&labels=show&curve=straight&layout=horizontal-tree&selected=clarin_eucr1c_1271859438118,clarin_eucr1c_1271859438177&
.. _description data category [SMC]: ./?depth-before=2&depth-after=4&link-distance=84&charge=179&friction=86&node-size=usage&labels=show&curve=straight&layout=horizontal-tree&selected=clarin_eucr1c_1271859438177,httpZZwww_isocat_orgZdatcatZDC_2520&
.. _description-datcat [SVG]: examples/description-datcat-smaller.svg
.. _description-datcat [PNG]: examples/description-datcat-smaller.png
.. _dot-layout [SVG]: examples/description-component-dot.svg
.. _higher up the trees [SVG]: examples/description-datcat.svg
.. _option: userdocs.html#Options

Access
------

There are multiple components and elements describing *access* (`access [SMC]`_) to a resource.
Here are a few layout variants:

.. figure:: examples/access_resize.png

   View `access-htree [PNG]`_, `access-htree [SVG]`_

.. figure:: examples/access-dot_resize.png

   View `access-dot [PNG]`_, `access-dot [SVG]`_

.. figure:: examples/access-force_resize.png

   View `access-force [PNG]`_, `access-force [SVG]`_

.. _access [SMC]: .?depth-before=2&depth-after=4&link-distance=42&charge=239&friction=58&node-size=4&labels=hide&curve=straight&layout=force&selected=clarin_eucr1c_1271859438124,clarin_eucr1c_1349361150637,clarin_eucr1c_1271859438187,clarin_eucr1c_1284723009146Access,clarin_eucr1c_1284723009150Access,clarin_eucr1c_1284723009151Access,TITUS_metadata_ResourceAccess,clarin_eucr1c_1311927752326&
.. _access-htree [SVG]: examples/access.svg
.. _access-dot [SVG]: examples/access-dot.svg
.. _access-force [SVG]: examples/access-force.svg
.. _access-htree [PNG]: examples/access.png
.. _access-dot [PNG]: examples/access-dot.png
.. _access-force [PNG]: examples/access-force.png


dublincore
----------
There are multiple profiles modelling the dublincore terms [DEF]:

* DcmiTerms_
* OLAC-DcmiTerms_
* dc-terms_
* dc-terms-modular_

.. figure:: examples/dcterms-dcmiterms-vtree.png
	 :width: 800px
	 
	 View `dcterms and dcmiterms [SMC]`_, `dcterms and dcmiterms v-tree [SVG]`_, `dcterms and dcmiterms h-tree [SVG]`_, 
	 `dcterms and dcmiterms v-tree [PNG]`_, `dcterms and dcmiterms h-tree [PNG]`_
	 
	 View `dcmi-terms only [SMC]`_, `dcmi-terms [SVG]`_, `dcmi-terms [PNG]`_
	  
.. _dcterms and dcmiterms [SMC]: .?depth-before=3&depth-after=5&link-distance=187&charge=179&friction=54&node-size=4&labels=hide&curve=straight&layout=horizontal-tree&selected=clarin_eucr1p_1271859438218,clarin_eucr1p_1271859438217,clarin_eucr1p_1288172614023,clarin_eucr1p_1288172614026&
.. _dcmi-terms only [SMC]: .?link-distance=24&charge=107&layout=force&selected=clarin_eucr1p_1288172614023,clarin_eucr1p_1288172614026&
.. _dcterms and dcmiterms h-tree [SVG]: examples/dcterms-dcmiterms.svg
.. _dcterms and dcmiterms v-tree [SVG]: examples/dcterms-dcmiterms-vtree.svg
.. _dcterms and dcmiterms h-tree [PNG]: examples/dcterms-dcmiterms.png
.. _dcterms and dcmiterms v-tree [PNG]: examples/dcterms-dcmiterms-vtree.png
.. _dcmi-terms [SVG]: examples/dcmiterms.svg
.. _dcmi-terms [PNG]: examples/dcmiterms.png
.. _DcmiTerms: http://catalog.clarin.eu/ds/ComponentRegistry/?item=clarin.eu:cr1:p_1288172614023
.. _OLAC-DcmiTerms: http://catalog.clarin.eu/ds/ComponentRegistry/?item=clarin.eu:cr1:p_1288172614026
.. _dc-terms: http://catalog.clarin.eu/ds/ComponentRegistry/?item=clarin.eu:cr1:p_1271859438218
.. _dc-terms-modular: http://catalog.clarin.eu/ds/ComponentRegistry/?item=clarin.eu:cr1:p_1271859438217

From the figure we can see the two distinct pairs of related profiles. The two with "DcmiTerms" point to the `dublincore terms`_ the other two "dc-terms" refer to `dublincore elements`_. This is a good example for the role of `Relation Registry`_. It allows to express relations beetween data categories, e.g. `the equivalencies between dc-elements and dc-terms`_. (Displaying the relations from RR is soon to be added feature for SMC browser.)

.. _dublincore terms: http://purl.org/dc/terms
.. _dublincore elements: http://purl.org/dc/elements/1.1/
.. _Relation Registry: http://lux13.mpi.nl/relcat/site/index.html
.. _the equivalencies between dc-elements and dc-terms: http://lux13.mpi.nl/relcat/set/dc

	
The dublincore terms (or rather elements) are used as data categories in a few more profiles:

* teiHeader
* HZSKCorpus
* EastRepublican

.. figure:: examples/dc-terms-force.png
   :width: 800px
   
   View `dc-terms force [SMC]`_, `dc-terms horizontal-tree [SMC]`_, `dc-terms horizontal-tree [SVG]`_
	 
.. _dc-terms force [SMC]: .?depth-before=3&depth-after=6&link-distance=91&charge=342&friction=58&node-size=4&labels=show&curve=straight&layout=force&selected=clarin_eucr1p_1271859438218,clarin_eucr1p_1271859438217,clarin_eucr1c_1324638957707,clarin_eucr1p_1282306194508,clarin_eucr1c_1282306194507,httpZZpurl_orgZdcZelementsZ1_1Zsource,httpZZpurl_orgZdcZtermsZcreated,httpZZpurl_orgZdcZtermsZrightsHolder&
.. _dc-terms horizontal-tree [SMC]: .?depth-before=3&depth-after=6&link-distance=190&charge=264&friction=86&node-size=4&labels=show&curve=straight&layout=horizontal-tree&selected=clarin_eucr1p_1271859438218,clarin_eucr1p_1271859438217,clarin_eucr1c_1324638957707,clarin_eucr1p_1282306194508,clarin_eucr1c_1282306194507,httpZZpurl_orgZdcZelementsZ1_1Zsource,httpZZpurl_orgZdcZtermsZcreated,httpZZpurl_orgZdcZtermsZrightsHolder&
.. _dc-terms horizontal-tree [SVG]: examples/dc-terms-htree.svg


Web Services 
------------

The below figure displays two profiles modelling WebServices: `BASWebService [DEF]`_ and `CLARINWebService [DEF]`_. It nicely exposes the similarity and parallel structure of the two profiles as well as both of them binding to the same data categories. Although the graph shows completely only the two profiles, there are more related profiles: the `ToolService [DEF]`_ and the `WeblichtWebService [DEF]`_
The `ToolService` is also visible in the graph (related via the component data category `DC-4159 [DEF]`_), but it is deliberately not selected, because it is too big
and makes the graph unreadable. You can still view it separately: `ToolService [SMC]`_.

.. figure:: examples/webservices.png
   :width: 800px
   
   View `webservices [SMC]`_, `webservices [SVG]`_, `webservices [PNG]`_
	 
.. _webservices [SMC]: .?depth-before=2&depth-after=9&link-distance=176&charge=324&friction=75&node-size=4&labels=show&curve=straight&layout=horizontal-tree&selected=clarin_eucr1p_1324638957718,clarin_eucr1p_1311927752335,httpZZwww_isocat_orgZdatcatZDC_4159&
.. _webservices [SVG]: examples/webservices.svg
.. _webservices [PNG]: examples/webservices.png
.. _ToolService [SMC]: .?depth-before=2&depth-after=10&link-distance=42&charge=143&friction=93&node-size=4&labels=hide&curve=straight&layout=force&selected=clarin_eucr1p_1311927752306&
.. _ToolService [DEF]: http://catalog.clarin.eu/ds/ComponentRegistry/?item=clarin.eu:cr1:p_1311927752306
.. _WeblichtWebService [DEF]: http://catalog.clarin.eu/ds/ComponentRegistry/?item=clarin.eu:cr1:p_1320657629644
.. _BASWebservice [DEF]: http://catalog.clarin.eu/ds/ComponentRegistry/?item=clarin.eu:cr1:p_1324638957718
.. _CLARINWebService [DEF]: http://catalog.clarin.eu/ds/ComponentRegistry/?item=clarin.eu:cr1:p_1311927752335
.. _DC-4159 [DEF]: http://www.isocat.org/datcat/DC-4159
