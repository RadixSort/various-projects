#ifndef HFR_ALTERA_H_
#define HFR_ALTERA_H_


typedef int(*rcvCbk)(unsigned short, unsigned char*);

/*********************************************************
* altera_init: initialize the board/ ethernet interface
*
*
* return : 0 on success, -1 on failure
*********************************************************/
int altera_init(rcvCbk pRecvCallback);

/*********************************************************
* altera_send: send data pData over usConnectionId
*
*
* return : 0 on success, -1 on failure
*********************************************************/
int altera_send(unsigned short usConnectionId, char* pData,
                unsigned int uiDataLen);



/*********************************************************
* displayMetrics: close the board
*
*
* return : 0 on success, -1 on failure
*********************************************************/
int displayMetrics(void);

/*********************************************************
* altera_close: close the board
*
*
* return : 0 on success, -1 on failure
*********************************************************/
int altera_close(void);

#endif /*HFR_ALTERA_H_*/
