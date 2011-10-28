package eu.clarin.cmdi.smc;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;
import java.util.HashMap;
import java.util.Map;

import javax.xml.transform.TransformerException;

import org.apache.log4j.Logger;

import eu.clarin.cmdi.mdservice.internal.MDTransformer;
import eu.clarin.cmdi.mdservice.internal.NoStylesheetException;
import eu.clarin.cmdi.mdservice.internal.Utils;

/** 
 * some of the generic stuff (getStream, getParams, addParam ...) taken from mdservice.GenericAction
 * @author m
 *
 */
public class SMC {
	
	private Map<String,String[]> params;
	
	public static Logger log = Logger.getLogger("SMC");
	
	public static void main(String[] args) {
	
		Utils.loadConfig("smc.properties");
		SMC smc = new SMC();
		smc.addParam("operation", "cmd-terms");
		smc.addParam("cache_dir", Utils.getConfig("cache.dir"));
		smc.init();

	}

/**
 * load data from registries based on configuration
 * transform and store as local xml in cache.dir  
 */
	public void init () {
 
		InputStream is =null;
		is = Utils.load2Stream(Utils.getConfig("termsets.config.file"));
		
		MDTransformer transformer = new MDTransformer();
		// set URL as srcFile (for MDTransformer to pass to xsl-scripts)
		// TODO: WHY??
		//transformer.setSrcFile(Utils.getConfig("termsets.config.file"));
		transformer.setParams(getParams());
		
		transformer.setTranskey("init");
		// here the transformation is invoked
		InputStream resultStream;
		try {
			resultStream = transformer.transformXML(is);

			// store the result in the cache
			String output_path = Utils.getConfig("cache.dir") +  getParam("operation") + ".xml" ;		
			File f = Utils.write2File(output_path, resultStream);
			log.debug("result stored in: " + f.getAbsolutePath());

		} catch (IOException e1) {
			log.debug(Utils.errorMessage(e1));
		} catch (InterruptedException e1) {
			log.debug(Utils.errorMessage(e1));
		} catch (TransformerException e1) {		
			log.debug(Utils.errorMessage(e1));
		} catch (NoStylesheetException e1) {
			log.debug(Utils.errorMessage(e1));
		}
		
	}

	/**
	 * Gets the local parameter map.
	 * 
	 * @return
	 */
	public Map<String,String[]> getParams() {
		if (params == null) {
			params = new HashMap<String,String[]>();
		}
		return params;
	}
	
	/**
	 * Add parameter into local parameter map.
	 * 
	 * @param key - parameter key
	 * @param value - parameter value
	 */
	public void addParam(String key, String value){
		String[] sarr = new String[1];
		sarr[0] = value;
		getParams().put(key, sarr);	
	}

	/**
	 * This is for simplified access to the the values of the request-parameters 
	 * They are stored in the parameters-map as a String-array, 
	 * but in most(?) situations, we expect just a simple string. 
	 * @param key
	 * @return
	 */
	public String getParam(String key) {
		String v = "";
		if (!(getParams().get(key)==null)) v=(String)getParams().get(key)[0];
		return v;
	}

	public static InputStream getStream(String uri, String rep) throws IOException
	{
		
		URL url = new URL(uri);
		URLConnection urlConnection = url.openConnection();
		
		if (rep.equals("rdf")) {
			urlConnection.setRequestProperty("Accept", "application/rdf+xml");
		}
		if (rep.equals("dcif")) {		
			urlConnection.setRequestProperty("Accept", "application/dcif+xml");			
		}
        //urlConnection.setRequestProperty("Accept-Language", getLang());
        
	 	InputStream resultStream = urlConnection.getInputStream();
		
        return resultStream;    
	}

	
	
	public static void test() {
		//String uri = "http://www.isocat.org/rest/profile/5";
		String uri = "http://www.isocat.org/rest/user/guest/search?keywords=chinese"; 
		String output_path = "C:/Users/m/3lingua/clarin/CMDI/SMC/output/isocat_search.dcif.xml";
				
		try {
			File f = Utils.write2File(output_path, getStream(uri,"dcif"));
			System.out.print(f.getAbsolutePath());
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}
}
