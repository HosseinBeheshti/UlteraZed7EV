#include "mainwindow.h"
#include "ui_mainwindow.h"

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent), ui(new Ui::MainWindow)
{
    ui->setupUi(this);

}

MainWindow::~MainWindow()
{
    delete ui;
}

void MainWindow::on_LEDStartTestButton_clicked()
{
    int blinkDelay = ui->inputBlinkDelay->text().toInt();
    blink_LED(blinkDelay);
}

void MainWindow::blink_LED(int blinkDelay)
{
    ZynqLedGPIO;
    ZynqLedGPIO.blink_operation(blinkDelay*1000);
}
