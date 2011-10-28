package eu.clarin.cmdi.mdservice.internal;

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.util.Properties;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.FactoryConfigurationError;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.Result;
import javax.xml.transform.Source;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.TransformerFactoryConfigurationError;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpression;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.xml.sax.SAXException;

import net.sf.json.JSON;
import net.sf.json.JSONSerializer;
import net.sf.json.xml.XMLSerializer;

import org.apache.log4j.Logger;

/**
 * Helper class provides reading of configuration properties and contains
 * all other helper and conversion functions.
 * 
 * @author 
 *
 */

public class Utils {

	public static Logger log = Logger.getLogger("Utils");

	/**
	 * Constant filename of application properties file.
	 */
	private static String config_path = "mdservice.properties";
	private static Properties  config;	


	/**
	 * Loads application configuration properties from filename in class constant config_path.
	 */
	public static void loadConfig() {
		loadConfig(config_path);
	}

	/**
	 * Loads application configuration properties from properties file configPath.
	 * 
	 * @param configPath - pathname string of java properties file.
	 */
	public static void loadConfig(String configPath) {
		
		System.setProperty("javax.xml.transform.TransformerFactory", "net.sf.saxon.TransformerFactoryImpl");
		InputStream config_file;
		 
		try {			
			config_file = Utils.class.getClassLoader().getResourceAsStream(configPath);
			if (config_file == null) {
			    log.error("CONFIGURATION ERROR: Properties file not found!");
			} else {
				log.debug("Reading configuration from: " + Utils.class.getClassLoader().getResource(configPath));
				config = new Properties();
				config.load(config_file);	
			}
			
		} catch (Exception e) {
			log.error("CONFIGURATION LOAD ERROR: " + e.getLocalizedMessage());
		} 
	}
	
	/**
	 * Returns application configuration properties.
	 * 
	 * @return
	 */
	public static Properties getConfig() {
		if (config==null)  {
			loadConfig(config_path);
		}
		return config;
	}
	
/**
 * convenience function to get a config property value
 * @param key
 * @return
 */
	public static String getConfig(String key) {
			return getConfig().getProperty(key);		
	}
	
	/**
	 * Creates error message string from exception data.
	 * 
	 * @param e - The exception object.
	 * @return
	 */
	public static String errorMessage(Exception e){
		String message = e.getStackTrace()[0].getFileName() + ":" + String.valueOf(e.getStackTrace()[0].getLineNumber()) + "  "+ e.getClass() + ": " + e.getLocalizedMessage();
		
		return message;
	}
	
	/**
	 * Creates error message string from error data.
	 * 
	 * @param e - The error object.
	 * @return
	 */
	public static String errorMessage(Error e){
		String message = e.getStackTrace()[0].getFileName() + ":" + String.valueOf(e.getStackTrace()[0].getLineNumber()) + "  "+ e.getClass() + ": " + e.getLocalizedMessage();
		
		return message;
	}
	
	/**
	 * Loads data from filename.
	 * 
	 * @param path
	 * @return
	 */
	public static InputStream load2Stream (String path) {
		
		InputStream file=null;
		 
		try {			
			file = Utils.class.getClassLoader().getResourceAsStream(path);
			if (file == null) {
			    log.error("File not found!: " + path);
			} else {
				log.debug("Reading in: " + Utils.class.getClassLoader().getResource(path));
			}
		}   catch (Exception e) {
			log.error(Utils.errorMessage(e));
		} 
		
		return file;
	}
	
	/**
	 * Writes data from stream to file.
	 * 
	 * @param path - The filename, where the data will be write.
	 * @param in - The InputStream to be written into file.
	 */
	public static File write2File (String path, InputStream in) {	
	try
	    {
			File f=new File(path);	    
		    OutputStream out=new FileOutputStream(f);
		    copyStreams(in,out);	    
		    out.close();	    
		    return f;
	    }
	    catch (Exception e){
	    	log.error(Utils.errorMessage(e));
	    }

	    return null;
	    
	}

	/**
	 * Loads data from file to XMLDocument.
	 * 
	 * @param path
	 * @return
	 */
	public static Document load2Document(String path)
	//public static Document readFSLS(String infile)
	{
		Document document = null;
		try {
		    DocumentBuilderFactory factory = 
		    DocumentBuilderFactory.newInstance();
		    DocumentBuilder builder = factory.newDocumentBuilder();
		    InputStream doc_is = load2Stream(path); 
		    document = builder.parse(doc_is);		    
		    
		}
		catch (FactoryConfigurationError e) {
		    // unable to get a document builder factory
			log.error(Utils.errorMessage(e));
		} 
		catch (ParserConfigurationException e) {
		    // parser was unable to be configured
			log.error(Utils.errorMessage(e));			
		}
		catch (IOException e) {
		    // i/o error
			log.error(Utils.errorMessage(e));			
		} catch (SAXException e) {
			log.error(Utils.errorMessage(e));
		}
		
		return document;
	}

	/**
	 * Copies inputstream in to outputstream out.
	 * 
	 * @param in
	 * @param out
	 * @throws IOException
	 * @throws InterruptedException
	 */
	public static void copyStreams (InputStream in, OutputStream out) throws IOException, InterruptedException {		
		
		byte[] buffer = new byte[1024];
		int len = in.read(buffer);
		while (len != -1) {
		    out.write(buffer, 0, len);
		    len = in.read(buffer);
		    if (Thread.interrupted()) {
		        throw new InterruptedException();
		    }
		}
	}	

	/**
	 * Converts stream to XML document.
	 * 
	 * @param is
	 * @return
	 */
	public static Document stream2Document(InputStream is){
	//public static Document getDocument(InputStream is){
		Document doc = null;
		DocumentBuilderFactory docFactory = DocumentBuilderFactory.newInstance();
     	DocumentBuilder docBuilder;
		try {
			docBuilder = docFactory.newDocumentBuilder();
			doc = docBuilder.parse(is);
		
		}catch (FactoryConfigurationError e) {
			    // unable to get a document builder factory
				log.error(Utils.errorMessage(e));
			} 
			catch (ParserConfigurationException e) {
			    // parser was unable to be configured
				log.error(Utils.errorMessage(e));			
			}
			catch (IOException e) {
			    // i/o error
				log.error(Utils.errorMessage(e));			
			} catch (SAXException e) {
				log.error(Utils.errorMessage(e));
			}
			
		return doc;
	}

	/**
	 * Returns string value  from XML stream  according to XPath expression. 
	 * 
	 * @param is
	 * @param expression
	 * @return
	 */
	public static String getXPathData(InputStream is, String expression){
	//public static String getDocumentData(InputStream is, String expression){
		String data = "";
	
		XPathFactory factory = XPathFactory.newInstance(); 
	    XPath xpath = factory.newXPath(); 
	    XPathExpression expr;
		try {
			expr = xpath.compile(expression);
			data = (String) expr.evaluate(stream2Document(is), XPathConstants.STRING);
		} catch (XPathExpressionException e) {
			log.error(Utils.errorMessage(e));	
		}
		        
		return data;
		
	}
	
	/**
	 * Creates simple XML document with given rootlement name.
	 * 
	 * @param rootelemname
	 * @return
	 */
	public static Document createDocument(String rootelemname){
		DocumentBuilderFactory docFactory = DocumentBuilderFactory.newInstance();
     	DocumentBuilder docBuilder;
     	Document doc = null;
		try {
			docBuilder = docFactory.newDocumentBuilder();
			doc = docBuilder.newDocument();
			// append root tag <index >
			Element root = (Element) doc.createElement(rootelemname);
			doc.appendChild(root);
		} catch (Exception e){
			log.error(Utils.errorMessage(e));	
		}
		return doc;
	}
	
	/**
	 * Converts stream to string.
	 * 
	 * @param is
	 * @return
	 */
	public  static String streamToString(InputStream is) {  
		
		BufferedReader reader = new BufferedReader(new InputStreamReader(is));  
		StringBuilder sb = new StringBuilder();  
		String line = null;  
		
		try {
			while ((line = reader.readLine()) != null) {  
			                 sb.append(line + "\n");  
			}
		} catch (IOException e) {
			log.error(Utils.errorMessage(e));
		}  finally {
			try {
				is.close();
			} catch (IOException e) {
				log.error(Utils.errorMessage(e));
			}
			try {
				is.reset();
			} catch (IOException e) {
				log.error(Utils.errorMessage(e));
			}
		}
		  
		
		return sb.toString();  
	}


	/**
	 * Converts XML document to stream.
	 * 
	 * @param node
	 * @return
	 * @throws TransformerConfigurationException
	 * @throws TransformerException
	 * @throws TransformerFactoryConfigurationError
	 */
	public static InputStream document2Stream(Node node) throws TransformerConfigurationException, TransformerException, TransformerFactoryConfigurationError{
		
		InputStream is = null;
		ByteArrayOutputStream outputStream = new ByteArrayOutputStream(); 
		Source xmlSource;
		
		try{
			//if (node == null) {
			//	xmlSource = new DOMSource(workspace_doc); 
			//} else {
				xmlSource = new DOMSource(node);
			//}
			Result outputTarget = new StreamResult(outputStream); 
			TransformerFactory.newInstance().newTransformer().transform(xmlSource, outputTarget); 
			is = new ByteArrayInputStream(outputStream.toByteArray()); 

		} catch (Exception e){
			log.error(Utils.errorMessage(e));
		}
		
		return is;
	}
	
	public static Document append2Document(Document sourcedoc,String parenttagname, Document appenddoc){

		Node r_element=  sourcedoc.getElementsByTagName(parenttagname).item(0);	
		Node d_element = appenddoc.getElementsByTagName("diagnostics").item(0);
		sourcedoc.adoptNode(d_element);
		r_element.appendChild(d_element);
		
		return sourcedoc;
	}
	public static void testJSON() {
		String str = "{'name':'JSON','integer':1,'double':2.0,'boolean':true,'nested':{'id':42},'array':[1,2,3]}";
		//Query q = new Query("dc.title=dino or dinosaur", Query.RECORDSET);
        JSON json = JSONSerializer.toJSON( str);  
        XMLSerializer xmlSerializer = new XMLSerializer();  
        String xml = xmlSerializer.write( json ); 
        log.debug(xml);
	}

}


