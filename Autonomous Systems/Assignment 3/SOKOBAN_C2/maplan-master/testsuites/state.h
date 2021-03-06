#ifndef TEST_STATE_H
#define TEST_STATE_H

TEST(testStateBasic);
TEST(testStatePreEff);
TEST(testPartStateUnset);
TEST(testPackerPubPart);
TEST(protobufTearDown);

TEST_SUITE(TSState) {
    TEST_ADD(testStateBasic),
    TEST_ADD(testStatePreEff),
    TEST_ADD(testPartStateUnset),
    TEST_ADD(testPackerPubPart),
    TEST_ADD(protobufTearDown),
    TEST_SUITE_CLOSURE
};

#endif /* TEST_STATE_H */
