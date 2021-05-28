package com.zavarese.binauralsleep.dao;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;

import com.zavarese.binauralsleep.sound.Binaural;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

public class ConfigDAO {

    SQLiteDatabase database;
    SQLiteHelper dbHelper;

    public ConfigDAO(Context context)
    {
        System.out.println("Dentro ConfigDAO");
        this.dbHelper = new SQLiteHelper(context);
    }

    public Binaural config(int id)
    {
        database = dbHelper.getReadableDatabase();

        Cursor cursor;
        String where = SQLiteHelper.KEY_ID + "=" + id;

        cursor = database.query(SQLiteHelper.TABLE_NAME,
                null,
                where,
                null,
                null,
                null,
                SQLiteHelper.KEY_NOME);

        Binaural b = new Binaural();

        while (cursor.moveToNext())
        {
            b.id = cursor.getInt(0);
            b.name = cursor.getString(1);
            b.paramIsoBeatMin = cursor.getFloat(2);
            b.paramIsoBeatMax = cursor.getFloat(3);
            b.paramFrequency = cursor.getFloat(4);
            b.paramDecreasing = (cursor.getInt(5)==0?false:true);

        }

        cursor.close();
        database.close();

        return b;
    }

    public ArrayList<Binaural> listConfig()
    {
        database = dbHelper.getReadableDatabase();

        ArrayList<Binaural> configs = new ArrayList<>();

        Cursor cursor;

        cursor = database.query(SQLiteHelper.TABLE_NAME,
                null,
                null,
                null,
                null,
                null,
                SQLiteHelper.KEY_NOME);

        cursor.moveToFirst();

        while (cursor.isAfterLast() == false)
        {
            Binaural b = new Binaural();
            b.id = cursor.getInt(0);
            b.name = cursor.getString(1);
            b.paramIsoBeatMin = cursor.getFloat(2);
            b.paramIsoBeatMax = cursor.getFloat(3);
            b.paramFrequency = cursor.getFloat(4);
            b.paramDecreasing = (cursor.getInt(5)==0?false:true);

            configs.add(b);
            cursor.moveToNext();
        }

        cursor.close();
        database.close();

        return configs;
    }


    public long addConfig (Binaural b)
    {

        database = dbHelper.getWritableDatabase();

        ContentValues values = new ContentValues();
        values.put(SQLiteHelper.KEY_NOME, b.name);
        values.put(SQLiteHelper.KEY_BEAT_INI, b.paramIsoBeatMin);
        values.put(SQLiteHelper.KEY_BEAT_END, b.paramIsoBeatMax);
        values.put(SQLiteHelper.KEY_FREQUENCY, b.paramFrequency);
        values.put(SQLiteHelper.KEY_DECREASE, b.paramDecreasing);

        long id = database.insert(SQLiteHelper.TABLE_NAME, null, values);

        database.close();
        return id;

    }

    public void updateConfig(Binaural b)
    {
        database = dbHelper.getWritableDatabase();

        ContentValues values = new ContentValues();
        values.put(SQLiteHelper.KEY_NOME, b.name);
        values.put(SQLiteHelper.KEY_BEAT_INI, b.paramIsoBeatMin);
        values.put(SQLiteHelper.KEY_BEAT_END, b.paramIsoBeatMax);
        values.put(SQLiteHelper.KEY_FREQUENCY, b.paramFrequency);
        values.put(SQLiteHelper.KEY_DECREASE, b.paramDecreasing);

        database.update(SQLiteHelper.TABLE_NAME, values,
                SQLiteHelper.KEY_ID +"=" +b.id,null);

        database.close();
    }


    public void deleteConfig (int id)
    {
        database = dbHelper.getWritableDatabase();

        database.delete(SQLiteHelper.TABLE_NAME,SQLiteHelper.KEY_ID +"="+ id,null);
        //database.delete(SQLiteHelper.TABLE_NAME,null,null);

        database.close();

    }

}

