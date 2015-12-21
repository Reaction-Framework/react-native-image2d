package io.reactionframework.android.react.image.image2d;

import android.content.Context;
import android.graphics.*;
import android.net.Uri;
import io.reactionframework.android.image.ImageUtils;

import java.util.UUID;

public class Image2DContext {
    private final String mId;
    private final Context mContext;
    private Bitmap mBitmap;
    private Canvas mCanvas;

    public Image2DContext(Context context) {
        mId = UUID.randomUUID().toString();
        mContext = context;
    }

    public String getId() {
        return mId;
    }

    public void create(Integer width, Integer height) {
        if (width == null || height == null) {
            throw new UnsupportedOperationException("Can not create Image2DContext. Image2DContext without image requires width and height.");
        }

        createWithBitmap(Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888), null, null);
    }

    public void createFromFileUrl(String url, Integer width, Integer height) {
        createWithBitmap(BitmapFactory.decodeFile(url), width, height);
    }

    public void createFromBase64String(String base64, Integer width, Integer height) {
        createWithBitmap(ImageUtils.bitmapFromByteArray(ImageUtils.dataFromBase64String(base64)), width, height);
    }

    public Uri save(String fileName) {
        return ImageUtils.storeInPictures(mContext, ImageUtils.bitmapToByteArray(mBitmap), fileName);
    }

    public String getAsBase64String() {
        return ImageUtils.dataToBase64String(ImageUtils.bitmapToByteArray(mBitmap));
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

    public void drawBorder(Rect borderRectangle, String borderColor) {
        Bitmap bitmap = mBitmap.copy(mBitmap.getConfig(), true);
        mCanvas.setBitmap(null);
        mBitmap.recycle();

        mBitmap = Bitmap.createBitmap(
                bitmap.getWidth() + borderRectangle.left + borderRectangle.right,
                bitmap.getHeight() + borderRectangle.top + borderRectangle.bottom,
                bitmap.getConfig());

        mCanvas.setBitmap(mBitmap);

        int androidBorderColor = Color.parseColor(borderColor);
        mCanvas.drawColor(androidBorderColor);

        mCanvas.drawBitmap(bitmap, null, new Rect(
                borderRectangle.left,
                borderRectangle.top,
                bitmap.getWidth() + borderRectangle.left,
                bitmap.getHeight() + borderRectangle.top
        ), null);

        bitmap.recycle();
    }

    public void release() {
        if (mCanvas != null) {
            mCanvas.setBitmap(null);
            mCanvas = null;
        }

        if (mBitmap != null) {
            mBitmap.recycle();
            mBitmap = null;
        }
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
    }
}