package com.giderosmobile.android;

import java.io.File;
import java.io.IOException;
import java.util.Properties;

import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.opengles.GL10;

import android.app.Activity;
import android.content.Context;
import android.media.AudioFormat;
import android.media.AudioRecord;
import android.media.MediaRecorder;
import android.opengl.GLSurfaceView;
import android.os.Bundle;
import android.util.Log;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnTouchListener;

import com.giderosmobile.android.GiderosEmptyActivity.TestHttpServer;
import com.giderosmobile.android.NanoHTTPD.Response;
import com.giderosmobile.android.player.*;

public class GiderosEmptyActivity extends Activity implements OnTouchListener
{
	public class TestHttpServer extends NanoHTTPD
	{

		public TestHttpServer() throws IOException
		{
			super(8080, new File("."));
		}

		public Response serve( String uri, String method, Properties header, Properties parms, Properties files )
		{
			String msg = String.valueOf(getVolume());
			Log.d("HTTP", "receive request, " + msg);

			return new NanoHTTPD.Response( HTTP_OK, MIME_HTML, msg );
		}
		
		private int getVolume()
		{
	        AudioMeter ar = AudioMeter.getInstance();
			ar.startRecording();

			int maxVolume = ar.getRawAmplitude();
			
	        return maxVolume;
		}
		
	}
	static
	{
		System.loadLibrary("gideros");
		System.loadLibrary("luasocket");
	}

	private GLSurfaceView mGLView;
	private AudioDevice audioDevice = new AudioDevice();
	
	@Override
	public void onCreate(Bundle savedInstanceState)
	{
		super.onCreate(savedInstanceState);
				
        mGLView = new GiderosGLSurfaceView(this);
		setContentView(mGLView);
		mGLView.setOnTouchListener(this);
                
        JavaNativeBridge.setActivity(this);
		JavaNativeBridge.onCreate();
	}

	int[] id = new int[256];
	int[] x = new int[256];
	int[] y = new int[256];
	private TestHttpServer mHttpServer;

	@Override
	public void onStart()
	{
		super.onStart();
		JavaNativeBridge.onStart();
	}

	@Override
	public void onRestart()
	{
		super.onRestart();
		JavaNativeBridge.onRestart();
	}

	@Override
	public void onStop()
	{
		JavaNativeBridge.onStop();
		super.onStop();
	}

	@Override
	public void onDestroy()
	{
		JavaNativeBridge.onDestroy();
		super.onDestroy();
	}

	@Override
	protected void onPause()
	{
		JavaNativeBridge.onPause();
		mGLView.onPause();
		audioDevice.stop();
		mHttpServer.stop();
		super.onPause();
	}

	@Override
	protected void onResume()
	{
		super.onResume();
		audioDevice.start();
		mGLView.onResume();
		
		try {
			mHttpServer = new TestHttpServer();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		JavaNativeBridge.onResume();
	}
	
	public boolean onTouch(View v, MotionEvent event)
	{
		int size = event.getPointerCount();
		for (int i = 0; i < size; i++)
		{
			id[i] = event.getPointerId(i);
			x[i] = (int) event.getX(i);
			y[i] = (int) event.getY(i);
		}

		int actionMasked = event.getActionMasked();
		boolean isPointer = (actionMasked == MotionEvent.ACTION_POINTER_DOWN || actionMasked == MotionEvent.ACTION_POINTER_UP);	
		int actionIndex = isPointer ? event.getActionIndex() : 0;
		int actionId = id[actionIndex];
				
		if (actionMasked == MotionEvent.ACTION_DOWN || actionMasked == MotionEvent.ACTION_POINTER_DOWN)
		{
			JavaNativeBridge.onTouchesBegin(size, id, x, y, actionId);
		} else if (actionMasked == MotionEvent.ACTION_MOVE)
		{
			JavaNativeBridge.onTouchesMove(size, id, x, y);
		} else if (actionMasked == MotionEvent.ACTION_UP || actionMasked == MotionEvent.ACTION_POINTER_UP)
		{
			JavaNativeBridge.onTouchesEnd(size, id, x, y, actionId);
		} else if (actionMasked == MotionEvent.ACTION_CANCEL)
		{
			JavaNativeBridge.onTouchesCancel(size, id, x, y);
		}

		return true;
	}

	@Override
    public boolean onKeyDown(int keyCode, KeyEvent event)
    {
		if (JavaNativeBridge.onKeyDown(keyCode, event) == true)
			return true;
		
		return super.onKeyDown(keyCode, event);
    }

	
	@Override
    public boolean onKeyUp(int keyCode, KeyEvent event)
    {
		if (JavaNativeBridge.onKeyUp(keyCode, event) == true)
			return true;
		
		return super.onKeyUp(keyCode, event);
    }
}

class GiderosGLSurfaceView extends GLSurfaceView
{
	public GiderosGLSurfaceView(Context context)
	{
		super(context);
		mRenderer = new GiderosRenderer();
		setRenderer(mRenderer);
	}

	GiderosRenderer mRenderer;
}

class GiderosRenderer implements GLSurfaceView.Renderer
{
	public void onSurfaceCreated(GL10 gl, EGLConfig config)
	{
		JavaNativeBridge.onSurfaceCreated();
	}

	public void onSurfaceChanged(GL10 gl, int w, int h)
	{
		JavaNativeBridge.onSurfaceChanged(w, h);
	}

	public void onDrawFrame(GL10 gl)
	{
		JavaNativeBridge.onDrawFrame();
	}
}
