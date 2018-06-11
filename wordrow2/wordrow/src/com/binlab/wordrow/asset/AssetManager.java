package com.binlab.wordrow.asset;

import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.g2d.BitmapFont;
import com.badlogic.gdx.graphics.g2d.Sprite;
import com.badlogic.gdx.graphics.g2d.TextureAtlas;
import com.badlogic.gdx.graphics.g2d.TextureRegion;
import com.badlogic.gdx.graphics.g2d.freetype.FreeTypeFontGenerator;
import com.badlogic.gdx.scenes.scene2d.ui.ImageButton.ImageButtonStyle;
import com.badlogic.gdx.scenes.scene2d.ui.Skin;

public class AssetManager {
	public static Texture splashTex;
	public static Sprite splashSprite;
	public static Texture tileTex;
	public static TextureRegion tileTexReg;
	public static TextureRegion goButtonDownReg;
	public static TextureRegion goButtonUpReg;
	public static TextureRegion startButtonDownReg;
	public static TextureRegion startButtonUpReg;
	public static TextureRegion backButtonDownReg;
	public static TextureRegion backButtonUpReg;
	public static BitmapFont font;
	public static ImageButtonStyle goButtonStyle;
	public static ImageButtonStyle startButtonStyle;
	public static ImageButtonStyle backButtonStyle;
	
	public static void load() {
		splashTex = new Texture(Gdx.files.internal("data/wordrow_splash.png"));
		splashSprite = new Sprite(splashTex);
		
		tileTex = new Texture(Gdx.files.internal("data/tile-01.png"));
		tileTexReg = new TextureRegion(tileTex, 0, 0, 512, 512);
		
		goButtonUpReg = new TextureRegion(tileTex, 512, 0, 218, 156);
		goButtonDownReg = new TextureRegion(tileTex, 512, 175, 218, 156);
		
		startButtonUpReg = new TextureRegion(tileTex, 740, 0, 218, 156);
		startButtonDownReg = new TextureRegion(tileTex, 740, 175, 218, 156);
		
		backButtonUpReg = new TextureRegion(tileTex, 958, 0, 218, 156);
		backButtonDownReg = new TextureRegion(tileTex, 958, 175, 218, 156);
		
		FreeTypeFontGenerator gen = new FreeTypeFontGenerator(Gdx.files.internal("font/corbel.ttf"));
		font = gen.generateFont(64);
		
		TextureAtlas goButtonAtlas = new TextureAtlas();
		goButtonAtlas.addRegion("up", goButtonUpReg);
		goButtonAtlas.addRegion("down", goButtonDownReg);
		
		TextureAtlas startButtonAtlas = new TextureAtlas();
		startButtonAtlas.addRegion("up", startButtonUpReg);
		startButtonAtlas.addRegion("down", startButtonDownReg);
		
		TextureAtlas backButtonAtlas = new TextureAtlas();
		backButtonAtlas.addRegion("up", backButtonUpReg);
		backButtonAtlas.addRegion("down", backButtonDownReg);
		
		Skin goButtonSkin = new Skin();
		goButtonSkin.addRegions(goButtonAtlas);
		
		Skin startButtonSkin = new Skin();
		startButtonSkin.addRegions(startButtonAtlas);
		
		Skin backButtonSkin = new Skin();
		backButtonSkin.addRegions(backButtonAtlas);
		
		goButtonStyle = new ImageButtonStyle();
		
		startButtonStyle = new ImageButtonStyle();
		
		backButtonStyle = new ImageButtonStyle();
		
		goButtonStyle.up = goButtonSkin.getDrawable("up");
		goButtonStyle.down = goButtonSkin.getDrawable("down");
		
		startButtonStyle.up = startButtonSkin.getDrawable("up");
		startButtonStyle.down = startButtonSkin.getDrawable("down");
		
		backButtonStyle.up = backButtonSkin.getDrawable("up");
		backButtonStyle.down = backButtonSkin.getDrawable("down");
	}
	
	public static void dispose() {
		tileTex.dispose();
	}
}
