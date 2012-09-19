package eu.clarin.cmdi.smc;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.net.URLConnection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;
//import org.apache.commons.configuration.Configuration;
//import org.apache.commons.lang.exception.NestableException;
//import org.apache.commons.configuration.ConfigurationException;
//import org.apache.commons.configuration.PropertiesConfiguration;
//



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
	private static String appname="smc"; 
	
	public SMC () {
		//Utils.loadConfig("smc.properties");
		
		this.configure();
		this.addParam("cache_dir", "file:/" + Utils.getConfig("cache.dir"));
		//this.addParam("cache_dir", config.getString("cache.dir"));
		
	}
	private Map<String,String[]> params;
	
	public static Logger log = Logger.getLogger("SMC");
	
	
	public static void main(String[] args) {
			
		SMC smc = new SMC();

		
		smc.init();		
		
		//InputStream is = smc.listTerms("isocat");
		//InputStream is = smc.map("nome do projecto");
		//String output_path = Utils.getConfig("cache.dir") +  "test_res_map.xml" ;		
		//File f = Utils.write2File(output_path, is);
		//log.debug("result stored in: " + f.getAbsolutePath());

	}

	public void configure(){
		Utils.loadConfig(appname, "smc.properties", this.getClass().getClassLoader());
	}
	public void configure(String configPath) {
		try {
			Utils.loadConfig(appname, configPath, this.getClass().getClassLoader());
			
			//config = new PropertiesConfiguration("smc.properties");
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
/**
 * load data from registries based on configuration
 * transform and store as local xml in cache.dir  
 */
	public void init () {
		
		
//		init_step ("cmd-profiles-raw");
//		don't do this! it is too big
		//init_step ("cmd-resolved");
		//init_step ("cmd-terms");
		init_step ("cmd-terms-nested");
		//init_step ("dcr-terms");
		//init_step ("isocat-languages");
		//init_step ("termsets");
		// init_step ("dcr-cmd-map");
		//init_step ("rr-relations");
		//init_step ("rr-terms");

	}
		 
	public void init_step (String data_key) {	
		InputStream is =null;
		is = Utils.load2Stream(Utils.getConfig("termsets.config.file"),this.getClass().getClassLoader());
		//is = Utils.load2Stream(config.getString("termsets.config.file"));
		
		
		MDTransformer transformer = new MDTransformer();
		transformer.configure(Utils.getAppConfig(appname), this.getClass().getClassLoader());
		
		// set URL as srcFile (for MDTransformer to pass to xsl-scripts)
		// TODO: WHY??
		//transformer.setSrcFile(Utils.getConfig("termsets.config.file"));
		addParam("data_key", data_key);
		//we want to refill the cache:
		//addParam("cache", "skip");
		//addParam("data_key", "cmd-terms");

		// this is necessary for the transformer (in MDUTILS-library) to search for the resources (config and xsls) in the correct context)
		//transformer.configure(Utils.getConfig(), this.getClass().getClassLoader());
		
		transformer.setParams(getParams());		
		transformer.setTranskey("init");
		// here the transformation is invoked
		InputStream resultStream;
		try {
			resultStream = transformer.transformXML(is);

			// store the result in the cache
			String output_path = Utils.getConfig("cache.dir") +  getParam("data_key") + ".xml" ;		
			//String output_path = config.getString("cache.dir") +  getParam("data_key") + ".xml" ;
			File f = Utils.write2File(output_path, resultStream);
			log.debug("SMC.init(" + getParam("data_key") + "): result stored in: " + f.getAbsolutePath());

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
	private Map<String,String[]> getParams() {
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
	private String getParam(String key) {
		String v = "";
		if (!(getParams().get(key)==null)) v=(String)getParams().get(key)[0];
		return v;
	}

	private static InputStream getStream(String uri, String rep) throws IOException
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

	
	
	private static void test() {
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
	
	/** 
	 * list termsets 
	 * @param context internal key(?) of the context set to start from; '*' or 'top' or '' for default top-level list
	 * @return stream with XML listing the available termsets
	 */
	public InputStream listTermsets(String context) {		
		InputStream is =null;
		is = Utils.load2Stream(Utils.getConfig("termsets.config.file").trim(), this.getClass().getClassLoader());
		return is;
	}
	
	/**
	 * list terms of a set
	 * @param context
	 * @return
	 */	
	public InputStream listTerms(String context) {
		 
		InputStream is =null;
		is = Utils.load2Stream(Utils.getConfig("termsets.config.file"),this.getClass().getClassLoader());
		
		MDTransformer transformer = new MDTransformer();
		// this is necessary for the transformer (in MDUTILS-library) to search for the resources (config and xsls) in the correct context)
		transformer.configure(Utils.getAppConfig(appname), this.getClass().getClassLoader());
		
		// set URL as srcFile (for MDTransformer to pass to xsl-scripts)
		// TODO: WHY??
		//transformer.setSrcFile(Utils.getConfig("termsets.config.file"));
		
		addParam("operation", "list");
		addParam("context", context);
		addParam("term", "*");
		 
		transformer.setParams(getParams());		
		transformer.setTranskey("list");

		InputStream resultStream=null;
		try {
			resultStream = transformer.transformXML(is);

		} catch (IOException e1) {
			log.debug(Utils.errorMessage(e1));
		} catch (InterruptedException e1) {
			log.debug(Utils.errorMessage(e1));
		} catch (TransformerException e1) {		
			log.debug(Utils.errorMessage(e1));
		} catch (NoStylesheetException e1) {
			log.debug(Utils.errorMessage(e1));
		}
		
		return resultStream;
	}
	
	/**
	 *  map from source term to target-terms 
	 * @param term
	 * @return
	 */
	public InputStream map(String term) {
		 
		InputStream is =null;
		is = Utils.load2Stream(Utils.getConfig("termsets.config.file"),this.getClass().getClassLoader());
		
		MDTransformer transformer = new MDTransformer();
		// this is necessary for the transformer (in MDUTILS-library) to search for the resources (config and xsls) in the correct context)
		transformer.configure(Utils.getAppConfig(appname), this.getClass().getClassLoader());
		
		log.debug("term: " + term);
		addParam("operation", "map");
		addParam("term", term);
		 
		transformer.setParams(getParams());		
		transformer.setTranskey("map");

		InputStream resultStream=null;
		try {
			resultStream = transformer.transformXML(is);

		} catch (IOException e1) {
			log.debug(Utils.errorMessage(e1));
		} catch (InterruptedException e1) {
			log.debug(Utils.errorMessage(e1));
		} catch (TransformerException e1) {		
			log.debug(Utils.errorMessage(e1));
		} catch (NoStylesheetException e1) {
			log.debug(Utils.errorMessage(e1));
		}
		
		return resultStream;
	}
	
}
