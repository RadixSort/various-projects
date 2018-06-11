package org.jpacman.undo;

import org.jpacman.framework.model.Ghost;

public class Move {

	private String dir;
	private boolean player;
	private Ghost theGhost;
	private int points;
	private int diff; // difference of point from that move
	private int x;
	private int y;
	private int n; // ghost index

	public Move(String direction, boolean player, Ghost g, int difference, int pointthen, int a,
	        int b, int c) {
		n = -1;
		if (!player) {
			theGhost = g;
			n = c;
		}
		diff = difference;
		x = a;
		y = b;
		points = pointthen;

		dir = direction;
		this.player = player;
	}

	public String getDir() {
		return dir;
	}

	public boolean isplayer() {
		return player;
	}

	public Ghost getGhost() {
		return theGhost;
	}

	public int getx() {
		return x;
	}

	public int gety() {
		return y;
	}

	public int getpoints() {
		return points;
	}

	public int getdiff() {
		return diff;
	}

	public int getn() {
		return n;
	}
}
