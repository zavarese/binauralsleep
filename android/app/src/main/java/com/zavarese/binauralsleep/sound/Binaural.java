package com.zavarese.binauralsleep.sound;

import android.annotation.TargetApi;
import android.media.audiofx.AudioEffect;
import android.media.audiofx.Equalizer;
import android.os.Build;

import com.zavarese.binauralsleep.sound.FilePlayer;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;


public class Binaural{

    public int id;
    public String name;
    public float paramFrequency;
    public float paramIsoBeatMax;
    public float paramIsoBeatMin;
    public static float paramMinutes;
    public static float paramVolume;
    public static String paramURL;
    public boolean paramDecreasing;
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
        short band = 0;
        short numBand = eq1.getNumberOfBands();
        int frequencyEq = Math.round(paramFrequency);

        eq2 = new Equalizer(Integer.MAX_VALUE,sessionID2);
        eq2.setEnabled(true);

        eq1.setBandLevel((short) 0, maxLvl);
        eq2.setBandLevel((short) 0, maxLvl);

        for(short i=1;i<numBand;i++){
            if(frequencyEq>=getFreqMin(i) && frequencyEq<=getFreqMax(i)){
                eq1.setBandLevel((short) i, maxLvl);
                eq2.setBandLevel((short) i, maxLvl);
                System.out.println("BandNum = "+i);
                band = i;
            }else{
                eq1.setBandLevel((short) i, minLvl);
                eq2.setBandLevel((short) i, minLvl);
                System.out.println("BandNum = "+i);
            }
        }

        if (!paramURL.equals("none")) {

            player = new FilePlayer(
                    paramURL,
                    Float.parseFloat(volumeNoise+""), (short)band, sessionId3, sessionId4, this.paramLoop);

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


    public String toJSON(ArrayList<Binaural> list){
        JSONObject jsonObject;
        JSONArray jsonArray = new JSONArray();

        try {

            for (int i = 0; i < list.size(); i++) {
                jsonObject= new JSONObject();
                jsonObject.put("id", ((Binaural)list.get(i)).id);
                jsonObject.put("name", ((Binaural)list.get(i)).name);
                jsonObject.put("isoBeatMin", ((Binaural)list.get(i)).paramIsoBeatMin);
                jsonObject.put("isoBeatMax", ((Binaural)list.get(i)).paramIsoBeatMax);
                jsonObject.put("frequency", ((Binaural)list.get(i)).paramFrequency);
                jsonObject.put("decreasing", ((Binaural)list.get(i)).paramDecreasing);

                jsonArray.put(jsonObject);
            }

            return jsonArray.toString();
        } catch (JSONException e) {
            e.printStackTrace();
            return "";
        }

    }
}
