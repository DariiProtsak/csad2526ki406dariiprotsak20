#include <gtest/gtest.h>
#include <climits>
#include "math_operations.h"

TEST(AdditionBasic, PositiveNumbers) {
    EXPECT_EQ(add(1, 2), 3);
    EXPECT_EQ(add(1000, 234), 1234);
}

TEST(AdditionBasic, ZeroAndMixed) {
    EXPECT_EQ(add(0, 0), 0);
    EXPECT_EQ(add(-1, 1), 0);
    EXPECT_EQ(add(5, 0), 5);
}

TEST(AdditionNegative, BothNegative) {
    EXPECT_EQ(add(-5, -7), -12);
}

TEST(AdditionEdgeCases, IntLimits) {
    EXPECT_EQ(add(INT_MAX, 0), INT_MAX);
    EXPECT_EQ(add(INT_MIN, 0), INT_MIN);
}