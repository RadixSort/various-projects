package org.jpacman.undo;

import org.jpacman.framework.factory.DefaultGameFactory;

public class UndoableDefaultGameFactory extends DefaultGameFactory {

	transient static UndoableGame theGame;

	@Override
	public UndoableGame makeGame() {
		theGame = new UndoableGame();
		return theGame;
	}

	@Override
	protected UndoableGame getGame() {
		assert theGame != null;
		return theGame;
	}
}
