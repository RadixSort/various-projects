package com.binlab.wordrow.play;

import com.badlogic.gdx.graphics.g2d.BitmapFont.TextBounds;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.badlogic.gdx.scenes.scene2d.Actor;
import com.binlab.wordrow.asset.AssetManager;

public class CenteredText extends Actor {
	private String text = null;
	private float beginX;
	private float beginY;
	
	public CenteredText(float x, float y, float scale, String str) {
		this(x, y, scale);
		setText(str);
		calculateTextBound();
	}
	
	public CenteredText(float x, float y, float scale) {
		setPosition(x, y); 
		setScale(scale);
	}
	
	@Override
	public void setPosition(float x, float y) {
		super.setPosition(x, y);
		calculateTextBound();
	}
	
	@Override
	public void draw(SpriteBatch batch, float parentAlpha) {
		if (text == null || text.isEmpty())
			return; 
		AssetManager.font.setColor(getColor());
		AssetManager.font.setScale(getScaleX());
		AssetManager.font.draw(batch, text, beginX, beginY);
	}
	
	public void setText(String text) {
		this.text = text;
		calculateTextBound();
	}
	
	@Override
	public void setScale(float scale) {
		super.setScale(scale);
		calculateTextBound();
	}
	
	private void calculateTextBound() {
		if (text == null)
			return;
		AssetManager.font.setScale(getScaleX());
		TextBounds bound = AssetManager.font.getBounds(text);
		beginX = getX() - bound.width/2;
		beginY = getY() + bound.height/2;
	}

	
}
