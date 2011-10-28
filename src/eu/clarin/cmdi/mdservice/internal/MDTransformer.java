package eu.clarin.cmdi.mdservice.internal;

import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.Reader;
import java.io.StringReader;
import java.io.StringWriter;
import java.net.URL;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;
import java.util.Map.Entry;

import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import org.apache.log4j.Logger;

import net.sf.saxon.event.MessageEmitter;

/**
 * Helper class, encapsulating the xsl-transformations handling.
 * The contract is, that the requester passes a key, which can be resolved to a xsl-script (momentary mapped in properties: Utils.getConfig())
 * 
 * Bad things happen, if the key or the appropriate xsl-file do not exist - well the client gets a diagnostic message.
 *    
 * 
 * @author vronk
 *
 */

public class MDTransformer {
	
	private static Logger log = Logger.getLogger("MDTransformer");

	private String transkey;
	private URL srcFile ;
	private Map<String, String[]> params;
		
	// don't use singleton!! Bad things happen
	// private MDTransformer singleton;
	//TransformerFactory tfactory ; 
	
	//public MDTransformer () {		
	//	tfactory = TransformerFactory.newInstance();	
	//}
	
	
	public URL getSrcFile() {
		return srcFile;
	}

	public void setSrcFile(URL srcFile) {
		this.srcFile = srcFile;
	}

	/**
	 * This serves the caller (mainly GenericProxyAction.prepare())
	 * to provide/fill the request parameters. 
	 * They then get translated to stylesheet-parameters (in SetTransformerParameters()).
	 * @return
	 */
	public void setParams(Map<String, String[]> map){
		this.params = map;
	}
	
	
	public Map<String,String[]> getParams(){
		return this.params;
	}

	/**
	 * Get the path to the xsl file from properties, based on the key (aka format-parameter)
	 * @param key
	 * @return
	 * @throws NoStylesheetException - if no matching entry in properties could be found 
	 */
	private String getXSLPath (String key) throws NoStylesheetException {		
		String xslpath = "";
		String xslfilename= Utils.getConfig().getProperty("xsl." + key);
		
		if (xslfilename!=null) {			
			xslpath =  Utils.getConfig().getProperty("scripts.path") + xslfilename;
		} else {
			throw new NoStylesheetException("No Stylesheet found for format-key: " + key);
		}
		log.debug("xslfile:" + xslpath);
		return xslpath;
	}
	/**
	 * Tries to load the stylesheet based on the key.
	 * This is done in two steps:
	 * 1. try to resolve the key to a path
	 * 2. get the xsl-file as a stream (and establish it as StreamSource) 
	 * 
	 * @param key The key identifying the stylesheet for the transformation as passed by GenericProxyAction.
	 * @return the stylesheet to be applied (as StreamSource)
	 * @throws NoStylesheetException If the stylesheet could not be located
	 */
	private StreamSource getXSLStreamSource (String key) throws NoStylesheetException{		
		
		InputStream xslstream;
					
		//URL myURL = new URL (getXSLPath(key));
		//xslstream = myURL.openStream();
		String xslPath = getXSLPath(key);
		xslstream = this.getClass().getClassLoader().getResourceAsStream(xslPath);
		StreamSource streamSource = new StreamSource(xslstream);

		streamSource.setSystemId(this.getClass().getClassLoader().getResource(xslPath).toString());
		return streamSource ;	
		
	}
	
	public void setTranskey(String key){
		transkey = key;
	}
	
	public String getTranskey(){
		//return params.get("x-cmd-format")[0];
		
		if (transkey.equals("") & params.containsKey("fullformat")) {
			transkey = params.get("fullformat")[0] ;	
		}
		return transkey;
	}

	/**
	 * The main method for transforming, applies the appropriate (based on the transkey) stylesheet on the xml-stream
	 * and writes the result into the output stream.    
	 * @param in InpuStream with xml  
	 * @param transkey this defines the stylesheet to use and is also passed to the stylesheet as "format"-parameter 
	 * @param out the stream to write the output to
	 * @throws TransformerException
	 * @throws IOException
	 * @throws NoStylesheetException 
	 */
	public void transformXML (InputStream in, OutputStream out ) throws TransformerException, IOException, NoStylesheetException {
	//public void transformXML (InputStream in, String transkey, String cols, String startRecord, String maximumRecords, String lang, String q, String repositoryURI, OutputStream out ) throws TransformerException, IOException {
	
			System.setProperty("javax.xml.transform.TransformerFactory", "net.sf.saxon.TransformerFactoryImpl");
	        // Create a transform factory instance.
	        TransformerFactory tfactory = TransformerFactory.newInstance();
	        //OutputStream os = new ByteArrayOutputStream();
	        StreamResult stream = new StreamResult(out);
	        
	        // Create a transformer for the stylesheet.
	        	//String xslpath = getXSLPath(transkey);	        
	        Transformer transformer = tfactory.newTransformer(
	        							getXSLStreamSource(getTranskey()));
	        SetTransformerParameters(transformer);
	        
	        //MessageWarner gg = new net.sf.saxon.event.MessageWarner();
	        MessageEmitter me = new net.sf.saxon.event.MessageEmitter();
	        StringWriter w = new StringWriter();
	        me.setWriter(w);
	       ((net.sf.saxon.Controller)transformer).setMessageEmitter(me);//new net.sf.saxon.event.MessageWarner());

	       
	        if (srcFile!=null) {
	        	
	        	File f = new File(srcFile.getPath());
	        	    
		        //log.debug("src:" + srcFile.getFile());
		        //log.debug("fpath:" + f.getAbsolutePath());
		        String root_uri =  srcFile.toString();
		        String xsrcfile =  srcFile.getFile();
		        if  (srcFile.getProtocol().equals("file")) {
		        	root_uri = "file:///" + f.getParent().replace('\\', '/');
		        	xsrcfile = "file:///" + f.getPath().replace('\\', '/');
		        } 
		        // TODO repository-path -removed, bad formating
		        String[] xsrcfiles = xsrcfile.split("&repository=");
		        String[] root_uris = root_uri.split("&repository=");
		        xsrcfile = xsrcfiles[0];
		        root_uri = root_uris[0];
		        ///
		        
		        log.debug("root_uri:" +  root_uri );
		        log.debug("xsrcfile:" +  xsrcfile );
		        
		        transformer.setParameter("root_uri", root_uri );
		        transformer.setParameter("src_file", xsrcfile);
	        } else {
	        	log.error("transformXML(): srcFile not set!!");	        		
	        }
	        // 
	        StreamSource src =new StreamSource();      	        
	        src.setInputStream(in);
	        // Transform the source XML to out-stream
	        transformer.transform(src, stream );
	        
	        // Write <xsl:message>
	        writeXslMessages(w);
	        ///log.debug(w.getBuffer().toString());	        
   }
	

	/**
	 * just a wrapper for the main method translating the output-stream into a input-stream (expected by the Controller-Actions to return as response)
	 * @param xmlStream the source xml stream 
	 * @param transkey 
	 * @return result-stream (converted to InputStream)
	 * @throws IOException
	 * @throws InterruptedException
	 * @throws TransformerException
	 * @throws NoStylesheetException 
	 */
	public InputStream transformXML ( InputStream xmlStream) throws IOException, InterruptedException, TransformerException, NoStylesheetException {
	//public InputStream transformXML ( InputStream xmlStream, String transkey, String cols, String startRecord, String maximumRecords, String lang, String q, String repositoryURI) throws IOException, InterruptedException, TransformerException {
		
		ByteArrayOutputStream out = new ByteArrayOutputStream();
		transformXML(xmlStream, out);		
	    InputStream transformedStream = new ByteArrayInputStream(out.toByteArray());
	    return transformedStream;
	}
	
	/**
	 * another wrapper for the main method allowing to directly pass a URL to the source-xml    
	 * @param xmlFile URL of the source-file   
	 * @param transkey
	 * @return the result-stream (already converted to an InputStream) 
	 * @throws TransformerException
	 * @throws IOException
	 * @throws NoStylesheetException 
	 */
	public InputStream transformXML (URL xmlFile ) throws IOException, InterruptedException, TransformerException, NoStylesheetException {
	//public InputStream transformXML (URL xmlFile, String transkey ) throws IOException, InterruptedException, TransformerException {
		srcFile= xmlFile;
		InputStream  xmlStream =
	     new BufferedInputStream(new FileInputStream(xmlFile.getPath()));
	    
		return transformXML ( xmlStream); 
	}

	/**
	 * this is for xml-data present as string (primarily the query string present as XCQL).
	 * if xml in a file or a stream, use the other methods 
	 * @param xml xml-data as string
	 * @param transkey 
	 * @return
	 * @throws NoStylesheetException 
	 * @throws IOException 
	 */
	public String transformXML (String xml) throws NoStylesheetException {
	//public String transformXML (String xml, String transkey ) {
		String result="";
		try {
	        // Create a transform factory instance.
			System.setProperty("javax.xml.transform.TransformerFactory", "net.sf.saxon.TransformerFactoryImpl");
			//System.setProperty("javax.xml.transform.TransformerFactory", "com.icl.saxon.TransformerFactoryImpl");
	        TransformerFactory tfactory = TransformerFactory.newInstance();
	        OutputStream os = new ByteArrayOutputStream();
	        StreamResult stream = new StreamResult(os);
	        // Create a transformer for the stylesheet.
	        Transformer transformer = tfactory.newTransformer(
	        				getXSLStreamSource(getTranskey()));

	        MessageEmitter me = new net.sf.saxon.event.MessageEmitter();
	        StringWriter w = new StringWriter();
	        me.setWriter(w);
	        ((net.sf.saxon.Controller)transformer).setMessageEmitter(me);//new net.sf.saxon.event.MessageWarner());

	        // Transform the source XML to System.out.
	        StreamSource src =new StreamSource();        
	        Reader reader  = new StringReader(xml);
	        src.setReader(reader);
	        
	        transformer.transform(src, stream );
	                            //  new StreamResult(new File("Simple2.out")));
	     // Write <xsl:message>
	        writeXslMessages(w);
	          
	        result = os.toString(); 
	        
			} catch (TransformerException e) {
				e.printStackTrace();
			}
			
			return result;
	}

	private void writeXslMessages(StringWriter w){
        
        byte[] bytes = w.getBuffer().toString().getBytes();
        InputStream is =  new ByteArrayInputStream(bytes);
        BufferedReader br = new BufferedReader(new InputStreamReader(is));
        String s;
		try {
			while ((s = br.readLine()) != null){
	        	log.debug(s);
	        }
		} catch (IOException e) {
			log.error(Utils.errorMessage(e));
		}
	}

	/**
	 * Makes the request-parameters available in the stylesheets
	 * by translating them to stylesheet-parameters
	 * @param transformer
	 */
	public void SetTransformerParameters(Transformer transformer){
		
		Set<Entry<String, String[]>> set = params.entrySet();
		Iterator<Entry<String, String[]>> i = set.iterator();

	    while(i.hasNext()){
	      Map.Entry<String,String[]> e = (Map.Entry<String,String[]>)i.next();
	      transformer.setParameter((String)e.getKey(), (String)e.getValue()[0]);
	    }
	}

	
	public static HashMap<String,String[]> createParamsMap(String key){
		HashMap<String,String[]> hm = new HashMap<String,String[]>();
		
	    if (key != null){
	    	String[] arrkey = new String[1];
	    	arrkey[0] = key;
			hm.put("fullformat", arrkey);			
	    }
	    return hm;
	}
	
}