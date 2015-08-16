//
//  ISocketServer.cpp
//  HelloWorld
//
//  Created by Odie Edo-Osagie on 16/08/2015.
//  Copyright (c) 2015 Oduwa Edo Osagie. All rights reserved.
//

#include "ISocketServer.h"
#include "CommonFuncs.h"

const char ISocketServer::FRAME_BUFFER_REQUEST_MESSAGE[] = "wantFrame";
const char ISocketServer::STOP_LISTENING_MESSAGE[] = "plsstop";


void ISocketServer::listenThreadFunction()
{
    int n = 0;
    while(isListening){
        bool hasMsg = readMessageIntoBuffer();
        
        if(hasMsg == true){
            printf("RECEIVED MSG FROM CLIENT: %s\n", messageBuffer);
            
            if(strcmp(messageBuffer, ISocketServer::FRAME_BUFFER_REQUEST_MESSAGE) == 0){
                isFrameDataBeingUsed = true;
                sendData(data, frameSize);
                isFrameDataBeingUsed = false;
            }
            else if(strcmp(messageBuffer, ISocketServer::STOP_LISTENING_MESSAGE) == 0){
                n = write(newsockfd, "Stopping..", 10);
                if(n <= 0){
                    CommonFuncs::error("ERROR writing to socket");
                }
                stopListening();
            }
            else{
                n = write(newsockfd, "gotcha", 6);
                if(n <= 0){
                    CommonFuncs::error("ERROR writing to socket");
                }
            }
        }
    }
}


bool ISocketServer::readMessageIntoBuffer()
{
    int n = 0;
    bzero(messageBuffer,256);
    n = read(newsockfd,messageBuffer,255);
    printf("READ: %d\n", n);
    if (n < 0){
        //CommonFuncs::error("ERROR reading from socket");
        return false;
    }
    if(n > 0){
        printf("Here is the message: %s",messageBuffer);
        return true;
    }
    
    return false;
}

ISocketServer::ISocketServer()
{
    width = 1664;
    height = 2392;
    frameSize = width*height*4;
    data = new signed char[frameSize];
    for(int i = 0; i < frameSize; i++){
        data[i] = 25;
    }
    isFrameDataBeingUsed = false;
    safeToSend = true;
}

ISocketServer::~ISocketServer()
{
    listenThread->detach();
    delete listenThread;
}

bool ISocketServer::connect(int port)
{
    sockfd = socket(AF_INET, SOCK_STREAM, 0);
    if(sockfd < 0){
        CommonFuncs::error("ERROR opening socket");
        return false;
    }
    
    bzero((char *) &serv_addr, sizeof(serv_addr));
    portno = port;
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_port = htons(portno); // converts number to big endian (network byte order) if on little endian host
    serv_addr.sin_addr.s_addr = INADDR_ANY;
    
    if (bind(sockfd, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) < 0){
        CommonFuncs::error("ERROR on binding");
        return false;
    }
    
    listen(sockfd,5);
    clilen = sizeof(cli_addr);
    newsockfd = accept(sockfd, (struct sockaddr *) &cli_addr, &clilen);
    if (newsockfd < 0){
        CommonFuncs::error("ERROR on accept");
        return false;
    }
    
    
    return true;
}


void ISocketServer::startListening()
{
    isListening = true;
    int n;
    
    listenThread = new std::thread(&ISocketServer::listenThreadFunction, this);
    //    listenThread->join();
    //    listenThread->detach();
    
    //listenThreadFunction();
    
    //    while(true){
    //        printf("pikachu");
    //        sleep(5);
    //    }
}

void ISocketServer::stopListening()
{
    isListening = false;
}

void ISocketServer::sendData(signed char* data, int len)
{
    // Write length of data
    char lenStr[10];
    sprintf(lenStr, "%d", len);
    int n = write(newsockfd,lenStr,10);
    
    
    // Write data
    n = write(newsockfd,data,len);
    if (n < 0){
        CommonFuncs::error("ERROR writing to socket");
    }
    else{
        printf("WROTE TO SOCKET");
    }
}