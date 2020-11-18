package pl.itto.webview_plugin.data.local;

import android.content.Context;
import android.content.SharedPreferences;

/**
 * Created by mvp on 06,July,2020
 */
public class PreferencesHelper {
    private static final String PREF_KEY = "FlutterSharedPreferences";

    private SharedPreferences sharedPreference;
    public SharedPreferences.Editor editor;
    public static PreferencesHelper sPrefs;
    
    public PreferencesHelper(Context context) {
        sharedPreference = context.getSharedPreferences(PREF_KEY, 0);
        editor = sharedPreference.edit();
    }

    public static PreferencesHelper getInstance(Context context) {
        if (sPrefs == null)
            sPrefs = new PreferencesHelper(context.getApplicationContext());
        return sPrefs;
    }

    public static void dispose() {
        sPrefs = null;
    }

    public boolean getBoolean(String key, boolean default_value) {
        return sharedPreference.getBoolean(key, default_value);
    }

    public float getFloat(String key, float default_value) {
        return sharedPreference.getFloat(key, default_value);
    }

    public int getInt(String key, int default_value) {
        return sharedPreference.getInt(key, default_value);
    }

    public long getLong(String key, long default_value) {
        return sharedPreference.getLong(key, default_value);
    }

    public String getString(String key, String default_value) {
        return sharedPreference.getString(key, default_value);
    }

    public void putFloat(String key, float value) {
        editor.putFloat(key, value);
        commitOrApplyPreferences(editor);
    }

    public void putBoolean(String key, boolean value) {
        editor.putBoolean(key, value);
        commitOrApplyPreferences(editor);
    }

    public void putInt(String key, int value) {
        editor.putInt(key, value);
        commitOrApplyPreferences(editor);
    }

    public void putLong(String key, long value) {
        editor.putLong(key, value);
        commitOrApplyPreferences(editor);
    }

    public void putString(String key, String value) {
        editor.putString(key, value);
        commitOrApplyPreferences(editor);
    }

    public void remove(String key) {
        editor.remove(key);
        commitOrApplyPreferences(editor);
    }

    public boolean contains(String key) {
        return sharedPreference.contains(key);
    }

    private void commitOrApplyPreferences(SharedPreferences.Editor preferencesEditor) {
        try {
            preferencesEditor.commit();
        } catch (Throwable t) {
            if (t instanceof OutOfMemoryError) {
                System.gc();
                preferencesEditor.commit();
            }
        }
    }
}
