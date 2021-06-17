package com.zavarese.binauralsleep.sound;

import android.media.audiofx.Equalizer;
import android.net.Uri;
import com.zavarese.binauralsleep.MainActivity;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import java.util.ArrayList;
import static com.zavarese.binauralsleep.Utils.*;


public class Binaural extends Throwable{

    public int id;
    public String name;
    public float paramFrequency;
    public float paramIsoBeatMax;
    public float paramIsoBeatMin;
    public String waveMin;
    public String waveMax;
    public boolean paramDecreasing;
    public float paramMinutes;
    public float paramVolume;
    public String paramPath;
    public String hasMusic;
    public String lastBeat;
    public Equalizer eq1;
    public Equalizer eq2;
    public static FilePlayer player;
    public static int sessionId1;
    public static int sessionId2;
    public static int sessionId3;
    public static int sessionId4;
    public boolean paramLoop = true;
    public Uri uri;
    public MainActivity mainActivity;

    public Binaural(){};

    public Binaural(Equalizer eq_1, Equalizer eq_2, int sessionID1, int sessionID2, int sessionID3, int sessionID4, MainActivity mainActivity){
        this.eq1 = eq_1;
        this.eq2 = eq_2;
        this.mainActivity = mainActivity;

        sessionId1 = sessionID1;
        sessionId2 = sessionID2;
        sessionId3 = sessionID3;
        sessionId4 = sessionID4;
    };

    public Binaural(int id, String name, float frequency, float isoBeatMin,  float isoBeatMax, boolean decreasing, String path){
        this.id = id;
        this.name = name;
        this.paramFrequency = Math.round(frequency);
        this.paramIsoBeatMin = Math.round(isoBeatMin);
        this.paramIsoBeatMax = Math.round(isoBeatMax);
        this.paramDecreasing = decreasing;
        this.waveMin = waveWord(isoBeatMin);
        this.waveMax = waveWord(isoBeatMax);
        this.paramPath = path;


        if(this.paramPath == null || this.paramPath.equals("")){
            this.hasMusic = "music:no";
        }else{
            this.hasMusic = "music:yes";
        }

        if(this.paramDecreasing){
            this.lastBeat = this.waveMin;
        }else{
            this.lastBeat = this.waveMax;
        }
    }

    public void setConfig(float frequency, float isoBeatMax, float isoBeatMin, float minutes, float volume, boolean decreasing, String path, float volumeMusic, boolean loop, Uri uri) {

        this.paramIsoBeatMax = isoBeatMax;
        this.paramIsoBeatMin = (isoBeatMin==0?0.1f:isoBeatMin);
        this.paramMinutes = minutes;
        this.paramFrequency = frequency;
        this.paramVolume = (path.equals("")?volume:volume/3);
        this.paramDecreasing = decreasing;
        this.paramPath = path;
        this.paramLoop = loop;
        this.uri = uri;

        eq1.setEnabled(true);
        short[] freqRange = eq1.getBandLevelRange();
        short minLvl = freqRange[0];
        short maxLvl = freqRange[1];
        short band = 0;
        short numBand = eq1.getNumberOfBands();
        int frequencyEq = Math.round(paramFrequency);

        eq2.setEnabled(true);

        eq1.setBandLevel((short) 0, maxLvl);
        eq2.setBandLevel((short) 0, maxLvl);

        for(short i=1;i<numBand;i++){
            if(frequencyEq>=getFreqMin(i) && frequencyEq<=getFreqMax(i)){
                eq1.setBandLevel(i, maxLvl);
                eq2.setBandLevel(i, maxLvl);
                band = i;
            }else{
                eq1.setBandLevel(i, minLvl);
                eq2.setBandLevel(i, minLvl);
            }
        }

        System.out.println("band = "+band);

        if (!paramPath.equals("")&&!paramPath.equals("error")) {
                player = new FilePlayer(
                        paramPath,
                        Float.parseFloat(volumeMusic + ""), (short) band, sessionId3, sessionId4, this.paramLoop, this.uri, this.mainActivity);

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
                jsonObject.put("waveMin", ((Binaural)list.get(i)).waveMin);
                jsonObject.put("waveMax", ((Binaural)list.get(i)).waveMax);
                jsonObject.put("path", ((Binaural)list.get(i)).paramPath);
                jsonObject.put("frequency", ((Binaural)list.get(i)).paramFrequency);
                jsonObject.put("decreasing", ((Binaural)list.get(i)).paramDecreasing);
                jsonObject.put("hasMusic", ((Binaural)list.get(i)).hasMusic);
                jsonObject.put("lastBeat", ((Binaural)list.get(i)).lastBeat);

                jsonArray.put(jsonObject);
            }

            return jsonArray.toString();
        } catch (JSONException e) {
            e.printStackTrace();
            return "";
        }

    }
}
