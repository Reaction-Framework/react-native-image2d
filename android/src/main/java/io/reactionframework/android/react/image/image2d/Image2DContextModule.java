package io.reactionframework.android.react.image.image2d;

import android.graphics.Rect;
import android.net.Uri;
import android.util.Log;
import com.facebook.react.bridge.*;

import java.util.HashMap;
import java.util.Map;

public class Image2DContextModule extends ReactContextBaseJavaModule {
    private static final String LOG_TAG = Image2DContextModule.class.getSimpleName();
    private static final String REACT_MODULE = "Image2DContextModule";

    private static Map<String, Image2DContext> mImage2DContexts;

    private static Map<String, Image2DContext> getImage2DContexts() {
        return mImage2DContexts == null ? (mImage2DContexts = new HashMap<>()) : mImage2DContexts;
    }

    private final ReactApplicationContext mContext;

    public Image2DContextModule(ReactApplicationContext reactContext) {
        super(reactContext);
        mContext = reactContext;
    }

    @Override
    public String getName() {
        return REACT_MODULE;
    }

    private Image2DContext createImage2DContext() {
        Image2DContext context = new Image2DContext(mContext);
        getImage2DContexts().put(context.getId(), context);
        return context;
    }

    private Image2DContext getImage2DContext(String id) {
        return getImage2DContexts().get(id);
    }

    private void releaseImage2DContext(String id) {
        Image2DContext context = getImage2DContext(id);
        context.release();
        getImage2DContexts().remove(id);
    }

    private void rejectWithException(Promise promise, Throwable exception) {
        Log.e(LOG_TAG, exception.getMessage());
        exception.printStackTrace();
        promise.reject(exception.getMessage());
    }

    @ReactMethod
    public void create(ReadableMap options, Promise promise) {
        Image2DContext context = createImage2DContext();

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
            Uri fileUrl = getImage2DContext(options.getString("id")).save(options.getMap("params").getString("fileName"));

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
            promise.resolve(getImage2DContext(options.getString("id")).getAsBase64String());
        } catch (Exception e) {
            rejectWithException(promise, e);
        }
    }

    @ReactMethod
    public void getWidth(ReadableMap options, Promise promise) {
        try {
            promise.resolve(getImage2DContext(options.getString("id")).getWidth());
        } catch (Exception e) {
            rejectWithException(promise, e);
        }
    }

    @ReactMethod
    public void getHeight(ReadableMap options, Promise promise) {
        try {
            promise.resolve(getImage2DContext(options.getString("id")).getHeight());
        } catch (Exception e) {
            rejectWithException(promise, e);
        }
    }

    @ReactMethod
    public void crop(ReadableMap options, Promise promise) {
        try {
            Image2DContext image2DContext = getImage2DContext(options.getString("id"));
            ReadableMap params = options.getMap("params");

            image2DContext.crop(new Rect(
                    params.getInt("left"),
                    params.getInt("top"),
                    image2DContext.getWidth() - params.getInt("right"),
                    image2DContext.getHeight() - params.getInt("bottom")
            ));

            promise.resolve(null);
        } catch (Exception e) {
            rejectWithException(promise, e);
        }
    }

    @ReactMethod
    public void drawBorder(ReadableMap options, Promise promise) {
        try {
            Image2DContext image2DContext = getImage2DContext(options.getString("id"));
            ReadableMap params = options.getMap("params");

            String borderColor = params.getString("color");

            image2DContext.drawBorder(new Rect(
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
        releaseImage2DContext(options.getString("id"));
        promise.resolve(null);
    }
}
