package com.zavarese.binauralsleep.sound;
import android.media.MediaPlayer;
import android.media.audiofx.Equalizer;

import java.io.IOException;

public class FilePlayer {
    public MediaPlayer currentPlayer = null;
    private Equalizer eqCurr;
    private Equalizer eqNext;
    private float volume;
    private String url;
    private int prepared;
    private MediaPlayer nextPlayer = null;
    private short channel;
    private int sessionId1;
    private int sessionId2;
    private boolean loop;

    public FilePlayer(String url, float volume, short channel, int sessionId1, int sessionId2, boolean loop){
        this.url = url;
        this.volume = volume;
        this.currentPlayer = new MediaPlayer();
        this.nextPlayer = new MediaPlayer();
        this.prepared = 0;
        this.channel = channel;
        this.sessionId1 = sessionId1;
        this.sessionId2 = sessionId2;
        this.loop = loop;

        this.currentPlayer.setAudioSessionId(this.sessionId1);
        this.eqCurr = new Equalizer(Integer.MAX_VALUE,this.sessionId1);
        this.eqCurr.setEnabled(true);
        short[] freqRange1 = this.eqCurr.getBandLevelRange();
        short minLvl1 = freqRange1[0];
        this.eqCurr.setBandLevel((short) channel,minLvl1);

    }

    public void stop(){
        if(currentPlayer.isPlaying()) {
            currentPlayer.stop();
        }
    }

    public void pause(){
        if(currentPlayer.isPlaying()) {
            currentPlayer.pause();
        }
    }

    public void release(){
        if(currentPlayer!=null) {
            currentPlayer.release();
        }
    }

    public boolean isPlaying(){
        if(currentPlayer!=null) {
            return currentPlayer.isPlaying();
        }else{
            return false;
        }
    }

    private void createNextMediaPlayer() {
        this.nextPlayer = new MediaPlayer();

        this.nextPlayer.setAudioSessionId(this.sessionId2);
        this.eqNext = new Equalizer(Integer.MAX_VALUE,this.sessionId2);
        this.eqNext.setEnabled(true);
        short[] freqRange2 = this.eqNext.getBandLevelRange();
        short minLvl2 = freqRange2[0];
        this.eqNext.setBandLevel((short) channel,minLvl2);

        try {
            this.nextPlayer.setDataSource(url);
            this.nextPlayer.setVolume((float) volume, (float) volume);
            this.nextPlayer.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
                @Override
                public void onPrepared(MediaPlayer mp) {
                    nextPlayer.seekTo(0);
                    currentPlayer.setNextMediaPlayer(nextPlayer);
                    currentPlayer.setOnCompletionListener(onCompletionListener);
                }
            });
            nextPlayer.prepareAsync();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private final MediaPlayer.OnCompletionListener onCompletionListener =
            new MediaPlayer.OnCompletionListener() {
                @Override
                public void onCompletion(MediaPlayer mediaPlayer) {
                    currentPlayer = nextPlayer;
                    createNextMediaPlayer();
                    mediaPlayer.release();
                }
            };

    public void play(){
        try {
            currentPlayer.setDataSource(url);
            currentPlayer.setVolume(this.volume, this.volume);

            if(!loop){
                currentPlayer.prepare();
                currentPlayer.start();
            }else{
                currentPlayer.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
                    @Override
                    public void onPrepared(MediaPlayer mediaPlayer) {
                        prepared = 1;
                        currentPlayer.start();
                    }
                });
                currentPlayer.prepareAsync();
                createNextMediaPlayer();
            }

        }catch (IOException e){
            e.printStackTrace();
        }
    }

    public int getPrepared(){
        return this.prepared;
    }
}
