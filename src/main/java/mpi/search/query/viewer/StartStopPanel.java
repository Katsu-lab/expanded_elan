package mpi.search.query.viewer;

import java.awt.CardLayout;
import java.awt.Color;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;

import javax.swing.Action;
import javax.swing.JButton;
import javax.swing.JPanel;

import mpi.search.SearchLocale;


/**
 * Panel with two or three buttons; a start or a stop button in card layout
 * (and optionally a close button) are shown. 
 *
 * @author Alexander Klassmann
 * @version Oct 5, 2004
 */
@SuppressWarnings("serial")
public class StartStopPanel extends JPanel {
    /** To change between start- and stop-Button. */
    private final CardLayout startPanelLayout = new CardLayout(0, 0);

    /** Panel that contains all three buttons. */
    private final JPanel buttonPanel;

    /** Panel to contain a start- and a stop-button. */
    private final JPanel startStopPlaceHolderPanel = new JPanel(startPanelLayout);

    /**
     * Constructor
     *
     * @param startAction the start search action
     * @param stopAction the cancel search action
     */
    public StartStopPanel(final Action startAction, final Action stopAction) {
        this(startAction, stopAction, new Action[0]);
    }

    /**
     * Creates a new StartStopPanel object.
     *
     * @param startAction the start search action
     * @param stopAction the cancel search action
     * @param closeAction the close search window action
     */
    public StartStopPanel(final Action startAction, final Action stopAction,
        final Action closeAction) {
        this(startAction, stopAction, new Action[] { closeAction });
    }

    /**
     * Constructor
     *
     * @param startAction the start search action
     * @param stopAction the cancel search action
     * @param furtherActions some further actions, rendered in the same way
     *        (printing, etc.)
     */
    public StartStopPanel(final Action startAction, final Action stopAction,
        final Action[] furtherActions) {
//    	startAction.putValue(Action.SMALL_ICON, null);
//    	stopAction.putValue(Action.SMALL_ICON, null);
        JButton startButton = new JButton(startAction);
        startButton.setText(SearchLocale.getString("Button.Search"));
        startButton.setIcon(null);
        startStopPlaceHolderPanel.add("SearchButton", startButton);

        JButton stopButton = new JButton(stopAction);
        stopButton.setText(SearchLocale.getString("Button.Cancel"));
        stopButton.setIcon(null);
        startStopPlaceHolderPanel.add("StopButton", stopButton);

        buttonPanel = new JPanel(new GridBagLayout());

        GridBagConstraints c = new GridBagConstraints();
        c.fill = GridBagConstraints.BOTH;
        c.insets = new Insets(0, 2, 0, 2);
        c.ipady = 2;
        buttonPanel.add(startStopPlaceHolderPanel, c);

        for (int i = 0; i < furtherActions.length; i++) {
            JButton button = new JButton(furtherActions[i]);
            buttonPanel.add(button, c);
        }

        //enclosing panel needed to avoid resizing of the buttons!
        add(buttonPanel);
    }

    /**
     * Sets the background color of the panel and child panels.
     * 
     * @param color the new background color
     */
    public final void setBackgroundColor(final Color color) {
        buttonPanel.setBackground(color);
        startStopPlaceHolderPanel.setBackground(color);
        super.setBackground(color);
    }

    /**
     * Sets the opaque flag of the panel and subcomponents
     * 
     * @param isOpaque the new opaque flag for the panel and subcomponents
     * 
     */
    @Override
	public void setOpaque(boolean isOpaque) {
    	if (buttonPanel != null) {
    		buttonPanel.setOpaque(isOpaque);
    	}
    	if (startStopPlaceHolderPanel != null) {
    		startStopPlaceHolderPanel.setOpaque(isOpaque);
    	}
		super.setOpaque(isOpaque);
	}

	/**
     * Shows start button.
     */
    public final void showStartButton() {
        startPanelLayout.first(startStopPlaceHolderPanel);
    }

    /**
     * Shows stop button.
     */
    public final void showStopButton() {
        startPanelLayout.last(startStopPlaceHolderPanel);
    }
}
