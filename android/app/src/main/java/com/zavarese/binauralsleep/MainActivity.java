package com.zavarese.binauralsleep;

import android.content.Context;
import android.graphics.Color;
import android.graphics.PorterDuff;
import android.graphics.Typeface;
import android.media.AudioManager;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import com.zavarese.binauralsleep.dao.ConfigDAO;
import com.zavarese.binauralsleep.sound.Binaural;
import com.zavarese.binauralsleep.sound.BinauralService;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.zavarese.binauralsleep/binaural";
    Binaural binaural = new Binaural();
    BinauralService wave;
    private static AudioManager audioManager;
    int sessionID1;
    int sessionID2;
    int sessionID3;
    int sessionID4;
    ConfigDAO configDAO = new ConfigDAO(this);

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        audioManager = (AudioManager) getContext().getSystemService(Context.AUDIO_SERVICE);
        sessionID1 = audioManager.generateAudioSessionId();
        sessionID2 = audioManager.generateAudioSessionId();
        sessionID3 = audioManager.generateAudioSessionId();
        sessionID4 = audioManager.generateAudioSessionId();

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    switch (call.method) {
                        case "play":
                            binaural.config(sessionID1, sessionID2, sessionID3, sessionID4,
                                    Float.parseFloat(call.argument("frequency")),
                                    Float.parseFloat(call.argument("isoBeatMax")),
                                    Float.parseFloat(call.argument("isoBeatMin")),
                                    Float.parseFloat(call.argument("minutes")),
                                    Float.parseFloat(call.argument("volumeWave"))/10,
                                    Boolean.parseBoolean(call.argument("decreasing")),
                                    call.argument("url"),
                                    Float.parseFloat(call.argument("volumeNoise"))/10,
                                    Boolean.parseBoolean(call.argument("loop"))
                                    );
                            wave = new BinauralService();
                            wave.execute(binaural);

                            result.success("");
                            break;

                        case "stop" :
                            wave.stop(binaural, 1);
                            result.success("");
                            break;

                        case "track" :
                            result.success(wave.getCurrentFrequency()+"");
                            break;

                        case "init" :
                            result.success(binaural.getFreqMin((short)1)+","+binaural.getFreqMax((short)1));
                            break;

                        case "playing" :
                            if(wave.isPlaying()){
                                result.success("true");
                            }else{
                                result.success("false");
                            }
                            break;

                        case "insert" :
                            configDAO.addConfig(
                                    new Binaural(
                                            0,
                                            call.argument("name"),
                                            Float.parseFloat(call.argument("frequency")),
                                            Float.parseFloat(call.argument("isoBeatMin")),
                                            Float.parseFloat(call.argument("isoBeatMax")),
                                            Boolean.parseBoolean(call.argument("decreasing"))
                            ));

                            //Toast.makeText(this, "Config added",2).show();
                            showMessage("Configuration created");
                            result.success("");
                            break;

                        case "update" :
                            System.out.println("ID = "+call.argument("id"));
                            configDAO.updateConfig(
                                    new Binaural(
                                            call.argument("id"),
                                            call.argument("name"),
                                            Float.parseFloat(call.argument("frequency")),
                                            Float.parseFloat(call.argument("isoBeatMin")),
                                            Float.parseFloat(call.argument("isoBeatMax")),
                                            Boolean.parseBoolean(call.argument("decreasing"))
                            ));

                            showMessage("Configuration updated");
                            result.success("");
                            break;

                        case "delete" :
                            configDAO.deleteConfig(call.argument("id"));
                            showMessage("Configuration deleted");
                            result.success("");
                            break;

                        case "list" :
                            result.success(binaural.toJSON(configDAO.listConfig()));
                            break;

                        case "config" :
                            binaural = configDAO.config(Integer.parseInt(call.argument("id")));
                            result.success(binaural.name+","+binaural.paramIsoBeatMin+","+binaural.paramIsoBeatMax+","+binaural.paramFrequency);
                            break;
                    }
                });

    }

    protected void onDestroy() {
        wave.stop(binaural,2);
        super.onDestroy();
    }

    protected void onResume(){
        //this.setVolumeControlStream(AudioManager.STREAM_MUSIC);
        super.onResume();
    }

    private void showMessage(String message){
        Toast toast = Toast.makeText(this, message, Toast.LENGTH_LONG);
        View view = toast.getView();

        //Gets the actual oval background of the Toast then sets the colour filter
        view.getBackground().setColorFilter(Color.parseColor("#FF607D8B"), PorterDuff.Mode.SRC_IN);

        //Gets the TextView from the Toast so it can be editted
        TextView text = view.findViewById(android.R.id.message);
        text.setTextColor(Color.WHITE);
        text.setTypeface(null, Typeface.BOLD);

        toast.show();
    }
}
