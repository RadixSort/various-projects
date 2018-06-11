package com.binlab.wordrow;

import com.badlogic.gdx.math.Rectangle;
import com.badlogic.gdx.math.Vector2;

public class Row {

	public static final int INVALID_SPACE = -1;
	public Rectangle rowBounds;
	
	int spaces;
	float height;
	float width;
	float x;
	float y;
	float spaceWidth;
	float spaceHeight;
	
	
	public Row(float x, float y, float width, float height, int spaces) {
		rowBounds = new Rectangle(x, y, width, height);
		this.width = width;
		this.height = height;
		this.x = x;
		this.y = y;
		this.spaces = spaces;
		spaceWidth = width / spaces;
		spaceHeight = height / spaces;
	}
	
	public int getSpaceNumber(float f, float g) {
		for (int i = 0 ; i < spaces ; i++) {
			float topY = y + height;
			float bottomY = y;
			float leftX = x + (spaceWidth * i);
			float rightX = x + (spaceWidth * (i + 1));
			System.out.println("left x: " + leftX);
			if (f <= leftX || f >= rightX || g <= bottomY || g >= topY)
				continue;
			return i;
		}
		return INVALID_SPACE;
	}
	
	public Vector2 getPositionFromSpaceNumber(int space) {
		return new Vector2((space * spaceWidth) + spaceWidth/2, 0);
	}

}
