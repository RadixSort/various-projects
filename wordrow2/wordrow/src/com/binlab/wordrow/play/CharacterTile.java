package com.binlab.wordrow.play;

import java.util.List;

import com.badlogic.gdx.graphics.Color;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.badlogic.gdx.scenes.scene2d.EventListener;
import com.badlogic.gdx.scenes.scene2d.Touchable;
import com.badlogic.gdx.utils.Array;
import com.binlab.wordrow.asset.Swatches;

public class CharacterTile extends Tile{
	
	CenteredText text;
	String textStr;
	
	public CharacterTile(float x, float y, float size, String str) {
		super(x, y, size);
		text = new CenteredText(x, y, size * 0.011f, str);
		text.setColor(Swatches.background);
		textStr = str;
	}
	
	public CharacterTile(float x, float y, float size, String str,
			Color col) {
		this(x, y, size, str);
		setColor(col);
	}

	@Override
	public void act(float delta) {
		// TODO Auto-generated method stub
		super.act(delta);
		text.setPosition(getX(), getY() + getHeight()/19);
	}
	
	
	
	@Override
	public void setPosition(float x, float y) {
		super.setPosition(x, y);
		if (text != null)
			text.setPosition(x, y);
	}
	
	@Override
	public void setTouchable(Touchable touchable) {
		super.setTouchable(touchable);
		if (getTouchable() == Touchable.disabled) {
			setColor(Swatches.orange);
		}
	}
	
	@Override
	public void draw(SpriteBatch batch, float parentAlpha) {
		super.draw(batch, parentAlpha);
		text.draw(batch, parentAlpha);
	}
	
	public void clearCaptureListeners() {
		Array<EventListener> caps = getCaptureListeners();
		for (int i = caps.size - 1; i >= 0 ; i--) {
			removeCaptureListener(caps.get(i));
		}
	}
	
	public String getString() {
		return textStr;
	}

}
