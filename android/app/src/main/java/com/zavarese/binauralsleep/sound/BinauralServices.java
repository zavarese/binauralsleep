package com.zavarese.binauralsleep.sound;

import android.annotation.TargetApi;
import android.app.Service;
import android.content.Intent;
import android.media.AudioAttributes;
import android.media.AudioFormat;
import android.media.AudioManager;
import android.media.AudioTrack;
import android.net.Uri;
import android.os.Binder;
import android.os.Build;
import android.os.Bundle;
import android.os.IBinder;
import android.os.Parcelable;

import com.zavarese.binauralsleep.Utils;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Locale;

public class BinauralServices extends Service implements SoundListener {
    private float currentFrequency = 0;
    private String isPlaying = "true";
    private AudioTrack audioTrack1;
    private AudioTrack audioTrack2;
    private static final int LAST_MINUTES = 10;
    private Controller controller = new Controller();
    private Binaural binaural;
    private static ExecThread execThread;

    //to get service connection
    public class Controller extends Binder {
        public SoundListener getSoundListener(){
            return (BinauralServices.this);
        }
    }

    class ExecThread extends Thread {

        ExecThread() {}

        public void run(){
            try {
                float freqEnd = binaural.paramIsoBeatMax - binaural.paramIsoBeatMin;
                isPlaying = "true";
                float lastFreq = 0;

                if (!binaural.paramPath.equals("") && !binaural.paramPath.equals("error")) {
                    try {
                        binaural.player.play();
                    } catch (Exception e) {
                        e.printStackTrace();
                        isPlaying = "error";
                        interrupt();
                    }
                }

                if (binaural.paramDecreasing) {
                    for (float freq = 0f; freq <= freqEnd; freq = freq + increment(binaural)) {
                        freq = Float.parseFloat(String.format(Locale.US, "%.2f", freq));
                        currentFrequency = binaural.paramIsoBeatMax - freq;

                        System.out.println("************ currentFrequency = "+ currentFrequency);
                        System.out.println("************ increment = "+ increment(binaural));

                        if(!isPlaying.equals("true"))break;

                        if (audioTrack1 != null && audioTrack1.getPlayState() == AudioTrack.PLAYSTATE_PLAYING) {
                            audioTrack2 = wavesBuilder(binaural, binaural.sessionId2, freq, -1);
                            executeAudio(audioTrack1, audioTrack2, binaural.paramVolume, binaural.paramSeconds);
                        } else {
                            if (audioTrack2 != null && audioTrack2.getPlayState() == AudioTrack.PLAYSTATE_PLAYING) {
                                audioTrack1 = wavesBuilder(binaural, binaural.sessionId1, freq, -1);
                                executeAudio(audioTrack2, audioTrack1, binaural.paramVolume, binaural.paramSeconds);
                            } else {
                                audioTrack1 = wavesBuilder(binaural, binaural.sessionId1, freq, -1);
                                executeAudio(null, audioTrack1, binaural.paramVolume, binaural.paramSeconds);
                            }
                        }

                        lastFreq = freq;
                    }
                } else {
                    for (float freq = freqEnd; freq > 0f; freq = freq - increment(binaural)) {
                        freq = Float.parseFloat(String.format(Locale.US, "%.2f", freq));
                        currentFrequency = binaural.paramIsoBeatMax - freq;

                        if(!isPlaying.equals("true"))break;

                        if (audioTrack1 != null && audioTrack1.getPlayState() == AudioTrack.PLAYSTATE_PLAYING) {
                            audioTrack2 = wavesBuilder(binaural, binaural.sessionId2, freq, -1);
                            executeAudio(audioTrack1, audioTrack2, binaural.paramVolume, binaural.paramSeconds);
                        } else {
                            if (audioTrack2 != null && audioTrack2.getPlayState() == AudioTrack.PLAYSTATE_PLAYING) {
                                audioTrack1 = wavesBuilder(binaural, binaural.sessionId1, freq, -1);
                                executeAudio(audioTrack2, audioTrack1, binaural.paramVolume, binaural.paramSeconds);
                            } else {
                                audioTrack1 = wavesBuilder(binaural, binaural.sessionId1, freq, -1);
                                executeAudio(null, audioTrack1, binaural.paramVolume, binaural.paramSeconds);
                            }
                        }

                        lastFreq = freq;
                    }
                }

                if (audioTrack1 != null && audioTrack1.getPlayState() == AudioTrack.PLAYSTATE_PLAYING) {
                    audioTrack2 = wavesBuilder(binaural, binaural.sessionId2, lastFreq, -1);
                    executeAudio(audioTrack1, audioTrack2, binaural.paramVolume, LAST_MINUTES*60);
                    stopAudio(audioTrack2);
                }

                if (audioTrack2 != null && audioTrack2.getPlayState() == AudioTrack.PLAYSTATE_PLAYING) {
                    audioTrack1 = wavesBuilder(binaural, binaural.sessionId1, lastFreq, -1);
                    executeAudio(audioTrack2, audioTrack1, binaural.paramVolume, LAST_MINUTES*60);
                    stopAudio(audioTrack1);
                }

                currentFrequency = 0;

                if (binaural.player != null && binaural.player.isPlaying()) {
                    binaural.player.stop();
                    binaural.player.release();
                }

                isPlaying = "false";
            }catch (Exception e){
                e.printStackTrace();
            }
        }
    }

    @Override
    public void onCreate() {
        // The service is being created
        execThread = new ExecThread();
    }


    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        binaural = new Binaural();
        Bundle extras = intent.getExtras();

        binaural = new Binaural(extras.getInt("sessionId1"), extras.getInt("sessionId2"), extras.getInt("sessionId3"), extras.getInt("sessionId4"), this);

        binaural.setConfig(
                extras.getFloat("frequency"),
                extras.getFloat("isoBeatMax"),
                extras.getFloat("isoBeatMin"),
                extras.getFloat("minutes"),
                extras.getFloat("volumeWave"),
                extras.getBoolean("decreasing"),
                extras.getString("path"),
                extras.getFloat("volumeMusic"),
                extras.getBoolean("loop"),
                (ArrayList<Uri>) extras.getSerializable(Intent.EXTRA_STREAM),
                extras.getFloat("seconds")
        );

        execThread.start();

        return START_NOT_STICKY;
    }

    @Override
    public IBinder onBind(Intent intent) {

        return controller;
    }

    @Override
    public void onDestroy() {
        // The service is no longer used and is being destroyed
        stop();
        super.onDestroy();
    }

    @Override
    public boolean onUnbind(Intent intent)
    {
        return true;  //Return to allow binding
    }


    public void stop() {
        currentFrequency = 0;
        isPlaying = "false";

        if (audioTrack1 != null && audioTrack1.getPlayState() == AudioTrack.PLAYSTATE_PLAYING) {
            stopAudio(audioTrack1);
        }

        if (audioTrack2 != null && audioTrack2.getPlayState() == AudioTrack.PLAYSTATE_PLAYING) {
            stopAudio(audioTrack2);
        }
    }

    private void stopAudio(AudioTrack audioTrack) {
        try {
            if (audioTrack != null && audioTrack.getPlayState() == AudioTrack.PLAYSTATE_PLAYING) {
                audioTrack.setVolume(0.00001f);
                Utils.sleepThread(50);
                audioTrack.setVolume(0f);
                Utils.sleepThread(50);
                audioTrack.stop();
                Utils.sleepThread(50);
                audioTrack.flush();
                audioTrack.release();
            }
        }catch (Exception ignored){}
    }

    private static float increment(Binaural binaural) {
        return Float.parseFloat(
                String.format(
                        Locale.US, "%.2f",(
                                (binaural.paramIsoBeatMax - binaural.paramIsoBeatMin)/((binaural.paramMinutes-LAST_MINUTES)*(60/binaural.paramSeconds))
                        )
                )
        );
    }

    @TargetApi(Build.VERSION_CODES.M)
    private AudioTrack wavesBuilder(Binaural binaural, int sessionId, float decrease,int loopCount) {
        AudioTrack audioTrack;

        float freqLeft = binaural.paramFrequency - ((binaural.paramIsoBeatMax - decrease) / 2);
        float freqRight = binaural.paramFrequency + ((binaural.paramIsoBeatMax - decrease) / 2);

        int sampleRate = AudioTrack.getNativeOutputSampleRate(AudioManager.STREAM_MUSIC);
        int minSize = AudioTrack.getMinBufferSize(sampleRate, AudioFormat.CHANNEL_OUT_STEREO,AudioFormat.ENCODING_PCM_16BIT);
        //int amplitudeMax = Utils.getAmplitudeMax(minSize);

        int amplitudeMax = Utils.getAdjustedAmplitudeMax(binaural.paramFrequency, minSize);
        System.out.println("amplitudeMax = "+amplitudeMax);

        //period of the sine waves
        int sCountLeft = (int) ((float) sampleRate / freqLeft);
        int sCountRight = (int) ((float) sampleRate / freqRight);

        int sampleCount = Utils.getLCM(sCountLeft, sCountRight) * 2;

        int buffSize = sampleCount * 4;

        audioTrack = new AudioTrack.Builder()
                .setAudioAttributes(new AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_MEDIA)
                        .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                        .build())
                .setAudioFormat(new AudioFormat.Builder()
                        .setChannelMask(AudioFormat.CHANNEL_OUT_STEREO)
                        .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                        .setSampleRate(sampleRate)
                        .build())
                .setBufferSizeInBytes(buffSize)
                .setTransferMode(AudioTrack.MODE_STATIC)
                .setSessionId(sessionId)
                .build();

        audioTrack.setVolume(0.00001f);

        short samples[] = new short[sampleCount];
        int amplitude = amplitudeMax;
        double twopi = 8. * Math.atan(1.);

        double leftPhase = amplitude*-8;
        double rightPhase = amplitude*-8;

        for (int i = 0; i < sampleCount; i = i + 2) {

            samples[i] = (short) (amplitude * Math.sin(leftPhase));
            samples[i + 1] = (short) (amplitude * Math.sin(rightPhase));

            if (i / 2 % sCountLeft == 0) {
                leftPhase = amplitude*-8;
            }
            leftPhase += twopi * freqLeft / sampleRate;
            if (i / 2 % sCountRight == 0) {
                rightPhase = amplitude*-8;
            }
            rightPhase += twopi * freqRight / sampleRate;
        }

        audioTrack.write(samples, 0, sampleCount);
        audioTrack.reloadStaticData();
        audioTrack.setLoopPoints(0, sampleCount / 2, loopCount);

        return audioTrack;

    }

    private void executeAudio(AudioTrack audioCurr, AudioTrack audioNext, float volume, float seconds) {
        boolean exit = true;

        audioNext.play();
        Utils.sleepThread(50);
        if(audioCurr!=null)audioCurr.setVolume(0.00001f);
        audioNext.setVolume(volume/4);


        if (audioCurr != null && audioCurr.getPlayState() == AudioTrack.PLAYSTATE_PLAYING) {
            Utils.sleepThread(50);
            audioCurr.pause();
            Utils.sleepThread(50);
            audioCurr.flush();
            audioCurr.release();
        }

        Calendar c;

        do {
            if(!isPlaying.equals("true"))break;

            for (int i=0;i<60;i=i+Math.round(seconds)) {
                c = Calendar.getInstance();
                if (c.get(Calendar.SECOND) == i) {
                    exit = false;
                }
            }
            Utils.sleepThread(1000);

        } while (exit);
    }

    public float getCurrentFrequency(){
        return currentFrequency;
    }

    public String isPlaying(){
        return isPlaying;
    }
}
