package mpi.eudico.webserviceclient.typecraft;

import java.io.IOException;
import java.io.StringReader;
import java.util.ArrayList;
import java.util.List;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.parsers.SAXParserFactory;

import mpi.eudico.server.corpora.util.ServerLogger;

import org.xml.sax.Attributes;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.DefaultHandler;

/**
 * A parser for the XML export format of TypeCraft (www.typecraft.org).
 * 
 * @author Han Sloetjes
 */
public class TCParser extends DefaultHandler {
	// parser
	private List<PhraseRecord> phraseRecords;
	private TextRecord textRecord;
	
	// content handler
	private StringBuilder content = new StringBuilder();
	PhraseRecord curPhrase;
	WordRecord curWord;
	MorphRecord curMorph;
	// content
	private String inputContent;
	
	/**
	 * @param inputContent the xml as string
	 */
	public TCParser(String inputContent) {
		this.inputContent = inputContent;
	}
	
	/**
	 * Parses the contents of the string.
	 * 
	 * @throws SAXException any SAX parse exception
	 * @throws IOException any IO exception
	 */
	public void parse() throws SAXException, IOException {
		if (inputContent == null) {
			return;// throw exception
		}
		phraseRecords = new ArrayList<PhraseRecord>();
		
        try {          
	   		SAXParserFactory parserFactory = SAXParserFactory.newInstance();
	   		parserFactory.setNamespaceAware(false);
	   		parserFactory.setValidating(false);
	   		parserFactory.newSAXParser().parse(new InputSource(new StringReader(inputContent)), this);
        } catch (SAXException se) {
        	//se.printStackTrace();
        	ServerLogger.LOG.warning("Parser exception: " + se.getMessage());
        	throw se;
        } catch (IOException ioe) {
        	//ioe.printStackTrace();
        	ServerLogger.LOG.warning("IO exception: " + ioe.getMessage());
        	throw ioe;
        } catch (ParserConfigurationException pce) {
        	ServerLogger.LOG.warning("Parser configuration exception: " + pce.getMessage());
			throw new SAXException(pce);
		}
	}

	/**
	 * @return the phrase records
	 */
	public List<PhraseRecord> getPhraseRecords() {
		return phraseRecords;
	}
	
	/**
	 * Returns the text record 
	 * @return the text record or {@code null}
	 */
	public TextRecord getTextRecord() {
		return textRecord;
	}
	
	/**
	 * Retrieves the long value of a string
	 * @param longString the input string
	 * @return a long value, 0 in case the string could not be parsed
	 */
	private long parseLong(String longString) {
		if (longString == null) {
			return 0;
		}
		try {
			return Long.parseLong(longString);
		} catch (NumberFormatException nfe) {}
		
		return 0;
	}
	
	@Override
	public void startElement(String uri, String localName, String qName,
            Attributes atts) throws SAXException {
		
		if (qName.equals("phrase")) {
			// create a new top level annotation
			curPhrase = new PhraseRecord();
			curPhrase.id = atts.getValue("id");
			curPhrase.valid = atts.getValue("valid");
			curPhrase.speaker = atts.getValue("speaker");// can be null
			long bt = parseLong(atts.getValue("offset"));
			long dur = parseLong(atts.getValue("duration"));
			if (! (bt == 0 && dur == 0)) {
				curPhrase.bt = bt;
				curPhrase.et = bt + dur;
			}
		} /*else if (qName.equals("original")) {
			// add text to phrase
		} else if (qName.equals("translation")) {
			// add sym as annotation to phrase
		} else if (qName.equals("description")) {
			
		} */else if (qName.equals("word")) {
			curWord = new WordRecord();
			curWord.text = atts.getValue("text");
			curWord.head = atts.getValue("head");
		} /*else if (qName.equals("pos")) {
			
		} */else if (qName.equals("morpheme")) {
			curMorph = new MorphRecord();
			curMorph.text = atts.getValue("text");
			curMorph.baseform = atts.getValue("baseform");
			curMorph.meaning = atts.getValue("meaning");
		} /*else if (qName.equals("gloss")) {
			
		} */else if (qName.equals("text")) {
			textRecord = new TextRecord();
			textRecord.id = atts.getValue("id");
			textRecord.lang = atts.getValue("lang");
		} /*else if (qName.equals("title")) {
			
		} else if (qName.equals("titleTranslation")) {
			
		} else if (qName.equals("body")) {
			
		} */else if (qName.equals("globaltags")) {
			
		} else if (qName.equals("globaltag")) {
			
		}

	}
	
	@Override
	public void characters(char[] ch, int start, int length) throws SAXException {
		content.append(ch, start, length);
	}
	
	@Override
	public void endElement(String uri, String localName, String qName)
			throws SAXException {
		if (qName.equals("phrase")) {
			// add the record
			phraseRecords.add(curPhrase);
		} else if (qName.equals("original")) {
			// add text to phrase
			curPhrase.text = content.toString().trim();
		} else if (qName.equals("translation")) {
			// add sym as annotation to phrase
			curPhrase.translation = content.toString().trim();
		} else if (qName.equals("description")) {
			curPhrase.description = content.toString().trim();
		} else if (qName.equals("word")) {
			curPhrase.wordRecords.add(curWord);
		} else if (qName.equals("pos")) {
			curWord.pos = content.toString().trim();
		} else if (qName.equals("morpheme")) {
			curWord.morphs.add(curMorph);
		} else if (qName.equals("gloss")) {
			curMorph.glosses.add(content.toString().trim());
		} /*else if (qName.equals("text")) {
			
		} */else if (qName.equals("title")) {
			textRecord.title = content.toString().trim();
		} else if (qName.equals("titleTranslation")) {
			textRecord.titleTrans = content.toString().trim();
		} else if (qName.equals("body")) {
			textRecord.body = content.toString().trim();
		} else if (qName.equals("globaltags")) {
			
		} else if (qName.equals("globaltag")) {
			
		}
		// reset the content
		content.delete(0, content.length());
	}
}
