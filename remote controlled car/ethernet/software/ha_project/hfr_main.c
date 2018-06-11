/*
 * CSEE 4840 Project
 * High Frequency Reader
 *
 * hfr_main.c: Has main function, Board init, Read/Write
 *
 * Created by : Manu
 * Modified by : Adil, Amandeep, Manu, Prabhat
 */

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>
#include <unistd.h>
#include "hfr_altera.h"
#include "hfr_config.h"

#include "basic_io.h"

#define AGGREGATERECVNUM 100


/* Count of total orders received */
unsigned int gPacketCount = 0;

/* Flag indicating to process the received orders */
int gPacketsReceivedFlag = 0;

/* Bid or Offer order */
typedef enum eStockType {
 eOffer = 0,
 eBid
}eStockType;

/* Temperory structure to copy data from the interrupt handler */
typedef struct StockData{
    unsigned char cOrderId[ODRIDSIZE+1];
    unsigned char cStock[HFRSTOCKSIZE+1];
    unsigned char cPrice[HFRPRICESIZE+1];
    unsigned char cNumShares[HFRNUMSHARESSIZE+1];
    unsigned char cBidFlag[HFRBIDOFFERSIZE+1];  /* Zero means Offer/ 1 means bid*/
}odrData;

static odrData gRecvData ;

/* Doubly Linked List to Keep Offer and Bid orders */
typedef struct marketData{
    unsigned int iOrderId;
    unsigned char cStock[HFRSTOCKSIZE+1];
    unsigned int iPrice;
    unsigned int iNumShares;
    struct marketData* pNextNode;
    struct marketData* pPreviousNode;
}marketData;

/* Head and Tail Pointer of the lists */
static marketData* pHeadNodeBid = NULL;
static marketData* pTailNodeBid = NULL;
static marketData* pHeadNodeOffer = NULL;
static marketData* pTailNodeOffer = NULL;


/*********************************************************
* charArray4ToInt
* 4 byte char array to int
* (only positive integers considered)
*
*********************************************************/
unsigned int charArray4ToInt(unsigned char* pBuffer)
{
    unsigned int iValue = 0;
    int i = 0, temp =0;
    if(NULL == pBuffer){
        return 0; // indicates error
    }
    for(i = 3; i >=0; i--){
        temp = pBuffer[i];
        iValue = (iValue | temp << (3-i)*8);
    }
    return iValue;
}

/*********************************************************
* addNode()
*
*
*
*********************************************************/
static void addNode(eStockType eBidFlag)
{
    marketData *pTemp = NULL;
    marketData *pCurrentNode = NULL;
    
    pTemp = (marketData*)malloc(sizeof(marketData));
    if(pTemp == NULL){
        printf("packetCount: %d\n", gPacketCount);
        printf("Error in add Node; probably no memory available \n");
        return;
    }

    /* Copy the values into the node */
    pTemp->iOrderId = charArray4ToInt(gRecvData.cOrderId);
    pTemp->iNumShares = charArray4ToInt(gRecvData.cNumShares);
    pTemp->iPrice = charArray4ToInt(gRecvData.cPrice);
    strcpy(pTemp->cStock,gRecvData.cStock);
    pTemp->cStock[HFRSTOCKSIZE] = 0;
    
#if 0 /* Check if the data received is as sent */
    if(pTemp->iPrice != 400){
       printf("Errrr Price: order id %d\n",pTemp->iOrderId);
    }
    if(pTemp->iNumShares != 500){
        printf("Errrr Num Shares: order id %d\n",pTemp->iOrderId);
    }
    if(strcmp(pTemp->cStock,"goog")){
        printf("Errrr Stock: order id %d\n",pTemp->iOrderId);
    }
    
#endif
    
    if(eBidFlag){ /* Bid List is in Descending order */
        if(pHeadNodeBid == NULL){ /* First element of the list*/
            pTemp->pPreviousNode = NULL;
            pTemp->pNextNode = NULL;
            pHeadNodeBid = pTemp;
            pTailNodeBid = pTemp;
        }
        else{
            pCurrentNode = pHeadNodeBid;
            /* Find a location to place the node */
            while((pCurrentNode) && (pCurrentNode->iPrice > pTemp->iPrice)){
                pCurrentNode = pCurrentNode->pNextNode;
            }
            if(pCurrentNode){
                if(pCurrentNode->pPreviousNode){
                    pCurrentNode->pPreviousNode->pNextNode = pTemp;
                    pTemp->pNextNode = pCurrentNode;
                    pTemp->pPreviousNode = pCurrentNode->pPreviousNode;
                    pCurrentNode->pPreviousNode = pTemp;
                }
                else{/* pTemp is the 1st node (head node) in the list now */  
                    pTemp->pPreviousNode = NULL;
                    pTemp->pNextNode = pHeadNodeBid;
                    pHeadNodeBid->pPreviousNode = pTemp;
                    pHeadNodeBid = pTemp;
                }       
            }
            else{ /* This is the last node in the list now */
                pTemp->pPreviousNode = pTailNodeBid;
                pTemp->pNextNode = NULL;
                pTailNodeBid->pNextNode = pTemp;
                pTailNodeBid = pTemp;
            }
        }
    }
    else{ /* Offer list is in ascending order */
        if(pHeadNodeOffer == NULL){ /* First element of the list*/
            pTemp->pPreviousNode = NULL;
            pTemp->pNextNode = NULL;
            pHeadNodeOffer = pTemp;
            pTailNodeOffer = pTemp;
        }
        else{
            pCurrentNode = pHeadNodeOffer;
             /* Find a location to place the node */
            while((pCurrentNode) && (pCurrentNode->iPrice < pTemp->iPrice)){
                pCurrentNode = pCurrentNode->pNextNode;
            }
            if(pCurrentNode){
                if(pCurrentNode->pPreviousNode){
                    pCurrentNode->pPreviousNode->pNextNode = pTemp;
                    pTemp->pNextNode = pCurrentNode;
                    pTemp->pPreviousNode = pCurrentNode->pPreviousNode;
                    pCurrentNode->pPreviousNode = pTemp;
                }
                else{/* pTemp is the 1st node (head node) in the list now */
                    pTemp->pPreviousNode = NULL;
                    pTemp->pNextNode = pHeadNodeOffer;
                    pHeadNodeOffer->pPreviousNode = pTemp;
                    pHeadNodeOffer = pTemp;
                }       
            }
            else{ /* This is the last node (tail node) in the list now */
                pTemp->pPreviousNode = pTailNodeOffer;
                pTemp->pNextNode = NULL;
                pTailNodeOffer->pNextNode = pTemp;
                pTailNodeOffer = pTemp;
            }
        }
    }
    return;
}

/*********************************************************
* deleteNode()
*
*
*
*********************************************************/
static void deleteNode(marketData* pNode, eStockType eBidFlag)
{
    if(pNode){
        /* Create appropriate links */
        if((pNode->pPreviousNode) && (pNode->pNextNode)){
            pNode->pPreviousNode->pNextNode = pNode->pNextNode;
            pNode->pNextNode->pPreviousNode = pNode->pPreviousNode;
        }
        
        /* The node being deleted is the head node */
        else if (pNode->pNextNode){ 
            if(eBidFlag){
                pHeadNodeBid = pNode->pNextNode;
            }
            else{
                pHeadNodeOffer = pNode->pNextNode;
            }
            pNode->pNextNode->pPreviousNode = NULL;
        }
        
        /* The node being deleted is the tail node */
        else if (pNode->pPreviousNode) { 
            if(eBidFlag){
                pTailNodeBid = pNode->pPreviousNode;  
            }
            else{
                pTailNodeOffer = pNode->pPreviousNode;
            }
            pNode->pPreviousNode->pNextNode = NULL;
        }
        
        else { /* The only node in the list */
            if(eBidFlag){
                pHeadNodeBid = NULL;
                pTailNodeBid = NULL;  
            }
            else{
                pHeadNodeOffer = NULL;
                pTailNodeOffer = NULL;
            }
        }
        
        /* Finally free the node */
        free(pNode);
    }
}

/*********************************************************
* makeDeals()
*
* Makes deals based on price (Only price)
*
*********************************************************/
static void makeDeals()
{
    while((pHeadNodeBid) && (pHeadNodeOffer) && (pHeadNodeBid->iPrice >= pHeadNodeOffer->iPrice) ){
        printf("Deal made:\n BidId: %u\t OfferId: %u\n", 
                    pHeadNodeBid->iOrderId, pHeadNodeOffer->iOrderId);
        deleteNode(pHeadNodeBid,1);
        deleteNode(pHeadNodeOffer,0);
    }
}

/*********************************************************
* printList()
*
* Prints the Bid list or Offer List
*
*********************************************************/
static void printList(eStockType eBidFlag)
{
    int count = 0;
    marketData* pTemp = NULL;
    
    /* Start at the head of Bid list or Offer list*/
    if(eBidFlag){
        pTemp = pHeadNodeBid;
        printf("Printing Bid List\n");
    }
    else{
        pTemp = pHeadNodeOffer;
        printf("Printing Offer List\n");
    }
    
    /* Print the list until there are nodes */
    while(pTemp){
        printf("OrderId: %u\t",pTemp->iOrderId);
        printf("Stock: %s\t",pTemp->cStock);
        printf("Price: %u\t",pTemp->iPrice);
        printf("NumShares: %u\n",pTemp->iNumShares);
        count++;
        pTemp = pTemp->pNextNode;
    }
    //printf("Num packets in the list is %d\n",count);
    return;
}

/*********************************************************
* displayStockData()
*  
* Displays data copied into the temporary structure 
*
*********************************************************/
void displayStockData(void)
{
    printf("OrderId: %s\n",gRecvData.cOrderId);
    printf("Stock: %s\n",gRecvData.cStock);
    printf("Price: %s\n",gRecvData.cPrice);
    printf("NumShares: %s\n",gRecvData.cNumShares);
    printf("BidFlag: %s\n",gRecvData.cBidFlag);
}

/***************************************************************************
* recvCallbackFunc()
*
*
*
***************************************************************************/
int recvCallbackFunc(unsigned short usConnectionId, unsigned char* pData)
{
    if(!pData){
        printf("Error found in recvCallbackFunc\n");
        return -1;
    }
    
    /* Copy the decoded maket order data byte by byte into the structure */
    
    /* Data is assumed to be in the following format :
     * Order Id  : 4 bytes  
     * Stock     : 4 bytes 
     * Price     : 4 bytes 
     * Num Shares: 4 bytes 
     * Bid/Offer : 1 byte */
     
     /* Order Id */
     memcpy(gRecvData.cOrderId, pData, ODRIDSIZE);
     gRecvData.cOrderId[ODRIDSIZE] = 0;
     
     /* Price */
     memcpy(gRecvData.cPrice, pData + ODRIDSIZE, HFRPRICESIZE);
     gRecvData.cPrice[HFRPRICESIZE] = 0; 
     
     /* Stock name */
     memcpy(gRecvData.cStock, pData + ODRIDSIZE +HFRPRICESIZE, HFRSTOCKSIZE);
     gRecvData.cStock[HFRSTOCKSIZE] = 0;
     
     /* Bid/ Offer Flag */
     memcpy(gRecvData.cBidFlag, pData + ODRIDSIZE + HFRSTOCKSIZE+ HFRPRICESIZE, HFRBIDOFFERSIZE);
     gRecvData.cBidFlag[HFRBIDOFFERSIZE] = 0;
     
     /* Number of Shares */
     memcpy(gRecvData.cNumShares, pData + ODRIDSIZE + HFRSTOCKSIZE+ HFRPRICESIZE + HFRBIDOFFERSIZE,
         HFRNUMSHARESSIZE);
     gRecvData.cNumShares[HFRNUMSHARESSIZE] = 0;
    
    /* Increment the packet (order) count */
    gPacketCount++;
   
    /* Add order to the list */
    addNode(gRecvData.cBidFlag[0]);
    
    /* Display the elements in the lists */
    if(gPacketCount % AGGREGATERECVNUM == 0){
        gPacketsReceivedFlag = 1;
    }
    return SUCCESS;
}


/*********************************************************
* main()
*
*
*
*********************************************************/
int main()
{  
    int iCount = 0;
    marketData* pTemp = NULL;
    
    short sRetVal = 0;
    short sRetVal1 = 0;
    short sRetVal2 = 0;
    unsigned short usConnectionId = HFR_CONNECTIONID;
    
    /* Initialize the board being used */
    sRetVal = altera_init(recvCallbackFunc);

    printf("altera_init done\n");
    if(sRetVal != SUCCESS){
        printf("error in altera_init\n");
        goto ErrorExit;
    }
    /* Wait for board to initialize */
    usleep(3000000);

    /* Send several test packets using Software to make sure board is initialized properly */
    while(1){
        sRetVal1 = altera_send(usConnectionId, "wsswadda", 14);
            
        //sRetVal2 = altera_send(usConnectionId, "1234567890A", 11);
        
        if(sRetVal1 != SUCCESS){
            printf("error in altera_send\n");
            goto ErrorExit;
        }
        /*if(sRetVal2 != SUCCESS){
            printf("error in altera_send\n");
            goto ErrorExit;
        }*/
    }
    /* Wait for packet(s) to be received */
    while(1){
        if(gPacketsReceivedFlag){
            gPacketsReceivedFlag = 0; /* Reset the flag */
            
 
            printList(eOffer); /* Print the Offer List */
            printList(eBid); /* Print the bid List */
            
            /* Display the number of elements in Offer list */
            pTemp = pHeadNodeOffer;
            iCount = 0;
            while(pTemp){
                pTemp = pTemp->pNextNode;
                iCount++; 
            }
            printf("Num elements in Offer List is %d\n",iCount);
            
            /* Display the number of elements in Bid list */
            pTemp = pHeadNodeBid;
            iCount = 0;
            while(pTemp){
                pTemp = pTemp->pNextNode;
                iCount++; 
            }
            printf("Num elements in Bid List is %d\n",iCount);
            
            makeDeals();
            
            printList(eOffer); /* Print the Offer List */
            printList(eBid); /* Print the bid List */
            displayMetrics(); /* Show HW read time and HW+SW read time */
            /* Switch to Software mode and send ack */   
            altera_send(1, "Packets Received Ack", 20);
        }
    }
    
    /* Close and exit gracefully */
    sRetVal = altera_close();
    if(sRetVal != SUCCESS){
        printf("error in altera_close\n");
        goto ErrorExit;
    }

    return 0;
    
    /* Error */
    ErrorExit:
        printf("Program terminated with an error condition\n");

    return 1;
}
