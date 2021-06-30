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

    private static final String PRESETTING_1 = "INSERT INTO "
            + TABLE_NAME + " ("
            + KEY_NOME  + ","
            + KEY_BEAT_INI  + ","
            + KEY_BEAT_END  + ","
            + KEY_FREQUENCY  + ","
            + KEY_DECREASE  + ","
            + KEY_TIME  + ","
            + KEY_PATH  + ""
            + ") VALUES ("
            + "\"Relaxation\","
            + "\"12\","
            + "\"20\","
            + "\"432\","
            + "\"1\","
            + "\"30\","
            + "\"\")";

    private static final String PRESETTING_2 = "INSERT INTO "
            + TABLE_NAME + " ("
            + KEY_NOME  + ","
            + KEY_BEAT_INI  + ","
            + KEY_BEAT_END  + ","
            + KEY_FREQUENCY  + ","
            + KEY_DECREASE  + ","
            + KEY_TIME  + ","
            + KEY_PATH  + ""
            + ") VALUES ("
            + "\"Deep Relaxation\","
            + "\"9\","
            + "\"16\","
            + "\"432\","
            + "\"1\","
            + "\"30\","
            + "\"\")";

    private static final String PRESETTING_3 = "INSERT INTO "
            + TABLE_NAME + " ("
            + KEY_NOME  + ","
            + KEY_BEAT_INI  + ","
            + KEY_BEAT_END  + ","
            + KEY_FREQUENCY  + ","
            + KEY_DECREASE  + ","
            + KEY_TIME  + ","
            + KEY_PATH  + ""
            + ") VALUES ("
            + "\"Sleep\","
            + "\"5\","
            + "\"13\","
            + "\"200\","
            + "\"1\","
            + "\"30\","
            + "\"\")";

    private static final String PRESETTING_4 = "INSERT INTO "
            + TABLE_NAME + " ("
            + KEY_NOME  + ","
            + KEY_BEAT_INI  + ","
            + KEY_BEAT_END  + ","
            + KEY_FREQUENCY  + ","
            + KEY_DECREASE  + ","
            + KEY_TIME  + ","
            + KEY_PATH  + ""
            + ") VALUES ("
            + "\"Concentration\","
            + "\"17\","
            + "\"28\","
            + "\"460\","
            + "\"0\","
            + "\"45\","
            + "\"\")";

    private static final String PRESETTING_5 = "INSERT INTO "
            + TABLE_NAME + " ("
            + KEY_NOME  + ","
            + KEY_BEAT_INI  + ","
            + KEY_BEAT_END  + ","
            + KEY_FREQUENCY  + ","
            + KEY_DECREASE  + ","
            + KEY_TIME  + ","
            + KEY_PATH  + ""
            + ") VALUES ("
            + "\"Deep Sleep\","
            + "\"4\","
            + "\"10\","
            + "\"200\","
            + "\"1\","
            + "\"45\","
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
        db.execSQL(PRESETTING_1);
        db.execSQL(PRESETTING_2);
        db.execSQL(PRESETTING_3);
        db.execSQL(PRESETTING_4);
        db.execSQL(PRESETTING_5);
    }


    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
/*
        if (oldVersion == 1 || newVersion == 1) {
            db.execSQL(PRESETTING_5);
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
