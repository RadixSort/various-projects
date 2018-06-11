#ifndef HFR_CONFIG_H_
#define HFR_CONFIG_H_

#define HFR_CONNECTIONID 1
#define HFRSTOCKSIZE 4
#define HFRPRICESIZE 4
#define HFRNUMSHARESSIZE 4
#define ODRIDSIZE 4
#define HFRBIDOFFERSIZE 1

typedef enum hfrErrCodes {
 SUCCESS = 0,
 err_BadInput,
 err_Board,
 err_Unknown
 }hfrErrCodes;


#endif /*HFR_CONFIG_H_*/
