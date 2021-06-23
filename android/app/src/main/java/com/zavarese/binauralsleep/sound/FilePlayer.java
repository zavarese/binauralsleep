package com.zavarese.binauralsleep.sound;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.media.audiofx.Equalizer;
import android.net.Uri;
import android.os.Bundle;
import android.os.Parcelable;

import com.zavarese.binauralsleep.MainActivity;

import java.io.IOException;
import java.util.ArrayList;

public class FilePlayer {
    public MediaPlayer currentPlayer;
    private Equalizer eqCurr;
    private Equalizer eqNext;
    private float volume;
    private String path;
    private MediaPlayer nextPlayer;
    private short channel;
    private int sessionId1;
    private int sessionId2;
    private boolean loop;
    private ArrayList<Uri> tracks;
    private Uri uri;
    private int currentTrack;
    private BinauralServices binauralServices;
    private MainActivity mainActivity;

    public FilePlayer(String path, float volume, short channel, int sessionId1, int sessionId2, boolean loop, ArrayList<Uri> uris, BinauralServices binauralServices){
        this.path = path;
        this.volume = volume;
        this.currentPlayer = new MediaPlayer();
        this.nextPlayer = new MediaPlayer();
        this.channel = channel;
        this.sessionId1 = sessionId1;
        this.sessionId2 = sessionId2;
        this.loop = loop;
        this.tracks = uris;
        this.binauralServices = binauralServices;
        this.currentTrack = 0;

        this.currentPlayer.setAudioSessionId(this.sessionId1);
        this.eqCurr = new Equalizer(Integer.MAX_VALUE,this.sessionId1);
        this.eqCurr.setEnabled(true);
        short[] freqRange1 = this.eqCurr.getBandLevelRange();
        short minLvl1 = freqRange1[0];
        this.eqCurr.setBandLevel(channel,minLvl1);

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

    private void nextMediaPlayer() {
        if(this.currentTrack==0 && !this.loop){
            return;
        }

        if(this.loop){
            this.currentTrack = getNextIndexTrack(this.currentTrack, this.tracks.size());
        }

        this.nextPlayer = new MediaPlayer();

        this.nextPlayer.setAudioSessionId(this.sessionId2);
        this.eqNext = new Equalizer(Integer.MAX_VALUE,this.sessionId2);
        this.eqNext.setEnabled(true);
        short[] freqRange2 = this.eqNext.getBandLevelRange();
        short minLvl2 = freqRange2[0];
        this.eqNext.setBandLevel(channel,minLvl2);

        try {
            this.nextPlayer.setDataSource(this.binauralServices, tracks.get(currentTrack));
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

            if(!this.loop){
                this.currentTrack = getNextIndexTrack(this.currentTrack, this.tracks.size());
            }

        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private final MediaPlayer.OnCompletionListener onCompletionListener =
            new MediaPlayer.OnCompletionListener() {
                @Override
                public void onCompletion(MediaPlayer mediaPlayer) {
                    currentPlayer = nextPlayer;
                    nextMediaPlayer();
                    mediaPlayer.release();
                }
            };

    public void play() throws IOException{

        currentPlayer.setDataSource(this.binauralServices, tracks.get(this.currentTrack));
        currentPlayer.setVolume(this.volume, this.volume);

        currentPlayer.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
            @Override
            public void onPrepared(MediaPlayer mediaPlayer) {
                currentPlayer.start();
            }
        });
        currentPlayer.prepareAsync();


        if(this.loop) {
            nextMediaPlayer();
        }

        if(!this.loop && this.tracks.size()>1) {
            this.currentTrack = getNextIndexTrack(this.currentTrack, this.tracks.size());
            nextMediaPlayer();
        }

    }

    private int getNextIndexTrack(int currIndex, int size){
        int index = currIndex;
        index++;
        if(size==index){
            index = 0;
        }

        return index;
    }

}
