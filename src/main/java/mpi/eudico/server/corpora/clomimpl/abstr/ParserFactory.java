/*
 * Created on Jun 4, 2004
 */
package mpi.eudico.server.corpora.clomimpl.abstr;

import mpi.eudico.server.corpora.clomimpl.chat.CHATParser;
//import mpi.eudico.server.corpora.clomimpl.cgn2acm.CGN2ACMParser;
import mpi.eudico.server.corpora.clomimpl.delimitedtext.DelimitedTextParser;
import mpi.eudico.server.corpora.clomimpl.dobes.EAF26Parser;
import mpi.eudico.server.corpora.clomimpl.dobes.EAF27Parser;
import mpi.eudico.server.corpora.clomimpl.dobes.EAF28Parser;
import mpi.eudico.server.corpora.clomimpl.dobes.EAF30Parser;
import mpi.eudico.server.corpora.clomimpl.flex.FlexParser;
import mpi.eudico.server.corpora.clomimpl.json.JSONWAParser;
import mpi.eudico.server.corpora.clomimpl.shoebox.ShoeboxParser;
import mpi.eudico.server.corpora.clomimpl.shoebox.ToolboxParser;
import mpi.eudico.server.corpora.clomimpl.subtitletext.SubtitleTextParser;
import mpi.eudico.server.corpora.clomimpl.transcriber.Transcriber14Parser;

/**
 * @author hennie
 *
 * @version Dec 2006: constant for EAF24 added
 * @version Nov 2007 constant for EAF25 and CSV (tab-delimited text) added
 * @version May 2008 constant for EAF26 added
 */
public class ParserFactory {
	/** constants for a number of known formats, formats for which a parser 
	 can be obtained through this factory */
	public static final int EAF21 = 0;
	public static final int CHAT = 1;
	public static final int SHOEBOX = 2;
	public static final int TRANSCRIBER = 3;
	public static final int CGN = 4;
	public static final int WAC = 5;
	public static final int EAF22 = 6;
	public static final int EAF23 = 7;
	public static final int EAF24 = 8;
	public static final int EAF25 = 9;
	public static final int CSV = 10;
	public static final int EAF26 = 11;
	public static final int TOOLBOX = 12;
	public static final int FLEX = 13;
	public static final int EAF27 = 14;
	public static final int EAF28 = 15;
	public static final int EAF30 = 16;
	public static final int SUBTITLE = 17;
	public static final int JSON = 18;// generic JSON
	public static final int JSON_WA = 19; // WebAnnotation JSON 
	
	/**
	 * 
	 * @param parserCode the format to get a parser for, one of the constants
	 * of this class
	 * @return a parser for the specified format or {@code null}
	 */
	public static Parser getParser(int parserCode) {
		switch (parserCode) {
		case CHAT:
			return new CHATParser();
		case SHOEBOX:
			return new ShoeboxParser();
		case TRANSCRIBER:
			return new Transcriber14Parser();
		case CGN: {
			//done this way to avoid explicit dependencies!
			Parser parser = null;
			try{
				parser = (Parser) Class.forName("mpi.eudico.server.corpora.clomimpl.cgn2acm.CGN2ACMParser").newInstance();
			}
			catch(Exception e){
				e.printStackTrace();
			}
			return parser;
		}
		case CSV:
			return new DelimitedTextParser();
		case EAF21:// fall through
		case EAF22:
		case EAF23:
		case EAF24:
		case EAF25:
		case EAF26:
			return new EAF26Parser();
		case TOOLBOX:
			return new ToolboxParser();
		case FLEX:
			return new FlexParser();
		case EAF27:
			return new EAF27Parser();
		case EAF28:
			return new EAF28Parser();
		case EAF30:
			return new EAF30Parser();
		case SUBTITLE:
			return new SubtitleTextParser();
		case JSON: //fall through for now
		case JSON_WA:
			return new JSONWAParser();
		default:
			// by default return the latest EAF parser
			return new EAF30Parser();
		}		
	}
}
