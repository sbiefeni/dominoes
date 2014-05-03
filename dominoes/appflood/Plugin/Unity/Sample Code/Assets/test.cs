using UnityEngine;
using System.Collections;
using System.Runtime.InteropServices;



using System;

public class test : MonoBehaviour {
	  int button_width = 200;
  int button_height = 70;
  int padding = 30;
	int top_off = 40;
	

	
	


void OnGUI()
{

		if (GUI.Button(new Rect (padding, top_off + padding, button_width, button_height), "panel from bottom")){
 AppFlood.showPanel(AppFlood.PANEL_BOTTOM);
	  }
		if (GUI.Button(new Rect (padding * 2 + button_width, top_off + padding, button_width, button_height), "panel from top")){
	      AppFlood.showPanel(AppFlood.PANEL_TOP);
	  }
		if (GUI.Button(new Rect (padding, top_off + padding * 2 + button_height, button_width, button_height), "full screen")){
			print ("call show full");
AppFlood.showFullscreen();
	  }
		
		if (GUI.Button(new Rect (padding * 2 + button_width,  top_off + padding * 2 + button_height, button_width, button_height), "test connect")){
	      bool connected = AppFlood.isConnected();
		  print("connected:" + connected);
	  }
	  if (GUI.Button(new Rect (padding,  top_off + padding * 3 + button_height * 2, button_width, button_height), "consume point")){
	      AppFlood.consumePoint(2, "Main Camera", "ConsumeFinished");
	  }
	  if (GUI.Button(new Rect (padding * 2 + button_width, top_off + padding * 3 + button_height * 2, button_width, button_height), "query point")){
	      AppFlood.queryPoint("Main Camera", "QueryDelegate");
	  }
		
	  if (GUI.Button(new Rect (padding * 2 + button_width, top_off + padding * 4 + button_height * 3, button_width, button_height), "get banner bottom")){
	      AppFlood.showBanner(AppFlood.BANNER_MIDDLE, AppFlood.BANNER_BOTTOM);
	  }
	  if (GUI.Button(new Rect (padding, top_off + padding * 5 + button_height * 4, button_width, button_height), "get banner top")){
	      AppFlood.showBanner(AppFlood.BANNER_SMALL, AppFlood.BANNER_TOP);
	  }
	  if (GUI.Button(new Rect (padding * 2 + button_width, top_off + padding * 5 + button_height * 4, button_width, button_height), "destroy banner")){
	      AppFlood.removeBanner();
	  }
     

		if (GUI.Button(new Rect (padding, top_off + padding * 7 + button_height * 6, button_width, button_height), "preload")){
          AppFlood.preload(AppFlood.AD_ALL, "Main Camera","LoadFinish");
      }
		
				if (GUI.Button(new Rect (padding * 2 + button_width, top_off + padding * 7 + button_height * 6, button_width, button_height), "Interstitial")){
          AppFlood.showInterstitial();
      }
	  	  if (GUI.Button(new Rect (padding * 2 + button_width, top_off + padding * 6 + button_height * 5, button_width, button_height), "get ad data")){
	      AppFlood.getRawData("Main Camera", "getADDataFinished");
	  } 
		
	  if (GUI.Button(new Rect (padding, top_off + padding * 4 + button_height * 3, button_width, button_height), "get ad type")){
	      int type = AppFlood.getAdType();
		  print("ad type:" + type);
	  }
	  
	  if (GUI.Button(new Rect (padding, top_off + padding * 6 + button_height * 5, button_width, button_height), "show offerWall")){
	      AppFlood.showOfferWall(0);
	  }
	  
}
	// Use this for initialization
	void Start () {
	print("aaaaaaaaa start");
	AppFlood.initializeWithId("LZpNXsDhJqVvncxa", "JguWAAOD857L5174c024",AppFlood.AD_ALL);
		AppFlood.setEventDelegate("Main Camera", "AdClicked", "Main Camera", "AdClosed");
	}
	
	// Update is called once per frame
	void Update () {
	
	}
	
	 void getADDataFinished(String message)
  {
	print("Unity load finish, message "+ message);
  }
  
  void LoadFinish(String message) {
	print("Unity load finish, json:" + message);
  }
  
  void AdClicked(String message) {
	print("Unity ad clicked, json:" + message);
  }
  
  void AdClosed(String message) {
	print("Unity ad closed, json:" + message);
  }
  
  void QueryDelegate(String message) {
	print("Unity query finished, json:" + message);
  }
  
  void ConsumeFinished(String message) {
	print("Unity consume finished, json:" + message);
  }
}
