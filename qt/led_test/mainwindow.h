#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include "gpio_cntrl.h"

QT_BEGIN_NAMESPACE
namespace Ui { class MainWindow; }
QT_END_NAMESPACE

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    MainWindow(QWidget *parent = nullptr);
    ~MainWindow();
    gpio_cntrl ZynqLedGPIO;

private slots:
    void on_LEDStartTestButton_clicked();
    void blink_LED(int blinkDelay);

private:
    Ui::MainWindow *ui;
};
#endif // MAINWINDOW_H
