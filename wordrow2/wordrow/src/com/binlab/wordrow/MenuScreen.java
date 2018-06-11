package com.binlab.wordrow;

import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.Screen;
import com.badlogic.gdx.graphics.Color;
import com.badlogic.gdx.graphics.GL20;
import com.badlogic.gdx.scenes.scene2d.InputEvent;
import com.badlogic.gdx.scenes.scene2d.Stage;
import com.badlogic.gdx.scenes.scene2d.ui.ImageButton;
import com.badlogic.gdx.scenes.scene2d.utils.ClickListener;
import com.binlab.wordrow.asset.AssetManager;
import com.binlab.wordrow.asset.AudioManager;
import com.binlab.wordrow.asset.Swatches;

public class MenuScreen implements Screen {

	ImageButton startButton;
	float width;
	float height;
	public Stage stage;

	Wordrow wordrow;

	// TEMPORAL PARAMETERS
	public final float MOVE_ANIMATION_TIME = 0.5f;

	public MenuScreen(Wordrow wordrow, float width, float height) {
		this.width = width;
		this.height = height;
		this.wordrow = wordrow;
		stage = new Stage(width, height);
		initButtons();
		AudioManager.load();
	}

	@Override
	public void render(float delta) {
		Gdx.gl.glClear(GL20.GL_COLOR_BUFFER_BIT);
		Color bg = Swatches.background;
		Gdx.gl.glClearColor(bg.r, bg.g, bg.b, bg.a);

		stage.act(delta);
		stage.draw();
	}

	@Override
	public void resize(int width, int height) {
		// TODO Auto-generated method stub

	}

	@Override
	public void show() {
		// TODO Auto-generated method stub

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

	}

	private void initButtons() {
		final float startButtonWidth = width * 0.2f;
		float startButtonHeight = startButtonWidth * 0.75f;
		startButton = new ImageButton(AssetManager.startButtonStyle);

		startButton.setPosition(width * 0.5f - (startButtonWidth / 2),
				height * 0.5f);
		startButton.setWidth(startButtonWidth);
		startButton.setHeight(startButtonHeight);
		stage.addActor(startButton);
		startButton.addCaptureListener(new ClickListener() {
			@Override
			public void clicked(InputEvent event, float x, float y) {
				AudioManager.clickb();
				wordrow.setScreen(wordrow.scr);
				Gdx.input.setInputProcessor(wordrow.scr.stage);
			}
		});
	}

}
