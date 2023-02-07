// Added by Katsuya Fukuoka 2022/12/20
package mpi.eudico.client.annotator.commands.global;

import java.awt.event.ActionEvent;

import mpi.eudico.client.annotator.ElanFrame2;

@SuppressWarnings("serial")
public class OpenMenuMA extends FrameMenuAction {

    public OpenMenuMA(String name, ElanFrame2 frame) {
        super(name, frame);
    }

    @Override
	public void actionPerformed(ActionEvent e) {

        ProcessBuilder processBuilder = new ProcessBuilder();
         processBuilder.command("/Users/FukuokaKatsuya/Documents/Systems/analysis-platform-python/serve.sh");

        try {
            Process process = processBuilder.start();
        } catch (Exception error) {
            error.printStackTrace();
        }
    }
}