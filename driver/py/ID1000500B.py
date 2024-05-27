import logging, time
from ipdi.ip.pyaip import pyaip, pyaip_init

# IP Convolution driver class
class conv_core:
    # Class constructor of IP Convolution driver
    def __init__(self, connector, nic_addr, port, csv_file):
        #object
        self.__pyaip = pyaip_init(connector, nic_addr, port, csv_file)

        if self.__pyaip is None:
            logging.debug("error")

        # Array of strings with information read
        self.dataRX = []

        self.__pyaip.reset()

        # IP Core IP-ID
        self.IPID = 0

        self.__getID()

        self.__clearStatus()

        logging.debug(f"IP Dummy controller created with IP ID {self.IPID:08x}")

    def conv(self, Y):
        if len(Y) == 0 or len(Y) > 32:
            logging.info("Input data is empty or is greater than 32")

        sizeY = len(Y)
        # hex_y = f"{sizeY:08x}"
        self.SizeY_config(sizeY)

        self.__writeData(Y)

        self.startIP()

        self.waitInt()

        conv_size = 10 + len(Y) - 1
        data_z = self.readData(conv_size)

        return data_z

    # Write data in the IP Core input memory
    def __writeData(self, data_Y):
        self.sizeDataY = len(data_Y)
        self.__pyaip.writeMem('MEMORY_Y', data_Y, len(data_Y), 0)
        logging.debug("Data captured in Mem Data In")

    # Read data from the IP Core output memory
    def readData(self,size):
        dataZ = self.__pyaip.readMem('MEMORY_Z', size, 0)
        logging.debug("Data obtained from Mem Data Out")
        return dataZ

    # Start processing in IP Core
    def startIP(self):
        self.__pyaip.start()
        logging.debug("Start sent")

    # Set and enable sizeY
    def SizeY_config(self, size_Y_config):
        self.sizeY = size_Y_config
        self.__pyaip.writeConfReg('CONFIG_REGISTER', [size_Y_config], 1, 0)
        logging.debug(f"Size Y setted to {size_Y_config} ")

    # Enable IP Core interruptions
    def enableINT(self):
        self.__pyaip.enableINT(0, None)
        logging.debug("Int enabled")

    # Disable IP Core interruptions
    def disableINT(self):
        self.__pyaip.disableINT(0)

        logging.debug("Int disabled")

    # Show IP Core status
    def status(self):
        STATUS = self.__pyaip.getStatus()
        logging.info(f"{STATUS:08x}")

    # Finish connection
    def finish(self):
        self.__pyaip.finish()

    # Wait for the completion of the process
    def waitInt(self):
        waiting = True

        while waiting:

            status = self.__pyaip.getStatus()

            logging.debug(f"status {status:08x}")

            if status & 0x1:
                waiting = False

            time.sleep(0.1)

    # Get IP ID
    def __getID(self):
        self.IPID = self.__pyaip.getID()

    # Clear status register of IP Dummy
    def __clearStatus(self):
        for i in range(8):
            self.__pyaip.clearINT(i)


if __name__ == "__main__":
    import sys, random, time, os

    logging.basicConfig(level=logging.INFO)
    connector = '/dev/ttyACM0'
    csv_file = '/home/anette/intelFPGA_lite/22.1std/quartus/HDL/ID1000500B/ID1000500B_config.csv'
    addr = 1
    port = 0

    data_Y = [0x00000001, 0x0000000B, 0x00000004, 0x000000FE, 0x000000FF]
    modeloOro = [0x0000FFFF, 0x0000FFF7, 0x00000017, 0x00000044, 0x0000003C, 0x0000006C, 0x00000006, 0x0000FFE2,
                 0x0000007A, 0x00000035, 0x0000FFF4, 0x0000FFF8, 0x0000FFFE, 0x0000FFFF]

    try:
        ipm = conv_core(connector, addr, port, csv_file)
        logging.info("Test Convolution: Driver created")
    except:
        logging.error("Test Convolution: Driver not created")
        sys.exit()

    ipm.disableINT()

    dataZ = ipm.conv(data_Y)
    print(f'data_Z Data: {[f"{x:08X}" for x in dataZ]}\n')

    for x, y in zip(modeloOro, dataZ):
        logging.info(f"TX: {x:08x} | RX: {y:08x} | {'TRUE' if x == y else 'FALSE'}")

    ipm.status()

    ipm.finish()

    logging.info("The End")
