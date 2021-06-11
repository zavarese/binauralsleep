package com.zavarese.binauralsleep.sound;

import android.annotation.TargetApi;
import android.media.AudioAttributes;
import android.media.AudioFormat;
import android.media.AudioManager;
import android.media.AudioTrack;
import android.os.AsyncTask;
import android.os.Build;

import com.zavarese.binauralsleep.MainActivity;
import com.zavarese.binauralsleep.Utils;

import java.io.IOException;
import java.lang.ref.WeakReference;
import java.util.Calendar;
import java.util.Locale;

import static com.zavarese.binauralsleep.sound.Binaural.paramMinutes;
import static com.zavarese.binauralsleep.sound.Binaural.paramVolume;
import static com.zavarese.binauralsleep.sound.Binaural.player;
import static com.zavarese.binauralsleep.sound.Binaural.sessionId1;
import static com.zavarese.binauralsleep.sound.Binaural.sessionId2;

public class BinauralService extends AsyncTask<Binaural, Void, Integer> {

    private static float currentFrequency = 0;
    private static String isPlaying = "true";
    private static int paramAction;   // 0 - nothing; 1 - stop; 2 - kill
    AudioTrack audioTrack1;
    AudioTrack audioTrack2;
    private static final int LAST_MINUTES = 10;
    private WeakReference<MainActivity> mActivity;

    public BinauralService(MainActivity activity){
        mActivity = new WeakReference<MainActivity>(activity);
    }

    public void stop(Binaural binaural, int action) {
        currentFrequency = 0;
        isPlaying = "false";
        paramAction = action;

        if (audioTrack1 != null && audioTrack1.getPlayState() == AudioTrack.PLAYSTATE_PLAYING) {
            stopAudio(audioTrack1);
        }

        if (audioTrack2 != null && audioTrack2.getPlayState() == AudioTrack.PLAYSTATE_PLAYING) {
            stopAudio(audioTrack2);
        }

        if(player != null && player.isPlaying()){
            player.stop();
            player.release();
            player = null;
        }

        cancel(true);
    }

    private void pauseAudio(AudioTrack audioTrack) {
        if(audioTrack != null && audioTrack.getPlayState()==AudioTrack.PLAYSTATE_PLAYING) {
            isPlaying = "false";
            audioTrack.setVolume(0.00001f);
            Utils.sleepThread(50);
            audioTrack.pause();
            Utils.sleepThread(50);
            audioTrack.flush();
            audioTrack.release();
        }
    }

    private void stopAudio(AudioTrack audioTrack) {
        if(audioTrack != null && audioTrack.getPlayState()==AudioTrack.PLAYSTATE_PLAYING) {
            isPlaying = "false";
            audioTrack.setVolume(paramVolume/2);
            Utils.sleepThread(50);
            audioTrack.setVolume(0f);
            Utils.sleepThread(50);
            audioTrack.stop();
            Utils.sleepThread(50);
            audioTrack.flush();
            audioTrack.release();
        }
    }

    private static float increment(Binaural binaural) {
        return Float.parseFloat(
                String.format(
                        Locale.US, "%.1f",(
                                (binaural.paramIsoBeatMax - binaural.paramIsoBeatMin)/(paramMinutes-LAST_MINUTES)
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

    private void executeAudio(AudioTrack audioCurr, AudioTrack audioNext, Binaural binaural, int minutes) {
        int seconds;

        audioNext.play();
        Utils.sleepThread(50);
        if(audioCurr!=null)audioCurr.setVolume(0.00001f);
        audioNext.setVolume(0.05f);
        Utils.sleepThread(50);
        audioNext.setVolume(paramVolume);
        Utils.sleepThread(50);

        if (audioCurr != null) {
            audioCurr.pause();
            Utils.sleepThread(50);
            audioCurr.flush();
            audioCurr.release();
        }

        Calendar c;

        seconds = minutes * 60;

        do {
            if (isCancelled()) {
                isPlaying = "false";
                break;
            }

            c = Calendar.getInstance();
            if (c.get(Calendar.SECOND) == 0) {
                seconds = seconds - 60;
                Utils.sleepThread(1000);
            }

        } while (seconds>0);
    }

    public float getCurrentFrequency(){
        return currentFrequency;
    }

    public String isPlaying(){
        return isPlaying;
    }

    @Override
    protected Integer doInBackground(Binaural... binaurals) {
        Binaural binaural = binaurals[0];
        float freqEnd = binaural.paramIsoBeatMax - binaural.paramIsoBeatMin;
        isPlaying = "true";
        paramAction = 0;
        float lastFreq = 0;

        if (!binaural.paramPath.equals("")&&!binaural.paramPath.equals("error")) {
            try {
                player.play();
            }catch (Exception e){
                e.printStackTrace();
                isPlaying = "error";
                return paramAction;
            }
        }

        if(binaural.paramDecreasing) {
            for (float freq = 0f; freq <= freqEnd; freq = freq + increment(binaural)) {
                freq = Float.parseFloat(String.format(Locale.US, "%.2f", freq));
                currentFrequency = binaural.paramIsoBeatMax - freq;

                if (audioTrack1 != null && audioTrack1.getPlayState() == AudioTrack.PLAYSTATE_PLAYING){
                    audioTrack2 = wavesBuilder(binaural, sessionId2, freq, -1);
                    executeAudio(audioTrack1, audioTrack2, binaural, 1);
                }else{
                    if (audioTrack2 != null && audioTrack2.getPlayState() == AudioTrack.PLAYSTATE_PLAYING){
                        audioTrack1 = wavesBuilder(binaural, sessionId1, freq, -1);
                        executeAudio(audioTrack2, audioTrack1, binaural, 1);
                    }else{
                        audioTrack1 = wavesBuilder(binaural, sessionId1, freq, -1);
                        executeAudio(null, audioTrack1, binaural, 1);
                    }
                }


                if (paramAction == 1) {
                    break;
                }

                if (paramAction == 2) {
                    return null;
                }

                lastFreq = freq;
            }
        }else{
            for (float freq = freqEnd; freq > 0f; freq = freq - increment(binaural)) {
                freq = Float.parseFloat(String.format(Locale.US, "%.2f", freq));
                currentFrequency = binaural.paramIsoBeatMax - freq;

                if (audioTrack1 != null && audioTrack1.getPlayState() == AudioTrack.PLAYSTATE_PLAYING){
                    audioTrack2 = wavesBuilder(binaural, sessionId2, freq, -1);
                    executeAudio(audioTrack1, audioTrack2, binaural, 1);
                }else{
                    if (audioTrack2 != null && audioTrack2.getPlayState() == AudioTrack.PLAYSTATE_PLAYING){
                        audioTrack1 = wavesBuilder(binaural, sessionId1, freq, -1);
                        executeAudio(audioTrack2, audioTrack1, binaural, 1);
                    }else{
                        audioTrack1 = wavesBuilder(binaural, sessionId1, freq, -1);
                        executeAudio(null, audioTrack1, binaural, 1);
                    }
                }

                if (paramAction == 1) {
                    break;
                }

                if (paramAction == 2) {
                    return null;
                }

                lastFreq = freq;
            }
        }

        if(audioTrack1!=null && audioTrack1.getPlayState() == AudioTrack.PLAYSTATE_PLAYING){
            audioTrack2 = wavesBuilder(binaural, sessionId2, lastFreq, -1);
            executeAudio(audioTrack1, audioTrack2, binaural, LAST_MINUTES);
            stopAudio(audioTrack2);
        }

        if(audioTrack2!=null && audioTrack2.getPlayState() == AudioTrack.PLAYSTATE_PLAYING){
            audioTrack1 = wavesBuilder(binaural, sessionId1, lastFreq, -1);
            executeAudio(audioTrack2, audioTrack1, binaural, LAST_MINUTES);
            stopAudio(audioTrack1);
        }

        currentFrequency = 0;
        isPlaying = "false";

        if(player != null && player.isPlaying()){
            player.stop();
        }

        return paramAction;
    }

    @Override
    protected void onPreExecute() {
        super.onPreExecute();
        if (mActivity.get() == null || mActivity.get().isFinishing()) {
            return;
        }
    }

    protected void onProgressUpdate(Void... values){

        super.onProgressUpdate(values);

        if ( mActivity.get() == null ||  mActivity.get().isFinishing()) {
            return;
        }
    }

    @Override
    protected void onPostExecute(Integer i) {
        super.onPostExecute(i);

        if (mActivity.get() == null || mActivity.get().isFinishing()) {
            return;
        }

    }

}
