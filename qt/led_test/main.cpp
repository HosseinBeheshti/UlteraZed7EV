#include "mainwindow.h"
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>


#include <QApplication>

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    MainWindow w;
    w.show();
    return a.exec();

    int valuefd, exportfd, directionfd;

    printf("GPIO test running...\n");

    // The GPIO has to be exported to be able to see it
    // in sysfs

    exportfd = open("/sys/class/gpio/export", O_WRONLY);
    if (exportfd < 0)
    {
        printf("Cannot open GPIO to export it\n");
        exit(1);
    }

    write(exportfd, "496", 8);
    close(exportfd);

    printf("GPIO exported successfully\n");

    // Update the direction of the GPIO to be an output

    directionfd = open("/sys/class/gpio/gpio496/direction", O_RDWR);
    if (directionfd < 0)
    {
        printf("Cannot open GPIO direction it\n");
        exit(1);
    }

    write(directionfd, "out", 8);
    close(directionfd);

    printf("GPIO direction set as output successfully\n");

    // Get the GPIO value ready to be toggled

    valuefd = open("/sys/class/gpio/gpio496/value", O_RDWR);
    if (valuefd < 0)
    {
        printf("Cannot open GPIO value\n");
        exit(1);
    }

    printf("GPIO value opened, now toggling...\n");

    // toggle the GPIO as fast a possible forever, a control c is needed
    // to stop it

    while (1)
    {
        write(valuefd,"1", 2);
        write(valuefd,"0", 2);
    }
}
