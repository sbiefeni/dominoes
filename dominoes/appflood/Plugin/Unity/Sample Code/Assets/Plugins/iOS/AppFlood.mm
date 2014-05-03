#import "AppFlood.h"
#import "AFDelegateWrapper.h"
#import <Foundation/Foundation.h>






extern "C"
{
    extern void UnitySendMessage(const char* obj, const char* method, const char* msg); 
    
    
void callMe(char * car)
{
UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:@"Unity Call"                                                                 message:@"Unity To Objecttive-c"                                                                                                                        delegate:nil 
cancelButtonTitle:NSLocalizedString(@"Close",nil) 
otherButtonTitles:nil]; 

[alerView show];
}
    void initializeWithId(char * appKey ,char * appSecret,int adType)
    {
       NSString * key = [[NSString alloc] initWithCString:appKey encoding:NSUTF8StringEncoding];
        NSString * secret = [[NSString alloc] initWithCString:appSecret encoding:NSUTF8StringEncoding];
        printf("key = %s secret %s %d \n",appKey,appSecret,adType );
        NSLog(@"ns log key = %@ secret %@ %d",key,secret,adType );
        [AppFlood initializeWithId:key key:secret adType:adType];
        [key release];
        [secret release];
    }
    void showFullscreen(){
        [AppFlood showFullscreen];
    }
    
    void showInterstitial(){
        [AppFlood showInterstitial];
    }
    
    /**
     *
     * return: the ad type can shown. the ad type was set in initial.
     **/
    int getAdType(){
        return [AppFlood getAdType];
    }
    
    /**
     *  check does AppFlood conect to server success.
     **/
    bool isConnected(){
        return [AppFlood isConnected];
    }
    
    /**
     *  preload ad message.
     *  params:
     *   type: the ad type you want to preload.
     *   delegate: a delegate, if preload success the delegate would be called.
     **/
    void preload(int type, char* obj,char* callback){

        [AppFlood preload:type delegate:[AFDelegateWrapper getAFRequestDelegate:obj callback:callback]];
        
    }

    
    /**
     * get a banner ad view controller.
     * params:
     *  type: banner type
     *  isAuto: does auto refresh ad.
     *
     * return: a view controller. You can use it in your codes.
     **/
    //+ (UIViewController*) newBannerViewController:(int) type isAuto: (BOOL) isAuto frame: (CGRect) frame;
    
    /**
     * show panel ad.
     * params:
     *  type: the animate type when panel shown.
     **/
    void showPanel(int  type){
        if(type == 0){
            [AppFlood showPanel:APPFLOOD_PANEL_TOP];
        }else{
            [AppFlood showPanel:APPFLOOD_PANEL_BOTTOM];
        }

        

    }
    
    /**
     * show list ad.
     * params:
     *  type: the animate type when list shown.
     **/
    void showOfferWall(int type){
        if(type == 0){
           [AppFlood showOfferWall:APPFLOOD_PANEL_TOP];
        }else{
            [AppFlood showOfferWall:APPFLOOD_PANEL_BOTTOM];
        }
        

    }
    void showBanner(int bannerType,int layoutType){
        [[AFBannerController getInstance] showBanner: bannerType layoutType: layoutType];
    }
    void removeBanner(){
        [[AFBannerController getInstance] removeBanner];
    }
    
    /**
     * get ads data.
     * params:
     *  delegate: the animate type when panel shown.
     **/
    void getRawData(const char * obj,const char* callback){

        [AppFlood getRawData:[AFDelegateWrapper getAFRequestDelegate:obj callback:callback]];
    }
    
    /**
     * used with getRawData, when the ad clicked, you should call this function for open download page and send cb.
     **/
    void handleAFClick(char* backUrl,char* clickUrl){
        NSString * back = [[NSString alloc] initWithCString:backUrl encoding:NSUTF8StringEncoding];
        NSString * click = [[NSString alloc] initWithCString:clickUrl encoding:NSUTF8StringEncoding];
        [AppFlood handleAFClick:back clickUrl: click];
        [back release];
        [click release];
    }
    
    
    void setEventDelegate(char * obj1,char* clickCallback,char * obj2,char* closeCallback){


        [AppFlood setEventDelegate:[AFDelegateWrapper getAFEventDelegate: obj1 clickCallback: clickCallback obj2: obj2 closeCallback:closeCallback]];
        
    }
    void consumePoint(int point,char* obj,char* callback){


        [AppFlood consumePoint:point delegate:[AFDelegateWrapper getAFRequestDelegate:obj callback:callback]];
    }
    void queryPoint(char*obj,char* callback){


        [AppFlood queryPoint:[AFDelegateWrapper getAFRequestDelegate:obj callback:callback]];
    }
    
    /**
     * call it to release AppFlood.
     **/
    void destroy(){
        [[AFBannerController getInstance] release];
        [AppFlood destroy];
        
    }
   }