package com.binlab.wordrow.play;

import com.badlogic.gdx.graphics.Color;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.badlogic.gdx.scenes.scene2d.Actor;
import com.badlogic.gdx.scenes.scene2d.Touchable;
import com.binlab.wordrow.asset.AssetManager;

public class Tile extends Actor {
	
	public Tile(float x, float y, float size, Color color) {
		this(x, y, size);
		setColor(new Color(color));
	}
	
	public Tile(float x, float y, float size) {
		this.setPosition(x, y);
		this.setSize(size, size);
	}
	
	@Override
	public Actor hit(float x, float y, boolean touchable) {
		if (touchable && getTouchable() != Touchable.enabled) return null;
		float halfWidth = getWidth()/2;
		float halfHeight = getHeight()/2;
		return x >= -halfWidth && x < halfWidth && y >= -halfHeight && y < halfHeight ? this : null;
	}
	
	@Override
	public void draw(SpriteBatch batch, float parentAlpha) {
		batch.setColor(getColor());
		batch.draw(
				AssetManager.tileTexReg, 
				getX() - getWidth()/2, 
				getY() - getHeight()/2,
				getWidth(),
				getHeight()
		);
	}

}
