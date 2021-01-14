#include "mainwindow.h"
#include "ui_mainwindow.h"

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
{
    ui->setupUi(this);
    ui->inputLEDSequence->setInputMask("FF");
}

MainWindow::~MainWindow()
{
    delete ui;
}


void MainWindow::on_LEDTestButton_clicked()
{

}
