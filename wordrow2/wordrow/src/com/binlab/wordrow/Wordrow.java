package com.binlab.wordrow;

import com.badlogic.gdx.Game;
import com.badlogic.gdx.Gdx;
import com.binlab.wordrow.asset.AssetManager;
import com.binlab.wordrow.asset.AudioManager;

public class Wordrow extends Game {
	
	float width = 100;
	float height;
	
	WordrowScreen scr; 
	MenuScreen menu;
	SplashScreen splash; 
	
	@Override
	public void create() {
		AssetManager.load();
		AudioManager.load();
		float deviceWidth = Gdx.graphics.getWidth();
		float deviceHeight = Gdx.graphics.getHeight();
		height = width * deviceHeight/deviceWidth;
		System.out.println("HEIGHT: " + height);
		
		splash = new SplashScreen(this, width, height); 
		menu = new MenuScreen(this, width, height);
		scr = new WordrowScreen(this, width, height);
		
		setScreen(splash);
		
	}

	@Override
	public void dispose() {
		super.dispose();
		AssetManager.dispose();
		AudioManager.dispose();
	}
	
	public WordrowScreen newGame(){
	    scr = new WordrowScreen(this, width, height);
		return scr; 
	}


}
