package com.binlab.wordrow;

import aurelienribon.tweenengine.Tween;
import aurelienribon.tweenengine.TweenManager;

import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.Screen;
import com.badlogic.gdx.graphics.Color;
import com.badlogic.gdx.graphics.GL20;
import com.badlogic.gdx.graphics.g2d.Sprite;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.badlogic.gdx.utils.Timer;
import com.badlogic.gdx.utils.Timer.Task;
import com.binlab.wordrow.asset.AssetManager;
import com.binlab.wordrow.asset.Swatches;
import com.binlab.wordrow.tween.SpriteAccessor;

public class SplashScreen implements Screen {

	private SpriteBatch spriteBatch;
	private Sprite splash;
	private TweenManager tweenManager; 
	Wordrow wordrow;
	float width;
	float height;
	

	public SplashScreen(Wordrow wordrow, float width, float height) {
		this.wordrow = wordrow;
		this.width = width;
		this.height = height;
	}

	@Override
	public void render(float delta) {
		Gdx.gl.glClear(GL20.GL_COLOR_BUFFER_BIT);
		Color bg = Swatches.background;
		Gdx.gl.glClearColor(bg.r, bg.g, bg.b, bg.a);
		
		tweenManager.update(delta); 
		
		spriteBatch.begin();
		splash.draw(spriteBatch);
		spriteBatch.end();

//		if (Gdx.input.justTouched()) {
//			AudioManager.clickb();
//			wordrow.setScreen(wordrow.menu);
//			Gdx.input.setInputProcessor(wordrow.menu.stage);
//		}
		
	}

	@Override
	public void resize(int width, int height) {
		// TODO Auto-generated method stub

	}

	@Override
	public void show() {
		spriteBatch = new SpriteBatch();
		
		splash = AssetManager.splashSprite;
		splash.setPosition((Gdx.graphics.getWidth() / 2 - splash.getWidth() / 2),
				(Gdx.graphics.getHeight() / 2 - splash.getHeight() / 2));
	
		
		tweenManager = new TweenManager(); 
		Tween.registerAccessor(Sprite.class, new SpriteAccessor());
		Tween.set(splash, SpriteAccessor.ALPHA).target(0).start(tweenManager); //David fix this magical please
		Tween.to(splash, SpriteAccessor.ALPHA, 2).target(0).start(tweenManager);
		Tween.to(splash, SpriteAccessor.ALPHA, 2).target(1).delay(3).start(tweenManager);
		Tween.to(splash, SpriteAccessor.ALPHA, 2).target(0).delay(5).start(tweenManager);
		
		float delay = 7; // seconds
		Timer.schedule(new Task(){
		    @Override
		    public void run() {
				wordrow.setScreen(wordrow.menu);
				Gdx.input.setInputProcessor(wordrow.menu.stage);
		    }
		}, delay);

	}

	@Override
	public void hide() {
		// TODO Auto-generated method stub

	}

	@Override
	public void pause() {
		// TODO Auto-generated method stub

	}

	@Override
	public void resume() {
		// TODO Auto-generated method stub

	}

	@Override
	public void dispose() {
		// TODO Auto-generated method stub

	}

}
