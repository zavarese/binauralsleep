package com.zavarese.binauralsleep;

import android.app.Activity;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.graphics.Color;
import android.media.AudioManager;
import android.media.audiofx.Equalizer;
import android.net.Uri;
import android.os.IBinder;
import android.text.SpannableString;
import android.text.style.AbsoluteSizeSpan;
import android.text.style.ForegroundColorSpan;
import android.view.View;
import android.widget.Toast;
import com.zavarese.binauralsleep.dao.ConfigDAO;
import com.zavarese.binauralsleep.sound.Binaural;
import com.zavarese.binauralsleep.sound.BinauralServices;
import com.zavarese.binauralsleep.sound.SoundListener;

import java.util.ArrayList;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity implements ServiceConnection {
    private static final String CHANNEL = "com.zavarese.binauralsleep/binaural";
    private Binaural binaural;
    private static AudioManager audioManager;
    private static int sessionID1;
    private static int sessionID2;
    private static int sessionID3;
    private static int sessionID4;
    private ConfigDAO configDAO = new ConfigDAO(this);
    //private static final int CHOOSE_FILE_REQUESTCODE = 8777;
    private static final int PICKFILE_RESULT_CODE = 8778;
    private String path="";
    private Uri uri;
    private ServiceConnection connection;
    Intent intent;
    private SoundListener soundListener;
    ArrayList<Uri> uris;


    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        audioManager = (AudioManager) getContext().getSystemService(Context.AUDIO_SERVICE);
        sessionID1 = audioManager.generateAudioSessionId();
        sessionID2 = audioManager.generateAudioSessionId();
        sessionID3 = audioManager.generateAudioSessionId();
        sessionID4 = audioManager.generateAudioSessionId();
        binaural = new Binaural();
        connection = this;
        uris = new ArrayList<Uri>();

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    switch (call.method) {

                        case "play":

                            this.path = call.argument("path");

                            intent = new Intent(this, BinauralServices.class);

                            intent.putExtra("sessionId1",sessionID1);
                            intent.putExtra("sessionId2",sessionID2);
                            intent.putExtra("sessionId3",sessionID3);
                            intent.putExtra("sessionId4",sessionID4);
                            intent.putExtra("frequency",Float.parseFloat(call.argument("frequency").toString()));
                            intent.putExtra("isoBeatMax",Float.parseFloat(call.argument("isoBeatMax").toString()));
                            intent.putExtra("isoBeatMin",Float.parseFloat(call.argument("isoBeatMin").toString()));
                            intent.putExtra("minutes",Float.parseFloat(call.argument("minutes").toString()));
                            intent.putExtra("volumeWave",Float.parseFloat(call.argument("volumeWave"))/10);
                            intent.putExtra("decreasing",Boolean.parseBoolean(call.argument("decreasing").toString()));
                            intent.putExtra("path",this.path);
                            intent.putExtra("volumeMusic",Float.parseFloat(call.argument("volumeMusic"))/10);
                            intent.putExtra("loop",Boolean.parseBoolean(call.argument("loop").toString()));
                            intent.putParcelableArrayListExtra(Intent.EXTRA_STREAM,uris);

                            startService();

                            result.success(this.path);
                            break;

                        case "stop" :
                            stopService();
                            result.success("");
                            break;

                        case "track" :
                            result.success(soundListener.getCurrentFrequency()+"");
                            break;

                        case "init" :
                            result.success(binaural.getFreqMin((short)1)+","+binaural.getFreqMax((short)1));
                            break;

                        case "playing" :
                            result.success(soundListener.isPlaying()+"");
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
                                            call.argument("path"),
                                            Float.parseFloat(call.argument("minutes"))
                            ));

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
                                            call.argument("path"),
                                            Float.parseFloat(call.argument("minutes"))
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
                            result.success(binaural.toJSON(configDAO.listConfig()));
                            break;

                        case "file_explorer" :
                            this.path = "";
                            openFileExplorer();
                            result.success("ok");
                            break;

                        case "config" :
                            binaural = configDAO.config(Integer.parseInt(call.argument("id")));
                            result.success(binaural.name+","+binaural.paramIsoBeatMin+","+binaural.paramIsoBeatMax+","+binaural.paramFrequency);
                            break;
                    }
                });

    }

    protected void onDestroy() {
        stopService();
        super.onDestroy();
    }

    protected void onResume(){
        //this.setVolumeControlStream(AudioManager.STREAM_MUSIC);
        super.onResume();
    }

    private void startService() {
        bindService(intent, connection, Context.BIND_AUTO_CREATE);
        startService(intent);
    }

    private void stopService() {
        stopService(intent);
        unbindService(connection);
    }

    @Override
    public void onServiceConnected(ComponentName componentName, IBinder service) {
        BinauralServices.Controller controller = (BinauralServices.Controller) service;
        soundListener = controller.getSoundListener();
    }

    @Override
    public void onServiceDisconnected(ComponentName componentName) {

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
        //intent = new Intent(Intent.ACTION_PICK, android.provider.MediaStore.Audio.Media.EXTERNAL_CONTENT_URI);
        //startActivityForResult(intent, PICKFILE_RESULT_CODE);

        intent = new Intent(Intent.ACTION_OPEN_DOCUMENT);
        intent.addCategory(Intent.CATEGORY_OPENABLE);
        intent.setType("*/*");
        intent.putExtra(Intent.EXTRA_ALLOW_MULTIPLE, true);
        String[] mimetypes = {"audio/mpeg", "audio/x-wav"};
        intent.putExtra(Intent.EXTRA_MIME_TYPES, mimetypes);

        startActivityForResult(intent, PICKFILE_RESULT_CODE);
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        uris = new ArrayList<Uri>();
        if (requestCode == PICKFILE_RESULT_CODE && resultCode == Activity.RESULT_OK){
            if(null != data) { // checking empty selection
                if(null != data.getClipData()) { // checking multiple selection or not
                    for(int i = 0; i < data.getClipData().getItemCount(); i++) {
                        uris.add(data.getClipData().getItemAt(i).getUri());
                    }
                } else {
                    uris.add(data.getData());
                }
                this.path = "ok";
            }

            //this.audioID = data.getDataString();
        }else{
            this.path = "error";
        }
    }
}
