import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

import org.jpacman.framework.model.Direction;
import org.jpacman.framework.model.Tile;
import org.jpacman.undo.UndoablePacman;
import org.junit.Test;

public class UndoStoryTest extends MovePlayerStoryTest {

	private UndoablePacman theUI;

	@Override
	public UndoablePacman makeUI() {
		theUI = new UndoablePacman();
		return theUI;
	}

	@Override
	protected UndoablePacman getUI() {

		return theUI;
	}

	@Test
	public void test_S7_1_Unmoved() {
		// given
		getEngine().start();

		getUI();
		// when
		UndoablePacman.undo();
		// then
		assertEquals(1, getPlayer().getTile().getY());
		assertTrue(getPlayer().getPoints() == 0);
	}

	@Test
	public void test_S7_2_UndoAtCoin() {
		// given
		getEngine().start();
		getEngine().left();
		getUI();
		// when
		UndoablePacman.undo();
		// then
		assertTrue(getPlayer().getPoints() == 0);
	}

	@Test
	public void test_S7_3_UndoAtNoCoin() {
		// given
		getEngine().start();
		getEngine().up();
		getUI();
		// when
		UndoablePacman.undo();
		// then
		assertEquals(1, getPlayer().getTile().getY());
	}

	@Test
	public void test_S7_4_DiedAtCoin() {
		Tile emptyTile = tileAt(1, 0);
		Tile ghostTile = tileAt(2, 1);
		// given
		getEngine().start();
		getEngine().up();
		getEngine().right();
		assertTrue(getPlayer().getPoints() > 0);
		getUI().getGame().moveGhost(theGhost(), Direction.UP);
		assertFalse(getPlayer().isAlive());
		assertTrue(getPlayer().getPoints() > 0);
		getUI();
		// when
		UndoablePacman.undo();
		// then
		assertTrue(getPlayer().isAlive());
		assertTrue(getPlayer().getPoints() == 0);
		assertEquals(emptyTile, getPlayer().getTile());
		assertEquals(ghostTile, theGhost().getTile());
	}

	@Test
	public void test_S7_5_DiedAtEmpty() {
		Tile startTile = tileAt(1, 1);
		Tile ghostTile = tileAt(2, 1);
		// given
		getEngine().start();
		getEngine().up();
		getUI().getGame().moveGhost(theGhost(), Direction.UP);
		getUI().getGame().moveGhost(theGhost(), Direction.LEFT);
		assertFalse(getPlayer().isAlive());
		getUI();
		// when
		UndoablePacman.undo();
		// then
		assertTrue(getPlayer().getPoints() == 0);
		assertTrue(getPlayer().isAlive());
		assertEquals(startTile, getPlayer().getTile());
		assertEquals(ghostTile, theGhost().getTile());
	}

	@Test
	public void test_S7_6_WonGame() {
		Tile endTile = tileAt(2, 0);
		Tile ghostTile = tileAt(2, 1);
		// given
		getEngine().start();
		getEngine().left(); // eat first food
		getEngine().right(); // go back
		getEngine().up(); // move next to final food
		getEngine().right(); // eat final food
		getUI();
		// when
		UndoablePacman.undo();
		// then
		assertEquals(endTile, getPlayer().getTile()); // didn't move could get angry
		assertEquals(ghostTile, theGhost().getTile());
		assertTrue(getUI().getGame().getPointManager().allEaten());
	}
}
