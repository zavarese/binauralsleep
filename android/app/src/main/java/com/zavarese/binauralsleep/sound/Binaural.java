package com.zavarese.binauralsleep.sound;

import android.annotation.TargetApi;
import android.media.audiofx.Equalizer;
import android.os.Build;

import com.zavarese.binauralsleep.sound.FilePlayer;


public class Binaural{

    public static int id;
    public static String name;
    public static float paramFrequency;
    public static float paramIsoBeatMax;
    public static float paramIsoBeatMin;
    public static float paramMinutes;
    public static float paramVolume;
    public static String paramURL;
    public static boolean paramDecreasing;
    public static Equalizer eq1;
    public static Equalizer eq2;
    public static FilePlayer player;
    public static int sessionId1;
    public static int sessionId2;
    public static int sessionId3;
    public static int sessionId4;
    public static boolean paramLoop = true;

    public Binaural(){};

    public Binaural(int id, String name, float frequency, float isoBeatMin, float isoBeatMax, boolean decreasing){
        this.id = id;
        this.name = name;
        this.paramFrequency = frequency;
        this.paramIsoBeatMin = isoBeatMin;
        this.paramIsoBeatMax = isoBeatMax;
        this.paramDecreasing = decreasing;
    }

    @TargetApi(Build.VERSION_CODES.M)
    public void config(int sessionID1, int sessionID2, int sessionID3, int sessionID4, float frequency, float isoBeatMax, float isoBeatMin, float minutes, float volume, boolean decreasing, String url, float volumeNoise, boolean loop) {

        paramIsoBeatMax = isoBeatMax;
        paramIsoBeatMin = (isoBeatMin==0?0.1f:isoBeatMin);
        paramMinutes = minutes;
        paramFrequency = frequency;
        paramVolume = volume;
        paramDecreasing = decreasing;
        paramURL = url;
        paramLoop = loop;

        sessionId1 = sessionID1;
        sessionId2 = sessionID2;
        sessionId3 = sessionID3;
        sessionId4 = sessionID4;

        eq1 = new Equalizer(Integer.MAX_VALUE,sessionID1);
        eq1.setEnabled(true);
        short[] freqRange = eq1.getBandLevelRange();
        short minLvl = freqRange[0];
        short maxLvl = freqRange[1];

        eq2 = new Equalizer(Integer.MAX_VALUE,sessionID2);
        eq2.setEnabled(true);

        eq1.setBandLevel((short) 0, maxLvl);
        eq1.setBandLevel((short) 1, maxLvl);
        eq1.setBandLevel((short) 2, minLvl);
        eq1.setBandLevel((short) 3, minLvl);
        eq1.setBandLevel((short) 4, minLvl);

        eq2.setBandLevel((short) 0, maxLvl);
        eq2.setBandLevel((short) 1, maxLvl);
        eq2.setBandLevel((short) 2, minLvl);
        eq2.setBandLevel((short) 3, minLvl);
        eq2.setBandLevel((short) 4, minLvl);

        if (!paramURL.equals("none")) {

            player = new FilePlayer(
                    paramURL,
                    Float.parseFloat(volumeNoise+""), (short)1, sessionId3, sessionId4, this.paramLoop);

        }
    }

    public int getFreqMin(short channel){
        Equalizer eq = new Equalizer(Integer.MAX_VALUE,1);
        int[] frequencyBand = eq.getBandFreqRange((short)channel);
        return frequencyBand[0]/1000;
    }

    public int getFreqMax(short channel){
        Equalizer eq = new Equalizer(Integer.MAX_VALUE,1);
        int[] frequencyBand = eq.getBandFreqRange((short)channel);
        return frequencyBand[1]/1000;
    }

}
