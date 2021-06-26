package com.zavarese.binauralsleep.dao;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

import java.io.IOException;

class SQLiteHelper extends SQLiteOpenHelper {

    private static final String DATABASE_NAME = "binaural.db";
    static final String TABLE_NAME ="configuration";

    static final String KEY_ID = "id";
    static final String KEY_NOME = "name";
    static final String KEY_BEAT_INI = "beat_ini";
    static final String KEY_BEAT_END = "beat_end";
    static final String KEY_FREQUENCY = "frequency";
    static final String KEY_DECREASE = "decrease";
    static final String KEY_TIME = "time";
    static final String KEY_PATH = "path";

    private static final int DATABASE_VERSION = 1;

    private static final String CREATE_TABLE = "CREATE TABLE " + TABLE_NAME + " ("
            + KEY_ID + " INTEGER PRIMARY KEY AUTOINCREMENT, "
            + KEY_NOME + " TEXT, "
            + KEY_BEAT_INI + " TEXT, "
            + KEY_BEAT_END + " TEXT, "
            + KEY_FREQUENCY + " TEXT, "
            + KEY_DECREASE + " TEXT, "
            + KEY_TIME + " TEXT, "
            + KEY_PATH + " TEXT);";

    private static final String DATABASE_ALTER_1 = "INSERT INTO "
            + TABLE_NAME + " ("
            + KEY_NOME  + ","
            + KEY_BEAT_INI  + ","
            + KEY_BEAT_END  + ","
            + KEY_FREQUENCY  + ","
            + KEY_DECREASE  + ","
            + KEY_TIME  + ","
            + KEY_PATH  + ","
            + ") VALUES ("
            + "\"Relaxing\","
            + "\"20\","
            + "\"13\","
            + "\"432\","
            + "\"60\","
            + "\"\")";

/*
    private static final String DATABASE_ALTER_1 = "ALTER TABLE "
            + TABLE_NAME + " ADD COLUMN " + KEY_DECREASE + " TEXT;";


    private static final String DATABASE_ALTER_2 = "ALTER TABLE "
            + TABLE_NAME + " ADD COLUMN " + KEY_VOL_MUSIC + " TEXT;";

    private static final String DATABASE_ALTER_3 = "ALTER TABLE "
            + TABLE_NAME + " ADD COLUMN " + KEY_VOL_WAVE + " TEXT;";

*/

    public SQLiteHelper(Context context) throws SecurityException {

        super(context, DATABASE_NAME, null, DATABASE_VERSION);
    }

    @Override
    public void onCreate(SQLiteDatabase db) {
        db.execSQL(CREATE_TABLE);
    }


    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
/*
        if (oldVersion < 2) {
            db.execSQL(DATABASE_ALTER_1);
        }


        if (oldVersion < 3) {
            db.execSQL(DATABASE_ALTER_2);
        }

        if (oldVersion < 4) {
            db.execSQL(DATABASE_ALTER_3);
        }

         */
    }
}
