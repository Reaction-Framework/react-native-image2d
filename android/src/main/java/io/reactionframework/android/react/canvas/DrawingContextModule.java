package io.reactionframework.android.react.canvas;

import android.graphics.Rect;
import android.net.Uri;
import com.facebook.react.bridge.*;

import java.util.HashMap;
import java.util.Map;

public class DrawingContextModule extends ReactContextBaseJavaModule {
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

    @ReactMethod
    public void create(ReadableMap options, Promise promise) {
        Integer width = null;
        Integer height = null;
        if (options.hasKey("size")) {
            ReadableMap imageSize = options.getMap("size");

            if (imageSize.hasKey("width") && imageSize.hasKey("height")) {
                width = imageSize.getInt("width");
                height = imageSize.getInt("height");
            }
        }

        DrawingContext context = createDrawingContext();

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
    }

    @ReactMethod
    public void save(ReadableMap options, Promise promise) {
        Uri fileUrl = getDrawingContext(options.getString("id")).save(options.getMap("params").getString("fileName"));

        if (fileUrl == null) {
            promise.reject("err");
            return;
        }

        promise.resolve(fileUrl.toString());
    }

    @ReactMethod
    public void getAsBase64String(ReadableMap options, Promise promise) {
        promise.resolve(getDrawingContext(options.getString("id")).getAsBase64String());
    }

    @ReactMethod
    public void getWidth(ReadableMap options, Promise promise) {
        promise.resolve(getDrawingContext(options.getString("id")).getWidth());
    }

    @ReactMethod
    public void getHeight(ReadableMap options, Promise promise) {
        promise.resolve(getDrawingContext(options.getString("id")).getHeight());
    }

    @ReactMethod
    public void crop(ReadableMap options, Promise promise) {
        DrawingContext drawingContext = getDrawingContext(options.getString("id"));
        ReadableMap params = options.getMap("params");

        int left = params.getInt("left");
        int top = params.getInt("top");
        int right = drawingContext.getWidth() - params.getInt("right");
        int bottom = drawingContext.getHeight() - params.getInt("bottom");

        Rect cropRectangle = new Rect(left, top, right, bottom);
        drawingContext.crop(cropRectangle);
        promise.resolve(null);
    }

    @ReactMethod
    public void release(ReadableMap options, Promise promise) {
        releaseDrawingContext(options.getString("id"));
        promise.resolve(null);
    }
}
