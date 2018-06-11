import org.jpacman.framework.factory.FactoryException;
import org.jpacman.framework.factory.IGameFactory;
import org.jpacman.framework.factory.MapParser;
import org.jpacman.test.framework.model.GameTest;
import org.jpacman.undo.UndoableDefaultGameFactory;
import org.jpacman.undo.UndoableGame;

public class UndoableGameTest extends GameTest {

	@Override
	protected UndoableGame makePlay(String singleRow) throws FactoryException {
		MapParser p = new MapParser(makeFactory());
		UndoableGame theGame = (UndoableGame) p.parseMap(new String[] { singleRow });
		return theGame;
	}

	@Override
	public IGameFactory makeFactory() {
		return new UndoableDefaultGameFactory();
	}
}
