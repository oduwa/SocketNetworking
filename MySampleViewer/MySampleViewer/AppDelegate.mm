//
//  AppDelegate.m
//  MySampleViewer
//
//  Created by Oduwa Edo Osagie on 12/08/2015.
//  Copyright (c) 2015 Oduwa Edo Osagie. All rights reserved.
//

#import "AppDelegate.h"
#import <Carbon/Carbon.h>
#import "TCPClient.h"
#import "base64.h"
#import "FXBase64/Base64.h"
#import "TCPServer.h"
#import "AndroidViewer.h"




@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

void generateRandomImageData(char* data, int size)
{
    for(int i = 0; i < size; i+=4){
        data[i] = rand() % 256; // r
    }
    for(int i = 1; i < size; i+=4){
        data[i] = rand() % 256; // g
    }
    for(int i = 2; i < size; i+=4){
        data[i] = rand() % 256; // b
    }
    for(int i = 3; i < size; i+=4){
        data[i] = 255; // a
    }
}

NSImage* createNSImageReg(signed char* data, int w, int h)
{
    NSBitmapImageRep* rep = [[NSBitmapImageRep alloc]
                             initWithBitmapDataPlanes:NULL pixelsWide:w
                             pixelsHigh:h bitsPerSample:8 samplesPerPixel:4
                             hasAlpha:YES isPlanar:NO
                             colorSpaceName:NSDeviceRGBColorSpace
                             bytesPerRow:(4 * w) bitsPerPixel:32];
    unsigned char* bitmapData = [rep bitmapData];
    memcpy(bitmapData, data, w * h * 4);
    NSImage* im = [[NSImage alloc] initWithSize:NSMakeSize(w, h)];
    [im addRepresentation:rep];
    return im;
}

class SharedStore {
public:
    static NSImageView* imageView;
};
NSImageView *publicImageView;

class Callback : public AndroidViewer::AndroidViewerCallbackInterface {
public:
    void newFrameAvailable(signed char* data){
        printf("Callback: %d\n", data[0]);
        NSImage *i = createNSImageReg(data, 1664,2392);
        publicImageView.image = i;
        /*
        dispatch_queue_t imageCreationQueue = dispatch_queue_create("Image Queue",NULL);
        dispatch_async(imageCreationQueue, ^{
            NSImage *i = createNSImageReg(data, 1664,2392);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                publicImageView.image = i;//SharedStore::imageView.image = i;
                //publicImageView.image = [NSImage imageNamed:@"freeformatter-output-2.jpg"];
            });
        });
         */
    }
    void debug(){
        NSLog(@"DEBUG CALLBACK");
    }
};
Callback cb;

NSImage* createNSImage(unsigned char* data, int w, int h)
{
    NSBitmapImageRep* rep = [[NSBitmapImageRep alloc]
                             initWithBitmapDataPlanes:NULL pixelsWide:w
                             pixelsHigh:h bitsPerSample:8 samplesPerPixel:4
                             hasAlpha:YES isPlanar:NO
                             colorSpaceName:NSDeviceRGBColorSpace
                             bytesPerRow:(4 * w) bitsPerPixel:32];
    unsigned char* bitmapData = [rep bitmapData];
    memcpy(bitmapData, data, w * h * 4);
    NSImage* im = [[NSImage alloc] initWithSize:NSMakeSize(w, h)];
    [im addRepresentation:rep];
    return im;
}

NSImage* createNSImage2(char* data, int w, int h)
{
    NSBitmapImageRep* rep = [[NSBitmapImageRep alloc]
                             initWithBitmapDataPlanes:NULL pixelsWide:w
                             pixelsHigh:h bitsPerSample:2 samplesPerPixel:3
                             hasAlpha:YES isPlanar:NO
                             colorSpaceName:NSDeviceRGBColorSpace
                             bytesPerRow:(6 * w) bitsPerPixel:6];
    unsigned char* bitmapData = [rep bitmapData];
    memcpy(bitmapData, data, w * h * 3);
    NSImage* im = [[NSImage alloc] initWithSize:NSMakeSize(w, h)];
    [im addRepresentation:rep];
    return im;
}

NSImage* createNSImage(char* data, int w, int h)
{
    NSBitmapImageRep* rep = [[NSBitmapImageRep alloc]
                             initWithBitmapDataPlanes:NULL pixelsWide:w
                             pixelsHigh:h bitsPerSample:2 samplesPerPixel:4
                             hasAlpha:YES isPlanar:NO
                             colorSpaceName:NSDeviceRGBColorSpace
                             bytesPerRow:(8 * w) bitsPerPixel:8];
    unsigned char* bitmapData = [rep bitmapData];
    memcpy(bitmapData, data, w * h * 4);
    NSImage* im = [[NSImage alloc] initWithSize:NSMakeSize(w, h)];
    [im addRepresentation:rep];
    return im;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    //[self makeImage];
    
//    TCPClient cli = TCPClient();
//    cli.connect("10.10.19.228", 6880);
//    char *encoded = cli.receiveTextMessage();
//    NSLog(@"%s", encoded);
//    
//    int flen = 50*50;
//    unsigned char* data = unbase64(encoded, 1020, &flen);
//    
//    for(int i = 0; i < 100; i++){
//        NSLog(@"i: %d", data[i]);
//    }
    
//    int size = 50*50*4;
//    unsigned char data[size];
//    for(int i = 0; i < size; i+=4){
//        data[i] = (unsigned char) 0x808000FF;
//        //NSLog(@"%c", data[i]);
//    }
//    for(int i = 1; i < size; i+=4){
//        data[i] = 0;
//        //NSLog(@"%c", data[i]);
//    }
//    for(int i = 2; i < size; i+=4){
//        data[i] = 00;
//        //NSLog(@"%c", data[i]);
//    }
//    for(int i = 3; i < size; i+=4){
//        data[i] = 255;
//        //NSLog(@"%c", data[i]);
//    }
//    
//    [self showImageWithData:data];
//    
//    int flen = 50*50;
//    char *encoded = base64(data, 50*50*4, &flen);
//    printf("%s\n", encoded);
    
    //[self yesterdaysImage];
    
    publicImageView/*SharedStore::imageView*/ = [[NSImageView alloc] initWithFrame:_window.frame];
    [_window setContentView:publicImageView];
    
    AndroidViewer *viewer = new AndroidViewer("localhost", 6880, &cb);
    viewer->connect();
    
    dispatch_queue_t viewingQueue = dispatch_queue_create("Viewing Queue",NULL);
    dispatch_async(viewingQueue, ^{
        viewer->startViewing();
    });
     
    
    
    
    /*
    TCPClient *cli = new TCPClient();
    char *ip = "10.10.19.228";
    cli->connect(ip, 6881);
    //cli.sendMessage();
    char* stuff = cli->receiveMessage();
    
    NSImageView *imageView = [[NSImageView alloc] initWithFrame:_window.frame];
    
    
    //NSImage *i = createNSImage(stuff, 50, 50);
    NSImage *i = createNSImageReg(stuff, 1664, 2392);
    //NSImage *i = createNSImageReg(stuff, 50, 50);
    
    imageView.image = i;
    [_window setContentView:imageView];
     */
     
}

- (void) useB64
{
    /*
    TCPClient cli = TCPClient();
    cli.connect("10.10.19.228", 6881);
    //sleep(5);
    char *encoded = cli.receiveTextMessage();
    NSString *encodedString = [NSString stringWithUTF8String:encoded];
    NSLog(@"ENCODED STRING: %@", encodedString);
    NSData *decodedData = [encodedString base64DecodedData];
    NSImage *image = [[NSImage alloc] initWithData:decodedData];
    
        NSString *encodedString = @"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";
    
    //NSString *encodedString = @"";
    
    NSData *imData = [[NSData alloc] initWithBase64EncodedData:[encodedString dataUsingEncoding:NSUTF8StringEncoding] options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSImageView *imageView = [[NSImageView alloc] initWithFrame:_window.frame];
    imageView.image = image;//[[NSImage alloc] initWithData:imData];//image;
    [_window setContentView:imageView];
     
     */
}

- (void) makeImage
{
    TCPClient cli = TCPClient();
    char *ip = "10.10.19.228";
    cli.connect(ip, 6880);
    //cli.sendMessage();
    char* stuff = cli.receiveMessage();
//    char data[(690/3)+690];
//    
//    for(int i = 0; i < 690; i+=3){
//        if(i == 0){
//            data[i] = stuff[i];
//        }
//        else{
//            data[i+1] = stuff[i];
//        }
//    }
//    for(int i = 1; i < 690; i+=3){
//        if(i == 1){
//            data[i] = stuff[i];
//        }
//        else{
//            data[i+1] = stuff[i];
//        }
//    }
//    for(int i = 2; i < 690; i+=3){
//        if(i == 2){
//            data[i] = stuff[i];
//        }
//        else{
//            data[i+1] = stuff[i];
//        }
//    }
//    for(int i = 3; i < (690/3); i+=4){
//        data[i] = 255;
//    }

    NSImageView *imageView = [[NSImageView alloc] initWithFrame:_window.frame];
    

    NSImage *i = createNSImage(stuff, 50, 50);
    //i = createNSImageReg(stuff, 1664, 2392);
    
    
    
    imageView.image = [NSImage imageNamed:@"freeformatter-output-2.jpg"];
    //imageView.image = i;
    [_window setContentView:imageView];
}

- (void) showImageWithData:(unsigned char*) data
{
    NSImageView *imageView = [[NSImageView alloc] initWithFrame:_window.frame];
    NSImage *i = createNSImage(data, 50, 50);
    imageView.image = i;
    [_window setContentView:imageView];
}

- (void) yesterdaysImage
{
    NSImageView *imageView = [[NSImageView alloc] initWithFrame:_window.frame];
    
    int size = 4*320*480;
    unsigned char data[size];
    for(int i = 0; i < size; i+=4){
        data[i] = rand() % 256;//255;
        //NSLog(@"%c", data[i]);
    }
    for(int i = 1; i < size; i+=4){
        data[i] = rand() % 256;//0;
        //NSLog(@"%c", data[i]);
    }
    for(int i = 2; i < size; i+=4){
        data[i] = rand() % 256;//00;
        //NSLog(@"%c", data[i]);
    }
    for(int i = 3; i < size; i+=4){
        data[i] = 255;
        //NSLog(@"%c", data[i]);
    }
    
    NSImage *i = createNSImage(data, 320, 480);
    
    
    
    imageView.image = [NSImage imageNamed:@"freeformatter-output-2.jpg"];
    imageView.image = i;
    [_window setContentView:imageView];
}



- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
