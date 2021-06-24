package com.zavarese.binauralsleep.sound;

import android.media.MediaPlayer;
import android.media.audiofx.Equalizer;
import android.net.Uri;

import java.io.IOException;
import java.util.ArrayList;

public class FilePlayer {
    public MediaPlayer currentPlayer;
    private static Equalizer eqCurr;
    private static float volume;
    private MediaPlayer nextPlayer;
    private static short channel;
    private static int sessionId1;
    private static boolean loop;
    private ArrayList<Uri> tracks;
    private int currentTrack;
    private static BinauralServices context;

    public FilePlayer(float volumeMusic, short band, int sessionID1, boolean isLoop, ArrayList<Uri> uris, BinauralServices binauralServices){

        volume = volumeMusic;
        this.currentPlayer = new MediaPlayer();
        this.nextPlayer = new MediaPlayer();
        channel = band;
        sessionId1 = sessionID1;
        loop = isLoop;
        this.tracks = uris;
        context = binauralServices;
        this.currentTrack = 0;

        this.currentPlayer.setAudioSessionId(sessionId1);
        eqCurr = new Equalizer(Integer.MAX_VALUE,sessionId1);
        eqCurr.setEnabled(true);
        short[] freqRange1 = eqCurr.getBandLevelRange();
        short minLvl1 = freqRange1[0];
        eqCurr.setBandLevel(channel,minLvl1);
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
        if(this.currentTrack==0 && !loop){
            return;
        }

        if(loop){
            this.currentTrack = getNextIndexTrack(this.currentTrack, this.tracks.size());
        }

        this.nextPlayer = new MediaPlayer();

        try {
            this.nextPlayer.setDataSource(context, tracks.get(currentTrack));
            this.nextPlayer.setVolume(volume, volume);
            this.nextPlayer.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
                @Override
                public void onPrepared(MediaPlayer mp) {
                    nextPlayer.seekTo(0);
                    currentPlayer.setNextMediaPlayer(nextPlayer);
                    currentPlayer.setOnCompletionListener(onCompletionListener);
                }
            });
            nextPlayer.prepareAsync();

            if(!loop){
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

        currentPlayer.setDataSource(context, tracks.get(this.currentTrack));
        currentPlayer.setVolume(volume, volume);

        currentPlayer.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
            @Override
            public void onPrepared(MediaPlayer mediaPlayer) {
                currentPlayer.start();
            }
        });
        currentPlayer.prepareAsync();


        if(loop) {
            nextMediaPlayer();
        }

        if(!loop && this.tracks.size()>1) {
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
