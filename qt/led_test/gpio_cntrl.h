#ifndef GPIO_CNTRL_H
#define GPIO_CNTRL_H

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <iostream>
#include <string>
using namespace std;
#include <unistd.h>


class gpio_cntrl
{
public:
    gpio_cntrl();
    int blink_operation(int blinkDelay);
};

#endif // GPIO_CNTRL_H
