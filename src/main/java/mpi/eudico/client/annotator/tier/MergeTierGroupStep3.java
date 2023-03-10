package mpi.eudico.client.annotator.tier;

import mpi.eudico.client.annotator.ElanLocale;
import mpi.eudico.client.annotator.commands.ELANCommandFactory;
import mpi.eudico.client.annotator.commands.MergeTierGroupCommand;
import mpi.eudico.client.annotator.gui.multistep.MultiStepPane;
import mpi.eudico.client.annotator.util.ProgressListener;
import mpi.eudico.server.corpora.clom.Transcription;



/**
 * The final step, the actual merge action.  A command is created and this pane
 * is connected as progress listener. The UI is a progress monitor.
 *
 * @author Han Sloetjes
 * @version 1.0 Nov 2009
 */
@SuppressWarnings("serial")
public class MergeTierGroupStep3 extends CalcOverlapsStep3 implements ProgressListener {
	private MergeTierGroupCommand com;

    /**
     * Constructor.
     *
     * @param multiPane the container pane
     * @param transcription the transcription
     */
    public MergeTierGroupStep3(MultiStepPane multiPane,
        Transcription transcription) {
        super(multiPane, transcription);

        //initComponents();
    }

    @Override
	public String getStepTitle() {
        return ElanLocale.getString("OverlapsDialog.MergingGroups");
    }

    /**
     * Calls doFinish.
	 */
	@Override
	public void enterStepForward() {
		doFinish();
	}

	/**
     * Creates a command, registers as listener and starts it on a new thread.
     * 
     * @return {@code false}
     */
    @Override
	public boolean doFinish() {
        // disable buttons
        multiPane.setButtonEnabled(MultiStepPane.ALL_BUTTONS, false);

        String tierName1 = (String) multiPane.getStepProperty("Source-1");
        String tierName2 = (String) multiPane.getStepProperty("Source-2");
        String destTierSuffix = (String) multiPane.getStepProperty("Suffix");
        
        if ((tierName1 == null) || (tierName2 == null) || (destTierSuffix == null)) {
            progressInterrupted(null,
                "Illegal argument: a tier could not be found");
        }

        // create a command and connect as listener
        
        com = (MergeTierGroupCommand) ELANCommandFactory.createCommand(transcription,
                ELANCommandFactory.MERGE_TIER_GROUP);
        com.addProgressListener(this);
        com.execute(transcription,
            new Object[] {
                tierName1, tierName2, destTierSuffix
            });
	
        return false;
    }

}
