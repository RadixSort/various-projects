package org.jpacman.undo;

import org.jpacman.framework.factory.FactoryException;
import org.jpacman.framework.model.IGameInteractor;
import org.jpacman.framework.ui.ButtonPanel;
import org.jpacman.framework.ui.MainUI;
import org.jpacman.framework.ui.PacmanInteraction;

@SuppressWarnings("serial")
public class UndoablePacman extends MainUI {

	private UndoButtonPanel buttonPanel;

	public static void undo() {
		if (!UndoableDefaultGameFactory.theGame.won()) {
			UndoableDefaultGameFactory.theGame.undo();
		}
	}

	public UndoablePacman() {

		super();
		setupFactory();
	}

	private void setupFactory() {
		UndoableDefaultGameFactory fact = new UndoableDefaultGameFactory();
		super.withFactory(fact);
	}

	@Override
	public IGameInteractor getGame() {
		return super.getGame();
	}

	@Override
	protected ButtonPanel createButtonPanel(PacmanInteraction pi) {
		assert pi != null;
		if (buttonPanel == null) {
			buttonPanel = new UndoButtonPanel();
			super.withButtonPanel(buttonPanel);
		}
		return buttonPanel.withParent(this).withInteractor(pi);
	}

	public static void main(String[] args) throws FactoryException {
		new UndoablePacman().main();
	}

}
