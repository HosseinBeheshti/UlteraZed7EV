#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QQuickWidget>
#include <QWebView>
#include <QDebug>

#include <iostream>
#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <string.h> // Strlen function

#include <fcntl.h>     // Flags for open()
#include <sys/stat.h>  // Open() system call
#include <sys/types.h> // Types for open()
#include <sys/mman.h>  // Mmap system call
#include <sys/ioctl.h> // IOCTL system call
#include <unistd.h>    // Close() system call
#include <sys/time.h>  // Timing functions and definitions
#include <getopt.h>    // Option parsing
#include <errno.h>     // Error codes

#include "AXIDMA/libaxidma.h"  // Interface to the AXI DMA
#include "AXIDMA/util.h"       // Miscellaneous utilities
#include "AXIDMA/conversion.h" // Miscellaneous conversion utilities
#include "AXIDMA/axidma_benchmark.h"

QT_BEGIN_NAMESPACE
namespace Ui
{
    class MainWindow;
}
QT_END_NAMESPACE

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    MainWindow(QWidget *parent = nullptr);
    ~MainWindow();

private slots:
    void on_initDMA_clicked();

    void on_TestTXRX_clicked();

private:
    Ui::MainWindow *ui;
    int rc;
    int tx_channel, rx_channel;
    int num_transfers = 10;
    size_t tx_size, rx_size;
    char *tx_buf, *rx_buf;
    axidma_dev_t axidma_dev;
    const array_t *tx_chans, *rx_chans;
    QString LastLogQstring;
};
#endif // MAINWINDOW_H
