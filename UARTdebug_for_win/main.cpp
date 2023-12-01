#include <iostream>
#include <iomanip>
#include "COMM_test.h"

int ShowBaudRateList();
DWORD chooseBaudRate(const int &baudRateNum);

int main () {
    int baudRateNum = ShowBaudRateList();
    DWORD baudRate = chooseBaudRate(baudRateNum);

    std::cout << "INPUT(Num of uint16 data):";
    int n;
    std::cin >> n;
    COMM_test comm_test("COM4", baudRate);
//    COMM_test comm_test;
    comm_test.SpeedTest(n);

    return 0;
}

int ShowBaudRateList() {
    int baudRateNum;

    std::cout << std::setw(4) << "No." << std::setw(12) << "Baud Rate" << std::endl;
    std::cout << "----------------" << std::endl;

    std::cout << std::setw(4) << 1 << "|" << std::setw(12) << CBR_110 << std::endl;
    std::cout << std::setw(4) << 2 << "|" << std::setw(12) << CBR_300 << std::endl;
    std::cout << std::setw(4) << 3 << "|" << std::setw(12) << CBR_600 << std::endl;
    std::cout << std::setw(4) << 4 << "|" << std::setw(12) << CBR_1200 << std::endl;
    std::cout << std::setw(4) << 5 << "|" << std::setw(12) << CBR_2400 << std::endl;
    std::cout << std::setw(4) << 6 << "|" << std::setw(12) << CBR_4800 << std::endl;
    std::cout << std::setw(4) << 7 << "|" << std::setw(12) << CBR_9600 << std::endl;
    std::cout << std::setw(4) << 8 << "|" << std::setw(12) << CBR_14400 << std::endl;
    std::cout << std::setw(4) << 9 << "|" << std::setw(12) << CBR_19200 << std::endl;
    std::cout << std::setw(4) << 10 << "|" << std::setw(12) << CBR_38400 << std::endl;
    std::cout << std::setw(4) << 11 << "|" << std::setw(12) << CBR_56000 << std::endl;
    std::cout << std::setw(4) << 12 << "|" << std::setw(12) << CBR_57600 << std::endl;
    std::cout << std::setw(4) << 13 << "|" << std::setw(12) << CBR_115200 << std::endl;
    std::cout << std::setw(4) << 14 << "|" << std::setw(12) << CBR_128000 << std::endl;
    std::cout << std::setw(4) << 15 << "|" << std::setw(12) << CBR_256000 << std::endl;

    std::cout << "----------------" << std::endl;
    std::cout << "INPUT(Baud Rate No. 1-15):";
    std::cin >> baudRateNum;
    return baudRateNum;
}

DWORD chooseBaudRate(const int &baudRateNum) {
    DWORD baudRate = CBR_115200;
    switch (baudRateNum) {
        case 1:
            baudRate = CBR_110;
            break;
        case 2:
            baudRate = CBR_300;
            break;
        case 3:
            baudRate = CBR_600;
            break;
        case 4:
            baudRate = CBR_1200;
            break;
        case 5:
            baudRate = CBR_2400;
            break;
        case 6:
            baudRate = CBR_4800;
            break;
        case 7:
            baudRate = CBR_9600;
            break;
        case 8:
            baudRate = CBR_14400;
            break;
        case 9:
            baudRate = CBR_19200;
            break;
        case 10:
            baudRate = CBR_38400;
            break;
        case 11:
            baudRate = CBR_56000;
            break;
        case 12:
            baudRate = CBR_57600;
            break;
        case 13:
            baudRate = CBR_115200;
            break;
        case 14:
            baudRate = CBR_128000;
            break;
        case 15:
            baudRate = CBR_256000;
            break;
        default:
            baudRate = CBR_115200;
            break;
    }
    return baudRate;
}
