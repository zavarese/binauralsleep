package com.zavarese.binauralsleep;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.media.AudioManager;
import android.media.audiofx.Equalizer;
import android.net.Uri;
import android.text.SpannableString;
import android.text.style.AbsoluteSizeSpan;
import android.text.style.ForegroundColorSpan;
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
    private Binaural binaural;
    private BinauralService wave;
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
    Equalizer eq1;
    Equalizer eq2;

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        audioManager = (AudioManager) getContext().getSystemService(Context.AUDIO_SERVICE);
        sessionID1 = audioManager.generateAudioSessionId();
        sessionID2 = audioManager.generateAudioSessionId();
        sessionID3 = audioManager.generateAudioSessionId();
        sessionID4 = audioManager.generateAudioSessionId();

        eq1 = new Equalizer(Integer.MAX_VALUE,sessionID1);
        eq2 = new Equalizer(Integer.MAX_VALUE,sessionID2);

        binaural = new Binaural(eq1, eq2, sessionID1, sessionID2, sessionID3, sessionID4, this);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    switch (call.method) {

                        case "play":
                            System.out.println("call.argument(path) = "+call.argument("path"));
                            //broadcastIntent();

                            if (this.path.equals("error")) {
                                this.path = "";
                            }else{
                                this.path = call.argument("path");
                            }

                            binaural.setConfig(Float.parseFloat(call.argument("frequency")),
                                    Float.parseFloat(call.argument("isoBeatMax")),
                                    Float.parseFloat(call.argument("isoBeatMin")),
                                    Float.parseFloat(call.argument("minutes")),
                                    Float.parseFloat(call.argument("volumeWave"))/10,
                                    Boolean.parseBoolean(call.argument("decreasing")),
                                    this.path,
                                    Float.parseFloat(call.argument("volumeMusic"))/10,
                                    Boolean.parseBoolean(call.argument("loop")),
                                    this.uri
                            );

                            wave = new BinauralService(this);
                            wave.execute(binaural);

                            result.success(this.path);
                            break;

                        case "stop" :
                            wave.stop(binaural.paramVolume, 1);
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
        wave.stop(binaural.paramVolume,2);
        super.onDestroy();
    }

    protected void onResume(){
        //this.setVolumeControlStream(AudioManager.STREAM_MUSIC);
        super.onResume();
    }

/*
    private void getSessions(){
        MediaSessionManager mediaSessionManager =  (MediaSessionManager) getApplicationContext().getSystemService(Context.MEDIA_SESSION_SERVICE);

        try {
            List<MediaController> mediaControllerList = mediaSessionManager.getActiveSessions
                    (new ComponentName(getApplicationContext(), NotificationReceiverService.class));
            for (MediaController m : mediaControllerList) {
                String packageName = m.getPackageName();
                MediaController.PlaybackInfo id = m.getPlaybackInfo();
                AudioAttributes a = id.getAudioAttributes();1
            }
        } catch (SecurityException e) {
        }
    }


    public void broadcastIntent() {
        Intent intent = new Intent();
        intent.setAction("android.media.action.OPEN_AUDIO_EFFECT_CONTROL_SESSION");
        sendBroadcast(intent);
    }

 */

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
        String[] mimetypes = {"audio/mpeg", "audio/x-wav"};
        intent.putExtra(Intent.EXTRA_MIME_TYPES, mimetypes);

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
            System.out.println("********* ERROR *************");
            this.path = "error";
        }
    }

}
