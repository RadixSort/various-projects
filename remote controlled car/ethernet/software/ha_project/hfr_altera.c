#include "basic_io.h"
#include "DM9000A.h"
#include <alt_types.h>
#include <ctype.h>
#include <string.h>
#include "hfr_altera.h"
#include "hfr_config.h"


#define MAX_MSG_LENGTH 240
#define MASK 0xFF

#define FLAG        2 //33+15  
                        // WTF? 
//#define 

#define PORT        37 //22+15  
#define ORDERID_H     40  //25+15 
#define ORDERID_L     41  //26+15  
#define NAME_H      42   //27+15 
#define NAME_L      43   //28+15 
#define PRICE_H     44  //29+15 
#define PRICE_L     45  //30+15  
#define QUANT_H     46  //31+15 
#define QUANT_L     47  //32+15 
#define BUY_SELL    48 //33+15  

#define LEN_NO_MARKET 18   //3+15  


// Ethernet MAC address.  Choose the last three bytes yourself
unsigned char mac_address[6] = { 0x01, 0x60, 0x6E, 0x12, 0x03, 0x10  };

unsigned int interrupt_number;

unsigned int receive_buffer_length;
unsigned char receive_buffer[1600] = {0}; /* Be careful about this harcoded value*/

#define UDP_PACKET_PAYLOAD_OFFSET (42)
#define UDP_PACKET_LENGTH_OFFSET (38)

#define IP_PACKET_ID_OFFSET  (18)

#define IP_HEADER_OFFSET  (14)
#define IP_HEADER_SIZE  (20)
#define IP_HEADER_CHECKSUM_OFFSET  (24)

#define PACKET_TOTAL_LENGTH_OFFSET (16)

#define UDP_PACKET_PAYLOAD (transmit_buffer + UDP_PACKET_PAYLOAD_OFFSET )

#define HWREAD_16(OFFSET) IORD_16DIRECT(DM9000ACUSTOM_BASE, (OFFSET)*4)
#define HWWRITE_16(OFFSET, DATA) IOWR_16DIRECT(DM9000ACUSTOM_BASE, (OFFSET)*4, DATA)
//IOWR_16DIRECT(DM9000ACUSTOM_BASE, 2*4, 1);

static unsigned short int gIPPacketIDNum = 0;
static rcvCbk gRecvCallback = NULL;

extern unsigned int charArray4ToInt(unsigned char* pBuffer);

unsigned char transmit_buffer[] = {
  // Ethernet MAC header
  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, // Destination MAC address                    0 1 2 3 4 5
  0x01, 0x60, 0x6E, 0x12, 0x03, 0x10, // Source MAC address                         6 7 8 9 10 11
  0x08, 0x00,                         // Packet Type: 0x800 = IP                    12 13   

  // IP Header
  0x45,                // version (IPv4), header length = 20 bytes                  14
  0x00,                // differentiated services field                              15   
  0x00,0x2E,           // total length: 20 bytes for IP header +                    16
                       // 8 bytes for UDP header + 240 bytes for payload            17
  0x3d, 0x35,          // packet ID                                                18 19
  0x00,                // flags                                                     20
  0x00,                // fragment offset                                           21  
  0x80,                // time-to-live                                              22
  0x11,                // protocol: 11 = UDP                                        23
  0x00,0x00,           // header checksum: incorrect                                24 25
  0xc0,0xa8,0x01,0x71, // source IP address                                         26 27 28 29
  0xc0,0xa8,0x01,0x7A, // destination IP address                                    30 31 32 33 

  // UDP Header
  0x27,0x2c, // source port port (10027: garbage)                                   34 35
  0x27,0x2c, // destination port (10027: garbage)                                   36 37
  0x00,     //zero, do not touch                                                    38
  0xF8,     // length (248: 8 for UDP header + 240 for data)                        39
  0x00,0x00, // checksum: 0 = none                                                  40
            
  // UDP payload (240 bytes) (First 5 bytes are for name)
  0x20, 0x20, 0x20, 0x20, 0x3A, 0x6d, 0x73, 0x67,                                   //41 ....
  0x74, 0x65, 0x73, 0x74, 0x20, 0x6d, 0x73, 0x67,
  0x74, 0x65, 0x73, 0x74, 0x20, 0x6d, 0x73, 0x67,
  0x74, 0x65, 0x73, 0x74, 0x20, 0x6d, 0x73, 0x67,
  0x74, 0x65, 0x73, 0x74, 0x20, 0x6d, 0x73, 0x67,
  0x74, 0x65, 0x73, 0x74, 0x20, 0x6d, 0x73, 0x67,
  0x74, 0x65, 0x73, 0x74, 0x20, 0x6d, 0x73, 0x67,
  0x74, 0x65, 0x73, 0x74, 0x20, 0x6d, 0x73, 0x67,
  0x74, 0x65, 0x73, 0x74, 0x20, 0x6d, 0x73, 0x67,
  0x74, 0x65, 0x73, 0x74, 0x20, 0x6d, 0x73, 0x67,
  0x74, 0x65, 0x73, 0x74, 0x20, 0x6d, 0x73, 0x67,
  0x74, 0x65, 0x73, 0x74, 0x20, 0x6d, 0x73, 0x67,
  0x74, 0x65, 0x73, 0x74, 0x20, 0x6d, 0x73, 0x67,
  0x74, 0x65, 0x73, 0x74, 0x20, 0x6d, 0x73, 0x67,
  0x74, 0x65, 0x73, 0x74, 0x20, 0x6d, 0x73, 0x67,
  0x74, 0x65, 0x73, 0x74, 0x20, 0x6d, 0x73, 0x67,
  0x74, 0x65, 0x73, 0x74, 0x20, 0x6d, 0x73, 0x67,
  0x74, 0x65, 0x73, 0x74, 0x20, 0x6d, 0x73, 0x67,
  0x74, 0x65, 0x73, 0x74, 0x20, 0x6d, 0x73, 0x67,
  0x74, 0x65, 0x73, 0x74, 0x20, 0x6d, 0x73, 0x67,
  0x74, 0x65, 0x73, 0x74, 0x20, 0x6d, 0x73, 0x67,
  0x74, 0x65, 0x73, 0x74, 0x20, 0x6d, 0x73, 0x67,
  0x74, 0x65, 0x73, 0x74, 0x20, 0x6d, 0x73, 0x67,
  0x74, 0x65, 0x73, 0x74, 0x20, 0x6d, 0x73, 0x67,
  0x74, 0x65, 0x73, 0x74, 0x20, 0x6d, 0x73, 0x67,
  0x74, 0x65, 0x73, 0x74, 0x20, 0x6d, 0x73, 0x67,
  0x74, 0x65, 0x73, 0x74, 0x20, 0x6d, 0x73, 0x67,
  0x74, 0x65, 0x73, 0x74, 0x20, 0x6d, 0x73, 0x67,
  0x74, 0x65, 0x73, 0x74, 0x20, 0x6d, 0x73, 0x67,
  0x74, 0x65, 0x73, 0x74, 0x20, 0x6d, 0x73, 0x67
};
                     
/**********************************************************
 * Computes the checksum of ipHeader of iLength
 *
*********************************************************/
unsigned short int IPCheckSum(unsigned char* ipHeader, int iLength)
{
    long sum = 0;  /* Sum is 4 bytes */
    int count = 0;
    unsigned short tempSum = 0;
    /* Compute the checksum */
    while(iLength > 1){
        tempSum = *(ipHeader);
        /* Copy the ipHeader lower byte to higher byte of tempSum */
        tempSum = (tempSum << 8) + 0x00;
        tempSum = tempSum + (*(ipHeader+1));
        sum = sum +  tempSum; /* 2 bytes of ipHeader used */
        ipHeader += 2; /* Move 2 bytes */
        if(sum & 0x80000000){   /* if high order bit set (when 4 bytes of sum may not be
enuf)*/
               sum = (sum & 0xFFFF) + (sum >> 16);
        }
        iLength -= 2;
        count++;
    }

    if(iLength){       /* if  ipHeader has odd bytes */
        sum = sum + (unsigned short)(*(ipHeader));
    }

    while(sum>>16){ /* Add the contents in 3rd and 4th byte to first 2 bytes */
        sum = (sum & 0xFFFF) + (sum >> 16);
    }

    return(~sum); /* take 1's compliment and return */
}


/**********************************************************
 * handle the ethernet interrupts
 *
*********************************************************/
static void ethernet_interrupt_handler() {
    unsigned int receive_status;
    char *p;
    unsigned short usIPCheckSum = 0;
    unsigned char ucDatabuffer[100] = {0};
    unsigned short usCount = 0;

    if(HWREAD_16(FLAG) == 1){ /* Check if market data or not */
        if(HWREAD_16(PORT)==0x2b27){
            /* Copy OrderId */
            for(usCount = 0; usCount < 2; usCount++){
               ucDatabuffer[usCount] = ((HWREAD_16(ORDERID_H)) >> usCount*8) & 0xFF;
            }
            for(usCount = 0; usCount < 2; usCount++){
                ucDatabuffer[usCount+2] = ((HWREAD_16(ORDERID_L)) >> usCount*8) & 0xFF;
            }
            /* Copy Price */
            for(usCount = 0; usCount < 2; usCount++){
                ucDatabuffer[usCount+4] = ((HWREAD_16(PRICE_H)) >> usCount*8) & 0xFF;
            }
            for(usCount = 0; usCount < 2; usCount++){
                ucDatabuffer[usCount+6] = ((HWREAD_16(PRICE_L)) >> usCount*8) & 0xFF;
            }
             
            /* Copy Name */
            for(usCount = 0; usCount < 2; usCount++){
                ucDatabuffer[usCount+8] = ((HWREAD_16(NAME_H)) >> usCount*8) & 0xFF;
            }
            for(usCount = 0; usCount < 2; usCount++){
                ucDatabuffer[usCount+10] = ((HWREAD_16(NAME_L)) >> usCount*8) & 0xFF;
            }
            
             /* Copy Quantity */
            for(usCount = 0; usCount < 2; usCount++){
                ucDatabuffer[usCount+13] = ((HWREAD_16(QUANT_H)) >> usCount*8) & 0xFF;
            }
            for(usCount = 0; usCount < 2; usCount++){
                ucDatabuffer[usCount+15] = ((HWREAD_16(QUANT_L)) >> usCount*8) & 0xFF;
            }
            
            
             /* Copy Buy/Sell*/
            ucDatabuffer[12] = HWREAD_16(BUY_SELL);
            if(gRecvCallback){ /* Check if the application has registered the recv cbk */
                gRecvCallback(1,ucDatabuffer);
            }      
        }
        else{        
            printf("\n Non Market Packet\n");
            printf("Length %d\n",HWREAD_16(LEN_NO_MARKET));
            
        }
        //msleep(1);
        HWWRITE_16(0, 0);
    }
    else{
        printf("lab2 default\n");
        receive_status = ReceivePacket(receive_buffer, &receive_buffer_length);
    
        if (receive_status == DMFE_SUCCESS) {
            printf("\n\nReceive Packet Length = %d\n", receive_buffer_length);
    
            if (receive_buffer_length >= 14) {
                /* A real Ethernet packet */
                if (receive_buffer[12] == 8 && receive_buffer[13] == 0 &&
                receive_buffer_length >= 34) {
                    /* An IP packet */
                    /* Check IP Header Checksum */
                    usIPCheckSum = IPCheckSum(receive_buffer+IP_HEADER_OFFSET,
    IP_HEADER_SIZE);
                    
                    if(usIPCheckSum){
                        printf("received checksum fail; discarding the packet\n");
                    }
                    else{
                        printf("received checksum successs\n");
                    }
    
                    if (receive_buffer[23] == 0x11) {
                        /* A UDP packet */
                        if (receive_buffer_length >= UDP_PACKET_PAYLOAD_OFFSET) {
                            /* receive_buffer has max of 1600 bytes. Hence read only 1600
    bytes */
                            receive_buffer[1599] = 0;
                            p = receive_buffer + UDP_PACKET_PAYLOAD_OFFSET;
                            //if(!usIPCheckSum){
                            if(1){
                                printf("First Byte: %x\n",receive_buffer[0]);
                                printf("Received: %s\n",receive_buffer +UDP_PACKET_PAYLOAD_OFFSET);
                                if(gRecvCallback){ /* Check if the application has registered
    the recv cbk */
                                    gRecvCallback(1,p);
                                }
                            }
                        }
                    }
                    else{
                        printf("Received non-UDP packet\n");
                    }
                }
                else {
                    printf("Received non-IP packet\n");
                }
            }
            else {
                printf("Malformed Ethernet packet\n");
            }
        }
        else {
            printf("Error receiving packet\n");
        }
    
      /* Display the number of interrupts on the LEDs */
      interrupt_number++;
      
    
      /* Clear the DM9000A ISR: PRS, PTS, ROS, ROOS 4 bits, by RW/C1 */
      dm9000a_iow(ISR, 0x3F);
    
      /* Re-enable DM9000A interrupts */
      dm9000a_iow(IMR, INTR_set);
    }
    return;
}


/**********************************************************
 * altera_init()
 *
*********************************************************/
int altera_init(rcvCbk pRecvCallback)
{
    unsigned short usCount = 0;
    short retVal = 0;

    /* Make sure we are writing to DMA PHY directly */
//    #define HWWRITE_16(OFFSET, DATA) IOWR_16DIRECT(DM9000ACUSTOM_BASE, (OFFSET)*4, DATA)
    HWWRITE_16(2, 0);    //DM9000ACUSTOM_BASE, 2*4, 0);
     
    /* Initalize the DM9000 and the Ethernet interrupt handler */
    retVal = DM9000_init(mac_address);

    if(retVal == DMFE_SUCCESS){
        printf("DM9000_init successful\n");
    }
    else
    {
        printf("DM9000_init fail\n");
        return err_Board;
    }
    interrupt_number = 0;
    
    //printf("init reading %x\n", IORD_16DIRECT(DM9000ACUSTOM_BASE, 0));
    
    /* Register interrupt handler */
    alt_irq_register(DM9000ACUSTOM_IRQ, NULL, (void*)ethernet_interrupt_handler);

    /* Clear the payload */
    for (usCount= MAX_MSG_LENGTH-1; usCount>0; usCount--) {
        UDP_PACKET_PAYLOAD[usCount] = 0;
    }

    /* Register Recv Callback */
    gRecvCallback = pRecvCallback; /* pRecvCallback could be NULL! */
    return SUCCESS;
}

/*********************************************************
* altera_send: send data pData over usConnectionId
*
*
* return : 0 on success, -1 on failure
*********************************************************/
int altera_send(unsigned short usConnectionId, char* pData,
                     unsigned int uiDataLen)
{
    short sRetVal = SUCCESS;
    unsigned short usCount = 0;
    unsigned int uiPacketLength = 0;
    unsigned int totPacketLength = 0;
    unsigned short usIPCheckSum = 0;

    /* Set to software send mode */
    HWWRITE_16(2, 0);
    if(!pData){
        return err_BadInput; /* TBD: application err codes */
    }
    strcpy(UDP_PACKET_PAYLOAD, pData);
    UDP_PACKET_PAYLOAD[uiDataLen] = 0; /* End of data */ //cause it sends strings
    
    /* Increment IP packet ID*/
    gIPPacketIDNum++;
    transmit_buffer[IP_PACKET_ID_OFFSET] = gIPPacketIDNum >> 8;
    transmit_buffer[IP_PACKET_ID_OFFSET + 1] = gIPPacketIDNum & 0xff;


    /* Compute IP Header Checksum */
    usIPCheckSum = IPCheckSum(transmit_buffer+IP_HEADER_OFFSET, IP_HEADER_SIZE);
    transmit_buffer[IP_HEADER_CHECKSUM_OFFSET] = usIPCheckSum >> 8;
    transmit_buffer[IP_HEADER_CHECKSUM_OFFSET+1] = usIPCheckSum & 0xff;

    /* Check IP Header Checksum */
    usIPCheckSum = IPCheckSum(transmit_buffer+IP_HEADER_OFFSET, IP_HEADER_SIZE);
    if(usIPCheckSum){
       printf("checksum fail\n");
    }
    else{
    //    printf("checksum successs\n");
    }

    /* Update packet length */
    //UDP section of packet length
    uiPacketLength = 8 + uiDataLen; //UDP HEADER IS 8 bytes
    transmit_buffer[UDP_PACKET_LENGTH_OFFSET] = uiPacketLength >> 8; //write to the zero
    transmit_buffer[UDP_PACKET_LENGTH_OFFSET + 1] = uiPacketLength & 0xff; //write the actual length
    
    //total packet length
    totPacketLength = 28 + uiDataLen; //IP header is 20 byres
    transmit_buffer[PACKET_TOTAL_LENGTH_OFFSET] = totPacketLength >> 8; //write to the zero
    transmit_buffer[PACKET_TOTAL_LENGTH_OFFSET + 1] = totPacketLength & 0xff; //write the actual length
    

    /* Send UDP packet */
    if (TransmitPacket(transmit_buffer, UDP_PACKET_PAYLOAD_OFFSET + uiDataLen +
            1)==DMFE_SUCCESS) {
        printf("\nMessage sent successfully\n");
        printf("Bytes sent: %d\n",UDP_PACKET_PAYLOAD_OFFSET + uiDataLen - 1);
        printf("Bytes: %s\n",UDP_PACKET_PAYLOAD);
        
     TransmitPacket(transmit_buffer, UDP_PACKET_PAYLOAD_OFFSET + uiDataLen + 1);

      TransmitPacket(transmit_buffer, UDP_PACKET_PAYLOAD_OFFSET + uiDataLen + 1);

       TransmitPacket(transmit_buffer, UDP_PACKET_PAYLOAD_OFFSET + uiDataLen + 1);
        
    }
    else {
        printf("\nMessage sending failed\n");
        sRetVal = err_Board;
    }

    /* reset data */
    for (usCount=MAX_MSG_LENGTH-1; usCount>0; usCount--) {
    UDP_PACKET_PAYLOAD[usCount] = 0;
    }

    /* Set the IP CheckSum Fields to Zero */
    transmit_buffer[IP_HEADER_CHECKSUM_OFFSET + 1] = 0x00;
    transmit_buffer[IP_HEADER_CHECKSUM_OFFSET] = 0x00;
    
    

    msleep(1);
    
    /* Set to custom hardware receive mode */
    HWWRITE_16(2, 1);   
            
    return sRetVal;
}

/*********************************************************
* displayMetrics: close the board
*
*
* return : 0 on success, -1 on failure
*********************************************************/
int displayMetrics(void)
{
    unsigned char ucDatabuffer[100] = {0};
    unsigned short usCount = 0;
    unsigned int usHWTime = 0;
    unsigned int usHWSWTime = 0;
    
   /* Copy HW read time */
    for(usCount = 0; usCount < 2; usCount++){
        ucDatabuffer[1 - usCount] = ((HWREAD_16(4)) >> usCount*8) & 0xFF;
    }
    for(usCount = 0; usCount < 2; usCount++){
        ucDatabuffer[1 - usCount +2] = ((HWREAD_16(3)) >> usCount*8) & 0xFF;
    }
  
    /* Copy HW/SW read time */
    for(usCount = 0; usCount < 2; usCount++){
        ucDatabuffer[1 - usCount+4] = ((HWREAD_16(6)) >> usCount*8) & 0xFF;
    }
    for(usCount = 0; usCount < 2; usCount++){
        ucDatabuffer[1 - usCount+6] = ((HWREAD_16(5)) >> usCount*8) & 0xFF;
    }

    usHWTime = charArray4ToInt(ucDatabuffer);
    printf("HW read time      %u\n",usHWTime);
    usHWSWTime = charArray4ToInt(ucDatabuffer+4);
    printf("Overall read time %u\n",usHWSWTime);
    return SUCCESS;
}

/*********************************************************
* altera_close: close the board
*
*
* return : 0 on success, -1 on failure
*********************************************************/
int altera_close(void)
{
    /* un register the interuupt handler */
    return SUCCESS;
}
