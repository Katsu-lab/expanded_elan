package mpi.search.result.viewer;
/**
 * A counter for search matches.
 * 
 * @author klasal
 * @version May 3, 2005
 */

import javax.swing.JLabel;

import mpi.search.result.model.Result;
import mpi.search.result.model.ResultChangeListener;
import mpi.search.result.model.ResultEvent;

@SuppressWarnings("serial")
public class MatchCounter extends JLabel implements ResultChangeListener{
    protected Result result;

   /**
     * Notification of a change in the results.
     * 
     * @param e the event
     */
    @Override
	public void resultChanged(ResultEvent e) {
        setResult((Result) e.getSource());
    }

    /**
     * Sets the results for the counter.
     * 
     * @param result the results
     */
    public void setResult(Result result) {
        this.result = result;
        render();
    }
    
    /**
     * Renders the result count.
     */
    public void render(){
        setText(result.getRealSize() + " matches");
    }
     
}
