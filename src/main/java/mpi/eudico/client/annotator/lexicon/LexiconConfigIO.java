package mpi.eudico.client.annotator.lexicon;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.parsers.SAXParserFactory;

import org.w3c.dom.DOMException;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.xml.sax.Attributes;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.DefaultHandler;


import mpi.eudico.client.annotator.Constants;
import static mpi.eudico.client.annotator.util.ClientLogger.LOG;
import mpi.eudico.server.corpora.lexicon.LexicalEntryFieldIdentification;
import mpi.eudico.server.corpora.lexicon.LexiconIdentification;
import mpi.eudico.server.corpora.lexicon.LexiconLink;
import mpi.eudico.server.corpora.lexicon.LexiconQueryBundle2;
import mpi.eudico.util.IoUtil;

/**
 * Writes and reads lexicon service and service clients configurations.
 * As a convenience, making reuse of definitions possible. 
 * 
 * @author Han Sloetjes
 */
public class LexiconConfigIO {
	private final String lexDir = Constants.ELAN_DATA_DIR + File.separator + "Lexicon";
	private final String lexFile = "LexiconConfig.xml";

	/**
	 * Constructor does nothing.
	 */
	public LexiconConfigIO() {
		super();
	}

	/**
	 * Writes the references to a simple XML file. The elements are the same as used in EAF.
	 * 
	 * @param linkBundle a list of lexicon references
	 */
	public void writeLexConfigs(List<LexiconQueryBundle2> linkBundle) {
		if(linkBundle != null) {
			try {
				DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
				DocumentBuilder db = dbf.newDocumentBuilder();
	            Document doc = db.newDocument();
	            Element root = doc.createElement("LEXICON_REFS");
	            // set attributes??
	            doc.appendChild(root);
	            
	            int index = 1;
	            for (LexiconQueryBundle2 bundle : linkBundle) {
	            	try {
		            	Element lexRef = doc.createElement("LEXICON_REF");
		            	lexRef.setAttribute("LEX_REF_ID", ("lr" + index));
		            	lexRef.setAttribute("TYPE", bundle.getLink().getLexSrvcClntType());
		            	lexRef.setAttribute("URL", bundle.getLink().getUrl());
		            	lexRef.setAttribute("LEXICON_ID", bundle.getLink().getLexId().getId());
		            	lexRef.setAttribute("LEXICON_NAME", bundle.getLink().getLexId().getName());
		        		if (bundle.getFldId() != null) {
		        			if (bundle.getFldId().getId() != null) {
		        				lexRef.setAttribute("DATCAT_ID", bundle.getFldId().getId());
		        			}
		        			if (bundle.getFldId().getName() != null) {
		        				lexRef.setAttribute("DATCAT_NAME", bundle.getFldId().getName());
		        			}
		        		}
		        		lexRef.setAttribute("NAME", bundle.getLink().getName());
		        		root.appendChild(lexRef);
		        		index++;
	            	} catch (DOMException dec) {
	            		// skip this element
	            		LOG.warning("Cannot add LEXICON_REF element: " + dec.getMessage());
	            	}
	            }
	            
				// write the file
				String path = lexDir + File.separator + lexFile;
		        try {
		        	File f = new File(lexDir);
		        	if (!f.exists()) {
		        		if (!f.mkdir()) {
		        			LOG.info("Could not create directory: " + lexDir);
		        		}
		        	}
		        	LOG.info("Writing lexicon references: " + path);
		            IoUtil.writeEncodedFile("UTF-8", path, root);
		        } catch (IOException ioe) {
		        	LOG.severe("Could not save the lexicon references xml file to: " + path +
		                "\n" + " Cause: " + ioe.getMessage());
		        } catch (Exception e) {
		        	LOG.severe("Could not save the lexicon references xml file to: " + path +
		                "\n" + " Cause: " + e.getMessage());
		        }
		        
			} catch (ParserConfigurationException pce) {
				LOG.warning("Cannot create an XML Document Builder: " + pce.getMessage());
			} catch (DOMException dom) {
				LOG.warning("Cannot create the root element for the XML file: " + dom.getMessage());
			}			

		} else {
			// delete the file??
		}
	}
	
	/**
	 * Read the lexicon references from the cache file.
	 *  
	 * @return a list of lexicon references
	 */
	public List<LexiconQueryBundle2> readLexConfigs() {
		String path = lexDir + File.separator + lexFile;
		File lexFile = new File(path);
		if (lexFile.exists() && lexFile.canRead()) {
			try {
				LexRefHandler handler = new LexRefHandler();

				SAXParserFactory parserFactory = SAXParserFactory.newInstance();
				parserFactory.setNamespaceAware(true);
				parserFactory.setValidating(false);
				parserFactory.newSAXParser().parse(lexFile, handler);
				return handler.getBundles();
			} catch (SAXException se) {
				LOG.warning("Cannot parse the lexicon references file: " + se.getMessage());
			} catch (IOException ioe) {
				LOG.warning("Cannot parse the lexicon references file: " + ioe.getMessage());
			} catch (ParserConfigurationException pce) {
				LOG.warning("Cannot parse the lexicon references file: " + pce.getMessage());
			}
			
		}
		
		return new ArrayList<LexiconQueryBundle2>(1);
	}
	
	/**
	 * The content handler, creates the LexiconQueryBundle objects.
	 * 
	 * @author Han Sloetjes
	 */
	class LexRefHandler extends DefaultHandler {
		private List<LexiconQueryBundle2> bundles;
		
		LexRefHandler() {
			bundles = new ArrayList<LexiconQueryBundle2>();
		}
		
		List<LexiconQueryBundle2> getBundles() {
			return bundles;
		}

		@Override
		public void startElement(String arg0, String name, String rawName,
				Attributes attributes) throws SAXException {
			if (name.equals("LEXICON_REF")) {
    			//String lexiconSrvcRef = attributes.getValue("LEX_REF_ID");	// Ref of LexiconQueryBundle
    			String lexiconClientName = attributes.getValue("NAME");		// Name of LexiconClientService
    			String lexiconSrvcType = attributes.getValue("TYPE");		// Type of LexiconClientService
    			String lexiconSrvcUrl = attributes.getValue("URL");			// URL of LexiconClientService
    			String lexiconSrvcId = attributes.getValue("LEXICON_ID");	// ID of Lexicon
    			String lexiconSrvcName = attributes.getValue("LEXICON_NAME");	// Name of Lexicon
    			
    			if (lexiconClientName != null && lexiconSrvcType != null) {
    				LexiconIdentification li = new LexiconIdentification(lexiconSrvcId, lexiconSrvcName);
    				LexiconLink link = new LexiconLink(lexiconClientName, 
    						lexiconSrvcType, lexiconSrvcUrl, 
    						null, li);
    				LexicalEntryFieldIdentification fldId = null;
        			String dataCategory = attributes.getValue("DATCAT_NAME");	// Name of LexicalEntryField
        			String dataCategoryId = attributes.getValue("DATCAT_ID");	// ID of LexicalEntryField
    				if (dataCategory != null) {
    					fldId = new LexicalEntryFieldIdentification(dataCategoryId, dataCategory);
    				}
        			
        			LexiconQueryBundle2 bundle = new LexiconQueryBundle2(link, fldId);
        			bundles.add(bundle);
    			} else {
    				return;
    			}
			}
		}
	}
	
}
