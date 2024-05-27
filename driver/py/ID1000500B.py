import logging
import time
from ipdi.ip.pyaip import pyaip, pyaip_init

# IP Convolution driver class
class ID1000500B:
    def __init__(self, connector, nic_addr, port, csv_file):
        self.__pyaip = pyaip_init(connector, nic_addr, port, csv_file)

        if self.__pyaip is None:
            logging.debug("Error creating CAIP object")

        self.data_RX = []
        self.__pyaip.reset()
        self.IPID = 0
        self.__get_ID()
        self.__clear_status()

        logging.debug(f"IP Dummy controller created with IP ID {self.IPID:08x}")

    def __write_data(self, data_Y):
        self.size_data_Y = len(data_Y)
        self.__pyaip.write_mem('MEMORY_Y', data_Y, len(data_Y), 0)
        logging.debug("Data captured in Mem Data In")

    def read_data(self, size):
        data_Z = self.__pyaip.read_mem('MEMORY_Z', size, 0)
        logging.debug("Data obtained from Mem Data Out")
        return data_Z

    def start_IP(self):
        self.__pyaip.start()
        logging.debug("Start sent")

    def SizeY_config(self, size_Y_config):
        self.size_Y = size_Y_config
        self.__pyaip.write_conf_reg('CONFIG_REGISTER', [size_Y_config], 1, 0)
        logging.debug(f"Size Y set to {size_Y_config} ")

    def enable_INT(self):
        self.__pyaip.enable_INT(0, None)
        logging.debug("Int enabled")

    def disable_INT(self):
        self.__pyaip.disable_INT(0)
        logging.debug("Int disabled")

    def status(self):
        status = self.__pyaip.get_status()
        logging.info(f"Status: {status:08x}")

    def finish(self):
        self.__pyaip.finish()

    def wait_int(self):
        waiting = True
        while waiting:
            status = self.__pyaip.get_status()
            logging.debug(f"Status: {status:08x}")
            if status & 0x1:
                waiting = False
            time.sleep(0.1)

        self.__pyaip.clear_INT(0)

    def __get_ID(self):
        self.IPID = self.__pyaip.get_ID()

    def __clear_status(self):
        for i in range(8):
            self.__pyaip.clear_INT(i)
            
    def conv(self, Y):
        if not Y or len(Y) > 32:
            logging.info("Input data is empty or greater than 32")
            return

        size_Y = len(Y)
        self.SizeY_config(size_Y)
        self.__write_data(Y)
        self.start_IP()
        self.wait_int()
        convolution_size = 10 + len(Y) - 1
        data_Z = self.read_data(convolution_size)
        return data_Z


if __name__ == "__main__":
    import sys

    logging.basicConfig(level=logging.INFO)
    connector = '/dev/ttyACM0'
    csv_file = '/home/anette/intelFPGA_lite/22.1std/quartus/HDL/ID1000500B/ID1000500B_config.csv'
    addr = 1
    port = 0

    data_Y = [0x00000001, 0x0000000B, 0x00000004, 0x000000FE, 0x000000FF]
    data_x = [0x0000FFFF, 0x0000FFF7, 0x00000017, 0x00000044, 0x0000003C, 
              0x0000006C, 0x00000006, 0x0000FFE2, 0x0000007A, 0x00000035, 
              0x0000FFF4, 0x0000FFF8, 0x0000FFFE, 0x0000FFFF]

    try:
        ipm = ID1000500B(connector, addr, port, csv_file)
        logging.info("Test Convolution: Driver created")
    except:
        logging.error("Test Convolution: Driver not created")
        sys.exit()

    ipm.disable_INT()

    data_Z = ipm.conv(data_Y)
    print(f'data_Z Data: {[f"{x:08X}" for x in data_Z]}\n')

    for x, y in zip(data_x, data_Z):
        logging.info(f"TX: {x:08x} | RX: {y:08x} | {'TRUE' if x == y else 'FALSE'}")

    ipm.status()
    ipm.finish()

    logging.info("The End")
