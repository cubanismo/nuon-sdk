/*
 * A small test for some floating point math that produced incorrect results
 * with the libgcc.a shipped by VM Labs, as well as a C transcription of the
 * problematic algorithm (broken part commented out, replaced by fixed logic
 * implemented in _mulsf3.s). Used both for debugging the original issue, and
 * to test the fix.
 *
 * Type "make" to build the Nuon version for testing in Nuance, where the
 * kprintf command will log to the status window and a file if so configured.
 *
 * Build the C transcription version for local debugging/testing with:
 *
 * $ gcc float-test.c -o float-test
 *
 */
#ifndef C_VERSION
#define C_VERSION 1
#endif

#if C_VERSION

#include <stdio.h>
#include <stdint.h>
#define kprintf(...) printf(__VA_ARGS__)
#define LOGF(...) printf(__VA_ARGS__)
//#define LOGF(...)

static float mulsf3(float a, float b)
{
    uint32_t uA = *(const uint32_t *)&a;
    uint32_t uB = *(const uint32_t *)&b;

    if ((uA == 0) || (uB == 0)) {
        return 0.f;
    }

    uint32_t signRes = (uA & 0x80000000U) ^ (uB & 0x80000000U);
    uint64_t mantissaA = (uA & 0x007fffffU) | 0x00800000U;
    uint64_t mantissaB = (uB & 0x007fffffU) | 0x00800000U;
    LOGF("mantissaA: 0x%08x, mantissaB: 0x%08x\n", mantissaA, mantissaB);

    uint32_t expA = (uA >> 23) & 0xffU;
    uint32_t expB = (uB >> 23) & 0xffU;
    LOGF("expA: 0x%08x, expB: 0x%08x\n", expA, expB);

    uint32_t expSum = (expA - 126) + expB;
    LOGF("expSum: 0x%08x\n", expSum);
    uint64_t mantissaProd = (mantissaA * mantissaB) >> 16ULL;
    LOGF("mantissaProd: 0x%08llx\n", mantissaProd);
    uint32_t resU;

    if (mantissaProd & 0x80000000ULL) {
//    if ((mantissaProd + 0x40ULL) & 0x80000000ULL) {
        LOGF("Took top path\n");
        mantissaProd += 0x80ULL;
        mantissaProd >>= 8ULL;
    } else {
        LOGF("Took bottom path\n");
        mantissaProd += 0x40ULL;
        mantissaProd >>= 7ULL;
        --expSum;
    }

    resU = ((uint32_t)(mantissaProd & ~0x00800000ULL)) | (expSum << 23U) | signRes;

    return *(const float *)&resU;
}

#else
extern void kprintf(const char *fmt, ...);
static float calcVal(float a, float b)
{
    return a * b;
}
#endif

int main(void)
{
    float a = 50.f;
    float b = 0.08f;
    float c = 0.04f;
    float d = 0.16f;

    kprintf("%f * %f = %f\n", a, b, calcVal(a, b));
    kprintf("%f * %f = %f\n", a, c, calcVal(a, c));
    kprintf("%f * %f = %f\n", a, d, calcVal(a, d));

    a = 50.0001f;

    kprintf("%f * %f = %f\n", a, b, calcVal(a, b));
    kprintf("%f * %f = %f\n", a, c, calcVal(a, c));
    kprintf("%f * %f = %f\n", a, d, calcVal(a, d));

    a = 100.f;

    kprintf("%f * %f = %f\n", a, b, calcVal(a, b));
    kprintf("%f * %f = %f\n", a, c, calcVal(a, c));
    kprintf("%f * %f = %f\n", a, d, calcVal(a, d));

    a = 100.0001f;

    kprintf("%f * %f = %f\n", a, b, calcVal(a, b));
    kprintf("%f * %f = %f\n", a, c, calcVal(a, c));
    kprintf("%f * %f = %f\n", a, d, calcVal(a, d));

    a = 5.0f;

    kprintf("%f * %f = %f\n", a, b, calcVal(a, b));
    kprintf("%f * %f = %f\n", a, c, calcVal(a, c));
    kprintf("%f * %f = %f\n", a, d, calcVal(a, d));

    return 0;
}

