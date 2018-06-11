package org.jpacman.undo;

import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Deque;

import org.jpacman.framework.model.Direction;
import org.jpacman.framework.model.Food;
import org.jpacman.framework.model.Game;
import org.jpacman.framework.model.Ghost;
import org.jpacman.framework.model.IBoardInspector.SpriteType;
import org.jpacman.framework.model.Sprite;
import org.jpacman.framework.model.Tile;

public class UndoableGame extends Game {

	@SuppressWarnings("rawtypes")
	private static Deque<ArrayList> undoMoves = new ArrayDeque<ArrayList>();
	ArrayList<Move> currentMoves = new ArrayList<Move>();

	public UndoableGame() {
		currentMoves = new ArrayList<Move>();
	}

	public void initialize() {
		ArrayList<Move> firstMoves = new ArrayList<Move>();
		// if !UnitTesting
		if (getBoard().getHeight() > 5) {

			Ghost ghost1 = getGhosts().get(0);
			Ghost ghost2 = getGhosts().get(1);
			Ghost ghost3 = getGhosts().get(2);
			Ghost ghost4 = getGhosts().get(3);

			Move initialMove1 = new Move("U", true, null, 0, 0, 11, 15, 0);
			Move initialMove2 = new Move(null, false, ghost1, 0, 0, 11, 9, 0);
			Move initialMove3 = new Move(null, false, ghost2, 0, 0, 11, 7, 0);
			Move initialMove4 = new Move(null, false, ghost3, 0, 0, 13, 9, 0);
			Move initialMove5 = new Move(null, false, ghost4, 0, 0, 9, 9, 0);

			firstMoves.add(initialMove1);
			firstMoves.add(initialMove2);
			firstMoves.add(initialMove3);
			firstMoves.add(initialMove4);
			firstMoves.add(initialMove5);

			// Beginning Condition
			if (getPlayer().getPoints() == 0) {
				ghostLocater(getGhosts().get(0), 11, 9);
				ghostLocater(getGhosts().get(1), 11, 7);
				ghostLocater(getGhosts().get(2), 13, 9);
				ghostLocater(getGhosts().get(3), 9, 9);
			}

			// Idle condition
			if (getPlayer().getPoints() == 0 && getPlayer().getTile().getX() == 11) {
				undoMoves.clear();
			}

		} else {
			undoMoves.push(currentMoves); // UnitTesting
		}
		// False Last Stack OR Empty Stack Condition
		if (undoMoves.size() == 0 || firstMoves != undoMoves.getLast()) {
			undoMoves.addLast(firstMoves);
			notifyViewers();
			return;
		}
	}

	public void ghostLocater(Ghost ghost, int x, int y) {
		Tile undoLocation = getBoard().tileAt(x, y);
		ghost.deoccupy();
		ghost.occupy(undoLocation);
	}

	@SuppressWarnings("unchecked")
	public void undo() {
		initialize();

		// Jesus Christ
		if (died()) {
			try {
				getPlayer().resurrect();
			} catch (NullPointerException e) {
			}
		}

		ArrayList<Move> toUndo = undoMoves.pop();
		Food john = new Food() {// nothing
		        };

		for (Move m : toUndo) {
			if (m.isplayer()) {
				if (m.getdiff() != 0) {
					if (getPlayer().getPoints() > 0)
						getPointManager().consumePointsOnBoard(getPlayer(), m.getdiff() * -1);
					if (m.getDir().equals("U")) {
						undomovePlayer(Direction.DOWN);
						getBoard().put(john, m.getx(), m.gety());
						getPlayer().setDirection(Direction.UP);
					} else if (m.getDir().equals("D")) {
						undomovePlayer(Direction.UP);
						getBoard().put(john, m.getx(), m.gety());
						getPlayer().setDirection(Direction.DOWN);
					} else if (m.getDir().equals("L")) {
						undomovePlayer(Direction.RIGHT);
						getBoard().put(john, m.getx(), m.gety());
						if (getBoard().getHeight() > 5) {
							if (getBoard().spriteAt(11, 15) != null
							        && getPlayer().getTile().getX() != 11)
								getBoard().spriteAt(11, 15).deoccupy();
						}
						getPlayer().setDirection(Direction.LEFT);
					} else {
						undomovePlayer(Direction.LEFT);
						getBoard().put(john, m.getx(), m.gety());
						if (getBoard().getHeight() > 5) {
							if (getBoard().spriteAt(11, 15) != null
							        && getPlayer().getTile().getX() != 11)
								getBoard().spriteAt(11, 15).deoccupy();
						}
						getPlayer().setDirection(Direction.RIGHT);
					}
				} else {
					if (m.getDir().equals("U")) {
						if (m.getpoints() == 0) {
							getPlayer().setDirection(Direction.LEFT);
							return;
						}
						undomovePlayer(Direction.DOWN);
						getPlayer().setDirection(Direction.UP);
					} else if (m.getDir().equals("D")) {
						undomovePlayer(Direction.UP);
						getPlayer().setDirection(Direction.DOWN);
					} else if (m.getDir().equals("L")) {
						undomovePlayer(Direction.RIGHT);
						getPlayer().setDirection(Direction.LEFT);
					} else {
						undomovePlayer(Direction.LEFT);
						getPlayer().setDirection(Direction.RIGHT);
					}
				}
			} else {
				Tile undoLocation = getBoard().tileAt(m.getx(), m.gety());
				Ghost undoGhost = m.getGhost();
				undoGhost.deoccupy();
				undoGhost.occupy(undoLocation);
			}
		}
	}

	public void ghostAdder(int size) {
		Move ghostmove = null;
		for (int counter = 0; counter < getGhosts().size(); counter++) {
			ghostmove = ghostmove(ghostmove, counter);
			currentMoves.add(ghostmove);
		}
	}

	private Move ghostmove(Move ghostmove, int counter) {
		Ghost tempGhost = getGhosts().get(counter);
		int x = tempGhost.getTile().getX();
		int y = tempGhost.getTile().getY();
		ghostmove = new Move("U", false, tempGhost, 0, 0, x, y, counter);
		return ghostmove;
	}

	@SuppressWarnings("unchecked")
	@Override
	public void movePlayer(Direction dir) {
		Tile target = getBoard().tileAtDirection(getPlayer().getTile(), dir);
		if (!canOccupyTile(target)) {
			super.movePlayer(dir);
		} else {
			Move currentmove;
			super.movePlayer(dir);

			currentMoves = new ArrayList<Move>();
			ArrayList<Move> temp = undoMoves.peek();

			int diff = 0;
			if (undoMoves.size() < 2 || (getPlayer().getPoints() != temp.get(0).getpoints()))
				diff = 10;

			int xx = getPlayer().getTile().getX();
			int yy = getPlayer().getTile().getY();

			switch (dir) {
				case UP:
					currentmove =
					        new Move("U", true, null, diff, getPlayer().getPoints(), xx, yy, 0);
					currentMoves.add(currentmove);
					ghostAdder(getGhosts().size());
					undoMoves.push(currentMoves);
					break;

				case DOWN:
					currentmove =
					        new Move("D", true, null, diff, getPlayer().getPoints(), xx, yy, 0);
					currentMoves.add(currentmove);
					ghostAdder(getGhosts().size());
					undoMoves.push(currentMoves);
					break;

				case LEFT:
					currentmove =
					        new Move("L", true, null, diff, getPlayer().getPoints(), xx, yy, 0);
					currentMoves.add(currentmove);
					ghostAdder(getGhosts().size());
					undoMoves.push(currentMoves);
					break;

				case RIGHT:
					currentmove =
					        new Move("R", true, null, diff, getPlayer().getPoints(), xx, yy, 0);
					currentMoves.add(currentmove);
					ghostAdder(getGhosts().size());
					undoMoves.push(currentMoves);
					break;
				default:
					break;
			}
		}

	}

	public void undomovePlayer(Direction dir) {
		super.movePlayer(dir);
	}

	private boolean canOccupyTile(Tile target) {
		assert target != null : "PRE: Argument can't be null";
		Sprite currentOccupier = target.topSprite();
		return currentOccupier == null || currentOccupier.getSpriteType() != SpriteType.WALL;
	}
}
