package com.binlab.wordrow;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.Screen;
import com.badlogic.gdx.audio.Music;
import com.badlogic.gdx.graphics.Color;
import com.badlogic.gdx.graphics.GL20;
import com.badlogic.gdx.math.Interpolation;
import com.badlogic.gdx.scenes.scene2d.InputEvent;
import com.badlogic.gdx.scenes.scene2d.InputListener;
import com.badlogic.gdx.scenes.scene2d.Stage;
import com.badlogic.gdx.scenes.scene2d.Touchable;
import com.badlogic.gdx.scenes.scene2d.actions.Actions;
import com.badlogic.gdx.scenes.scene2d.ui.ImageButton;
import com.badlogic.gdx.scenes.scene2d.utils.ClickListener;
import com.binlab.wordrow.asset.AssetManager;
import com.binlab.wordrow.asset.AudioManager;
import com.binlab.wordrow.asset.Swatches;
import com.binlab.wordrow.play.CharacterTile;
import com.binlab.wordrow.word.RandomStringGenerator;
import com.binlab.wordrow.word.WordManager;

public class WordrowScreen implements Screen {
	
	Wordrow wordrow;

	float width;
	float height;

	public Stage stage;
	List<CharacterTile> discardedTiles;
	List<CharacterTile> topRow;
	List<CharacterTile> bottomRow;
	ImageButton goButton;
	ImageButton backButton;

	// DIMENSIONAL PARAMETERS
	public final float WORD_ROW_Y;
	public final float ROW_Y;
	public final float TILE_SIZE;
	public final float PADDING;

	// TEMPORAL PARAMETERS
	public final float MOVE_ANIMATION_TIME = 0.5f;

	// GAMEPLAY PARAMETERS
	public final int TILE_COUNT = 10;

	// WORD PARAMETERS
	WordManager wordMan;
	RandomStringGenerator strGen;
	
	//AUDIO
	Music BGMusic; 

	public WordrowScreen(Wordrow wordrow, float width, float height) {
		this.wordrow = wordrow;
		try {
			wordMan = new WordManager();
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}

		this.width = width;
		this.height = height;

		PADDING = width * 0.05f;
		TILE_SIZE = (width - (PADDING * 2)) / TILE_COUNT;
		WORD_ROW_Y = height * 0.75f;
		ROW_Y = height * 0.5f;

		discardedTiles = new ArrayList<CharacterTile>();
		topRow = new ArrayList<CharacterTile>();
		bottomRow = new ArrayList<CharacterTile>();
		stage = new Stage(width, height);

		initRandomStringGenerator();
		initButtons();
		
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

	}

	@Override
	public void show() {
		fillRow();
		AudioManager.playBackgroundMusic();
	}

	@Override
	public void hide() {

	}

	@Override
	public void pause() {

	}

	@Override
	public void resume() {

	}

	@Override
	public void dispose() {

	}

	private float getTileXByRowPosition(int rowPosition) {
		return PADDING + ((0.5f + rowPosition) * TILE_SIZE);
	}

	void putTileInTopRow(final CharacterTile ct) {
		stage.getRoot().removeActor(ct);
		stage.addActor(ct);
		topRow.add(ct);

		ct.clearCaptureListeners();
		ct.addCaptureListener(new InputListener() {
			@Override
			public boolean touchDown(InputEvent event, float x, float y,
					int pointer, int button) {
				AudioManager.moveTile();
				putTileInBottomRow(ct);
				organizeRow();
				return true;
			}
		});
	}

	void putTileInBottomRow(final CharacterTile ct) {
		stage.getRoot().removeActor(ct);
		stage.addActor(ct);
		topRow.remove(ct);
		if (!bottomRow.contains(ct))
			bottomRow.add(ct);
		ct.clearCaptureListeners();
		ct.addCaptureListener(new InputListener() {
			@Override
			public boolean touchDown(InputEvent event, float x, float y,
					int pointer, int button) {
				AudioManager.moveTile();
				putTileInTopRow(ct);
				organizeRow();
				return true;
			}
		});
	}

	void organizeRow() {
		for (int i = 0; i < bottomRow.size(); i++) {
			bottomRow.get(i).clearActions();
			bottomRow.get(i).addAction(
					Actions.moveTo(getTileXByRowPosition(i), ROW_Y,
							MOVE_ANIMATION_TIME, Interpolation.exp10Out));
		}

		while (topRow.size() < TILE_COUNT && discardedTiles.size() > 0) {
			int lastDiscarded = discardedTiles.size() - 1;
			CharacterTile ct = discardedTiles.get(lastDiscarded);
			topRow.add(0, ct);
			discardedTiles.remove(lastDiscarded);
		}

		while (topRow.size() > TILE_COUNT) {
			CharacterTile ct = topRow.get(0);
			topRow.remove(0);
			discardedTiles.add(ct);
			ct.addAction(Actions.moveTo(-TILE_SIZE * 2, WORD_ROW_Y,
					MOVE_ANIMATION_TIME));
		}

		for (int i = 0; i < topRow.size(); i++) {
			topRow.get(i).clearActions();
			topRow.get(i).addAction(
					Actions.moveTo(getTileXByRowPosition(i), WORD_ROW_Y,
							MOVE_ANIMATION_TIME, Interpolation.exp10Out));
		}
	}

	void wordRowify() {
		for (CharacterTile ct : topRow) {
			bottomRow.remove(ct);
		}
		organizeRow();
		if (bottomRow.size() == TILE_COUNT)
			return;
		int wordRowSize = topRow.size();
		for (int i = 0; i < wordRowSize; i++) {
			topRow.get(i).setTouchable(Touchable.disabled);
		}
		fillRow();
		for (CharacterTile ct : discardedTiles) {
			stage.getRoot().removeActor(ct);
		}

		String wordRowStr = getWordRowString();
		for (int i = 0; i < wordRowStr.length(); i++) {
			try {
				if (wordMan.isValidWord(wordRowStr.substring(i), " ")) {
					System.out.println(wordRowStr.substring(i));
				}
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
	}

	String getWordRowString() {
		String str = "";
		for (int i = 0; i < topRow.size(); i++) {
			str += topRow.get(i).getString();
		}
		return str;
	}

	void fillRow() {
		int rowSize = bottomRow.size();

		for (int i = 0; i < TILE_COUNT - rowSize; i++) {
			System.out.println(i);
			CharacterTile ct = new CharacterTile(width + 10, ROW_Y, TILE_SIZE,
					strGen.getString(), Swatches.green);
			ct.addAction(Actions.sequence(Actions.delay(0.07f * i), Actions
					.moveTo(getTileXByRowPosition(i + rowSize), ROW_Y,
							MOVE_ANIMATION_TIME, Interpolation.pow4Out)));
			// ct.setTouchable(Touchable.disabled);
			putTileInBottomRow(ct);
			stage.addActor(ct);
		}
	}

	void initRandomStringGenerator() {
		strGen = new RandomStringGenerator();
		strGen.addString("A", 9);
		strGen.addString("B", 2);
		strGen.addString("C", 2);
		strGen.addString("D", 4);
		strGen.addString("E", 12);
		strGen.addString("F", 2);
		strGen.addString("G", 3);
		strGen.addString("H", 2);
		strGen.addString("I", 9);
		strGen.addString("J", 2);
		strGen.addString("K", 2);
		strGen.addString("L", 4);
		strGen.addString("M", 2);
		strGen.addString("N", 6);
		strGen.addString("O", 8);
		strGen.addString("P", 2);
		strGen.addString("Qu", 1);
		strGen.addString("R", 6);
		strGen.addString("S", 4);
		strGen.addString("T", 6);
		strGen.addString("U", 4);
		strGen.addString("V", 2);
		strGen.addString("W", 2);
		strGen.addString("X", 1);
		strGen.addString("Y", 2);
		strGen.addString("Z", 1);
	}
	
	private void stopWordrowScreen(){
		AudioManager.stopBackgroundMusic();
	}

	private void initButtons() {
		System.out.println("Init button");
		
		float goButtonWidth = width * 0.2f;
		float goButtonHeight = goButtonWidth * 0.75f;
		goButton = new ImageButton(AssetManager.goButtonStyle);

		goButton.setPosition(width * 0.25f - (goButtonWidth / 2), -100);
		goButton.setWidth(goButtonWidth);
		goButton.setHeight(goButtonHeight);
		stage.addActor(goButton);
		goButton.addCaptureListener(new ClickListener() {
			@Override
			public void clicked(InputEvent event, float x, float y) {
				AudioManager.click();
				wordRowify();
			}
		});

		goButton.addAction(Actions.moveTo(width * 0.25f - (goButtonWidth / 2),
				height * 0.08f, MOVE_ANIMATION_TIME, Interpolation.pow3Out));
		
		float backButtonWidth = width * 0.2f;
		float backButtonHeight =  backButtonWidth * 0.75f;
		backButton = new ImageButton(AssetManager.backButtonStyle);
		
		backButton.setPosition(width * 0.75f - (backButtonWidth/2), -100);
		backButton.setWidth(backButtonWidth);
		backButton.setHeight(backButtonHeight);
		stage.addActor(backButton);
		backButton.addCaptureListener(new ClickListener() {
			@Override
			public void clicked(InputEvent event, float x, float y) {
				stopWordrowScreen();
				AudioManager.clickb();
				wordrow.newGame(); 
				wordrow.setScreen(wordrow.menu);
				Gdx.input.setInputProcessor(wordrow.menu.stage);
			}
		});
		
		backButton.addAction(Actions.moveTo(width * 0.75f - (goButtonWidth / 2),
				height * 0.08f, MOVE_ANIMATION_TIME, Interpolation.pow3Out));
	}
}
