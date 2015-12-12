package io.reactionframework.android.react.canvas;

import android.content.Context;
import android.graphics.*;
import android.net.Uri;
import io.reactionframework.android.image.ImageUtils;

import java.util.UUID;

public class DrawingContext {
    private final String mId;
    private final Context mContext;
    private Bitmap mBitmap;
    private Canvas mCanvas;

    public DrawingContext(Context context) {
        mId = UUID.randomUUID().toString();
        mContext = context;
    }

    public String getId() {
        return mId;
    }

    public void create(Integer width, Integer height) {
        if (width != null && height != null) {
            createWithBitmap(Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888), null, null);
            return;
        }

        mCanvas = new Canvas();
    }

    public void createFromFileUrl(String url, Integer width, Integer height) {
        createWithBitmap(BitmapFactory.decodeFile(url), width, height);
    }

    public void createFromBase64String(String base64, Integer width, Integer height) {
        createWithBitmap(ImageUtils.bitmapFromString(base64), width, height);
    }

    public Uri save(String fileName) {
        return ImageUtils.storePhoto(mContext, mBitmap, fileName);
    }

    public String getAsBase64String() {
        /*Paint mPaint = new Paint();
        mPaint.setColor(Color.RED);
        mPaint.setStyle(Paint.Style.FILL);
        mCanvas.drawRect(0, 0, 200, 200, mPaint);*/

        return ImageUtils.bitmapToString(mBitmap);
    }

    public int getWidth() {
        return mCanvas.getWidth();
    }

    public int getHeight() {
        return mCanvas.getHeight();
    }

    public void crop(Rect cropRectangle) {
        Bitmap bitmap = Bitmap.createBitmap(mBitmap, cropRectangle.left, cropRectangle.top, cropRectangle.width(), cropRectangle.height());
        mCanvas.setBitmap(null);
        mBitmap.recycle();
        mBitmap = bitmap;
        mCanvas.setBitmap(mBitmap);
    }

    public void drawBorder(Rect borderRectangle) {
        Bitmap bitmap = mBitmap.copy(mBitmap.getConfig(), true);
        mCanvas.setBitmap(null);
        mBitmap.recycle();

        mBitmap = Bitmap.createBitmap(
                bitmap.getWidth() + borderRectangle.left + borderRectangle.right,
                bitmap.getHeight() + borderRectangle.top + borderRectangle.bottom,
                bitmap.getConfig());

        // TODO borderColor as parameter
        int borderColor = Color.RED;

        mCanvas.setBitmap(mBitmap);
        mCanvas.drawColor(borderColor);
        mCanvas.drawBitmap(bitmap, null, new Rect(
                borderRectangle.left,
                borderRectangle.top,
                bitmap.getWidth() + borderRectangle.left,
                bitmap.getHeight() + borderRectangle.top
        ), null);

        bitmap.recycle();
    }

    public void release() {

    }

    private void createWithBitmap(Bitmap bitmap, Integer width, Integer height) {
        if (width != null && height != null) {
            Bitmap tmp = Bitmap.createScaledBitmap(bitmap, width, height, false);
            bitmap.recycle();
            bitmap = tmp;
        }

        mBitmap = bitmap.copy(bitmap.getConfig(), true);
        bitmap.recycle();
        mCanvas = new Canvas(mBitmap);

        // crop(new Rect(20,20,100,100));
    }
}
