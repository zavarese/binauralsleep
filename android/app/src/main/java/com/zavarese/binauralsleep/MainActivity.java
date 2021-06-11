package com.zavarese.binauralsleep;

import android.Manifest;
import android.app.Activity;
import android.content.ContentResolver;
import android.content.ContentValues;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.graphics.Color;
import android.graphics.PorterDuff;
import android.graphics.Typeface;
import android.media.AudioManager;
import android.net.Uri;
import android.os.Build;
import android.provider.MediaStore;
import android.text.SpannableString;
import android.text.style.AbsoluteSizeSpan;
import android.text.style.ForegroundColorSpan;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;
import com.zavarese.binauralsleep.dao.ConfigDAO;
import com.zavarese.binauralsleep.sound.Binaural;
import com.zavarese.binauralsleep.sound.BinauralService;

import java.io.File;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.zavarese.binauralsleep/binaural";
    private Binaural binaural = new Binaural();
    private BinauralService wave;
    private static AudioManager audioManager;
    private int sessionID1;
    private int sessionID2;
    private int sessionID3;
    private int sessionID4;
    private ConfigDAO configDAO = new ConfigDAO(this);
    //private static final int CHOOSE_FILE_REQUESTCODE = 8777;
    private static final int PICKFILE_RESULT_CODE = 8778;
    private String path;
    private Uri uri;
    //private String audioID;

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
                            System.out.println("call.argument(path) = "+call.argument("path"));

                            binaural.config(sessionID1, sessionID2, sessionID3, sessionID4,
                                    Float.parseFloat(call.argument("frequency")),
                                    Float.parseFloat(call.argument("isoBeatMax")),
                                    Float.parseFloat(call.argument("isoBeatMin")),
                                    Float.parseFloat(call.argument("minutes")),
                                    Float.parseFloat(call.argument("volumeWave"))/10,
                                    Boolean.parseBoolean(call.argument("decreasing")),
                                    call.argument("path"),
                                    Float.parseFloat(call.argument("volumeNoise"))/10,
                                    Boolean.parseBoolean(call.argument("loop")),
                                    this.uri,
                                    this
                            );


                            wave = new BinauralService(this);
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
                            result.success(wave.isPlaying());
                            break;

                        case "insert" :
                            long id = configDAO.addConfig(
                                    new Binaural(
                                            0,
                                            call.argument("name"),
                                            Float.parseFloat(call.argument("frequency")),
                                            Float.parseFloat(call.argument("isoBeatMin")),
                                            Float.parseFloat(call.argument("isoBeatMax")),
                                            Boolean.parseBoolean(call.argument("decreasing")),
                                            call.argument("path")
                            ));

                            //Toast.makeText(this, "Config added",2).show();
                            spanMessage("Configuration created");
                            result.success(id+"");
                            break;

                        case "update" :
                            configDAO.updateConfig(
                                    new Binaural(
                                            call.argument("id"),
                                            call.argument("name"),
                                            Float.parseFloat(call.argument("frequency")),
                                            Float.parseFloat(call.argument("isoBeatMin")),
                                            Float.parseFloat(call.argument("isoBeatMax")),
                                            Boolean.parseBoolean(call.argument("decreasing")),
                                            call.argument("path")
                            ));

                            spanMessage("Configuration updated");
                            result.success("");
                            break;

                        case "delete" :
                            configDAO.deleteConfig(call.argument("id"));
                            spanMessage("Configuration deleted");
                            result.success("");
                            break;

                        case "list" :
                            System.out.println("LIST BD");
                            result.success(binaural.toJSON(configDAO.listConfig()));
                            break;

                        case "file_explorer" :
                            this.path = "";
                            openFileExplorer();
                            result.success("OK");
                            break;

                        case "get_music" :
                            result.success(this.path);
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

    private void spanMessage(String message){
        SpannableString spannableString = new SpannableString(message);
        spannableString.setSpan(
                new ForegroundColorSpan(Color.GREEN), 0, spannableString.length(), 0
        );
        spannableString.setSpan(
                new AbsoluteSizeSpan(45), 0, spannableString.length(), 0
        );
        Toast toast = Toast.makeText(this, spannableString, Toast.LENGTH_SHORT);
        toast.show();
    }

    private void openFileExplorer(){
        Intent intent;
        intent = new Intent(Intent.ACTION_PICK, android.provider.MediaStore.Audio.Media.EXTERNAL_CONTENT_URI);
        startActivityForResult(intent, PICKFILE_RESULT_CODE);

    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        if (requestCode == PICKFILE_RESULT_CODE && resultCode == Activity.RESULT_OK){
            this.uri = data.getData();
            this.path = uri.getPath();
            System.out.println("this.path = "+uri.getPath());
            //this.audioID = data.getDataString();
        }else{
            this.path = "error";
        }

    }

}
