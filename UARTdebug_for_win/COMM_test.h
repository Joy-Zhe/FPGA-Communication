//
// Created by Joy Zheng on 2023/12/2.
//

#ifndef UARTDEBUG_FOR_WIN_COMM_TEST_H
#define UARTDEBUG_FOR_WIN_COMM_TEST_H

#include <windows.h>
#include <iostream>
#include <string>
#include <tchar.h>
#include <chrono>

class COMM_test {
public:
    COMM_test() {
        OpenSerialPort();
    }
    explicit COMM_test(char *portName) {
        OpenSerialPort(portName);
    }
    explicit COMM_test(char *portName, DWORD BR) {
        baudRate = BR;
        OpenSerialPort(portName);
    }
    explicit COMM_test(DWORD BR) {
        baudRate = BR;
        OpenSerialPort();
    }
    ~COMM_test() {
        CloseSerialPort();
    }
    void SpeedTest(const int &n);
    void CheckRW(const int &n);
private:
    HANDLE hSerial{};
    DWORD baudRate = CBR_115200;
    DWORD byteSize = 8;
    DWORD stopBits = ONESTOPBIT;
    DWORD parity = NOPARITY;

    void OpenSerialPort(const char *portName = "COM4");
    void ReadFromSerialPort(const int &dataNum);
    void WriteToSerialPort(const int &dataNum);
    void CloseSerialPort();
};

void COMM_test::OpenSerialPort(const char *portName) {
    hSerial = CreateFile(
            _T(portName),
            GENERIC_READ | GENERIC_WRITE,
            0,
            nullptr,
            OPEN_EXISTING,
            FILE_ATTRIBUTE_NORMAL,
            nullptr
    );

    DCB dcbSerialParams = { 0 };
    dcbSerialParams.DCBlength = sizeof(dcbSerialParams);

    if (!GetCommState(hSerial, &dcbSerialParams)) {
        std::cerr << "Error getting serial port state" << std::endl;
        CloseHandle(hSerial);
        return;
    }

    dcbSerialParams.BaudRate = baudRate; // BaudRate
    dcbSerialParams.ByteSize = byteSize;       // DataBits
    dcbSerialParams.StopBits = stopBits; // StopBits
    dcbSerialParams.Parity = parity; // Parity

    if (!SetCommState(hSerial, &dcbSerialParams)) {
        std::cerr << "Error setting serial port state" << std::endl;
        CloseHandle(hSerial);
        return;
    }
    SetupComm(hSerial, 1024, 1024);
    COMMTIMEOUTS timeouts = { 0 };
    timeouts.ReadIntervalTimeout = 100;
    timeouts.ReadTotalTimeoutConstant = 500;
    timeouts.ReadTotalTimeoutMultiplier = 100;
    timeouts.WriteTotalTimeoutConstant = 500;
    timeouts.WriteTotalTimeoutMultiplier = 100;
    SetCommTimeouts(hSerial, &timeouts);
}

void COMM_test::ReadFromSerialPort(const int &dataNum) {
    DWORD bytesRead = 0;
    char *buffer = new char[dataNum + 1];

    if (ReadFile(hSerial, buffer, dataNum + 1, &bytesRead, nullptr)) {
        std::cout << "Received: " << buffer << std::endl;
//        std::cout << "Received: " << bytesRead << std::endl;
        delete [] buffer;
    } else {
        std::cerr << "Error reading from serial port" << std::endl;
    }
}

void COMM_test::WriteToSerialPort(const int &dataNum) {
    DWORD bytesSend = 0;

    char *data = new char[dataNum + 1];

    for(int i = 0; i < dataNum; i++) {
        data[i] = 'a';
    }
    data[dataNum] = '\0';

    if (WriteFile(hSerial, data, dataNum + 1, &bytesSend, nullptr)) {
        std::cout << "Send: " << data << std::endl;
//        std::cout << "Send: " << bytesSend << std::endl;
        delete[] data;
    }
    else {
        delete[] data;
        std::cerr << "Error writing to serial port" << std::endl;
    }
}

void COMM_test::CloseSerialPort() {
    CloseHandle(hSerial);
}

void COMM_test::SpeedTest(const int &n) {
    int dataNum = n * 2; // uint16 = 2 bytes
//    OpenSerialPort();

    auto start = std::chrono::high_resolution_clock::now();
    for (int i = 0; i < dataNum; ++i) {
        WriteToSerialPort(1);
        ReadFromSerialPort(1);
        Sleep(1000);
    }
    auto end = std::chrono::high_resolution_clock::now();
    std::cout << "Time to Write and Read "
              << n
              << " uint16 data: "
              << std::chrono::duration_cast<std::chrono::milliseconds>(end - start).count()
              << "ms"
              << "("
              << std::chrono::duration_cast<std::chrono::microseconds>(end - start).count()
              << " us)"
              << std::endl;
//    CloseSerialPort();
}

void COMM_test::CheckRW(const int &n) {

}

#endif //UARTDEBUG_FOR_WIN_COMM_TEST_H
