package com.zavarese.binauralsleep;

import android.media.AudioTrack;

public class Utils {

    //private static final int AMPLITUDE_MAX = 32768;

    public static int getAdjustedAmplitudeMax(float frequency, int minSize) {
        //scale amplitude for human perception. 100hz or less = max

        int amplitudeMax = getAmplitudeMax(minSize);
        int amplitude = 0;

        float amplitudeScale1 = 200 / frequency;
        float amplitudeScale2 = 350 / frequency;

        if (frequency <= 200){
            amplitude = amplitudeMax;
        }

        if (frequency > 200 && frequency <= 350){
            amplitude = amplitudeMax/Math.round(amplitudeScale1);
        }

        if (frequency > 350 && frequency <= 400){
            amplitude = amplitudeMax/Math.round(amplitudeScale2);
        }

        if (frequency > 400){
            amplitude = amplitudeMax;
        }

        return amplitude;
    }

    public static int getAmplitudeMax(int minSize) {
        // Find a suitable buffer size
        int sizes[] = {1024, 2048, 4096, 8192, 16384, 32768};
        int size = 0;

        for (int s : sizes)
        {
            if (s > minSize)
            {
                size = s;
                break;
            }
        }

        return size;
    }

    public static int getLCM(int a,int b)
    {
        int x;
        int y;
        if(a<b)
        {
            x=a;
            y=b;
        }
        else
        {
            x=b;
            y=a;
        }
        int i=1;
        while(true)
        {
            int x1=x*i;
            int y1=y*i;
            for(int j=1;j<=i;j++)
            {
                if(x1==y*j)
                {
                    return x1;
                }
            }
            i++;
        }
    }

    public static void sleepThread(int millis) {
        try {
            Thread.currentThread();
            Thread.sleep(millis);
        } catch (InterruptedException ex) {
            ex.printStackTrace();
        }
    }
}


