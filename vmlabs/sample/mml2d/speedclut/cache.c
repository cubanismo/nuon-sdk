// first nybble:  (number of ways - 1)
// second nybble: way size: 0 = 1K, 1 = 2K, 2 = 4K
// third nybble:  line size: 0 = 16, 1 = 32, 2 = 64, 3 = 128
//
#if 0
// these are the settings for 4K direct mapped caches
int __icachectl __attribute__ ((section ("dtram"))) = 0x021;
int __dcachectl __attribute__ ((section ("dtram"))) = 0x021;
//#else
// these are the settings for 3K three-way caches
int __icachectl __attribute__ ((section ("dtram"))) = 0x201;
int __dcachectl __attribute__ ((section ("dtram"))) = 0x201;
#endif

// these are settings for DVD player, 1way 1K of cache.
int __icachectl __attribute__ ((section ("dtram"))) = 0x01;
int __dcachectl __attribute__ ((section ("dtram"))) = 0x01;
