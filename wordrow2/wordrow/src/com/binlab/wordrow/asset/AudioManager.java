package com.binlab.wordrow.asset;

import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.audio.Music;
import com.badlogic.gdx.audio.Sound;

public class AudioManager {

	private static Sound soundClick;
	private static Sound soundClickb;
	private static Sound soundMoveTile;
	private static Music gameBGMusic;

	public static void load() {
		soundClick = Gdx.audio.newSound(Gdx.files.internal("Audio/Click.wav"));
		soundClickb = Gdx.audio.newSound(Gdx.files.internal("Audio/Clickb.wav"));
		soundMoveTile = Gdx.audio.newSound(Gdx.files
				.internal("Audio/MoveTiles.wav"));
		gameBGMusic = Gdx.audio.newMusic(Gdx.files.internal("Audio/gameBGMusic.mp3"));
	}

	public static void dispose() {
		soundClick.dispose();
		soundClickb.dispose();
		soundMoveTile.dispose();
		gameBGMusic.dispose();
	}
	
	public static void click() {
		soundClick.play();
	}
	
	public static void clickb() {
		soundClickb.play();
	}
	
	public static void moveTile() {
		soundMoveTile.play();
	}
	
	public static void playBackgroundMusic() {
		gameBGMusic.play();
		gameBGMusic.setVolume((float) 0.2);
		gameBGMusic.setLooping(true);
	}
	
	public static void stopBackgroundMusic() {
		gameBGMusic.stop();
	}
}