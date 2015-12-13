package io.reactionframework.android.react.canvas;

import android.graphics.Rect;
import android.net.Uri;
import android.util.Log;
import com.facebook.react.bridge.*;

import java.util.HashMap;
import java.util.Map;

public class DrawingContextModule extends ReactContextBaseJavaModule {
    private static final String LOG_TAG = DrawingContextModule.class.getSimpleName();
    private static final String REACT_MODULE = "DrawingContextModule";

    private static Map<String, DrawingContext> mDrawingContexts;

    private static Map<String, DrawingContext> getDrawingContexts() {
        return mDrawingContexts == null ? (mDrawingContexts = new HashMap<>()) : mDrawingContexts;
    }

    private final ReactApplicationContext mContext;

    public DrawingContextModule(ReactApplicationContext reactContext) {
        super(reactContext);
        mContext = reactContext;
    }

    @Override
    public String getName() {
        return REACT_MODULE;
    }

    private DrawingContext createDrawingContext() {
        DrawingContext context = new DrawingContext(mContext);
        getDrawingContexts().put(context.getId(), context);
        return context;
    }

    private DrawingContext getDrawingContext(String id) {
        return getDrawingContexts().get(id);
    }

    private void releaseDrawingContext(String id) {
        DrawingContext context = getDrawingContext(id);
        context.release();
        getDrawingContexts().remove(id);
    }

    private void rejectWithException(Promise promise, Throwable exception) {
        Log.e(LOG_TAG, exception.getMessage());
        exception.printStackTrace();
        promise.reject(exception.getMessage());
    }

    @ReactMethod
    public void create(ReadableMap options, Promise promise) {
        DrawingContext context = createDrawingContext();

        try {
            Integer width = null;
            Integer height = null;

            if (options.hasKey("size")) {
                ReadableMap imageSize = options.getMap("size");

                if (imageSize.hasKey("width") && imageSize.hasKey("height")) {
                    width = imageSize.getInt("width");
                    height = imageSize.getInt("height");
                }
            }

            if (options.hasKey("fileUrl")) {
                context.createFromFileUrl(options.getString("fileUrl"), width, height);
                promise.resolve(context.getId());
                return;
            }

            if (options.hasKey("base64String")) {
                context.createFromBase64String(options.getString("base64String"), width, height);
                promise.resolve(context.getId());
                return;
            }

            context.create(width, height);
            promise.resolve(context.getId());
        } catch (Exception e) {
            context.release();
            rejectWithException(promise, e);
        }
    }

    @ReactMethod
    public void save(ReadableMap options, Promise promise) {
        try {
            Uri fileUrl = getDrawingContext(options.getString("id")).save(options.getMap("params").getString("fileName"));

            if (fileUrl == null) {
                promise.reject("err");
                return;
            }

            promise.resolve(fileUrl.toString());
        } catch (Exception e) {
            rejectWithException(promise, e);
        }
    }

    @ReactMethod
    public void getAsBase64String(ReadableMap options, Promise promise) {
        try {
            promise.resolve(getDrawingContext(options.getString("id")).getAsBase64String());
        } catch (Exception e) {
            rejectWithException(promise, e);
        }
    }

    @ReactMethod
    public void getWidth(ReadableMap options, Promise promise) {
        try {
            promise.resolve(getDrawingContext(options.getString("id")).getWidth());
        } catch (Exception e) {
            rejectWithException(promise, e);
        }
    }

    @ReactMethod
    public void getHeight(ReadableMap options, Promise promise) {
        try {
            promise.resolve(getDrawingContext(options.getString("id")).getHeight());
        } catch (Exception e) {
            rejectWithException(promise, e);
        }
    }

    @ReactMethod
    public void crop(ReadableMap options, Promise promise) {
        try {
            DrawingContext drawingContext = getDrawingContext(options.getString("id"));
            ReadableMap params = options.getMap("params");

            drawingContext.crop(new Rect(
                    params.getInt("left"),
                    params.getInt("top"),
                    drawingContext.getWidth() - params.getInt("right"),
                    drawingContext.getHeight() - params.getInt("bottom")
            ));

            promise.resolve(null);
        } catch (Exception e) {
            rejectWithException(promise, e);
        }
    }

    @ReactMethod
    public void drawBorder(ReadableMap options, Promise promise) {
        try {
            DrawingContext drawingContext = getDrawingContext(options.getString("id"));
            ReadableMap params = options.getMap("params");

            String borderColor = params.getString("color");

            drawingContext.drawBorder(new Rect(
                    params.getInt("left"),
                    params.getInt("top"),
                    params.getInt("right"),
                    params.getInt("bottom")
            ), borderColor);

            promise.resolve(null);
        } catch (Exception e) {
            rejectWithException(promise, e);
        }
    }

    @ReactMethod
    public void release(ReadableMap options, Promise promise) {
        releaseDrawingContext(options.getString("id"));
        promise.resolve(null);
    }
}
