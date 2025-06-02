// HexPosition.cpp
#include "HexPosition.h"

HexPosition::HexPosition(int r, int c, QObject *parent)
    : QObject(parent), m_row(r), m_col(c) {}