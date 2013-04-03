/** @defgroup G_ISERIAL iSerial SDK
 Provides access to iSerial serial and bluetooth devices.
 In order to use iSerialSDK in your program, several steps have to be performed:
 - Include iSerialSDK.h and libdtdevices.a in your project.
 - Go to Frameworks and add ExternalAccessory framework
 - Edit your program plist file, add new element and select "Supported external accessory protocols" from the list,
 then add it - com.datecs.iserial.communication
 @{
 */

#import <Foundation/Foundation.h>

#define PARITY_NONE 0
#define PARITY_EVEN 1
#define PARITY_ODD 2

#define DATABITS_7 1
#define DATABITS_8 0

#define STOPBITS_1 0
#define STOPBITS_2 1

#define FLOW_NONE 0
#define FLOW_RTS_CTS 1
#define FLOW_DTR_DSR 2
#define FLOW_XON_XOFF 3

/**
 Notifications, sent from iSerialSDK on various events
 **/
@protocol iSerialDelegate
@optional

/**
 Notification sent when iSerial device is connected, you can proceed to create serial or bluetooth connection after
 **/
-(void)iSerialConnected;

/**
 Notification sent when iSerial device disconnects
 **/
-(void)iSerialDisconnected;

/**
 Notification sent when bluetooth discovery completes successfully, even if no devices are found
 **/
-(void)bluetoothDiscoveryComplete;

/**
 Notification sent when bluetooth discovery fails.
 @param error the error code and description
 **/
-(void)bluetoothDiscoveryFailedWithError:(NSError *)error;

/**
 Notification sent when bluetooth discovery finds new bluetooth device
 @param btAddress bluetooth address of the device
 @param btName bluetooth name of the device
 **/
-(void)bluetoothDeviceDiscovered:(NSString *)btAddress name:(NSString *)btName;

@end

/** Operation successful. */
static const int ISERIAL_ENONE = 0;
/** General error / Unknown error. */
static const int ISERIAL_EGENERAL = -1;
/** Create error. */
static const int ISERIAL_ECREATE = -2;
/** Open error. */
static const int ISERIAL_EOPEN = -3;
/** Close error. */
static const int ISERIAL_ECLOSE = -4;
/** Device or resource busy. */
static const int ISERIAL_EBUSY = -5;
/** Timeout expired. */
static const int ISERIAL_ETIMEOUT = -6;
/** Unsupported method or operation. */
static const int ISERIAL_ENOSUPPORTED = -7;
/** Memory allocation error. */
static const int ISERIAL_EMEMORY = -8;
/** Invalid parameter. */
static const int ISERIAL_EPARAM = -9;
/** Input/Output error. */
static const int ISERIAL_EIO = -10;
/** CRC error. */
static const int ISERIAL_ECRC = -11;
/** Flash error. */
static const int ISERIAL_EFLASH = -12;
/** EEPROM error. */
static const int ISERIAL_EEEPROM = -13;
/** Device error. */
static const int ISERIAL_EDEVICE = -14;
/** The operation is not implemented. */
static const int ISERIAL_ENOIMPLEMENTED = -15;
/** The device or resource does not exists. */
static const int ISERIAL_ENOEXIST = -16;
/** Invalid command. */
static const int ISERIAL_EINVALID_CMD = -17;
/** Not exist object. */
static const int ISERIAL_ENOT_EXIST_OBJECT = -18;
/** No more items. */
static const int ISERIAL_ENOMORE = -19;
/** Command Failed */
static const int ISERIAL_EFAILED = -20;
/** Invalid parameter */
static const int ISERIAL_EINVALID = -21;

/**
 Provides access to iSerial accessory functionality.
 */
@interface iSerial : NSObject

/**
 Sets serial settings. You can call this function before iSerial is connected, in this case, the settings will be stored and will be used upon new connection.
 @param baudRate serial baud rate
 @param parity serial parity, one of the PARITY_* constants
 @param dataBits serial data bits, one of the DATABITS_* constants
 @param stopBits serial stop bits, one of the STOPBITS_* constants
 @param flowControl serial flow control, one of the FLOW_* constants
 @param error returns error information, you can pass nil if you don't want it
 @return TRUE upon success, FALSE otherwise
 **/

-(BOOL)serialSetSettingsBaud:(int)baudRate parity:(int)parity dataBits:(int)dataBits stopBits:(int)stopBits flowControl:(int)flowControl error:(NSError **)error;
/**
 Opens serial connection to the remote device, notification will be posted on the streams when they are opened
 @param error returns error information, you can pass nil if you don't want it
 @return TRUE upon success, FALSE otherwise
 **/

-(BOOL)serialConnect:(NSError **)error;

/**
 Connect to a bluetooth devie, given it's address
 @param address bluetooth device address, as returned by the discovery
 @param pin connection pin, or nil to try insecure connection to the device
 @param error returns error information, you can pass nil if you don't want it
 @return TRUE upon success, FALSE otherwise
 **/
-(BOOL)btConnect:(NSString *)address pin:(NSString *)pin error:(NSError **)error;

/**
 Disconnects from a bluetooth device. Currently, this function disables and enables the bluetooth module, for the lack of better
 means to do it, so if you want to drop the connection and shut down the module, just disable it instead of disconnecting first.
 **/
-(void)btDisconnect;

/**
 Enables/disables the bluetooth module
 @param enabled if TRUE, bluetooth module is turned on, FALSE turns it off
 @param error returns error information, you can pass nil if you don't want it
 @return TRUE upon success, FALSE otherwise
 **/
-(BOOL)btSetEnabled:(BOOL)enabled error:(NSError **)error;

/**
 Initiates background bluetooth device discovery, the module have to be enabled first. Events will be posted to indicate discovered
 devices and the status of the discovery process.
 @param maxDevices the maximum number of devices to discover, the parameter is adjusted to match the attached bluetooth module
 @param maxTime the maximum time for the discovery process, the parameter is adjusted to match the attached bluetooth module
 @param codTypes Class Of Device to look for or 0 for all devices
 @param error returns error information, you can pass nil if you don't want it
 @return TRUE upon success, FALSE otherwise
 **/
-(BOOL)btDiscoverDevicesInBackground:(int)maxDevices maxTime:(double)maxTime codTypes:(int)codTypes error:(NSError **)error;

/**
 When iSerial is connected, this property indicates if serial communication is supported
 **/
@property(readonly) BOOL serialSupported;

/**
 When iSerial is connected, this property indicates if bluetooth communication is supported
 **/
@property(readonly) BOOL bluetoothSupported;

/**
 Adds delegate to the class
 **/
@property(assign) id delegate;

/**
 Returns current connection state with the iSerial
 **/
@property(readonly) BOOL connected;

/**
 Returns iSerial device name
 **/
@property(readonly) NSString *deviceName;
/**
 Returns iSerial device model
 **/
@property(readonly) NSString *deviceModel;
/**
 Returns iSerial firmware version
 **/
@property(readonly) NSString *firmwareRevision;
/**
 Returns iSerial hardware version
 **/
@property(readonly) NSString *hardwareRevision;
/**
 Returns iSerial serial number
 **/
@property(readonly) NSString *serialNumber;

/**
 Input stream, in case of serial connection, you can use it directly, in case of bluetooth - you can use it after connecting with btConnect.
 See NSInputStream documentation.
 **/
@property(readonly) NSInputStream *inputStream;

/**
 Output stream, in case of serial connection, you can use it directly, in case of bluetooth - you can use it after connecting with btConnect.
 See NSOutputStream documentation.
 **/
@property(readonly) NSOutputStream *outputStream;

/**
 SDK version number in format MAJOR*100+MINOR, i.e. version 1.15 will be returned as 115
 */
@property(readonly) int sdkVersion;


@end

/**@}*/
