package org.jpacman.undo;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.JButton;

import org.jpacman.framework.ui.ButtonPanel;

@SuppressWarnings("serial")
public class UndoButtonPanel extends ButtonPanel {

	@Override
	public void initialize() {
		super.initialize();
		JButton undoButton = createUndoButton();
		addButton(undoButton);

	}

	protected JButton createUndoButton() {
		JButton undoButton = new JButton("Undo");
		undoButton.addActionListener(new ActionListener() {
			@Override
			public void actionPerformed(ActionEvent e) {
				pause();
				UndoablePacman.undo();
			}
		});
		return undoButton;
	}
}
