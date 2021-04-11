#include "mainwindow.h"
#include "ui_mainwindow.h"

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent), ui(new Ui::MainWindow)
{
    ui->setupUi(this);

    // initalize log console
    ui->logConsole->setText("GPS Emulator");
    ui->logConsole->setReadOnly(true);
    ui->TestTXRX->setEnabled(false);
    ui->logConsole->append("Press Init DMA to initalize PL DMA");
}

MainWindow::~MainWindow()
{
    delete ui;
}

void MainWindow::on_initDMA_clicked()
{
    int tx_size_init = 10;
    int rx_size_init = 10;
    tx_channel = 0;
    rx_channel = 1;
    tx_size = MIB_TO_BYTE(tx_size_init);
    rx_size = MIB_TO_BYTE(rx_size_init);

    LastLogQstring = "AXI DMA Parameters:";
    ui->logConsole->append(LastLogQstring);
    std::cout << LastLogQstring.toStdString() << std::endl;
    LastLogQstring = "Transmit Buffer Size:" + QString::number(BYTE_TO_MIB(tx_size)) + " MiB";
    ui->logConsole->append(LastLogQstring);
    std::cout << LastLogQstring.toStdString() << std::endl;
    ;
    LastLogQstring = "Receive Buffer Size:" + QString::number(BYTE_TO_MIB(rx_size)) + " MiB";
    ui->logConsole->append(LastLogQstring);
    std::cout << LastLogQstring.toStdString() << std::endl;
    ;

    // Initialize the AXI DMA device
    axidma_dev = axidma_init();
    if (axidma_dev == NULL)
    {
        LastLogQstring = "Failed to initialize the AXI DMA device.";
        ui->logConsole->append(LastLogQstring);
        std::cout << LastLogQstring.toStdString() << std::endl;
        rc = 1;
    }

    // Map memory regions for the transmit and receive buffers
    tx_buf = static_cast<char *>(axidma_malloc(axidma_dev, tx_size));
    if (tx_buf == NULL)
    {
        LastLogQstring = "Unable to allocate transmit buffer from the AXI DMA device.";
        ui->logConsole->append(LastLogQstring);
        std::cout << LastLogQstring.toStdString() << std::endl;
        rc = -1;
        axidma_destroy(axidma_dev);
    }
    rx_buf = static_cast<char *>(axidma_malloc(axidma_dev, rx_size));
    if (rx_buf == NULL)
    {
        LastLogQstring = "Unable to allocate receive buffer from the AXI DMA device";
        ui->logConsole->append(LastLogQstring);
        std::cout << LastLogQstring.toStdString() << std::endl;
        rc = -1;
        axidma_free(axidma_dev, tx_buf, tx_size);
        axidma_destroy(axidma_dev);
    }

    // Get all the transmit and receive channels
    tx_chans = axidma_get_dma_tx(axidma_dev);
    rx_chans = axidma_get_dma_rx(axidma_dev);

    if (tx_chans->len < 1)
    {
        LastLogQstring = "Error: No transmit channels were found.";
        ui->logConsole->append(LastLogQstring);
        std::cout << LastLogQstring.toStdString() << std::endl;
        rc = -ENODEV;
        axidma_free(axidma_dev, rx_buf, rx_size);
        axidma_free(axidma_dev, tx_buf, tx_size);
        axidma_destroy(axidma_dev);
    }
    if (rx_chans->len < 1)
    {
        LastLogQstring = "Error: No receive channels were found.";
        ui->logConsole->append(LastLogQstring);
        std::cout << LastLogQstring.toStdString() << std::endl;
        rc = -ENODEV;
        axidma_free(axidma_dev, rx_buf, rx_size);
        axidma_free(axidma_dev, tx_buf, tx_size);
        axidma_destroy(axidma_dev);
    }

    /* If the user didn't specify the channels, we assume that the transmit and
     * receive channels are the lowest numbered ones. */
    if (tx_channel == -1 && rx_channel == -1)
    {
        tx_channel = tx_chans->data[0];
        rx_channel = rx_chans->data[0];
    }
    LastLogQstring = "Using transmit channel " + QString::number(tx_channel) + " and receive channel " + QString::number(rx_channel);
    ui->logConsole->append(LastLogQstring);
    std::cout << LastLogQstring.toStdString() << std::endl;
    ui->initDMA->setEnabled(false);
    ui->TestTXRX->setEnabled(true);
}

void MainWindow::on_TestTXRX_clicked()
{
    int rc;
    struct axidma_video_frame *tx_frame, *rx_frame;
    // Initialize the buffer region we're going to transmit
    init_data(tx_buf, rx_buf, tx_size,rx_size);
    // Perform the DMA transaction
    rc = axidma_twoway_transfer(axidma_dev, tx_channel, tx_buf, tx_size, tx_frame,
                                rx_channel, rx_buf, rx_size, rx_frame, true);
    if (rc < 0)
    {
        LastLogQstring = "Single transfer test failed";
        ui->logConsole->append(LastLogQstring);
        std::cout << LastLogQstring.toStdString() << std::endl;
    }
    // Verify that the data in the buffer changed
    rc = verify_data(tx_buf, rx_buf, (size_t)tx_size, (size_t)rx_size);
    LastLogQstring = "DMA Single transfer test successfully completed";
    ui->logConsole->append(LastLogQstring);
    std::cout << LastLogQstring.toStdString() << std::endl;
}
